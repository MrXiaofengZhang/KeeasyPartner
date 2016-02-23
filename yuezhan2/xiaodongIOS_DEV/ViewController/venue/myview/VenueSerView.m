//
//  VenueSerView.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/25.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "VenueSerView.h"

@implementation VenueSerView
- (id)initWithFrame:(CGRect)frame Title:(NSString*)title AndImg:(NSString*)img{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.leftImg];
        self.leftImg.image = [UIImage imageNamed:img];
        [self addSubview:self.nameLb];
        self.nameLb.text = title;
        self.frame = frame;
    }
    return self;
}
- (UIImageView*)leftImg{
    if (_leftImg == nil) {
        _leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2.5, 15, 15)];
    }
    return _leftImg;
}
- (UILabel*)nameLb{
    if (_nameLb == nil) {
        _nameLb = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 60, 20)];
        _nameLb.textColor = [UIColor lightGrayColor];
        _nameLb.font = Content_lbfont;
        _nameLb.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLb;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
