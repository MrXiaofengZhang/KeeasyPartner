//
//  ZHReverseCode.h
//  yuezhan123
//
//  Created by zhoujin on 15/4/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"
typedef void(^codeReverseBlock)(NSString *string);
typedef  void(^codeForwardBlock)(NSDictionary *dic);
@interface ZHReverseCode : NSObject<BMKGeoCodeSearchDelegate>
@property(nonatomic,strong)void(^codeReverse)(NSString *string);
//正向
@property(nonatomic,strong)void(^codeForward)(NSDictionary *dic);
//反向地理编码
-(void)shareReverseCodeWithLongitude:(NSString *)longitude WithLatitude:(NSString *)latitude With:(codeReverseBlock)block;
//正向地理编码
//cityName 勿写“市”
-(void)shareForwardCodeWithCityName:(NSString *)cityname AndAddress:(NSString *)address With:(codeForwardBlock)block;
@end
