//
//  WPCAreaSelectCell.m
//  yuezhan123
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCAreaSelectCell.h"

@implementation WPCAreaSelectCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _titleLab = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLab.layer.borderWidth = 1;
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self.contentView addSubview:_titleLab];
    }
    return self;
}

@end
