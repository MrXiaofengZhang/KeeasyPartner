//
//  ZHVenueTaocanController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@class ZHTaocanModel;
@class ZHVenueModel;
@interface ZHVenueTaocanController : BaseViewController
@property (nonatomic,strong) ZHTaocanModel *taocanModel;
@property (nonatomic,strong) ZHVenueModel *vennueModel;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *lat;
@property (nonatomic,strong) NSString *lon;
@property (nonatomic,strong) UIImage *venueImg;
@property (nonatomic,strong) NSDictionary *venuesInfoDic;
@end

