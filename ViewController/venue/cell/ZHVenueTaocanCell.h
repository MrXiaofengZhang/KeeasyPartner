//
//  ZHVenueTaocanCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHTaocanModel;
@interface ZHVenueTaocanCell : UITableViewCell
@property (nonatomic,strong) UILabel *titleLb;
@property (nonatomic,strong) UILabel *redLb;//优惠价
@property (nonatomic,strong) UILabel *yuanjiaLb;//原价
@property (nonatomic,strong) UIButton *yishouLb;//已售
- (void)configTaocanModel:(ZHTaocanModel*)model;
@end
