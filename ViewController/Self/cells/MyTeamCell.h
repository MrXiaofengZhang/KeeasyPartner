//
//  MyTeamCell.h
//  yuezhan123
//
//  Created by admin on 15/8/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "SWTableViewCell.h"

@interface MyTeamCell : SWTableViewCell

@property (nonatomic, strong) UIImageView *headImg;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *slogonLab;
@property (nonatomic, strong) UIImageView *typeImg;
@property (nonatomic, strong) UILabel *countLab;
@property (nonatomic, strong) UILabel *stateLab;

- (void)configMyTeamWithDicinfo:(NSDictionary *)info;
- (void)configMyApplyWithDicInfo:(NSDictionary *)info;

@end
