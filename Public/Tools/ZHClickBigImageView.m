//
//  ZHClickBigImageView.m
//  yuezhan123
//
//  Created by zhoujin on 15/4/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHClickBigImageView.h"
#import "UIView+WebCacheOperation.h"
@implementation ZHClickBigImageView
{
    UIView *_backGroundView;
    UIImageView *_imageView;
    UIImage *_userImg;
    NSMutableData *_imageData;
}
- (id)initWithUserHeadImg:(UIImage *)headImg;
{
    self = [super init];
    if (self) {
        self.frame=CGRectMake(0, 0,UISCREENWIDTH,UISCREENHEIGHT);
        _backGroundView=[[UIView alloc]initWithFrame:self.bounds];
        _backGroundView.backgroundColor=[UIColor lightGrayColor];

        _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, UISCREENHEIGHT/4, UISCREENWIDTH, UISCREENHEIGHT/2)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _userImg=headImg;
        _imageView.image = headImg;
        [self addSubview:_backGroundView];
        [self addSubview:_imageView];
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
