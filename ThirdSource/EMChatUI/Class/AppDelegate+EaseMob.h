//
//  AppDelegate+EaseMob.h
//  EasMobSample
//
//  Created by dujiepeng on 12/5/14.
//  Copyright (c) 2014 dujiepeng. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD+Add.h"
@interface AppDelegate (EaseMob)

@property(nonatomic, strong)NSDictionary * mylaunchOptions;


- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions ;


- (void)showNotificationWithMessage:(EMMessage *)message;
//由信鸽推送的消息
- (void)showNotificationWithDict:(NSDictionary *)message;
@end
