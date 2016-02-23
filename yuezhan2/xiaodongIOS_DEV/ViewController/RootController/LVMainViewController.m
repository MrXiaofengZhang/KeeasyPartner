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
@interface LVMainViewController ()<UITabBarControllerDelegate,IChatManagerDelegate>{
    LVAppointViewController * vc1;
    LVSportViewController * vc2;
    WPCTeamHpVC * vc3;
    WPCChatHomePageVC * vc4;
    WPCMyOwnVC * vc5;
    UIView *myCount;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMessageCount) name:NotificationRefreshMessageCount object:nil];
    [self setMessageCount];
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
                item.badgeValue =[NSString stringWithFormat:@"%ld",(unsigned long)badgeNum];
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
            vc5.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
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
            vc5.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
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
            item.badgeValue =[NSString stringWithFormat:@"%ld",(unsigned long)[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]];
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
    myCount  =[[UIView alloc] initWithFrame:CGRectMake(BOUNDS.size.width*0.84, mygap, mygap*2, mygap*2)];
    myCount.layer.cornerRadius = mygap;
    myCount.backgroundColor = color_red_dan;
    [self.tabBar addSubview:myCount];
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
