//
//  PhoneManaddCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/3/3.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "PhoneManaddCell.h"

@implementation PhoneManaddCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.addBtn];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.width/2.0;
}
- (UIButton*)addBtn{
    if (_addBtn == nil) {
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-80, 15.0, 50.0, 25.0)];
        _addBtn.layer.cornerRadius = mygap;
        [_addBtn setBackgroundColor:SystemBlue];
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        
    }
    return _addBtn;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
