//
//  WPCGroupChatVC.m
//  yuezhan123
//
//  Created by admin on 15/7/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCGroupChatVC.h"
#import "ZHInviteCell.h"
#import "NearByModel.h"
#import "ChatViewController.h"
@interface WPCGroupChatVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *mTableView;
@property (nonatomic, strong)NSMutableArray *selectedFriend;// 选中的好友的数组
@property (nonatomic, strong)UIButton *rightBtn;

@end

@implementation WPCGroupChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发起群聊天";
    [self navgationBarLeftReturn];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initialDatasource];
    [self.view addSubview:self.mTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
}

- (void)confirmAction {
    //群聊至少要俩名参与
    if (_selectedFriend.count<1) {
        [self showHint:@"至少选择1名好友"];
        return;
    }
    //创建群聊
    //初始成员为群名
    NSMutableArray *source = [NSMutableArray array];
     NSMutableString *groupName = [[NSMutableString alloc] initWithString:@""];
    for (NearByModel *buddy in _selectedFriend) {
        [groupName appendString:[LVTools mToString: buddy.nickName]];
        [groupName appendString:@","];
            [source addObject:[LVTools mToString: buddy.userId]];
    }

    NSLog(@"%@",source);
    EMGroupStyleSetting *setting = [[EMGroupStyleSetting alloc] init];
    setting.groupStyle = eGroupStyle_PrivateMemberCanInvite;
    //        setting.groupMaxUsersCount = 4;默认200
    //默认群组名不包括自己的昵称
    [groupName appendString:[kUserDefault objectForKey:kUserName]];
    NSLog(@"%@",groupName);
    NSString *messageStr = [NSString stringWithFormat:@"%@邀请您加入群组",[LVTools mToString:[kUserDefault objectForKey:kUserName]]];
    [self showHudInView:self.view hint:@"创建中..."];
    [[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:groupName description:[NSString stringWithFormat:@"%@的群聊",[LVTools mToString:[kUserDefault objectForKey:kUserName]]] invitees:source initialWelcomeMessage:messageStr styleSetting:setting completion:^(EMGroup *group, EMError *error) {
        [self hideHud];
        if (group && !error) {
            [self showHint:NSLocalizedString(@"group.create.success", @"create group success")];
            //跳转到聊天界面
            ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:group.groupId isGroup:YES WithIcon:@""];
            chatController.isTemporaryGroup = YES;
            chatController.title = group.groupSubject;
            [self.navigationController pushViewController:chatController animated:YES];
        }
        else{
            [self showHint:NSLocalizedString(@"group.create.fail", @"Failed to create a group, please operate again")];
        }
    } onQueue:nil];

}

- (void)initialDatasource {
    _dataArray = [NSMutableArray array];
    _selectedFriend = [NSMutableArray array];
    [self loadData];
}

- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mTableView;
}

- (void)loadData{
    //通过环信获取好友ID
    [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
            for (EMBuddy *buddy in buddyList) {
                if (buddy.followState != eEMBuddyFollowState_NotFollowed) {
                    [ids addObject:buddy.username];
                }
            }
            [self loadUsersInfoWithIds:ids];
        }
        else{
            [self showHint:error.description];
        }
    } onQueue:nil];
    
}
//    NSMutableDictionary * dic = [LVTools getTokenApp];
//    NSString * userLogin = [kUserDefault objectForKey:kUserLogin];
//    if (userLogin) {
//        NSString * userId = [kUserDefault objectForKey:kUserId];
//        [dic setValue:userId forKey:@"uid"];
//    }
//    [DataService requestWeixinAPI:getFriendList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
//        NSDictionary * resultDic = (NSDictionary *)result;
//        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
//        {
//            for (NSDictionary *dic in resultDic[@"friendList"])
//            {
//                NearByModel * model = [[NearByModel alloc] init];
//                [model setValuesForKeysWithDictionary:dic];
//                [_dataArray addObject:model];
//            }
//            [self.mTableView reloadData];
//            [self.mTableView.footer endRefreshing];
//        }else{
//            [self showHint:ErrorWord];
//        }
//    }];

- (void)loadUsersInfoWithIds:(NSArray*)ids{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    NSString * lat =[LVTools mToString: [kUserDefault valueForKey:kLocationLat]];
    NSString * lng =[LVTools mToString: [kUserDefault valueForKey:kLocationlng]];
    [dic setObject:ids forKey:@"ids"];
    [dic setObject:lng forKey:@"longitude"];
    [dic setObject:lat forKey:@"latitude"];
    [DataService requestWeixinAPI:getUsersByIds parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        [self.mTableView.mj_footer endRefreshing];
        if ([resultDic[@"status"] boolValue])
        {
            NSLog(@"%@",resultDic);
            [_dataArray removeAllObjects];
            for (NSDictionary *dic in resultDic[@"data"][@"users"])
            {
                NearByModel * model = [[NearByModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [_dataArray addObject:model];
                [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:model] Key:[NSString stringWithFormat:@"xd%@",[LVTools mToString: model.userId]]];
            }
            if (_dataArray.count==0) {
                [self showHint:@"您还没有添加任何人为好友,赶快去添加吧"];
            }
            else{
                [self.mTableView reloadData];
            }
        }else{
            [self showHint:ErrorWord];
        }
    }];
}

#pragma mark UITableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idece =@"idecell";
    ZHInviteCell *cell =[tableView dequeueReusableCellWithIdentifier:idece];
    if (cell == nil) {
        cell = [[ZHInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idece menbertype:MenberInviteFriendType];
    }
    [cell configModel:[_dataArray objectAtIndex:indexPath.row]];
    cell.selectedBtn.tag = 200+indexPath.row;
    
    [cell.selectedBtn addTarget:self action:@selector(selectedOnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击");
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (void)selectedOnClick:(UIButton*)btn{
    btn.selected = !btn.selected;
    NearByModel *model =(NearByModel*)[_dataArray objectAtIndex:btn.tag-200];
    model.selected = btn.selected;
    if (btn.selected) {
        [_selectedFriend addObject:model];
    } else {
        if ([_selectedFriend containsObject:model]) {
            [_selectedFriend removeObject:model];
        }
    }
    if (_selectedFriend.count > 0) {
        [self.navigationItem.rightBarButtonItem setTitle:[NSString stringWithFormat:@"(%ld)确定",(long)[_selectedFriend count]]];
    } else {
        [self.navigationItem.rightBarButtonItem setTitle:@"确定"];
    }
}

@end
