//
//  WPCApointInfoTableViewCell.h
//  yuezhan123
//
//  Created by admin on 15/5/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface WPCApointInfoTableViewCell : SWTableViewCell

@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *dateLab;
@property (nonatomic, strong) UILabel *appliedNumLab;
@property (nonatomic, strong) UIImageView *contentImage;

- (void)configCellContentWithDic:(NSDictionary *)dic;

@end
