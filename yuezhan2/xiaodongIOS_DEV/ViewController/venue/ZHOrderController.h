//
//  ZHOrderController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/7.
//  Copyright (c) 2015年 LV. All rights reserved.
//订单详情

#import "BaseViewController.h"
@class ZHTaocanModel;
@class ZHVenueModel;
@interface ZHOrderController : BaseViewController
@property (nonatomic,strong) ZHTaocanModel *taocanModel;
//@property (nonatomic,strong) ZHVenueModel *vennueModel;
//@property (nonatomic,strong) NSString *phone;
//@property (nonatomic,strong) NSString *lat;
//@property (nonatomic,strong) NSString *lon;
//@property (nonatomic,strong) UIImage *venueImg;
//@property (nonatomic,assign) OrderStatus orderstatus;//订单状态
@property (nonatomic,strong) NSString *idString;

@end
