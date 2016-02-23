//
//  TypeView.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/31.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "TypeView.h"

@implementation TypeView
- (id)initWithFrame:(CGRect)frame Type:(NSString *)type AndTitle:(NSString *)title{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1.00];
        UIImageView *typeImg = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, (frame.size.height-30.0)/2.0, 30.0, 30.0)];
        [typeImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"type%@",type]]];
        [self addSubview:typeImg];
        UILabel *sportNameLb = [[UILabel alloc] initWithFrame:CGRectMake(typeImg.right+mygap, typeImg.top, BOUNDS.size.width-50.0, 30.0)];
        sportNameLb.font = [UIFont systemFontOfSize:17.0];
        sportNameLb.textColor = [UIColor colorWithRed:0.627 green:0.624 blue:0.624 alpha:1.00];
        sportNameLb.text = title;
        [self addSubview:sportNameLb];
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
