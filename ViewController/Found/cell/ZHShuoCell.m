//
//  ZHShuoCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHShuoCell.h"

@implementation ZHShuoCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self customViews];
    }
    return self;
}
- (void)customViews{
    self.contentView.backgroundColor = BackGray_dan;
    UIView *whiteBg= [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 160.0)];
    whiteBg.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:whiteBg];
    [whiteBg addSubview:self.headImg];
    [whiteBg addSubview:self.nameLb];
    [whiteBg addSubview:self.mcontentView];
    [self.mcontentView addSubview:self.mImageView];
    [self.mcontentView addSubview:self.contentLb];
    [whiteBg addSubview:self.timeLb];
    [whiteBg addSubview:self.removeBtn];
    //分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.removeBtn.bottom+mygap*2, BOUNDS.size.width, 0.5)];
    line.backgroundColor = BackGray_dan;
    [whiteBg addSubview:line];
    [whiteBg addSubview:self.visitCount];
    [whiteBg addSubview:self.commentBtn];
    [whiteBg addSubview:self.zanBtn];
}
#pragma  mark getter
- (UIButton*)headImg{
    if (_headImg == nil) {
        _headImg = [[UIButton alloc]initWithFrame:CGRectMake(mygap*2, mygap*2, 50, 50)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 25.0;
    }
    return _headImg;
}
- (UILabel*)nameLb{
    if (_nameLb == nil) {
        _nameLb = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.right+mygap*2, _headImg.top, BOUNDS.size.width-_headImg.right-mygap*4, 20)];
        _nameLb.text = @"seven";
        _nameLb.textColor = [UIColor lightGrayColor];
        _nameLb.textAlignment = NSTextAlignmentLeft;
        _nameLb.font = Content_lbfont;
    }
    return _nameLb;
}
- (UIView*)mcontentView{
    if (_mcontentView == nil) {
        _mcontentView = [[UIView alloc] initWithFrame:CGRectMake(_nameLb.left, _nameLb.bottom+mygap, _nameLb.width, 44)];
        _mcontentView.backgroundColor = BackGray_dan;
    }
    return _mcontentView;
}
- (UIImageView*)mImageView{
    if (_mImageView == nil) {
        _mImageView = [[UIImageView alloc] initWithFrame:CGRectMake(mygap, mygap, _mcontentView.height-2*mygap, _mcontentView.height-2*mygap)];
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mImageView.clipsToBounds = YES;
    }
    return _mImageView;
}
- (UILabel*)contentLb{
    if (_contentLb == nil) {
        _contentLb = [[UILabel alloc] initWithFrame:CGRectMake(_mImageView.right+mygap, mygap, _mcontentView.width-_mImageView.right-4*mygap, _mImageView.height)];
        _contentLb.text = @"北京3v3篮球赛";
        _contentLb.textColor = [UIColor blackColor];
        _contentLb.textAlignment = NSTextAlignmentLeft;
        _contentLb.font = Btn_font;
    }
    return _contentLb;
}
- (UILabel*)timeLb{
    if (_timeLb == nil) {
        _timeLb = [[UILabel alloc] initWithFrame:CGRectMake(_nameLb.left, _mcontentView.bottom+mygap, 60, 20)];
        _timeLb.text = @"2小时前";
        _timeLb.textColor = [UIColor lightGrayColor];
        _timeLb.textAlignment = NSTextAlignmentLeft;
        _timeLb.font = Content_lbfont;
    }
    return _timeLb;
}
- (UIButton*)removeBtn{
    if (_removeBtn == nil) {
        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeBtn setFrame:CGRectMake(_timeLb.right+mygap, _timeLb.top, _timeLb.width, _timeLb.height)];
        _removeBtn.titleLabel.font = Content_lbfont;
        [_removeBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_removeBtn setTitleColor:NavgationColor forState:UIControlStateNormal];
    }
    return _removeBtn;
}
- (UIButton*)commentBtn{
    if (_commentBtn == nil) {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentBtn setFrame:CGRectMake(_visitCount.right, _visitCount.top, BOUNDS.size.width/4.0, _visitCount.height)];
        _commentBtn.layer.borderColor = BackGray_dan.CGColor;
        _commentBtn.layer.borderWidth = 0.3;
        [_commentBtn setImage:[UIImage imageNamed:@"comment_wpc"] forState:UIControlStateNormal];
        
        [_commentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _commentBtn;
}
- (UIButton*)zanBtn{
    if (_zanBtn == nil) {
        _zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zanBtn setFrame:CGRectMake(_commentBtn.right, _visitCount.top, BOUNDS.size.width/4.0, _visitCount.height)];
        [_zanBtn setImage:[UIImage imageNamed:@"hasPraised_wpc"] forState:UIControlStateSelected];
        [_zanBtn setImage:[UIImage imageNamed:@"praise_wpc"] forState:UIControlStateNormal];
        [_zanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _zanBtn;
}
- (UILabel*)visitCount{
    if (_visitCount == nil) {
        _visitCount = [[UILabel alloc] initWithFrame:CGRectMake(0,_removeBtn.bottom+mygap*2, BOUNDS.size.width/2.0, 45)];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"visite"]];
        icon.frame = CGRectMake(30, 15, 14, 14);
        //[_visitCount addSubview:icon];
        _visitCount.text = @"浏览56次";
        _visitCount.textColor = [UIColor lightGrayColor];
        _visitCount.textAlignment = NSTextAlignmentCenter;
        _visitCount.font = Content_lbfont;

    }
    return _visitCount;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
