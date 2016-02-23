//
//  TeamResultCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/20.
//  Copyright © 2016年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamResultCell : UITableViewCell
@property (nonatomic, strong) UIButton *teamImg;
@property (nonatomic, strong) UIImageView *teamLevelImg;
@property (nonatomic, strong) UILabel *teamNameLb;
@property (nonatomic, strong) UILabel *rankLb;
- (void)configWithTeamInfoDic:(NSDictionary*)dic;
@end
