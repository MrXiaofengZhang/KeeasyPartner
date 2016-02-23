//
//  PopoverView.h
//  ArrowView
//
//  Created by guojiang on 4/9/14.
//  Copyright (c) 2014年 LINAICAI. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

typedef NS_ENUM(NSInteger, PopoverStyle) {
    PopoverStyleDefault = 0,
    PopoverStyleBlack,
    PopoverStyleTrancent
};

#import <UIKit/UIKit.h>

@interface PopoverView : UIView
-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images andStyle:(PopoverStyle)style;
-(void)show;
-(void)dismiss;
-(void)dismiss:(BOOL)animated;

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);
@property (nonatomic, assign) PopoverStyle popStyle;
@property (nonatomic, copy) void (^dismissBlock)();

@end
