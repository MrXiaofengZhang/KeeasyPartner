//
//  ScoreCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/14.
//  Copyright © 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreCell : UITableViewCell
@property (nonatomic,strong) UILabel *dateLb;
@property (nonatomic,strong) UILabel *monthLb;
@property (nonatomic,strong) UILabel *sportLb;
@property (nonatomic,strong) UILabel *statusLb;
- (void)configInfo:(NSDictionary*)dic;
@end
