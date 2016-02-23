//
//  LVNearByViewController.m
//  yuezhan123
//
//  Created by LV on 15/3/27.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVNearByViewController.h"
#import "LoginLoginZhViewController.h"
#import "WPCFriednMsgVC.h"
#import "NearByTableViewCell.h"
#import "NearByModel.h"
#import "ZHGenderView.h"
#import "UMSocial.h"
#import "ZHNearXuanController.h"
@interface LVNearByViewController ()<UITableViewDataSource,UITableViewDelegate,UMSocialDataDelegate,UMSocialUIDelegate,ZHRefreshDelegate>{
    NSIndexPath *selectPath;
    NSString *genderType;
    NSString *maxAge;
    NSString *minAge;
    NSString *sportType;
    int page;
}

@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray * NearByArray;

@end

@implementation LVNearByViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"附近的人";
    genderType = @"";
    maxAge = @"";
    minAge = @"";
    sportType = @"";
    page = 1;
    self.NearByArray = [NSMutableArray arrayWithCapacity:0];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(chooseAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    [self navgationBarLeftReturn];
    [self makeUI];
    //[self loadData];
    
}
- (void)chooseAction {

    ZHNearXuanController *shaixuanVC= [[ZHNearXuanController alloc] init];
    shaixuanVC.shaixuanType = ShaixuanTypePerson;
    shaixuanVC.chuanBlock = ^(NSArray *arr) {
        [self.NearByArray removeAllObjects];
        page = 1;
        minAge = arr[0];
        maxAge = arr[1];
        sportType = arr[2];
        genderType = arr[3];
        [self loadData];
    };
    [self.navigationController pushViewController:shaixuanVC animated:YES];
}

- (void)makeUI{
    [self.view addSubview:self.tableView];
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
}


#pragma  mark --加载数据
- (void)loadData{
    NSString * lat = [kUserDefault objectForKey:kLocationLat];
    NSString * lng = [kUserDefault objectForKey:kLocationlng];
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:lat forKey:@"latitude"];
    [dic setValue:lng forKey:@"longitude"];
    
    NSString * userLogin = [kUserDefault objectForKey:kUserLogin];
    if (userLogin) {
        NSString * userId = [kUserDefault objectForKey:kUserId];
        [dic setValue:userId forKey:@"uid"];
    }
    
    [dic setValue:minAge forKey:@"minAge"];
    [dic setValue:maxAge forKey:@"maxAge"];
    [dic setValue:sportType forKey:@"love_sports"];
    [dic setValue:genderType forKey:@"gender"];
    
    
    [dic setValue:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [dic setValue:@"10" forKey:@"rows"];
    NSLog(@"%@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    request =[DataService requestWeixinAPI:getNearFriendList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"result === %@",result);
        NSDictionary * resultDic = (NSDictionary *)result;
        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
        {
            page ++;
            
            for (NSDictionary *dic in resultDic[@"friendList"])
            {
                NearByModel * model = [[NearByModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [self.NearByArray addObject:model];
                [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:model] Key:[NSString stringWithFormat:@"xd%@",[LVTools mToString: model.uid]]];
            }
            if ([self.NearByArray count] > 0) {
                _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            }
            [self.tableView reloadData];
           
        }else{
            [self showHint:ErrorWord];
        }
    }];
}

#pragma mark --分享
- (void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response{
    if (response.responseCode == UMSResponseCodeSuccess) {
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }else{
        [self showHint:@"分享失败"];
    }
}
- (BOOL)isDirectShareInIconActionSheet{
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NearByModel * model = self.NearByArray[indexPath.row];
    NSString * uidStr = [NSString stringWithFormat:@"%@",model.uid];
    NSLog(@"uidstr ====%@",uidStr);
    WPCFriednMsgVC * vc = [[WPCFriednMsgVC alloc] init];
    vc.uid = uidStr;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.NearByArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NearByTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[NearByTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID2"];
    }
    NearByModel * model = self.NearByArray[indexPath.row];
    [cell configModel:model];
    
    __weak typeof(self) weakSelf = self;
    cell.addFirend = ^(BOOL isLogin,NSString * uid,NSString * userName){
        
        if (isLogin)
        {
            [WCAlertView showAlertWithTitle:nil message:[NSString stringWithFormat:@"是否添加%@为好友?",userName] customizationBlock:^(WCAlertView *alertView) {
                //
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                //
                if(buttonIndex == 1){
                    [self addFriendWith:uid AndName:userName withIndex:indexPath];
                    
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"添加", nil];
                    }else
        {
            //进入登录界面
            LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
            [weakSelf.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
        }
    };
    
    cell.chatFirend = ^(NSString * uid,NSString * userName){
        NSString * uidStr = [NSString stringWithFormat:@"%@",uid];
        WPCFriednMsgVC * vc = [[WPCFriednMsgVC alloc] init];
        vc.uid = uidStr;
        vc.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}
- (void)addFriendWith:(NSString*)fuid AndName:(NSString*)userName withIndex:(NSIndexPath*)index{
    //            BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:[NSString stringWithFormat:@"%@",uid] message:@"我要添加你为好友" error:nil];
    //            if (isSuccess) {
    //                NSLog(@"发送好友请求成功");
    //            }
    //
    //            //好友同意我为好友
    //
    //            //同意加好友
    //           BOOL isSuccess2 = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:[NSString stringWithFormat:@"%@",uid] error:nil];
    //            if (isSuccess2) {
    //                NSLog(@"发送同意成功");
    //            }
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    NSString * myId = [kUserDefault objectForKey:kUserId];
    //NSString * myname = [kUserDefault objectForKey:kUserName];
    
    [dic setValue:[NSString stringWithFormat:@"%@",myId] forKey:@"uid"];
    [dic setValue:[NSString stringWithFormat:@"%@",fuid] forKey:@"fuid"];
    [dic setValue:userName forKey:@"fusername"];
    [dic setValue:@"1" forKey:@"status"];
    [self showHudInView:self.view hint:@"添加中..."];
    //添加好友
    [DataService requestWeixinAPI:addFrirend parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [self showHint:@"添加成功!"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshOldList object:nil];
            // 移除黑名单
            [[EaseMob sharedInstance].chatManager unblockBuddy:[LVTools mToString:[LVTools mToString:fuid]]];
            NearByModel *model = [_NearByArray objectAtIndex:index.row];
            model.isFriend = @"true";
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
            //发送加好友通知
           
        }else{
            [self showHint:ErrorWord];
        }
    }];

}
#pragma  mark --监听加好友请求
- (void)didReceiveBuddyRequest:(NSString *)username
                               message:(NSString *)message{
    
    EMError *error = nil;
    BOOL isSuccess = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:&error];
    if (isSuccess && !error) {
        NSLog(@"发送同意成功");
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(BOUNDS), CGRectGetHeight(BOUNDS) - 49 - 20) style:UITableViewStylePlain];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ZHRefreshDelegate
- (void)sendMsg:(NSString *)msg{
    NearByModel *model= [_NearByArray objectAtIndex:selectPath.row];
    model.isFriend = msg;
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
