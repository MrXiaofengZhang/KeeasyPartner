//
//  LVShareManager.h
//  yuezhan123
//
//  Created by LV on 15/4/6.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>
//@class UMSocialAccountEntity;
@interface LVShareManager : NSObject
//qq第三方登陆
+ (void)QQZoneClickTarget:(id)taget;//网页版
//友盟分享
+ (void)shareText:(NSString *)shareTextString Targert:(id)tagert;
//分享带图片
+ (void)shareText:(NSString *)shareTextString Targert:(id)tagert AndImg:(UIImage*)img;
@end
