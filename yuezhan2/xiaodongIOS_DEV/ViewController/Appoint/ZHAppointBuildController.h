//
//  ZHAppointBuildController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/7.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"

@interface ZHAppointBuildController : BaseViewController

@property (nonatomic, strong)NSMutableDictionary *datasource;
@property (nonatomic, strong)NSString *idString;
- (void)changeTitle:(NSString *)str;

@end
