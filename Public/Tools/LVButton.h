//
//  LVButton.h
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LVSelectBtnProtcol <NSObject>



@end

@interface LVButton : UIButton

@property (nonatomic, copy)void (^indexClick)(NSString *);

- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)title WithImg:(NSString *)imgStr WithColor:(NSInteger)redOrClear WithTag:(NSInteger)btnTag;

- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)titleStr WithBgImg:(NSString *)imgStr WithTag:(NSInteger)btnTag;

- (instancetype)initWithFrame:(CGRect)frame selectWithImage:(NSString *)imgStr UnSelectWithImag:(NSString *)imgStr2 WithTitle:(NSString *)title WithTag:(NSInteger)tag;

- (instancetype)initWithFrame:(CGRect)frame Sifttile:(NSString *)title WithTag:(NSInteger)btnTag;

//设置button的选中或者不选中,number:1:轮转按钮，2:筛选按钮
- (void)selectedOrNo:(BOOL)select WithNum:(NSInteger)number;

- (instancetype)initWithFrame:(CGRect)frame WithSiftBtn:(NSString *)siftName WithLine:(BOOL)isLine;

- (instancetype)initWithFrame:(CGRect)frame WithMatch:(BOOL)isClick;
- (void)setLabelFont:(UIFont*)font;
- (void)setlabelText:(NSString *)text;
@end
