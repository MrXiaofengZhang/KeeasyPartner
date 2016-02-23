//
//  WPCTeamCell.h
//  yuezhan123
//
//  Created by admin on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "SWTableViewCell.h"
@class TeamModel;
@interface WPCTeamCell : SWTableViewCell

@property (nonatomic, strong)UIImageView *headImg;
@property (nonatomic, strong)UILabel *nameLab;
@property (nonatomic, strong)UIImageView *typeImg;
@property (nonatomic, strong)UILabel *decleartionLab;
@property (nonatomic, strong)UILabel *distanceLab;
@property (nonatomic, strong)UILabel *playingLab;
@property (nonatomic, strong)UILabel *matchingLab;

@property (nonatomic, strong)UIButton *rankImg;
@property (nonatomic, strong)UIButton *ownerImg;
@property (nonatomic, strong)UIButton *addBtn;
- (void)configTeamModel:(TeamModel*)model;
@end
