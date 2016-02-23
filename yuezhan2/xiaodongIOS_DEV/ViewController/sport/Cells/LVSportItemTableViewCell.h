//
//  LVSportItemTableViewCell.h
//  yuezhan123
//
//  Created by apples on 15/3/20.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GetMatchListModel;

@interface LVSportItemTableViewCell : UITableViewCell

@property (strong, nonatomic)  UIView *bgView;

@property (strong, nonatomic)  UIButton *iconImgBtn;

@property (strong, nonatomic)  UILabel *titleLabel;

@property (strong, nonatomic)  UILabel *stateLabel;//时间

@property (strong, nonatomic)  UIImageView *sportImgView;

@property (strong ,nonatomic) UILabel *signedCount;//报名人数

@property (strong, nonatomic) UIButton *baomingBtn;//报名按钮

//校动UI控件
@property (strong, nonatomic) UILabel *sportNameLb;//比赛名称
@property (strong, nonatomic) UILabel *beginDateLb;//白赛开始时间
@property (strong, nonatomic) UIButton *statusLb;//比赛报名状态
@property (strong, nonatomic) UIImageView *sportImageView;//比赛海报
@property (strong, nonatomic) UIView *grayView;
@property (strong, nonatomic) UIImageView *sportTypeImgView;//比赛类型
@property (strong, nonatomic) UILabel *signedLb;//报名数
@property (strong, nonatomic) UILabel *zanLb;//点赞数
@property (strong, nonatomic) UILabel *commentLb;//评论数
@property (strong, nonatomic) UILabel *shareLb;//分享数
- (void)configMatchModel:(GetMatchListModel *)model;

@end
