//
//  LVMainViewController.m
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVMainViewController.h"
#import "WPCChatHomePageVC.h"
#import "LVSportViewController.h"  //赛事一级界面
#import "LVAppointViewController.h"//约战一级界面
#import "WPCTeamHpVC.h"//发现一级界面
#import "WPCMyOwnVC.h"//新的wpc个人中心
#import "MobClick.h"
#import "ApplyViewController.h"
//#import "WPCFriednMsgVC.h"
#import "MessageController.h"
@interface LVMainViewController ()<UITabBarControllerDelegate,IChatManagerDelegate>{
    LVAppointViewController * vc1;
    LVSportViewController * vc2;
    WPCTeamHpVC * vc3;
    WPCChatHomePageVC * vc4;
    WPCMyOwnVC * vc5;
}

@property (nonatomic, assign)NSInteger tabNum;

@end

@implementation LVMainViewController

- (instancetype)initWithNumber:(NSInteger)number{
    self = [super init];
    if (self) {
        self.tabNum = number;
        [self makeUI];
        [self createItems];
        self.delegate = self;
    }
    return self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    //NSLog(@"%d",tabBarController.selectedIndex);
    NSArray *tabArr = @[@"AppointList",@"SportList",@"Found",@"Chat",@"selfIndex"];
    [MobClick event:[tabArr objectAtIndex:tabBarController.selectedIndex]];
    if (tabBarController.selectedIndex == 2) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (tabBarController.selectedIndex == 3) {
        NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
        if (![isLogin isEqualToString:@"1"]) {
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getmessageNum) name:RECEIVEREMOTENOTIFICATION object:nil];
    //订阅展示视图消息，将直接打开某个分支视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentView:) name:@"PresentView" object:nil];
    //[self setMessageCount];
    if ([[kUserDefault objectForKey:kToken] length]==32) {
        [self getmessageNum];
    }
    
    
}
- (void)presentView:(NSNotification*)noti{
    
//        NSError *parseError = nil;
//        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:noti.userInfo
//                                                            options:NSJSONWritingPrettyPrinted error:&parseError];
//        NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送内容"
//                                                        message:str
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                              otherButtonTitles:nil];
//        [alert show];
    //如果能返回关注人的id，就可以直接跳到关注人详情。现在只是当收到消息中心消息时，跳到消息中心
    UIViewController *showViewController = nil;
    NSString *type = noti.userInfo[@"type"];
    if ([type isEqualToString:@"message"]) {
        showViewController = [[MessageController alloc] init];
        showViewController.title = @"消息中心";
        showViewController.hidesBottomBarWhenPushed = YES;
        [[self.viewControllers objectAtIndex:self.selectedIndex]  pushViewController:showViewController animated:YES];
    }
    

}
- (void)getmessageNum{
    
    if([[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]==0){
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [DataService requestWeixinAPI:selfmessagecenterNum parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
        NSLog(@"%@",result);
        if([result[@"status"] boolValue]){
            //全为0表示个人中心没有新内容
            if(([[LVTools mToString:result[@"data"][@"messageCount"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"messageCount"]] length]==0)&&
               ([[LVTools mToString:result[@"data"][@"fansStatus"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"fansStatus"]] length]==0)&&
               ([[LVTools mToString:result[@"data"][@"matchCount"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"matchCount"]] length]==0)&&
               [[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]==0&&
               ([[LVTools mToString:result[@"data"][@"replyCount"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"replyCount"]] length]==0)){
                _myCount.hidden = YES;
            }else{
                _myCount.hidden = NO;
            }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
    }
    else{
        self.myCount.hidden = NO;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
   // EMPushNotificationOptions * option = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
}
#pragma mark - IChatManagerDelegate 消息变化

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [self setMessageCount];
//    [_chatListVC refreshDataSource];
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setMessageCount];
}

- (void)didFinishedReceiveOfflineMessages
{
    [self setMessageCount];
}

-(void)setMessageCount{
    //需要加上申请未读消息数
    NSInteger badgeNum = [[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]+[[[ApplyViewController shareController] dataSource] count];
    NSLog(@"未读个数%d",(int)badgeNum);
    
    for (NSInteger i = 0; i<self.tabBar.items.count; i++)
    {
        UITabBarItem * item = self.tabBar.items[i];
        if (i==2) {
            if (badgeNum>0) {
//                item.badgeValue =[NSString stringWithFormat:@"%ld",(unsigned long)badgeNum];
            }
            else if(badgeNum==0){
                item.badgeValue =nil;
            }
            else{
                item.badgeValue =nil;
            }
        }
    }

}
// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (vc5) {
        if (unreadCount > 0) {
//            vc5.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            vc5.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}
//统计未读申请数
- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[[ApplyViewController shareController] dataSource] count];
    if (vc5) {
        if (unreadCount > 0) {
//            vc5.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            vc5.tabBarItem.badgeValue = nil;
        }
    }
}

- (void)createItems{
    NSArray * titleArray = @[/*@"约战",*/@"赛事",@"球队",/*@"聊天",*/@"我的"];
    NSArray * UnselectImageNameArray = @[/*@"main_tab1_1",*/@"main_tab2_1",@"main_tab6_1",/*@"main_tab4_1",*/@"main_tab5_1"];
    NSArray * selectImageNameArray= @[/*@"main_tab1_2",*/@"main_tab2_2",@"main_tab6_2",/*@"main_tab4_2",*/@"main_tab5_2"];
    for (NSInteger i = 0; i<self.tabBar.items.count; i++)
    {
        UITabBarItem * item = self.tabBar.items[i];
       
            //需要对图片进行单独处理
            UIImage*selectImage=[UIImage imageNamed:selectImageNameArray[i]];
            selectImage=[selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIImage*unSelectImage=[UIImage imageNamed:UnselectImageNameArray[i]];
            unSelectImage=[unSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            //以上是防止在bar上显示为阴影而不是图片
            item.selectedImage=selectImage;
            item.image=unSelectImage;
            item.title=titleArray[i];
        if (i==3) {
        if ([[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]>0) {
//            item.badgeValue =[NSString stringWithFormat:@"%ld",(unsigned long)[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]];
            }
        }
    }
    if (iOS7)
    {
        [[UITabBarItem appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:garyLineColor} forState:UIControlStateNormal];
        
        [[UITabBarItem appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:SystemBlue} forState:UIControlStateSelected];
    }else
    {
        [[UITabBarItem appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:garyLineColor} forState:UIControlStateNormal];
        
        [[UITabBarItem appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:SystemBlue} forState:UIControlStateSelected];
        
    }
    
    self.selectedIndex = self.tabNum;
    _myCount  =[[UIView alloc] initWithFrame:CGRectMake(BOUNDS.size.width*0.84, mygap, mygap*2, mygap*2)];
    _myCount.layer.cornerRadius = mygap;
    _myCount.backgroundColor = [UIColor redColor];
    _myCount.hidden = YES;
    [self.tabBar addSubview:_myCount];
}

- (void)makeUI{
//    LVAppointViewController * vc1 = [[LVAppointViewController alloc] init];
//    vc1.title = @"约战";
//    UINavigationController * nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    if (vc2 == nil) {
    vc2 = [[LVSportViewController alloc] init];
    vc2.title = @"校内赛事";
    UINavigationController * nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    
    vc3 = [[WPCTeamHpVC alloc] init];
    //vc3.title = @"球队";
    UINavigationController * nc3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    
//    WPCChatHomePageVC *vc4 = [[WPCChatHomePageVC alloc] init];
//    UINavigationController * nc4 = [[UINavigationController alloc] initWithRootViewController:vc4];
    
    vc5 = [[WPCMyOwnVC alloc] init];
    vc5.basicVC = YES;
    UINavigationController * nc5 = [[UINavigationController alloc] initWithRootViewController:vc5];
        self.viewControllers = @[/*nc1,*/nc2,nc3,/*nc4,*/nc5];
    }
    
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
