//
//  WPCRefundView.m
//  yuezhan123
//
//  Created by admin on 15/7/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCRefundView.h"

@implementation WPCRefundView

- (id)initWithFrame:(CGRect)frame contentTitle:(NSString *)title index:(NSString *)index {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.btn1];
        [self addSubview:self.btn2];
        [_btn1 setTitle:title forState:UIControlStateNormal];
        [_btn2 setTitle:index forState:UIControlStateNormal];
    }
    return self;
}

- (void)changeColorWithState:(BOOL)hasdone {
    if (hasdone) {
        _btn1.backgroundColor = NavgationColor;
        
        _btn2.layer.borderColor = [NavgationColor CGColor];
        [_btn2 setTitleColor:NavgationColor forState:UIControlStateNormal];
        
    } else {
        _btn1.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        
        _btn2.layer.borderColor = [RGBACOLOR(222, 222, 222, 1) CGColor];
        [_btn2 setTitleColor:RGBACOLOR(222, 222, 222, 1) forState:UIControlStateNormal];
        
    }
}

- (UIButton *)btn1 {
    if (!_btn1) {
        _btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn1.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _btn1.frame = CGRectMake(0, 0, self.width, 70*propotion);
        [_btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _btn1;
}

- (UIButton *)btn2 {
    if (!_btn2) {
        _btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn2.frame = CGRectMake(52*propotion, 52*propotion, 36*propotion, 36*propotion);
        _btn2.layer.cornerRadius = 18*propotion;
        [_btn2.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _btn2.layer.borderWidth = 1;
        _btn2.backgroundColor = [UIColor whiteColor];
        _btn2.layer.masksToBounds = YES;
    }
    return _btn2;
}

@end
