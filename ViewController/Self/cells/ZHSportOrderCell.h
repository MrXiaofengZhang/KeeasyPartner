//
//  ZHSportOrderCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@class GetMatchListModel;
@interface ZHSportOrderCell : SWTableViewCell
@property (nonatomic,strong) UIImageView *SportImg;
@property (nonatomic,strong) UIImageView *sportStatus;
@property (nonatomic,strong) UILabel *moneyLb;
@property (nonatomic,strong) UILabel *countLb;
@property (nonatomic,strong) UILabel *accountLb;
@property (nonatomic,strong) UILabel *stateLb;//订单状态
@property (nonatomic,strong) UIButton *payBtn;
@property (nonatomic,assign) BOOL duringPay;//支付时间内
@property (nonatomic,assign) BOOL matchHasEnd;//比赛是否结束

- (void)configMatchModel:(GetMatchListModel*)model;
- (void)configMatchDic:(NSDictionary*)dic;
@end
