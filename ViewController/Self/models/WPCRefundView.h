//
//  WPCRefundView.h
//  yuezhan123
//
//  Created by admin on 15/7/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPCRefundView : UIView

@property (nonatomic, strong)UIButton *btn1;
@property (nonatomic, strong)UIButton *btn2;

- (id)initWithFrame:(CGRect)frame contentTitle:(NSString *)title index:(NSString *)index;
- (void)changeColorWithState:(BOOL)hasdone;

@end
