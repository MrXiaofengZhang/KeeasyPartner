//
//  AppDelegate.h
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "BMapKit.h"
#import "ASIDownloadCache.h"
@class LVMainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKLocationServiceDelegate,IChatManagerDelegate,WXApiDelegate>
{
    Reachability * hostReach;
    EMConnectionState _connectionState;
    BaseResp *baseResp;
}
@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL AppisNetAvailable;//网络是否可用
@property (strong, nonatomic) BMKLocationService* locatonService;
@property (strong, nonatomic) BMKMapManager * locationManager;
//@property (strong, nonatomic) ASIDownloadCache *myCache;
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property (strong, nonatomic) UILabel *myAlertView;

//附近的人和战队成员测试用的model array
@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) NSDictionary *citiesDictionary;
@property (nonatomic, strong) LVMainViewController *mainController;
@end

