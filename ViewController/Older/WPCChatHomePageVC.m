 //
//  WPCChatHomePageVC.m
//  yuezhan123
//
//  Created by admin on 15/7/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCChatHomePageVC.h"
#import "PopoverView.h"
#import "WPCGroupChatVC.h"
#import "WPCAddPartnerVC.h"
#import "NearByModel.h"
#import "ZHInviteCell.h"
#import "ApplyViewController.h"
#import "GroupListViewController.h"
#import "WPCFriednMsgVC.h"
#import "SRRefreshView.h"
#import "ChatListCell.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "EmpatyView.h"
#import "ZHAgreementViewController.h"
#import "LoginLoginZhViewController.h"
#import "PhoneListController.h"
#import "LVSportViewController.h"
@interface WPCChatHomePageVC () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,SRRefreshDelegate,IChatManagerDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UITableView *secondTable;
@property (nonatomic, strong) NSMutableArray *dataArray;//secondTable
@property (nonatomic, strong) UILabel *countlab;//新好友申请
@property (nonatomic, strong) UILabel *countlab1;//新联系人


@property (strong, nonatomic) NSMutableArray        *dataSource;//tableView

@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) UIView                *networkStateView;

@end

@implementation WPCChatHomePageVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"聊天记录",@"通讯录"]];
    _segmentControl.frame = CGRectMake(124*propotion, 5, 500*propotion, 33);
    _segmentControl.selectedSegmentIndex = 0;
    [_segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    [self initialDatasource];
    [self initialInterface];
    [self MJRefresh];
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
        [self.tableView reloadData];
    } onQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSateChange:) name:LOGINSTATECHANGE_NOTIFICATION object:nil];
    //当有好友关系变化时.刷新好友列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:NotificationRefreshOldList object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageCount) name:NotificationNewApply object:nil];
    [self refreshMessageCount];
}
- (void)refreshMessageCount{
    if([ApplyViewController shareController].dataSource.count==0){
        _countlab.hidden = YES;
    }else{
        _countlab.hidden = NO;
        _countlab.text = [NSString stringWithFormat:@"%d",(int)([ApplyViewController shareController].dataSource.count)];
        //[[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshOldList object:nil];
    }
}
#pragma  mark --刷新
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.secondTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
}
- (void)loginSateChange:(NSNotification*)noti{
    if ([noti.object boolValue]) {
        [self loadData];
        [self loadGroupShows];
    }
    else{
        //清除数据，主要清楚头部数据
        [_dataArray removeAllObjects];
        [self.secondTable reloadData];
        
        [_dataSource removeAllObjects];
        [_tableView reloadData];
        
        self.tableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptyChat" AndText:@"暂无聊天记录"];
        
    }

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_segmentControl];
    [self refreshMessageCount];
    [self countlab1];
    if(![[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]){
    [WCAlertView showAlertWithTitle:nil message:@"您还未登录,不能查看聊天信息" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        //
        if (buttonIndex == [alertView cancelButtonIndex]) {
            [self.tabBarController setSelectedIndex:0];
        }
        else{
            LoginLoginZhViewController * vc = [[LoginLoginZhViewController alloc] init];
            UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
        
    } cancelButtonTitle:@"先逛逛" otherButtonTitles:@"立刻登录", nil];
    }
    else{
    [self refreshDataSource];
    [self registerNotifications];
//    [self getmessageNum];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_segmentControl removeFromSuperview];
    [self unregisterNotifications];
    
}
- (void)getmessageNum{
//    NSMutableDictionary *dic = [LVTools getTokenApp];
//    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"recipient"];
//    [dic setValue:@"6" forKey:@"type"];
//    [DataService requestWeixinAPI:selfmessagecenterNum parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
//        
//        NSLog(@"%@",result);
//        if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
//            if([[LVTools mToString:result[@"num"]] isEqualToString:@"0"]){
//                _countlab.hidden = YES;
//            }else{
//                _countlab.hidden = NO;
//                _countlab.text = [LVTools mToString:result[@"num"]];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshOldList object:nil];
//            }
//        }
//        else{
//            
//        }
//    }];
    
}

- (void)removeEmptyConversationsFromDB
{
    
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    if (conversations.count==0) {
        self.tableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptyChat" AndText:@"暂无聊天记录"];
    }
    else{
        self.tableView.backgroundView = nil;
    }
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

- (void)initialInterface {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right_more_wpc"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAction)];
    [self.view addSubview:self.secondTable];
    
    [self removeEmptyConversationsFromDB];
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self networkStateView];
    
    _secondTable.hidden = YES;
}
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"chatListCell"];
    }
    
    return _tableView;
}
- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}
- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}
- (UILabel *)countlab {
    if (!_countlab) {
        _countlab = [[UILabel alloc] initWithFrame:CGRectMake(140, 20, 20, 20)];
        _countlab.backgroundColor = [UIColor redColor];
        _countlab.textColor = [UIColor whiteColor];
        _countlab.layer.cornerRadius = _countlab.width/2.0;
        _countlab.layer.masksToBounds = YES;
        _countlab.font = Content_lbfont;
        _countlab.textAlignment = NSTextAlignmentCenter;
        _countlab.hidden = YES;
    }
     _countlab.text = [NSString stringWithFormat:@"%ld",(long)[ApplyViewController shareController].dataSource.count];
    return _countlab;
}
- (UILabel *)countlab1 {
    if (!_countlab1) {
        _countlab1 = [[UILabel alloc] initWithFrame:CGRectMake(140, 20, 20, 20)];
        _countlab1.backgroundColor = [UIColor redColor];
        _countlab1.textColor = [UIColor whiteColor];
        _countlab1.layer.cornerRadius = _countlab.width/2.0;
        _countlab1.layer.masksToBounds = YES;
        _countlab1.font = Content_lbfont;
        _countlab1.textAlignment = NSTextAlignmentCenter;
        _countlab1.hidden = YES;
    }
    _countlab1.text = [NSString stringWithFormat:@"%ld",((LVSportViewController*)[((UINavigationController*)[self.navigationController.tabBarController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0]).newPeopleCount];
    return _countlab1;
}

- (UITableView *)secondTable {
    if (!_secondTable) {
        _secondTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT) style:UITableViewStylePlain];
        _secondTable.dataSource = self;
        _secondTable.delegate = self;
        _secondTable.showsVerticalScrollIndicator = NO;
        _secondTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _secondTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 180+8.0)];
        headview.backgroundColor = RGBACOLOR(235, 235, 235, 1);
        
        NSArray *arr = @[@"new_partner_wpc",@"phoneList",@"groupchat_wpc"];
        NSArray *arr1 = @[@"新的好友",@"手机通讯录",@"群聊"];
        for (int i = 0; i < arr.count; i ++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,5+60*i, UISCREENWIDTH, 60.0)];
            view.tag = 700+i;
            view.backgroundColor = [UIColor whiteColor];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];
            [view addGestureRecognizer:tap];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 46.0, 46.0)];
            img.image = [UIImage imageNamed:arr[i]];
            [view addSubview:img];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(img.right+10, 12, 120, 36.0)];
            lab.text = arr1[i];
            lab.font = Title_font;
            [view addSubview:lab];
            
            if (i != arr.count-1) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 59.5, UISCREENWIDTH, 0.5)];
                line.backgroundColor = RGBACOLOR(222, 222, 222, 1);
                [view addSubview:line];
                if (i==1) {
                    [view addSubview:self.countlab1];
                }
                else if (i==2){
                    [view addSubview:self.countlab];
                }
                
            }
            [headview addSubview:view];
        }
        _secondTable.tableHeaderView = headview;
    }
    return _secondTable;
}

- (void)clickAction:(UITapGestureRecognizer *)tap {
    if(tap.view.tag==700){
        //新的
//        ZHApplyJoinController *joinVC =[[ZHApplyJoinController alloc] init];
//        joinVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:joinVC animated:YES];
        [self.navigationController pushViewController:[ApplyViewController shareController] animated:YES];
    }
    else if (tap.view.tag==701){
        PhoneListController *phoneVC =[[PhoneListController alloc] init];
        [self.navigationController pushViewController:phoneVC animated:YES];
    }
    else{
        //群聊
        GroupListViewController *groupVC =[[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
        groupVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:groupVC animated:YES];
    }
}

//- (UITextField *)textField {
//    if (!_textField) {
//        _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, UISCREENWIDTH-20, 30)];
//        _textField.delegate = self;
//        _textField.backgroundColor = [UIColor whiteColor];
//        _textField.layer.borderWidth = 0.5;
//        _textField.layer.borderColor = [RGBACOLOR(220, 220, 220, 1) CGColor];
//    }
//    return _textField;
//}

- (void)initialDatasource {
    _dataArray = [NSMutableArray array];
    //判断是否登录
    if ([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
        [self loadData];
        [self loadGroupShows];
    }
}
- (void)loadGroupShows{
    //加载群头像信息
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
        //
        NSLog(@"%@",groups);
        NSMutableArray *groupidArr = [[NSMutableArray alloc] initWithCapacity:0];
        for (EMGroup *group in groups) {
            [groupidArr addObject:group.groupId];
        }
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setObject:groupidArr forKey:@"groupIds"];
        [DataService requestWeixinAPI:getGroupShowByGroupIds parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
            //
            NSLog(@"群组头像信息%@",result);
            if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
                if (![result[@"userInfoList"] isKindOfClass:[NSNull class]]) {
                    
                    for (NSDictionary *groupshowdic in result[@"userInfoList"]) {
                        NSString *groupId=[LVTools mToString:groupshowdic[@"groupid"]];
                        NSString *path =[LVTools mToString:groupshowdic[@"path"]];
                        [kUserDefault setValue:path forKey:groupId];
                        [kUserDefault synchronize];
                    }
                    [self.tableView reloadData];
                }
            }
            else{
                //[self showHint:@"加载群聊头像信息失败,请下拉刷新"];这里不能显示
            }
            
        }];
    } onQueue:nil];

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
            if(ids.count!=0){
            [self loadUsersInfoWithIds:ids];
            }
            else{
                [self.secondTable.mj_header endRefreshing];
                [self showHint:@"你还没有好友"];
            }
        }
        else{
            [self.secondTable.mj_header endRefreshing];
            [self showHint:error.description];
        }
    } onQueue:nil];

}
- (void)loadUsersInfoWithIds:(NSArray*)ids{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    NSString * lat =[LVTools mToString: [kUserDefault valueForKey:kLocationLat]];
    NSString * lng =[LVTools mToString: [kUserDefault valueForKey:kLocationlng]];
    [dic setObject:ids forKey:@"ids"];
    [dic setObject:lng forKey:@"longitude"];
    [dic setObject:lat forKey:@"latitude"];
    [DataService requestWeixinAPI:getUsersByIds parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        [self.secondTable.mj_header endRefreshing];
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
                [self.secondTable reloadData];
                [self.tableView reloadData];
            }
        }else{
            [self showHint:ErrorWord];
        }
    }];
}
#pragma mark -- tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   if ([tableView isEqual:_tableView]){
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        ChatViewController *chatController;
        NSString *title = conversation.chatter;
       NSString *icon = @"";
        if (conversation.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    title = group.groupSubject;
                    break;
                }
            }
        }
        else{
            NearByModel *model=[NSKeyedUnarchiver unarchiveObjectWithData: [LVTools mGetLocalDataByKey:[NSString stringWithFormat:@"xd%@",conversation.chatter]]];
            title = [LVTools mToString:model.nickName];
            icon = model.path;
        }
        NSString *chatter = conversation.chatter;
        chatController = [[ChatViewController alloc] initWithChatter:chatter isGroup:conversation.isGroup WithIcon:icon];
        chatController.title = title;
        chatController.hidesBottomBarWhenPushed= YES;
        [self.navigationController pushViewController:chatController animated:YES];
    }
   else{
       NearByModel *model = [_dataArray objectAtIndex:indexPath.row];
       NSString *chatter =[LVTools mToString: model.userId];
       ChatViewController *chatController = chatController = [[ChatViewController alloc] initWithChatter:chatter isGroup:NO WithIcon:model.path];
       chatController.title = model.nickName;
       chatController.hidesBottomBarWhenPushed= YES;
       [self.navigationController pushViewController:chatController animated:YES];
   }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == _tableView){
        return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return kFriendCellHeight;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([tableView isEqual:_tableView]) {
            EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        }
        else if([tableView isEqual:_secondTable]){
            //删除好友
            //环信删除好友
            NearByModel *fModel = [_dataArray objectAtIndex:indexPath.row];
            [_dataArray removeObjectAtIndex:indexPath.row];
            [_secondTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EMError *error;
                [[EaseMob sharedInstance].chatManager removeBuddy:[LVTools mToString: fModel.userId] removeFromRemote:YES error:&error];
                if (!error) {
                    [[EaseMob sharedInstance].chatManager removeConversationByChatter:[LVTools mToString: fModel.userId] deleteMessages:YES append2Chat:YES];
                    //刷新消息个数
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
                }
                else{
                    [self showHint:@"删除好友失败,请重试"];
                }
            });            
//            NSDictionary * dic = [LVTools getTokenApp];
//            NSString *uid =[LVTools mToString: [kUserDefault objectForKey:kUserId]];
//            [dic setValue:uid forKey:@"uid"];
//            [dic setValue:[LVTools mToString: fModel.uid] forKey:@"fuid"];
//            [self showHudInView:self.view hint:@"正在删除..."];
//            [DataService requestWeixinAPI:deleteFriend parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
//                //
//                [self hideHud];
//                NSDictionary * dic = (NSDictionary *)result;
//                if ([dic[@"resultCodeInfo"] isEqualToString:@"删除成功"]) {
//                    [self showHint:@"删除好友成功"];
//                    [_dataArray removeObjectAtIndex:indexPath.row];
//                    [_secondTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                    //将消息只为已读
//                    EMConversation  *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:[LVTools mToString: fModel.uid] isGroup:NO];
//                    [conversation markAllMessagesAsRead:YES];
//                    //加黑名单
//                    //[[EaseMob sharedInstance].chatManager blockBuddy:[LVTools mToString: fModel.uid]  relationship:eRelationshipBoth];
//                    //最新解决办法 删除会话
//                    [[EaseMob sharedInstance].chatManager removeConversationByChatter:[LVTools mToString: fModel.uid] deleteMessages:YES append2Chat:NO];
//                    //刷新消息个数
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
//                }
//                else{
//                    [self showHint:@"删除好友失败,请重试"];
//                }
//            }];

        }
        else{
            
        }
    }
}

#pragma mark -- tableview datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView){
        static NSString *identify = @"chatListCell";
        ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        cell.name = conversation.chatter;
        NearByModel *model=nil;
        if (conversation.isGroup==NO) {
            if ([LVTools mGetLocalDataByKey:[NSString stringWithFormat:@"xd%@",conversation.chatter]]) {
                model =[NSKeyedUnarchiver unarchiveObjectWithData: [LVTools mGetLocalDataByKey:[NSString stringWithFormat:@"xd%@",conversation.chatter]]];
            }
            cell.name =[LVTools mToString: model.nickName];
            cell.placeholderImage = [UIImage imageNamed:@"plhor_2"];
            cell.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,model.path]];
            if (cell.name.length==0) {
                cell.name = @"该消息来自陌生人";
            }
        }
        else{
            cell.placeholderImage =[UIImage imageNamed:@"groupPrivateHeader"];
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    cell.name = group.groupSubject;
                    NSString *iconPath =[LVTools mToString: [kUserDefault objectForKey:group.groupId]];
                    cell.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,iconPath]];
                    break;
                }
            }
        }
        cell.detailMsg = [self subTitleMessageByConversation:conversation];
        cell.time = [self lastMessageTimeByConversation:conversation];
        cell.unreadCount = [self unreadMessageCountByConversation:conversation];
        if (indexPath.row % 2 == 1) {
            cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
        }else{
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        return cell;
    }
    else {
        static NSString *cellID = @"cellid";
        ZHInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[ZHInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID menbertype:MenberNearByType];
            cell.headimg.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headimgOnclick:)];
            [cell.headimg addGestureRecognizer:tap];
        }
        cell.tag = 800+indexPath.row;
        [cell configModel:_dataArray[indexPath.row]];
        cell.headimg.tag = 900+indexPath.row;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 if (tableView == _tableView){
        return  self.dataSource.count;
    }
    return _dataArray.count;
    
}

- (NSArray *)rightbuttons {
    NSMutableArray *arr = [NSMutableArray array];
    [arr sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.99f green:0.01f blue:0.01f alpha:1.0]
                                title:@"删除"];
    return arr;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
}

- (void)segmentAction:(UISegmentedControl *)seg {
    NSInteger index = seg.selectedSegmentIndex;
    if (index == 0) {
        //聊天记录
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"right_more_wpc"]];
        _tableView.hidden = NO;
        _secondTable.hidden = YES;
    } else {
        //通讯录
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"addPartner_wpc"]];
        _tableView.hidden = YES;
        _secondTable.hidden = NO;
    }
}

- (void)moreAction {
    if (_segmentControl.selectedSegmentIndex == 0) {
        CGPoint point = CGPointMake(UISCREENWIDTH-25, 69);
        PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:@[@"添加好友",@"发起群聊"] images:@[@"waddPartner_wpc",@"wgroup_chat_wpc"] andStyle:PopoverStyleBlack];
        pop.borderColor = [UIColor clearColor];
        pop.selectRowAtIndex = ^ (NSInteger index) {
            switch (index) {
                case 0:
                {
                    //添加战友
                    WPCAddPartnerVC *vc = [[WPCAddPartnerVC alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:
                {
                    //发起群聊天
                    WPCGroupChatVC *vc = [[WPCGroupChatVC alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
        };
        __block PopoverView *tempPop = pop;
        pop.dismissBlock = ^() {
            tempPop = nil;
        };
        [pop show];
    } else {
        WPCAddPartnerVC *vc = [[WPCAddPartnerVC alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
#pragma mark SaomiaoViewControllerDelagate
#pragma mark saomiaoDelegate
- (void)getErWeiResult:(NSString *)ErWeiMa{
    NSLog(@"%@",ErWeiMa);
    if (ErWeiMa) {
        [self showHint:ErWeiMa];
        if ([ErWeiMa hasPrefix:@"http"]) {
            ZHAgreementViewController *agreeVC =[[ZHAgreementViewController alloc] init];
            agreeVC.urlstring = ErWeiMa;
            agreeVC.title = @"";
            agreeVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:agreeVC animated:YES];
        }
        else{
            [WCAlertView showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"无法识别的二维码%@",ErWeiMa] customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                //
            } cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        }
    }
    //keeasy:id
}
#pragma mark - public

-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [self loadGroupShows];
    [_tableView reloadData];
    [self hideHud];
}

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
    
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
    [self refreshDataSource];
}
#pragma mark - private

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    if (ret.count==0) {
        self.tableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptyChat" AndText:@"暂无聊天记录"];
    }
    else{
        self.tableView.backgroundView = nil;
    }
    return ret;
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.vidio1", @"[vidio]");
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}
#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}
#pragma mark UIsearchDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"搜索好友");
}
#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self refreshDataSource];
    [_slimeView endRefresh];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}
- (void)headimgOnclick:(UITapGestureRecognizer*)tap{
    NearByModel *model = [_dataArray objectAtIndex:tap.view.tag-900];
    WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
    vc.uid = model.userId;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
