//
//  ZHTeamDetaillCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/6.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHTeamDetaillCell.h"

@implementation ZHTeamDetaillCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(0, mygap, BOUNDS.size.width*.3, 34);
    self.detailTextLabel.frame = CGRectMake(BOUNDS.size.width*.36, mygap, BOUNDS.size.width*(1-.37), 44-mygap*2);
    self.separatorInset = UIEdgeInsetsMake(0, BOUNDS.size.width*.36, 0, 0);
    self.textLabel.textAlignment = NSTextAlignmentRight;
    self.textLabel.font = Btn_font;
    self.detailTextLabel.font = Btn_font;
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.textColor = [UIColor lightGrayColor];
    self.detailTextLabel.textColor = [UIColor blackColor];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
