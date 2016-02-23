//
//  UIViewController+HUD.m
//  KeeasyBusse1.0
//
//  Created by xieweiwei on 14-7-14.
//  Copyright (c) 2014年 zhangxiaofeng. All rights reserved.
//

#import "UIViewController+HUD.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
static const void *HttpRequestHUDKey = &HttpRequestHUDKey;

@implementation UIViewController (HUD)
- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint{
    UIView *gray = [[UIView alloc] initWithFrame:BOUNDS];
    gray.alpha = 0.5;
    gray.tag = 50;
    gray.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gray];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.labelText = hint;
    [view addSubview:HUD];
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)showHint:(NSString *)hint{
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:15.0];
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint andHeight:(CGFloat)height
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:15.0];
    hud.margin = 10.f;
    hud.yOffset = height;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)hideHud{
    UIView *grayView = [self.view viewWithTag:50];
    [grayView removeFromSuperview];
    [[self HUD] hide:YES];
}
-(void)backOnCLcik:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)addRihtBtnWithImage:(NSString *)image WithSelector:(SEL)selector{
    UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 20, 20)];
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
}
-(void)addBackButtonItem{
    UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 30, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"Public_fh.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backOnCLcik:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
}
@end
