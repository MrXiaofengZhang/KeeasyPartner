//
//  ZHGenderView.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/5/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHGenderView.h"

@implementation ZHGenderView
- (id)initWithFrame:(CGRect)frame WithGender:(NSString *)gender AndAge:(NSString *)age{
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.height/6.0;
        [self addSubview:self.imageView];
        if ([gender isEqualToString:@"1"]) {
            self.backgroundColor = [UIColor colorWithRed:0.298f green:0.635f blue:0.863f alpha:1.00f];
            self.imageView.image = [UIImage imageNamed:@"icon_nan"];
        }
        else {
            self.backgroundColor = [UIColor colorWithRed:0.988f green:0.608f blue:0.576f alpha:1.00f];
            self.imageView.image = [UIImage imageNamed:@"icon_nv"];
        }
        self.imageView.frame = CGRectMake(0, 0, frame.size.width/2.0, frame.size.height);
        [self addSubview:self.lab];
        self.lab.text = [LVTools mToString:age];
        self.lab.frame = CGRectMake(frame.size.width/2.0, 0, frame.size.width/2.0, frame.size.height);
        self.lab.font = [UIFont systemFontOfSize:11.0];
    }
    return self;
}
#pragma mark getter
- (UIImageView*)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}
- (UILabel*)lab{
    if (_lab == nil) {
        _lab = [[UILabel alloc] initWithFrame:CGRectZero];
        _lab .textAlignment = NSTextAlignmentCenter;
        _lab.backgroundColor = [UIColor clearColor];
        _lab.textColor = [UIColor whiteColor];
        _lab .font = Content_lbfont;
    }
    return _lab;
}
#pragma mark set
- (void)setGender:(NSString *)gender{
    if ([gender isEqualToString:@"1"]) {
        self.backgroundColor = [UIColor colorWithRed:0.298f green:0.635f blue:0.863f alpha:1.00f];
        self.imageView.image = [UIImage imageNamed:@"icon_nan"];
    }
    else {
        self.backgroundColor = [UIColor colorWithRed:0.988f green:0.608f blue:0.576f alpha:1.00f];
        self.imageView.image = [UIImage imageNamed:@"icon_nv"];
    }

}
- (void)setAge:(NSString *)age{
    self.lab.text = age;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
