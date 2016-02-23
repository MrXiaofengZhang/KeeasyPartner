//
//  WPCOrderPayVC.h
//  VenueTest
//
//  Created by admin on 15/6/25.
//  Copyright (c) 2015年 zhoujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ZHTaocanModel.h"
#import "ZHVenueModel.h"
@interface WPCOrderPayVC : BaseViewController

@property (nonatomic, strong) ZHTaocanModel *taocanModel;
@property (nonatomic, strong) ZHVenueModel *vennueModel;
@property (nonatomic, strong) NSMutableDictionary *dic;
@property (nonatomic, strong) NSString *ordertype;//(@"1代表的是场馆预定界面过来的";@"2"代表的是团购界面立即抢购过来的)
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderName;
@property (nonatomic, strong) NSString *orderCost;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *orderNum;//订单编号
@property (nonatomic, strong) NSString *totalCost;

@end
