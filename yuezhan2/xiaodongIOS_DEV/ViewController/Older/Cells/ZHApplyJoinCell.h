//
//  ZHApplyJoinCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHApplyJoinCell : UITableViewCell
@property (nonatomic,strong) UILabel *timeLb;
@property (nonatomic,strong) UIButton *agreeBtn;
@property (nonatomic,strong) UIButton *rejectBtn;
- (void)configDic:(NSDictionary*)dic;
@end
