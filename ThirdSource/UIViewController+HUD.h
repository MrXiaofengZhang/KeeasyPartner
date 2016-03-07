//
//  UIViewController+HUD.h
//  KeeasyBusse1.0
//
//  Created by xieweiwei on 14-7-14.
//  Copyright (c) 2014年 zhangxiaofeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HUD)
- (void)showHudInView:(UIView *)view hint:(NSString *)hint;

- (void)hideHud;

- (void)showHint:(NSString *)hint;
- (void)showHint:(NSString *)hint andHeight:(CGFloat)height;
- (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;
/**
 *  添加返回按钮
 */
-(void)addBackButtonItem;
/**
 *  添加navgationBr右按钮
 *
 *  @param image    按钮图
 *  @param selector 按钮事件
 */
-(void)addRihtBtnWithImage:(NSString *)image WithSelector:(SEL)selector;
@end
