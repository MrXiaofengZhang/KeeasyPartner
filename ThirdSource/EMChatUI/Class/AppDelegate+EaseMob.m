//
//  AppDelegate+EaseMob.m
//  EasMobSample
//
//  Created by dujiepeng on 12/5/14.
//  Copyright (c) 2014 dujiepeng. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "NearByModel.h"
#import "ApplyViewController.h"
#import "LVMainViewController.h"
#import "XGPush.h"//信鸽
#import "XGSetting.h"//信鸽
/**
 *  本类中做了EaseMob初始化和推送等操作
 */
@interface AppDelegate ()

@end

@implementation AppDelegate (EaseMob)
@dynamic mylaunchOptions;


- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if (launchOptions) {
        
        NSDictionary*userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

        if(userInfo)
        {
            [self didReiveceRemoteNotificatisonApplication:application WithLanption:userInfo];
        }
    }
    //当前环信后台状态为链接
    _connectionState = eEMConnectionConnected;
    //注册远程通知初始化
    [self registerRemoteNotification];
    //配置【环信的远程通知】
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"xd_dev";
#else
    apnsCertName = @"xd_dis";
#endif
    //yizhichaoyue#xiaodong
    NSLog(@"%@",apnsCertName);
    //easemob-demo#chatdemoui
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"yizhichaoyue#xiaodongup"
                                       apnsCertName:apnsCertName
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:NO]}];
    
    // 登录成功后，自动去取好友列表
    // SDK获取结束后，会回调
    // - (void)didFetchedBuddyList:(NSArray *)buddyList error:(EMError *)error方法。
//    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    // 注册环信监听
    [self registerEaseMobNotification];
    [[EaseMob sharedInstance] application:application
            didFinishLaunchingWithOptions:launchOptions];
    //注册监听app生命周期的通知
    [self setupNotifiers];
    //登陆环信
    [self loginEM];
}
- (void)loginEM{
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"])
    {
        NSString * username = [NSString stringWithFormat:@"%@",[kUserDefault objectForKey:kUserId]];
        NSString * password = [NSString stringWithFormat:@"%@",@"123456"];
        
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error)
         {
             
             NSLog(@"\n登陆的信息：%@\n登陆的错误：%@ 未读消息个数%ld",loginInfo,error, (unsigned long)[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]);
             //刷新消息个数
             [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
             if (!error && loginInfo) {
                 
                 [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                 [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                 
                 //第一次进来获得消息个数
              
             }else{
                 NSLog(@"%@",error.description);
             }
           
             
         } onQueue:nil];
    }
}


// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - notifiers
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
    
    

    
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //注册设备
    //[[XGSetting getInstance] setChannel:@"appstore"];
    //[[XGSetting getInstance] setGameServer:@"巨神峰"];
    
    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
    NSLog(@"deviceTokenStr  is %@",deviceTokenStr);
    [kUserDefault setObject:deviceTokenStr forKey:KxgToken];
    [kUserDefault synchronize];

    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

// 注册推送
- (void)registerRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;

    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}



#pragma mark - IChatManagerDelegate
// 开始自动登录回调
-(void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.errorAutoLogin", @"Automatic logon failure") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
    else{
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.beginAutoLogin", @"Start automatic login...") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    }
    
    [alertView show];
}

// 结束自动登录回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.errorAutoLogin", @"Automatic logon failure") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
    else{
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.endAutoLogin", @"End automatic login...") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
        //设置badge
        [self.mainController setMessageCount];
    }
    
    [alertView show];
}

// 好友申请回调
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    NSLog(@"%@ %@",username,message);
    if (!username) {
        return;
    }
    if (!message) {
        message = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), username];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":username, @"username":username, @"applyMessage":message, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleFriend]}];
    [[ApplyViewController shareController] addNewApply:dic];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewApply object:nil];
}

// 离开群组回调
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSString *tmpStr = group.groupSubject;
    NSString *str;
    if (!tmpStr || tmpStr.length == 0) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *obj in groupArray) {
            if ([obj.groupId isEqualToString:group.groupId]) {
                tmpStr = obj.groupSubject;
                break;
            }
        }
    }
    
    if (reason == eGroupLeaveReason_BeRemoved) {
        str = [NSString stringWithFormat:NSLocalizedString(@"group.beKicked", @"you have been kicked out from the group of \'%@\'"), tmpStr];
    }
    if (str.length > 0) {
       
    }
}

// 申请加入群组被拒绝回调
- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason
                                       error:(EMError *)error{
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), groupname];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:reason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!groupId || !username) {
        return;
    }
    
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), username, groupname];
    }
    else{
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), username, groupname, reason];
    }
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.sendApplyFail", @"send application failure:%@\nreason：%@"), reason, error.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":groupname, @"groupId":groupId, @"username":username, @"groupname":groupname, @"applyMessage":reason, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleJoinGroup]}];
        [[ApplyViewController shareController] addNewApply:dic];
//        if (self.mainController) {
//            [self.mainController setupUntreatedApplyCount];
//        }
    }
}

// 已经同意并且加入群组后的回调
- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error
{
    if(error)
    {
        return;
    }
    
    NSString *groupTag = group.groupSubject;
    if ([groupTag length] == 0) {
        groupTag = group.groupId;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed and joined the group of \'%@\'"), groupTag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}


// 绑定deviceToken回调
- (void)didBindDeviceWithError:(EMError *)error
{
    if (error) {
       NSLocalizedString(@"apns.failToBindDeviceToken", @"Fail to bind device token");
    }
}

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
//    [self.mainController networkChanged:connectionState];
}

// 打印收到的apns信息
-(void)didReiveceRemoteNotificatisonApplication:(UIApplication *)application WithLanption:(NSDictionary *)userInfo{
    

    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送内容"
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
   
    UILocalNotification * notification = [[UILocalNotification alloc] init];
     NSString *title = userInfo[@"f"];
    notification.alertBody = [NSString stringWithFormat:@"%@ :%@", title, userInfo[@"m"]];
    notification.alertBody =[[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    [self application:application didReceiveLocalNotification:notification];
    

}
#pragma  mark --发送本地推送
- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
    
    NSLog(@"%@",message);
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedStringFromTable(@"message.location", @"Localizable", @"");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.video", @"");
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    NearByModel *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData: [LVTools mGetLocalDataByKey:[NSString stringWithFormat:@"xd%@",message.groupSenderName]]];
                    NSString *userName =@"陌生人";
                    if (userInfo) {
                        userName = [LVTools mToString:userInfo.nickName];
                    }
                    title = [NSString stringWithFormat:@"%@(%@)", userName, group.groupSubject];
                    notification.alertBody = [NSString stringWithFormat:@"%@ :%@",title, messageStr];
                    break;
                }
            }
        }
        else{
        //用户昵称
        NearByModel *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData: [LVTools mGetLocalDataByKey:[NSString stringWithFormat:@"xd%@",title]]];
       // notification.alertBody = [NSString stringWithFormat:@"%@(%@) :%@",userInfo.nickName, title, messageStr];//带uid
            if(userInfo){
                notification.alertBody = [NSString stringWithFormat:@"%@ :%@",userInfo.nickName, messageStr];//不带uid
            }
            else{
                notification.alertBody = [NSString stringWithFormat:@"%@ :%@",@"陌生人", messageStr];//可能是陌生人
            }
        }
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
// 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    notification.alertBody = [[NSString alloc] initWithFormat:@"%@", notification.alertBody];
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber += 1;
}
//由信鸽推送的消息
- (void)showNotificationWithDict:(NSDictionary *)message{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.alertBody = [[NSString alloc] initWithFormat:@"%@", notification.alertBody];
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber += 1;

}
- (void)didFinishedReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages{
    NSLog(@"++++++");
}
@end
