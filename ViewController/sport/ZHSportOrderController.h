//
//  ZHSportOrderController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/8.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
#import "GetMatchListModel.h"
@interface ZHSportOrderController : BaseViewController

@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) GetMatchListModel *detalModel;//区分不同的model，可能有赛事的model，场馆的model
@property (nonatomic, strong) NSString *isVerify;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderNum;
@property (nonatomic, strong) NSString *orderName;
@property (nonatomic, strong) NSString *orderCost;

@end
