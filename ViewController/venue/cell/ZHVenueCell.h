//
//  ZHVenueCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/24.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHVenueModel;
@interface ZHVenueCell : UITableViewCell
@property (nonatomic,strong) UILabel *nameLb;//场馆名字
@property (nonatomic,strong) UIImageView *locationImg;//距离图片
@property (nonatomic,strong) UILabel *locationLb;//距离
@property (nonatomic,strong) UIView *breakLine;
@property (nonatomic,strong) UIImageView *mImageView;//场馆图片
@property (nonatomic,strong) UILabel *dizhiLb;//具体地址
@property (nonatomic,strong) UILabel *isfreeLb;//费用
@property (nonatomic,strong) UILabel *isYudingLb;//预定类型
@property (nonatomic,strong) UIView *Pingfen;//评分
@property (nonatomic,strong) UIImageView *jianView;//推荐
- (void)configVenueModel:(ZHVenueModel*)venueModel;
- (void)setScoreWith:(NSString*)score;

@end
