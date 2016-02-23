//
//  ApplyJionCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ApplyJionCell.h"

@implementation ApplyJionCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}
- (void)layoutSubviews{
  
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.height/2.0;
    self.detailTextLabel.textColor = [UIColor lightGrayColor];
    UIView *line =[[UIView alloc] initWithFrame:CGRectMake(0, 59.0, BOUNDS.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:line];
}
@end
