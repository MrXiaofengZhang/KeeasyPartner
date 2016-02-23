//
//  ZHVenueOrderCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@interface ZHVenueOrderCell : SWTableViewCell
@property (nonatomic,strong) UILabel *nameLb;//场馆名字
@property (nonatomic,strong) UIView *breakLine;
@property (nonatomic,strong) UIImageView *mImageView;//场馆图片
@property (nonatomic,strong) UILabel *dizhiLb;//具体地址
@property (nonatomic,strong) UILabel *isfreeLb;//费用
@property (nonatomic,strong) UILabel *isYudingLb;//订单状态类型
@property (nonatomic,strong) UIImageView *invalidImg;
@property (nonatomic,strong) UIButton *btn;
- (void)configVenueModel:(NSDictionary *)dict;

@end
