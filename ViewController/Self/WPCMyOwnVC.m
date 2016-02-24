//
//  WPCMyOwnVC.m
//  yuezhan123
//
//  Created by admin on 15/5/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCMyOwnVC.h"
#import "WPCTimeMachineVC.h"
#import "WPCMyOwnPersonalInfoVC.h"
#import "WPCMyOwnMsgCenterVC.h"
#import "WPCChangePackageVC.h"
#import "UMSocial.h"
#import "LoginLoginZhViewController.h"
#import "SelfSetZhViewController.h"
#import "AppDelegate.h"
#import "ZHClickBigImageView.h"
#import "NearByModel.h"
#import "ZHSelfOrderController.h"
#import "ZHSelfSportController.h"
#import "WPCMyTeamVC.h"
#import "MyinfoController.h"
#import "MySchoolInfoController.h"
#import "WPCChatHomePageVC.h"
#import "ListViewController.h"
#import "MessageController.h"
#import "ApplyViewController.h"
#import "AboutmeController.h"
#import "LVMainViewController.h"
@interface WPCMyOwnVC () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    BOOL isSignIn;//判断是否签到过
    ZHClickBigImageView *bigImageview;
    UILabel *countlab;//消息中心消息个数
    UILabel *countlab1;//聊天消息个数
    UILabel *orderNumLb;//赛事消息个数
    UIView *comentStatus;//新回复
    UIView *fansStatus;//新粉丝
}
@property (nonatomic, strong) UITableView *myOwnTableView;
@property (nonatomic, strong) NSArray *preArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSDictionary *dic;
@end

@implementation WPCMyOwnVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preArray = @[@[@"报名信息"],@[@"聊天",@"我的赛事"],@[@"消息中心"],@[@"设置"]];
    self.imageArray = @[@[@"personal_info"],@[@"xxi",@"participated_match"],@[@"xiaoxinzx",@"order_manage"],@[@"setting_wpc"]];
    comentStatus = [[UIView alloc] initWithFrame:CGRectMake(LEFTX/1.2, -mygap/2, mygap*2, mygap*2)];
    comentStatus.layer.cornerRadius = mygap;
    comentStatus.backgroundColor = [UIColor redColor];
    comentStatus.hidden = YES;
    
    fansStatus = [[UIView alloc] initWithFrame:CGRectMake(LEFTX/1.2, -mygap/2, mygap*2, mygap*2)];
    fansStatus.layer.cornerRadius = mygap;
    fansStatus.backgroundColor = [UIColor redColor];
    fansStatus.hidden = YES;
    [self initialInterface];
    //[self loadData];
    countlab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH-48.0, 48.0/3, 48.0/3, 48.0/3)];
    countlab.layer.cornerRadius = 48.0/6;
    countlab.layer.masksToBounds = YES;
    countlab.textAlignment = NSTextAlignmentCenter;
    countlab.backgroundColor = [UIColor redColor];
    countlab.font = [UIFont systemFontOfSize:10];
    countlab.textColor = [UIColor whiteColor];
    countlab.hidden = YES;
    
    countlab1 = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH-48.0, 48.0/3, 48.0/3, 48.0/3)];
    countlab1.layer.cornerRadius = 48.0/6;
    countlab1.layer.masksToBounds = YES;
    countlab1.textAlignment = NSTextAlignmentCenter;
    countlab1.backgroundColor = [UIColor redColor];
    countlab1.font = [UIFont systemFontOfSize:10];
    countlab1.textColor = [UIColor whiteColor];
    countlab1.hidden = YES;


    
    orderNumLb  =[[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH-48.0, 48.0/3, 48.0/3, 48.0/3)];
    orderNumLb.layer.cornerRadius = 48.0/6;
    orderNumLb.textAlignment = NSTextAlignmentCenter;
    orderNumLb.backgroundColor = [UIColor redColor];
    orderNumLb.font = [UIFont systemFontOfSize:10];
    orderNumLb.textColor = [UIColor whiteColor];
    orderNumLb.hidden = YES;

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSateChange:) name:LOGINSTATECHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personInfoChange:) name:NotificationRefreshAppoint object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageCount) name:NotificationRefreshMessageCount object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageCount) name:NotificationNewApply object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getmessageNum) name:RECEIVEREMOTENOTIFICATION object:nil];//收到推送
}
- (void)refreshMessageCount{
    NSInteger unred = [[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]+[ApplyViewController shareController].dataSource.count;
    if (unred != 0) {
        countlab1.hidden = NO;
        countlab1.text = [NSString stringWithFormat:@"%d",(int)unred];
        ((LVMainViewController*)(self.tabBarController)).myCount.hidden = NO;
    }
    else{
        countlab1.hidden = YES;
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)personInfoChange:(NSNotification*)noti{
    //[self loadData];
}
- (void)loginSateChange:(NSNotification*)noti{
    if ([noti.object boolValue]) {
        [self loadData];
    }
    else{
        //清除数据，主要清楚头部数据消息个数和绑定状态
        UIView *HeadView =[self.view viewWithTag:2600];
        [self reloadHeadView:HeadView];
        countlab.hidden = YES;
        countlab1.hidden = YES;
        orderNumLb.hidden = YES;
        [_myOwnTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)getmessageNum{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [DataService requestWeixinAPI:selfmessagecenterNum parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
        NSLog(@"%@",result);
        if([result[@"status"] boolValue]){
            if([[LVTools mToString:result[@"data"][@"messageCount"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"messageCount"]] length]==0){
                countlab.hidden = YES;
            }else{
                countlab.hidden = NO;
                countlab.text = [LVTools mToString:result[@"data"][@"messageCount"]];
            }
            if([[LVTools mToString:result[@"data"][@"matchCount"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"matchCount"]] length]==0){
                orderNumLb.hidden = YES;
            }else{
                orderNumLb.hidden = NO;
                orderNumLb.text = [LVTools mToString:result[@"data"][@"matchCount"]];
            }
            //粉丝
            if([[LVTools mToString:result[@"data"][@"fansStatus"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"fansStatus"]] length]==0){
                fansStatus.hidden = YES;
            }else{
                fansStatus.hidden = NO;
            }
            //我的评论
            if([[LVTools mToString:result[@"data"][@"replyCount"]] isEqualToString:@"0"]||[[LVTools mToString:result[@"data"][@"replyCount"]] length]==0){
                comentStatus.hidden = YES;
            }else{
                comentStatus.hidden = NO;
            }
            if([[LVTools mToString:result[@"data"][@"messageCount"]] isEqualToString:@"0"]&&[[LVTools mToString:result[@"data"][@"fansStatus"]] isEqualToString:@"0"]&&[[LVTools mToString:result[@"data"][@"matchCount"]] isEqualToString:@"0"]&&[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]==0&&[[LVTools mToString:result[@"data"][@"replyCount"]] isEqualToString:@"0"]){
              ((LVMainViewController*)(self.tabBarController)).myCount.hidden = YES;
            }else{
            ((LVMainViewController*)(self.tabBarController)).myCount.hidden = NO;
            }

        }
        else{
            [self showHint:ErrorWord];
        }
    }];

}
//获取消息中心未读消息个数
- (void)loadData
{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if ([islogin isEqualToString:@"1"]) {
        //[self requestData];
        //获取本地的用户信息
        [self loadDataBycache];
    }
    else{
        
    }
}
- (void)loadDataBycache{
    self.dic = [NSKeyedUnarchiver unarchiveObjectWithData: [LVTools mGetLocalDataByKey:[NSString stringWithFormat:@"xd%@",[LVTools mToString:[kUserDefault objectForKey:kUserId]]]]];
    if (self.dic)
    {
        //请求成功后的数据处理
        _model=[[FriendListModel alloc]init];
       
        [_model setValuesForKeysWithDictionary:self.dic[@"user"]];
        [_myOwnTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:3], nil] withRowAnimation:UITableViewRowAnimationNone];
        UIView *view = (UIView *)[self.view viewWithTag:2600];
        //这里不应该每次都add，每次add之前要先remove
        [LVTools createTheSortsLab:self.dic[@"user"] inView:view];
        UIButton *image = (UIButton *)[self.view viewWithTag:2603];
        if ([[LVTools mToString:_dic[@"path"]] length] != 0) {
            NSString *imgstr = [NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:self.dic[@"path"]]];
            [image sd_setBackgroundImageWithURL:[NSURL URLWithString:imgstr] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
            //[(UIImageView*)[[self myOwnTableView] tableHeaderView] setImage:[LVTools convertGaussImage:img]];
            [kUserDefault setValue:[LVTools mToString: [self.dic objectForKey:@"path"]] forKey:KUserIcon];
            [kUserDefault synchronize];
        } else {
            //todo
            [image setBackgroundImage:[UIImage imageNamed:@"plhor_2"] forState:UIControlStateNormal];
        }
        
        UIButton *namelab = (UIButton *)[self.view viewWithTag:2604];
        if ([[LVTools mToString:self.model.nickName] length] != 0) {
            [namelab setTitle:[LVTools mToString:self.model.nickName] forState:UIControlStateNormal];
        } else {
            //todo
            [namelab setTitle:@"无名" forState:UIControlStateDisabled];
        }
        //没有个性签名这个键值对，暂用loveSportsMeaning作为其键
        UILabel *signLab = (UILabel *)[self.view viewWithTag:2605];
        if ([[LVTools mToString:self.model.signature] length] != 0) {
            signLab.text = [LVTools mToString:self.model.signature];
        } else {
            //todo
            signLab.text = @"这个家伙很懒,什么也没写";
        }
    }
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"获取个人信息失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        UIButton *nameLab = (UIButton *)[self.view viewWithTag:2604];
        [nameLab setTitle:@"点击刷新" forState:UIControlStateNormal];
    }

}
- (void)requestData
{
    NSMutableDictionary *dic=[LVTools getTokenApp];
    [self showHudInView:self.view hint:@"获取个人信息中..."];
    [dic setObject:[LVTools mToString: [kUserDefault valueForKey:kUserId]] forKey:@"uid"];
    [DataService requestWeixinAPI:selfcenterhome parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary *dic=(NSDictionary *)result;
        self.dic = dic[@"personal"];
        [self hideHud];
        if ([[dic objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
        {
            _model=[[FriendListModel alloc]init];
            NSDictionary *persionDic=[dic objectForKey:@"personal"];
            [_model setValuesForKeysWithDictionary:persionDic];
            //请求成功后的数据处理
            [_myOwnTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:3], nil] withRowAnimation:UITableViewRowAnimationNone];
            
            UIView *view = (UIView *)[self.view viewWithTag:2600];
            //这里不应该每次都add，每次add之前要先remove
            [LVTools createTheSortsLab:self.dic inView:view];
            UIButton *image = (UIButton *)[self.view viewWithTag:2603];
            if ([[LVTools mToString:_dic[@"iconPath"]] length] != 0) {
                NSString *imgstr = [NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:self.dic[@"iconPath"]]];
                [image sd_setBackgroundImageWithURL:[NSURL URLWithString:imgstr] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
                //[(UIImageView*)[[self myOwnTableView] tableHeaderView] setImage:[LVTools convertGaussImage:img]];
                [kUserDefault setValue:[LVTools mToString: [[dic objectForKey:@"personal"]  objectForKey:@"iconPath"]] forKey:KUserIcon];
                [kUserDefault synchronize];
            } else {
                //todo
                [image setBackgroundImage:[UIImage imageNamed:@"plhor_2"] forState:UIControlStateNormal];
            }
            
            UIButton *namelab = (UIButton *)[self.view viewWithTag:2604];
            if ([[LVTools mToString:self.dic[@"userName"]] length] != 0) {
                [namelab setTitle:[LVTools mToString:self.dic[@"userName"]] forState:UIControlStateNormal];
            } else {
                //todo
                [namelab setTitle:@"无名" forState:UIControlStateDisabled];
            }
            //没有个性签名这个键值对，暂用loveSportsMeaning作为其键
            UILabel *signLab = (UILabel *)[self.view viewWithTag:2605];
            if ([[LVTools mToString:self.dic[@"sign"]] length] != 0) {
                signLab.text = [LVTools mToString:self.dic[@"sign"]];
            } else {
                //todo
                signLab.text = @"这个家伙很懒,什么也没写";
            }
        }
        else
        {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"获取个人信息失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            UIButton *nameLab = (UIButton *)[self.view viewWithTag:2604];
            [nameLab setTitle:@"点击刷新" forState:UIControlStateNormal];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self refreshMessageCount];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    if ([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
        [self getmessageNum];
        [self loadDataBycache];
    }
}
- (void)initialInterface
{
    _myOwnTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, UISCREENWIDTH, UISCREENHEIGHT+20) style:UITableViewStylePlain];
    _myOwnTableView.backgroundColor = UIColorFromRGB(234, 234, 234);
    _myOwnTableView.dataSource = self;
    _myOwnTableView.delegate = self;
    _myOwnTableView.showsVerticalScrollIndicator = NO;
    
    _myOwnTableView.tableHeaderView = [self createTheHeaderView];
    _myOwnTableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:_myOwnTableView];
    
}
//头部视图刷新
- (void) reloadHeadView:(UIView*)headV{
    UIButton *headImg = (UIButton *)[headV viewWithTag:2603];
    [headImg setBackgroundImage:[UIImage imageNamed:@"plhor_2"] forState:UIControlStateNormal];
    UIButton *nameLab = (UIButton *)[headV viewWithTag:2604];
    [nameLab setTitle:@"点击登录" forState:UIControlStateNormal];
    
    UILabel *signLab = (UILabel *)[headV viewWithTag:2605];
    signLab.text = @"这个家伙很懒,什么也没写";
    UIView *view = [headV viewWithTag:111];
    [view removeFromSuperview];
}
- (void)myinfoClick{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if ([islogin isEqualToString:@"1"]) {
    MyinfoController *myinfoVC =[[MyinfoController alloc] init];
    myinfoVC.hidesBottomBarWhenPushed = YES;
    myinfoVC.infoDic = [[NSMutableDictionary alloc] initWithDictionary:self.dic];
    [self.navigationController pushViewController:myinfoVC animated:YES];
    }
    else{
        [WCAlertView showAlertWithTitle:nil message:@"未登录,请前往登录" customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
                [self turnToLogin];
            }
        } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    }
}
- (UIView *)createTheHeaderView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    UIView *headerView;
    if (self.basicVC) {
        headerView = [LVTools headerViewWithbackgroudcolor: [UIImage imageNamed:@"backGround"] backBtn:nil settingBtn:nil beginTag:2600 islogin:islogin isHide:YES];
    } else {
        UIImage *image = [UIImage imageNamed:@"back"];
        headerView = [LVTools headerViewWithbackgroudcolor: [UIImage imageNamed:@"backGround"] backBtn:image settingBtn:nil beginTag:2600 islogin:islogin isHide:YES];
        UIButton *backbtn = (UIButton *)[headerView viewWithTag:2601];
        [backbtn addTarget:self action:@selector(backaction) forControlEvents:UIControlEventTouchUpInside];
    }
    headerView.tag = 2600;
    headerView.userInteractionEnabled = YES;
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myinfoClick)]];
    
    UIButton *name = (UIButton *)[headerView viewWithTag:2604];
    [name addTarget:self action:@selector(turnToLogin) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *img = (UIButton *)[headerView viewWithTag:2603];
    [img addTarget:self action:@selector(headImageClick) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:headerView];
    
    UIView *tBtnV = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.bottom, BOUNDS.size.width, 50.0f)];
    tBtnV.backgroundColor = [UIColor whiteColor];
    tBtnV.userInteractionEnabled = YES;
    NSArray *arr = @[@"tbtn1",@"tbtn3",@"tbtn4",@"fs"];
    NSArray *strarr = @[@"我的关注",@"我的收藏",@"我的评论",@"粉丝"];
    for (int i=0; i<arr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*4*LEFTX+3*LEFTX, mygap, LEFTX, LEFTX)];
        [btn setImage:[UIImage imageNamed:[arr objectAtIndex:i]] forState:UIControlStateNormal];
        btn.contentMode = UIViewContentModeCenter;
        btn.tag = 51+i;
        [btn addTarget:self action:@selector(bOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [tBtnV addSubview:btn];
        UIButton *lab = [[UIButton alloc] initWithFrame:CGRectMake(btn.left-20.0, btn.bottom+mygap, LEFTX+40.0f, 20.0f)];
        lab.titleLabel.font = Content_lbfont;
        [lab setTitle:[strarr objectAtIndex:i] forState:UIControlStateNormal];
        [lab setTitleColor:[UIColor colorWithRed:0.424 green:0.424 blue:0.424 alpha:1.00] forState:UIControlStateNormal];
        [lab addTarget:self action:@selector(bOnClick:) forControlEvents:UIControlEventTouchUpInside];
        lab.tag = 61+i;
        [tBtnV addSubview:lab];
        if (i==2) {
            [btn addSubview:comentStatus];
        }
        if (i==3) {
            [btn addSubview:fansStatus];
        }
    }
    [v addSubview:tBtnV];
    v.frame = CGRectMake(0, 0, BOUNDS.size.width, tBtnV.bottom+mygap*2);
    return v;
}
- (void)bOnClick:(UIButton*)btn{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
    [WCAlertView showAlertWithTitle:nil message:@"未登录,请前往登录" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
            [self turnToLogin];
        }
    } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    }
    else{
    if(btn.tag == 51||btn.tag == 61){
        ListViewController *listVC =[[ListViewController alloc] init];
        listVC.title = @"我的关注";
        listVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listVC animated:YES];
    }
    else if(btn.tag == 52||btn.tag == 62){
        ListViewController *listVC =[[ListViewController alloc] init];
        listVC.title = @"我的收藏";
        listVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listVC animated:YES];
    }
    else if (btn.tag == 53||btn.tag == 63){
        //我的评论
        AboutmeController *aboutVC = [[AboutmeController alloc] init];
        aboutVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
    else{
        ListViewController *listVC =[[ListViewController alloc] init];
        listVC.title = @"我的粉丝";
        listVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listVC animated:YES];
    }
    }
}
- (void)backaction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)headImageClick
{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if ([islogin isEqualToString:@"1"]) {
        UIButton *img = (UIButton *)[self.view viewWithTag:2603];
        if (bigImageview == nil) {
            bigImageview=[[ZHClickBigImageView alloc]initWithUserHeadImg:img.currentBackgroundImage];
            //添加事件
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHeadImg:)];
            [bigImageview addGestureRecognizer:tap];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveHeadImg:)];
            longPress.minimumPressDuration = 0.5;
            [bigImageview addGestureRecognizer:longPress];
        }
        [bigImageview.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[kUserDefault objectForKey:KUserIcon]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        [self.view addSubview:bigImageview];
    }
}
- (void)hideHeadImg:(id)sender{
    [bigImageview removeFromSuperview];
}

- (void)saveHeadImg:(UILongPressGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state ==UIGestureRecognizerStateBegan) {
        UIActionSheet *act = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存头像", nil];
        act.tag = 200;
        AppDelegate *ap =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [act showInView:ap.window];
    }
    else if (gestureRecognizer.state ==UIGestureRecognizerStateChanged) {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //保存
    UIButton *img = (UIButton *)[self.view viewWithTag:2603];
    if (buttonIndex == 0) {
        [LVTools saveImageToPhotos:img.currentBackgroundImage WithTarget:self AndMothod:@selector(image:didFinishSavingWithError:contextInfo:)];
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    
    NSString *msg = nil ;
    
    if(error != NULL){
        
        msg = @"保存图片失败" ;
        
    }else{
        
        msg = @"保存图片成功" ;
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                          
                                                    message:msg
                          
                                                   delegate:self
                          
                                          cancelButtonTitle:@"确定"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
}

- (void)turnToLogin
{
    //进入登陆界面
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];

    }
    else{
        //个人信息加载失败重新加载数据
        //[self requestData];
        [self loadDataBycache];
    }
}

- (void)settingclick
{
}

#pragma mark -- tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self returnRowsFromSection:section];
}

- (NSInteger)returnRowsFromSection:(NSInteger)sect
{
    return [_preArray[sect] count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
        //创建cell内容
    CGFloat cellHeight = cell.bounds.size.height;
    if (cell.contentView.subviews.count==0) {
        UIImageView *cellImg = [[UIImageView alloc] initWithFrame:CGRectMake(cellHeight/4, cellHeight/5, cellHeight*3/5, cellHeight*3/5)];
        cellImg.image = [UIImage imageNamed:_imageArray[indexPath.section][indexPath.row]];
        [cell.contentView addSubview:cellImg];
        
        UILabel *cellLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cellImg.frame)+cellHeight/4, cellHeight/4, 150, cellHeight/2)];
        cellLab.font = [UIFont systemFontOfSize:14];
        cellLab.text = _preArray[indexPath.section][indexPath.row];
        [cell.contentView addSubview:cellLab];
    }

    
    //(时光机和消息中心额外的视图要进行判断)，同时需要注册通知进行判断消息是否读完
    if (indexPath.section == 2 && indexPath.row == 0) {
        //消息中心
        if (countlab.superview==nil) {
            [cell addSubview:countlab];
        }
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        //聊天
        if (countlab1.superview==nil) {
            [cell addSubview:countlab1];
        }
    }

    if (indexPath.section == 1 && indexPath.row == 1) {
        //赛事
        if (orderNumLb.superview==nil) {
            [cell addSubview:orderNumLb];
        }
    }
    if (indexPath.section==3&&indexPath.row==0) {
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        if([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]){
            if ([[LVTools mToString:[kUserDefault valueForKey:KUserMobile]] length]==11) {
                //cell.detailTextLabel.text = @"已绑定";
            }
            else{
               // cell.detailTextLabel.text = @"未绑定";
            }
        }
        else{
            //cell.detailTextLabel.text = @"未绑定";
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark -- tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 10;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if ((![islogin isEqualToString:@"1"])&&(!(indexPath.section==3&&indexPath.row==0))) {
        //提示用户登陆

     [WCAlertView showAlertWithTitle:nil message:@"未登录,请前往登录" customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
                [self turnToLogin];
            }
        } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];

    } else {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                    //个人资料
                {
//                    WPCMyOwnPersonalInfoVC *vc = [[WPCMyOwnPersonalInfoVC alloc] init];
//                    vc.dict =[[NSMutableDictionary alloc] initWithDictionary: self.dic];
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
                    MySchoolInfoController *vc = [[MySchoolInfoController alloc] init];
                    //vc.dict =[[NSMutableDictionary alloc] initWithDictionary: self.dic];
                    vc.infoDic = self.dic;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];

                }
                    break;
                default:
                    break;
            }
        } else if (indexPath.section == 1) {
            switch (indexPath.row) {
                case 0:
                {
                    //聊天
                    WPCChatHomePageVC *vc = [[WPCChatHomePageVC alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2:
                {
                    //我的约战
                    ZHSelfSportController *appointVC = [[ZHSelfSportController alloc] init];
                    appointVC.type = 0;
                    appointVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:appointVC animated:YES];
                }
                    break;
                case 1:
                {
                    //我的赛事
//                    ZHSelfSportController *sportVC = [[ZHSelfSportController alloc] init];
//                    sportVC.type = 1;
//                    sportVC.title = @"我的赛事";
//                    sportVC.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:sportVC animated:YES];
                    ListViewController *listVC =[[ListViewController alloc] init];
                    listVC.title = @"我的赛事";
                    listVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:listVC animated:YES];
                }
                    break;
                default:
                    break;
            }
        } else if (indexPath.section == 2) {
            switch (indexPath.row) {
                case 0:
                    //消息中心
                {
//                    WPCMyOwnMsgCenterVC *vc = [[WPCMyOwnMsgCenterVC alloc] init];
//                    vc.title = @"消息中心";
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
                    MessageController *vc= [[MessageController alloc] init];
                    vc.title = @"消息中心";
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:
                {
                    //订单管理
                    ZHSelfOrderController *orderVC = [[ZHSelfOrderController alloc] init];
                    orderVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:orderVC animated:YES];
                }
                    break;
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case 1:
                    //更改绑定
                {
                    WPCChangePackageVC *vc = [[WPCChangePackageVC alloc] init];
                    vc.chuanBlock = ^(NSArray *arr){
                        [_myOwnTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    };
                    vc.title = @"绑定手机";
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 0:
                    //设置
                {
                    SelfSetZhViewController *vc = [[SelfSetZhViewController alloc] init];
                    vc.title = @"设置";
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 601) {
//        if (buttonIndex == 0) {
//            [self showHudInView:self.view hint:@"正在退出..."];
//            [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
//                [self hideHud];
//                if (!error) {
//                    [kUserDefault setValue:@"0" forKey:kUserLogin];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
//                    [kUserDefault setObject:nil forKey:kUserId];
//                    [kUserDefault setValue:@"" forKey:kUserPassword];
//                    [kUserDefault setValue:@"" forKey:kUserName];
//                    [kUserDefault setValue:@"" forKey:KUserMobile];
//                    [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
//                    }];
//                    [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
//                    }];
//                    [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToSina  completion:^(UMSocialResponseEntity *response){
//                    }];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
//                    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
//                    //present登录界面 或者只是刷新界面的内容
//                }
//                else{
//                    [self showHint:@"退出失败"];
//                    NSLog(@"退出失败原因:%@",error.description);
//                }
//            } onQueue:nil];
//        }
//    }
//}

//签到cell点击事件(客服点击也是这个事件，flag标志为，签到为1，客服为2),点击灰色空白处让视图消失
- (void)bounceTheSignInView:(int)index
{
    //灰色背景视图tag == 2680，弹出提示视图tag == 2681
    UIView *grayView = [[UIView alloc] initWithFrame:self.view.frame];
    grayView.alpha = 0.5;
    grayView.tag = 2680;
    grayView.backgroundColor = UIColorFromRGB(121, 121, 121);
    [self.view addSubview:grayView];
    
    UITapGestureRecognizer *fadeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeAway)];
    [grayView addGestureRecognizer:fadeTap];
    
    UIView *fakeAlert = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH-80, (UISCREENWIDTH-40)/2)];
    fakeAlert.center = CGPointMake(UISCREENWIDTH/2, UISCREENHEIGHT/2);
    fakeAlert.tag = 2681;
    fakeAlert.backgroundColor = UIColorFromRGB(234, 234, 234);
    [self.view addSubview:fakeAlert];
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH-80, 18)];
    lab1.center = CGPointMake((UISCREENWIDTH-80)/2, 35);
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.text = @"每日签到，+1积分";
    [fakeAlert addSubview:lab1];
    
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH-80, 30)];
    lab2.center = CGPointMake((UISCREENWIDTH-80)/2, 80);
    lab2.textColor = UIColorFromRGB(170, 170, 170);
    lab2.numberOfLines = 2;
    lab2.font = [UIFont systemFontOfSize:13];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.text = @"满200积分会得到由约战123提供的精美礼品一份";
    [fakeAlert addSubview:lab2];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 70, 30);
    btn.center = CGPointMake((UISCREENWIDTH-80)/2, (UISCREENWIDTH-40)/2-40);
    btn.titleLabel.textColor = [UIColor whiteColor];
    if (index == 1) {
        //签到
        lab1.text = @"每日签到，+1积分";
        lab2.text = @"满200积分会得到由约战123提供的精美礼品一份";
        if (isSignIn) {
            btn.backgroundColor = UIColorFromRGB(193, 193, 193);
            [btn setTitle:@"已签到" forState:UIControlStateNormal];
        } else {
            btn.backgroundColor = UIColorFromRGB(59, 141, 212);
            [btn setTitle:@"签到" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(signinClick) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        //客服
        lab1.text = @"客服电话";
        lab2.text = @"400-6643255";
        lab2.font = [UIFont systemFontOfSize:16];
        lab2.textColor = [UIColor blackColor];
        [btn setTitle:@"拨打" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(phonecallClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [fakeAlert addSubview:btn];
}

- (void)fadeAway
{
    UIView *view1 = (UIView *)[self.view viewWithTag:2680];
    UIView *view2 = (UIView *)[self.view viewWithTag:2681];
    [view1 removeFromSuperview];
    [view2 removeFromSuperview];
    view1 = nil;
    view2 = nil;
}

- (void)phonecallClick
{
    
}

- (void)signinClick
{
    //todo
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
