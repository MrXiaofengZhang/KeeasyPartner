//
//  ZHAppointItemCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/22.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@class GetAppliesModel;

@interface ZHAppointItemCell : SWTableViewCell
@property (nonatomic,strong) UIButton *headImg;//发起人头像
@property (nonatomic,strong) UILabel *nameLb;//发起人昵称
@property (nonatomic,strong) UILabel *statusImg;//约战状态
@property (nonatomic,strong) UILabel *distanceLb;//约战距离
@property (nonatomic,strong) UIImageView *appointImg;//约战图片
@property (nonatomic,strong) UILabel *appointnameLb;//约战名
@property (nonatomic,strong) UILabel *timeLb;//时间段
@property (nonatomic,strong) UILabel *cityLb;//城市
@property (nonatomic,strong) UIImageView *sportTypeImg;//运动类型
@property (nonatomic,strong) UILabel *zanCountLb;//赞同数
@property (nonatomic,strong) UILabel *noZanCountLb;//反对数，参与人数
@property (nonatomic,strong) UILabel *commentCountLb;//评论数
@property (nonatomic,strong) UILabel *shareCountLb;//分享数

- (void)configDefaultModel:(GetAppliesModel *)model;
- (void)configDefaultDic:(NSDictionary *)dic;
@end
