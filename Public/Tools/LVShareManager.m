//
//  LVShareManager.m
//  yuezhan123
//
//  Created by LV on 15/4/6.
//  Copyright (c) 2015年 LV. All rights reserved.
//

/*
    【分享】
 */

#import "LVShareManager.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialDataService.h"

@implementation LVShareManager

//友盟分享 api
+ (void)shareText:(NSString *)shareTextString Targert:(id)tagert{
    
    [UMSocialSnsService presentSnsIconSheetView:tagert
                                         appKey:kUMAppkey
                                      shareText:[NSString stringWithFormat:@"%@",shareTextString]
                                     shareImage:[UIImage imageNamed:@"appImg"]
                                shareToSnsNames:@[UMShareToSms,
                                                  UMShareToWechatSession,
                                                  UMShareToWechatTimeline,
                                                  UMShareToQQ,UMShareToSina,
                                                  UMShareToTencent,UMShareToQzone,UMShareToEmail]
                                       delegate:tagert];
    
}
+ (void)shareText:(NSString *)shareTextString Targert:(id)tagert AndImg:(UIImage*)img{
    
    [UMSocialSnsService presentSnsIconSheetView:tagert
                                         appKey:kUMAppkey
                                      shareText:[NSString stringWithFormat:@"%@",shareTextString]
                                     shareImage:img
                                shareToSnsNames:@[UMShareToSms,
                                                  UMShareToWechatSession,
                                                  UMShareToWechatTimeline,
                                                  UMShareToQQ,UMShareToSina,
                                                  UMShareToTencent,UMShareToQzone,UMShareToEmail]
                                       delegate:tagert];
    
}

+ (void)QQZoneClickTarget:(id)taget{
    
}
@end
