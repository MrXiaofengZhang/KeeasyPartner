//
//  TeamCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/11.
//  Copyright © 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamCell : UITableViewCell
@property (nonatomic, strong) UIButton *teamImg;
@property (nonatomic, strong) UIImageView *teamLevelImg;
@property (nonatomic, strong) UILabel *teamNameLb;
@property (nonatomic, strong) UILabel *contentLb;
@property (nonatomic, strong) UIButton *zanBtn;
@property (nonatomic, strong) UILabel *zanCountLb;
- (void)configWithTeamInfoDic:(NSDictionary*)dic;
- (void)configWithUserInfoDic:(NSDictionary*)dic;
@end
