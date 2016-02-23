//
//  LVTextField.m
//  yuezhan123
//
//  Created by LV on 15/4/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVTextField.h"

@implementation LVTextField


#pragma  mrak --注册专门使用的textField
- (instancetype)initWithFrame:(CGRect)frame WithPlaceholder:(NSString *)placeholderStr Withtarget:(id)target{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mygap, 0)];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 5.0f;
        self.placeholder = placeholderStr;
        self.delegate = target;
        self.textAlignment = NSTextAlignmentLeft;
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
