//
//  EmpatyView.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/8/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "EmpatyView.h"

@implementation EmpatyView
- (id)initWithImg:(NSString *)imgName AndText:(NSString *)text{
    if (self = [super initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height)]) {
        UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        imageView.center = self.center;
        imageView.image = [UIImage imageNamed:imgName];
        [self addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom+mygap, self.width, 30)];
        label.textColor = Content_lbColor;
        label.font = Content_lbfont;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        [self addSubview:label];
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
