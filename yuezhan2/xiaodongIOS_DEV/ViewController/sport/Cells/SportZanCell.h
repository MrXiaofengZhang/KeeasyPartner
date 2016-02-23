//
//  SportZanCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/20.
//  Copyright © 2016年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHGenderView;
@interface SportZanCell : UITableViewCell
@property (nonatomic, strong) UIButton *userIcon;
@property (nonatomic, strong) ZHGenderView *userGenderV;
@property (nonatomic, strong) UILabel *userNameLb;
@property (nonatomic, strong) UILabel *distanceLb;
@property (nonatomic, strong) UILabel *timeLb;
- (void)configWithUserInfoDic:(NSDictionary*)dic;
@end
