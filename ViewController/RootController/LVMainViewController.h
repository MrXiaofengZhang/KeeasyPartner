//
//  LVMainViewController.h
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LVMainViewController : UITabBarController
@property (nonatomic,strong) UIView *myCount;
//传递一个number，表明第几个tabbar被选中
- (instancetype)initWithNumber:(NSInteger)number;
//设置未读申请个数
//- (void)setupUntreatedApplyCount;
//设置未读数
-(void)setMessageCount;
@end
