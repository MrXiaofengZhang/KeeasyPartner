//
//  LVBindingQQViewController.h
//  yuezhan123
//
//  Created by LV on 15/4/14.
//  Copyright (c) 2015年 LV. All rights reserved.
//

/*
    绑定QQ绑定界面
 */

#import "BaseViewController.h"

@interface LVBindingQQViewController : BaseViewController

- (instancetype)initWithQQid:(NSString *)qqIdStr WithUserName:(NSString *)userName withType:(NSString*)type;
@property (nonatomic,strong) NSString *iconPath;

@end
