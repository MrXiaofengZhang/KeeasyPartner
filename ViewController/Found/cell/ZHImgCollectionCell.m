//
//  ZHImgCollectionCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHImgCollectionCell.h"

@implementation ZHImgCollectionCell
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView];

    }
    return self;
}
@end
