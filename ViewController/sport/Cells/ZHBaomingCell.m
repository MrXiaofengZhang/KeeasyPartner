//
//  ZHBaomingCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/24.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHBaomingCell.h"

@implementation ZHBaomingCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLb];
        [self.contentView addSubview:self.contentFiled];
       //[self.contentView addSubview:self.selectBtn];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.titleLb];
        [self.contentView addSubview:self.contentFiled];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}
- (UILabel*)titleLb{
    if (_titleLb == nil) {
        _titleLb = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 100, 30)];
        _titleLb.textColor = [UIColor colorWithRed:0.506f green:0.506f blue:0.506f alpha:1.00f];
        _titleLb.textAlignment = NSTextAlignmentLeft;
        _titleLb.font = Btn_font;
    }
    return _titleLb;
}
- (UITextField*)contentFiled{
    if (_contentFiled == nil) {
        _contentFiled = [[UITextField alloc] initWithFrame:CGRectMake(130, 14, BOUNDS.size.width-130-10, 30)];
        _contentFiled.font = Btn_font;
        _contentFiled.returnKeyType = UIReturnKeyDone;
    }
    return _contentFiled;
}
- (UIButton*)selectBtn{
    if (_selectBtn == nil) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame = CGRectMake(BOUNDS.size.width-30-30, 14, 30, 30);
        [_selectBtn setBackgroundColor:[UIColor lightGrayColor]];
        
    }
    return _selectBtn;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
