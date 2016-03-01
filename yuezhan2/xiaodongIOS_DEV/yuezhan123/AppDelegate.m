//
//  AppDelegate.m
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "AppDelegate.h"
#import "Utility.h"    //加密
#import "XGPush.h"//信鸽
#import "XGSetting.h"//信鸽
#import "UMSocialConfig.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "LoginLoginZhViewController.h"
#import "LVMainViewController.h"
#import "AppDelegate+EaseMob.h"
#import "MobClick.h"
#import "WXApi.h"
#import "payRequsestHandler.h"
#import "ApplyViewController.h"
#define MKKEY @"qGrc6jMYNRi7I6PluB82kT2m"




void UncaughtExceptionHandler(NSException *exception) {
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    
    /**
     *  把异常崩溃信息发送至开发者邮件
     */
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:751714024@qq.com"];
    [mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
    [mailUrl appendFormat:@"&body=%@", content];
    // 打开地址
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
}
@interface AppDelegate ()<EMChatManagerLoginDelegate,EMChatManagerChatDelegate,UIAlertViewDelegate>
@end

#define _IPHONE80_ 80000

@implementation AppDelegate


-(void) onResp:(BaseResp*)resp
{
//    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    //NSString *strTitle;
    baseResp = resp;
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
//        strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    }
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
//        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
//                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
//                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
    }
    NSString *distingush;
    if (baseResp.errCode == WXSuccess) {
        distingush = @"0";//成功
        NSDictionary *dic = @{@"code":distingush};
        [[NSNotificationCenter defaultCenter] postNotificationName:WXPAY_BACK_NOTIFICATION object:nil userInfo:dic];
    } else if (baseResp.errCode == WXErrCodeCommon) {
//        distingush = @"-1";
        [WCAlertView showAlertWithTitle:nil message:@"支付失败" customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    } else {
//        distingush = @"-2";
        [WCAlertView showAlertWithTitle:nil message:@"支付取消" customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];

    }
}

- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";

    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}
- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
}
- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    //[MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    //[MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:kUMAppkey reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
          [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //[MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //NSLog(@"------------%@",NSHomeDirectory());
    //判断是否通过点击推送进入应用
    NSDictionary* remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        self.isLaunchedByNotification = YES;
    }
    else{
        self.isLaunchedByNotification = NO;
    }
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    [LVTools getIphoneInfo];
    [self judgeFirst];

    [self umengTrack];
    [self XGPushDefault:launchOptions];
    [self UMShareDefault];
    [self setNavgationBar];
    [self reachabitlity];
    [self getLoaction];
   // NSLog(@"%@", [[EaseMob sharedInstance] sdkVersion]);
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    //NSLog(@"环信sdk%@", [[EaseMob sharedInstance] sdkVersion]);
    [WXApi registerApp:APP_ID withDescription:@"schoolsport"];
    return YES;
}
- (UILabel*)myAlertView{
    if (_myAlertView == nil) {
        _myAlertView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 20)];
        _myAlertView.backgroundColor = [UIColor blackColor];
        _myAlertView.font = Content_lbfont;
        _myAlertView.textColor = [UIColor whiteColor];
        _myAlertView.alpha = 0;
    }
    return _myAlertView;
}
#pragma mark --推送初始化
- (void)XGPushDefault:(NSDictionary *)launchOptions{
    [XGPush startApp:2200163208 appKey:@"IAN29BS2E77D"];
    NSLog(@"------%@",[LVTools mToString:[kUserDefault objectForKey:KUserMobile]]);
    if([LVTools mToString:[kUserDefault objectForKey:KUserMobile]].length==11){
    [XGPush setAccount:[LVTools mToString:[kUserDefault objectForKey:KUserMobile]]];
    }
    else{
    }
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
    
    //推送反馈回调版本示例
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]];
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_

//注册UserNotification成功的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //用户已经允许接收以下类型的推送
    //UIUserNotificationType allowedTypes = [notificationSettings types];
     [application registerForRemoteNotifications];
}

//按钮点击事件回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]){
        NSLog(@"ACCEPT_IDENTIFIER is clicked");
    }
    completionHandler();
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //环信配置文件：
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    }
//iOS7可以使用 此方法的调用时，MainViewController已经被初始化，所以我们已经可以在MainViewController注册推送消息的监听，用于展示对应的视图
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentView" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVEREMOTENOTIFICATION object:nil];

}
//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    //环信配置文件
    [[EaseMob sharedInstance] application:app didFailToRegisterForRemoteNotificationsWithError:err];
}
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //更新未读消息个数
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
    //[XGPush localNotificationAtFrontEnd:notification userInfoKey:@"clockID" userInfoValue:@"myid"];
    NSLog(@"message=%@",userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVEREMOTENOTIFICATION object:nil];
    //当收到推送时，app作相应提示
#if !TARGET_IPHONE_SIMULATOR
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        [self showNotificationWithDict:userInfo];
        
    }else {
        [self playSoundAndVibration];
        //显示推送信息
//        [WCAlertView showAlertWithTitle:@"新消息" message:userInfo[@"aps"][@"alert"] customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
//            //
//            if(buttonIndex==[alertView cancelButtonIndex]){
//                
//            }
//            else{
//                //去消息中心或者聊天中心
//                
//            }
//        } cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [self.mainController showHint:userInfo[@"aps"][@"alert"]];
        
    }
#endif

    NSString *type  =[LVTools mToString: [userInfo objectForKey:@"type"]];
    if ([type isEqualToString:@"1"]) {
        //加好友推送
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        self.myAlertView.text = [NSString stringWithFormat:@"%@已经添加您为好友了,进入好友列表开始聊天吧",[userInfo objectForKey:@"username"]];
        [[UIApplication sharedApplication].keyWindow addSubview:self.myAlertView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.myAlertView];
        [UIView animateWithDuration:0.3 animations:^{
            //
            self.myAlertView.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                NSLog(@"动画完成了");
                [UIView animateKeyframesWithDuration:0.3 delay:2.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                    self.myAlertView.alpha = 0;
                    [self.myAlertView removeFromSuperview];
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
                    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
                } completion:^(BOOL finished) {
                    //
                }];
            }
        }];
    }
    else if ([type isEqualToString:@"2"]){
        //发起约战
    }
    else if([type isEqualToString:@"3"]){
        //应战
    }
    else{
        //其他
    }
}
#pragma mark --友盟分享初始化[开始]====================================================//
- (void)UMShareDefault{
    //分享雨第三方登录
    [UMSocialData setAppKey:kUMAppkey];
    [UMSocialData openLog:NO];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToWechatTimeline,UMShareToWechatSession,UMShareToQzone]];
    //微信
    [UMSocialWechatHandler setWXAppId:APP_ID appSecret:APP_SECRET url:kDownLoadUrl];
    //QQ
    [UMSocialQQHandler setQQWithAppId:@"1104870693" appKey:@"HQzQ4C0LKo8JN3EH" url:kDownLoadUrl];
    [UMSocialQQHandler setSupportWebView:YES];
    //[UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。若在新浪后台设置我们的回调地址，“http://sns.whalecloud.com/sina2/callback”，这里可以传nil
    //新浪
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    if ([url.description hasPrefix:@"wxf55ed19d5d94f596://pay"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      NSLog(@"result = %@",resultDic);
                                                  }];
    }
    if ([url.host isEqualToString:@"platformapi"]) {
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation      
{
    NSLog(@"%@",url.description);
    if ([url.description hasPrefix:@"wxf55ed19d5d94f596://pay"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      NSLog(@"result = %@",resultDic);
                                                  }];
    }
    if ([url.host isEqualToString:@"platformapi"]) {
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    return  [UMSocialSnsService handleOpenURL:url];
}
#pragma  mark --友盟分享初始化[结束]====================================================//

#pragma  mark --判断是否初次启动程序
- (void)judgeFirst{
    if (!self.mainController) {
        self.mainController = [[LVMainViewController alloc] initWithNumber:0];
    }
    self.window.rootViewController = self.mainController;
}

#pragma  mark -- 开始定位
- (void)getLoaction{
  [self locationManager];
    _locatonService = [[BMKLocationService alloc] init];
    _locatonService.delegate=self;
   [BMKLocationService setLocationDistanceFilter:1000];
   [BMKLocationService setLocationDesiredAccuracy:10.0];
    [_locatonService startUserLocationService];
}
#pragma  mark --百度定位
- (BMKMapManager *)locationManager{
    if (!_locationManager)
    {
        _locationManager = [[BMKMapManager alloc] init];
        BOOL ret = [_locationManager start:MKKEY generalDelegate:nil];
        if (!ret) {
            [kUserDefault setValue:@"39.954225" forKey:kLocationLat];
            [kUserDefault setValue:@"116.426748" forKey:kLocationlng];
            [kUserDefault synchronize];
            NSLog(@"百度定位 start failed!");
        }
//        else{
//            NSLog(@"百度定位 start successed!");
//            [kUserDefault setValue:@"39.954225" forKey:kLocationLat];
//            [kUserDefault setValue:@"116.426748" forKey:kLocationlng];
//            [kUserDefault synchronize];
////            if(TARGET_IPHONE_SIMULATOR){
////                
////            }
////            else{
////                
////            }
//        }
    }
    return _locationManager;
}
#pragma mark-BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    CLLocationCoordinate2D  origionLoaction=userLocation.location.coordinate;
//    if ([[kUserDefault valueForKey:kLocationLat] length] > 0) {
//        
//    } else {
        [kUserDefault setValue:[NSString stringWithFormat:@"%f",origionLoaction.latitude] forKey:kLocationLat];
        [kUserDefault setValue:[NSString stringWithFormat:@"%f",origionLoaction.longitude] forKey:kLocationlng];
        [kUserDefault synchronize];
//        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE_NOTIFICATION object:userLocation.location];
//    }
    
}
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"定位失败");
//    [kUserDefault setValue:@"" forKey:kLocationlng];
//    [kUserDefault setValue:@"" forKey:kLocationLat];
//    [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE_NOTIFICATION object:nil];
}

- (void)reachabitlity{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: @"NetworkReachabilityChangedNotification"
                                               object: nil];
    
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
}

- (void)checkNetworkState{
    Reachability * wifi = [Reachability reachabilityForLocalWiFi];
    Reachability * connection = [Reachability reachabilityForInternetConnection];
    if ([wifi currentReachabilityStatus] != NotReachable) {
        NSLog(@"是wifi网络");
        self.AppisNetAvailable = YES;
    }else if ([connection currentReachabilityStatus] != NotReachable){
        NSLog(@"是2G/3G网");
        self.AppisNetAvailable = YES;
    }else{
        NSLog(@"没有网络");
        [self showErrorMsg:NotNetWork];
    }
}

- (void)reachabilityChanged:(NSNotification *)note{
    Reachability * curReach = [note object];
//    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (status == kNotReachable) {
        [self showErrorMsg:NotNetWork];
    }else{
        self.AppisNetAvailable = YES;
        //[LVTools getIphoneInfo];
    }
}
- (void)showErrorMsg:(NSString *)msg{
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.labelFont = [UIFont systemFontOfSize:15.0];
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)setNavgationBar{
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,/*[UIFont boldSystemFontOfSize:22],NSFontAttributeName,*/ nil];
    [[UINavigationBar appearance] setTitleTextAttributes:dic];
//    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    if (iOS7) { // 判断是否是IOS7
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"收到本地推送,%@",notification);
    NSLog(@"%@",notification.alertBody);
    //这里不做跳转处理,只刷新消息个数
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
    //跳转到聊天页面，
    //NSArray *array =[notification.alertBody componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"(:)"]];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NotificationChatView object:@{@"uid":[array objectAtIndex:1],@"userName":[array objectAtIndex:0]}];
    //[WCAlertView showAlertWithTitle:@"124" message:[array objectAtIndex:2] customizationBlock:nil completionBlock:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
}
#pragma mark --【账号异地登陆】
- (void)didLoginFromOtherDevice{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString * date = [formatter stringFromDate:[NSDate date]];
    NSString * msg = [NSString stringWithFormat:@"您的账号异地登录%@\n请重新登录",date];
    UIAlertView * aler = [[UIAlertView alloc] initWithTitle:@"提  示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    aler.tag = 1000;
    [aler show];
    //注销用户信息
    [kUserDefault setValue:nil forKey:kUserId];
    [kUserDefault setValue:@"" forKey:kUserPassword];
    [kUserDefault setValue:@"" forKey:kUserName];
    [kUserDefault setValue:@"" forKey:KUserMobile];
    [kUserDefault setValue:@"0" forKey:kUserLogin];
    [kUserDefault setValue:@"" forKey:KUserAcount];
    [kUserDefault setValue:nil forKey:[NSString stringWithFormat:@"xd%@",[kUserDefault objectForKey:kUserId]]];
    [kUserDefault synchronize];
    [XGPush setAccount:@"*"];
    [XGPush registerDeviceStr:[kUserDefault objectForKey:KxgToken]];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSTATECHANGE_NOTIFICATION object:@NO userInfo:nil];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginAtOtherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        //alertView.tag = 100;
        //[alertView show];
        if (!error) {
             [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
            //发通知刷新个人中新页面
        }
    } onQueue:nil];
    
   
//    UIViewController * vc = [self getCurrentVC];
//    [vc.tabBarController.navigationController popToViewController:self.window.rootViewController animated:YES];
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //跳到登录页
    if (alertView.tag == 1000) {
        [[ApplyViewController shareController] clear];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

//账号被删
- (void)didRemovedFromServer
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginUserRemoveFromServer", @"your account has been removed from the server side") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        alertView.tag = 101;
        [alertView show];
    } onQueue:nil];
}

//#pragma mark --获取当前的vc
//- (UIViewController *)getCurrentVC
//{
//    UIViewController *result = nil;
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    if (window.windowLevel != UIWindowLevelNormal)
//    {
//        NSArray *windows = [[UIApplication sharedApplication] windows];
//        for(UIWindow * tmpWin in windows)
//        {
//            if (tmpWin.windowLevel == UIWindowLevelNormal)
//            {
//                window = tmpWin;
//                break;
//            }
//        }
//    }
//    UIView *frontView = [[window subviews] objectAtIndex:0];
//    id nextResponder = [frontView nextResponder];
//    
//    if ([nextResponder isKindOfClass:[UIViewController class]])
//        result = nextResponder;
//    else
//        result = window.rootViewController;
//    
//    return result;
//}


#pragma mark --【收到（本地）推送】
- (void)didReceiveMessage:(EMMessage *)message{
    [self.mainController setMessageCount];
    //刷新消息个数
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:message.from];
    BOOL needShowNotification = YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }else {
            [self playSoundAndVibration];
        }
#endif
    }
}
static const CGFloat kDefaultPlaySoundInterval = 3.0;
#pragma mark --【铃声】
- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}
#pragma mark 生命周期
- (void)applicationWillEnterForeground:(UIApplication *)application{
    if ([LVTools mToString: [kUserDefault objectForKey:kToken]].length!=32) {
        [LVTools getIphoneInfo];
    }
}
-(void)applicationDidEnterBackground:(UIApplication *)application{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]];
//    [kUserDefault setValue:@"" forKey:kLocationLat];
//    [kUserDefault setValue:@"" forKey:kLocationlng];
//    [kUserDefault synchronize];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]];
    
}

- (void)applicationDidFinishLaunching:(UIApplication *)application{
    
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
}
- (void)applicationWillResignActive:(UIApplication *)application{
    
}
- (void)applicationWillTerminate:(UIApplication *)application{
    
}
@end
