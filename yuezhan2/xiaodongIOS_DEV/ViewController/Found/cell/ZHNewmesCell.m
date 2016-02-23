//
//  ZHNewmesCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHNewmesCell.h"

@implementation ZHNewmesCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createViews];
    }
    return self;
}
- (void)createViews{
    [self.contentView addSubview:self.timeLb];
    [self.contentView addSubview:self.contentLb];
    [self.contentView addSubview:self.contentImg];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 70, BOUNDS.size.width, 1.0f)];
    line.backgroundColor = BackGray_dan;
    [self.contentView addSubview:line];
}
- (void)layoutSubviews{
    self.imageView.frame = CGRectMake(mygap*2, mygap, 40, 40);
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 20.0;
    self.textLabel.frame = CGRectMake(self.imageView.right+mygap*2, self.imageView.top, BOUNDS.size.width-self.imageView.right-2*mygap-100, 20) ;
    self.textLabel.textColor = NavgationColor;
    self.textLabel.font = Btn_font;
    
    self.detailTextLabel.frame = CGRectMake(self.textLabel.left, self.textLabel.bottom, self.textLabel.width, 20);
    self.detailTextLabel.textColor = [UIColor blackColor];
    self.timeLb.frame = CGRectMake(self.textLabel.left, self.detailTextLabel.bottom, self.textLabel.width, 20);
    self.contentLb.frame = CGRectMake(BOUNDS.size.width-60-mygap, mygap, 60, 60);
    self.contentImg.frame = self.contentLb.frame;
}
#pragma mark Getter
- (UILabel*)timeLb{
    if (_timeLb == nil) {
        _timeLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLb.textColor = [UIColor lightGrayColor];
        _timeLb.font = Content_lbfont;
        _timeLb.textAlignment = NSTextAlignmentLeft;
        _timeLb.text = @"9:23";
    }
    return _timeLb;
}
- (UILabel*)contentLb{
    if (_contentLb == nil) {
        _contentLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLb.font = Btn_font;
        _contentLb.numberOfLines = 0;
        _contentLb.textAlignment = NSTextAlignmentLeft;
        _contentLb.text = @"今天想吃大餐";
        _contentLb.textColor = [UIColor lightGrayColor];
    }
    return _contentLb;
}
- (UIImageView*)contentImg{
    if (_contentImg == nil) {
        _contentImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        _contentImg.backgroundColor = [UIColor redColor];
    }
    return _contentImg;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
