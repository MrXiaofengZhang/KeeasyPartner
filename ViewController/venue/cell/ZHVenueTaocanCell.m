//
//  ZHVenueTaocanCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHVenueTaocanCell.h"
#import "ZHTaocanModel.h"
@implementation ZHVenueTaocanCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[ super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        UIView *back =[[UIView alloc] initWithFrame:CGRectMake(mygap, mygap, BOUNDS.size.width-2*mygap, 60)];
        back.backgroundColor = [UIColor colorWithRed:0.941f green:0.945f blue:0.953f alpha:1.00f];
        [self.contentView addSubview:back];
        [back addSubview:self.titleLb];
        [back addSubview:self.redLb];
        [back addSubview:self.yuanjiaLb];
        [back addSubview:self.yishouLb];
//        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
//        arrow.frame = CGRectMake(_redLb.right+5, 15, 19, 19);
//        arrow.userInteractionEnabled = YES;
//        [self.contentView addSubview:arrow];
    }
    return self;
}
- (void)configTaocanModel:(ZHTaocanModel*)model{
    _titleLb.text = model.packageName;
    //_yuanjiaLb.text =[NSString stringWithFormat:@"原价:%@元", model.originalPrice];
    NSString *oldPrice = [NSString stringWithFormat:@"原价:%@元", model.originalPrice];
    NSUInteger length = [oldPrice length];
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:oldPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(2, length-2)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(2, length-2)];
    [_yuanjiaLb setAttributedText:attri];
    _redLb.text =[NSString stringWithFormat:@"%@元", model.discountPrice];
//    NSString *str = [LVTools mToString:model.salesCount];
//    [_yishouLb setTitle:[NSString stringWithFormat:@"已售%@",str] forState:UIControlStateNormal];
}
- (UILabel*)titleLb{
    if (_titleLb == nil) {
        _titleLb = [[UILabel alloc]initWithFrame:CGRectMake(mygap, mygap, BOUNDS.size.width*0.7, 20)];
        _titleLb.text = @"个人专属套餐";
        _titleLb.textAlignment = NSTextAlignmentLeft;
        _titleLb.font = Btn_font;
        _titleLb.textColor = Content_lbColor;
    }
    return _titleLb;
}
- (UILabel*)redLb{
    if(_redLb == nil ){
        _redLb = [[UILabel alloc] initWithFrame:CGRectMake(_titleLb.left, _titleLb.bottom+mygap, 60, 20)];
        _redLb.textColor = NavgationColor;
        _redLb.textAlignment = NSTextAlignmentLeft;
        _redLb.font = Btn_font;
        _redLb.text = @"86元";
    }
    return _redLb;
}
- (UILabel*)yuanjiaLb{
    if (_yuanjiaLb == nil) {
        _yuanjiaLb = [[UILabel alloc] initWithFrame:CGRectMake(_redLb.right+mygap*2, _redLb.top, 100, 20)];
        _yuanjiaLb.textAlignment = NSTextAlignmentLeft;
        _yuanjiaLb.text = @"128元";
        _yuanjiaLb.font = Content_lbfont;
        _yuanjiaLb.textColor = Content_lbColor;
    }
    return _yuanjiaLb;
}
- (UIButton*)yishouLb{
    if (_yishouLb == nil) {
        _yishouLb = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-10-100, 35, 100, 20)];
//        [_yishouLb setTitle:@"已售20" forState:UIControlStateNormal];
        [_yishouLb setBackgroundColor:[UIColor clearColor]];
        [_yishouLb setTitleColor:Content_lbColor forState:UIControlStateNormal];
        _yishouLb.titleLabel .textAlignment = NSTextAlignmentRight;
        _yishouLb.titleLabel.font = Content_lbfont;
    }
    return _yishouLb;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
