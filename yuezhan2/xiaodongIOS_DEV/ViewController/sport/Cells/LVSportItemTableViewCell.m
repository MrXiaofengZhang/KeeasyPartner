//
//  LVSportItemTableViewCell.m
//  yuezhan123
//
//  Created by apples on 15/3/20.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVSportItemTableViewCell.h"
#import "GetMatchListModel.h"
#define colorGreen [UIColor colorWithRed:0.000 green:0.600 blue:0.278 alpha:1.00]
#define spaceWidth 10.0
@implementation LVSportItemTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView2];
    }
    return self;
}
- (void)createView2{
    [self.contentView addSubview:self.sportNameLb];
    [self.contentView addSubview:self.beginDateLb];
    [self.contentView addSubview:self.statusLb];
    [self.contentView addSubview:self.sportImageView];
    
}
- (void)createView{
    [self.contentView addSubview:self.bgView];
    self.contentView.backgroundColor = BackGray_dan;
    [self.bgView addSubview:self.iconImgBtn];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.stateLabel];
    [self.bgView addSubview:self.signedCount];
    [self.bgView addSubview:self.sportImgView];
    self.bgView.height = self.iconImgBtn.bottom+spaceWidth/2.0+_sportImgView.height+spaceWidth;
    NSLog(@"cell height %f",self.bgView.height+spaceWidth);
}
#pragma mark getter
- (UIView*)bgView{
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, spaceWidth/2.0, BOUNDS.size.width, 0)];
        self.bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}
- (UIImageView*)sportImgView{
    
    if (_sportImgView == nil) {
        _sportImgView = [[UIImageView alloc] initWithFrame:CGRectMake(spaceWidth, _iconImgBtn.bottom+spaceWidth, _bgView.width-2*spaceWidth, _bgView.width*(400/1086.0))];
        [_sportImgView addSubview:self.baomingBtn];
    }
    return _sportImgView;
}
- (UIButton*)iconImgBtn{
    if (_iconImgBtn == nil) {
        _iconImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconImgBtn.frame = CGRectMake(spaceWidth, spaceWidth, 48, 48);
    }
    return _iconImgBtn;
}
- (UILabel*)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImgBtn.right+spaceWidth, spaceWidth+mygap, _bgView.width-spaceWidth-_iconImgBtn.right, 20)];
        //self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}
- (UILabel*)stateLabel{
    if (_stateLabel ==nil) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom , 100, 20)];
        self.stateLabel.font = [UIFont systemFontOfSize:16.0];
        self.stateLabel.textColor = [UIColor lightGrayColor];
    }
    return _stateLabel;
}
- (UILabel*)signedCount{
    if (_signedCount == nil) {
        UILabel *textLb= [[UILabel alloc] initWithFrame:CGRectMake(self.bgView.width-75, self.stateLabel.top, 45, 20)];
        textLb.text = @"已报名:";
        textLb.font = Content_lbfont;
        textLb.textColor = Content_lbColor;
        [self.bgView addSubview:textLb];
        _signedCount = [[UILabel alloc] initWithFrame:CGRectMake(textLb.right, textLb.top, 55, textLb.height)];
        _signedCount.textColor = color_red_dan;
        _signedCount.textAlignment = NSTextAlignmentLeft;
        _signedCount.font = Content_lbfont;
        _signedCount.text = @"100";
    }
    return _signedCount;
}
- (UIButton*)baomingBtn{
    if (_baomingBtn == nil) {
        _baomingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _baomingBtn.hidden = YES;
        [_baomingBtn setFrame:CGRectMake(_sportImgView.width-85.0f, _sportImgView.height-30.0f, 85.0f, 25.0f)];
        [_baomingBtn setImage:[UIImage imageNamed: @"quickBaoming"] forState:UIControlStateNormal];
    }
    return _baomingBtn;
}
- (void)configMatchModel:(GetMatchListModel *)model
{
    self.sportNameLb.text = model.name;
    self.beginDateLb.text = [NSString getCreateTime:[NSString stringWithFormat:@"%lld", [model.starttime longLongValue]/1000]];
    self.signedLb.text = [LVTools mToString:model.singUpNum];
    self.zanLb.text = [LVTools mToString:model.praiseNum];
    self.commentLb.text = [LVTools mToString:model.commentNum];
    self.shareLb.text = [LVTools mToString:model.share];
    [self.sportImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,model.matchShow]] placeholderImage:[UIImage imageNamed:@"match_plo"]];
    
  
        if ([[LVTools mToString: model.type] isEqualToString:@"2"]) {
            [self.sportTypeImgView setImage:[UIImage imageNamed:@"typeIcon1"]];
        }
        else{
            [self.sportTypeImgView setImage:[UIImage imageNamed:@"typeIcon"]];
        }
    if ([[LVTools mToString:model.signUpStatus] isEqualToString:@"0"]) {
        self.statusLb.selected = NO;
        _statusLb.layer.borderColor = SystemBlue.CGColor;
    }
    else if ([[LVTools mToString:model.signUpStatus] isEqualToString:@"1"]){
        self.statusLb.selected = YES;
        _statusLb.layer.borderColor = colorGreen.CGColor;
    }
    else{
        
    }
}
//校动比赛单元格UI
- (UILabel*)sportNameLb{
    if (_sportNameLb == nil) {
        _sportNameLb = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, BOUNDS.size.width-2*mygap-100.0, 20.0)];
        _sportNameLb.text = @"2015上海交通大学篮球赛";
        _sportNameLb.backgroundColor = [UIColor clearColor];
        _sportNameLb.font = Title_font;
        _sportNameLb.textAlignment = NSTextAlignmentLeft;
        _sportNameLb.textColor = [UIColor blackColor];
    }
    return _sportNameLb;
}
- (UILabel*)beginDateLb{
    if (_beginDateLb == nil) {
        _beginDateLb = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, _sportNameLb.bottom, BOUNDS.size.width-2*mygap, 20.0)];
        _beginDateLb.text = @"2015-12-12";
        _beginDateLb.backgroundColor = [UIColor clearColor];
        _beginDateLb.font = Btn_font;
        _beginDateLb.textAlignment = NSTextAlignmentLeft;
        _beginDateLb.textColor = [UIColor colorWithRed:0.341 green:0.341 blue:0.341 alpha:1.00];
    }
    return _beginDateLb;
}
- (UIButton*)statusLb{
    if (_statusLb == nil) {
        _statusLb = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-90.0, _sportNameLb.top+10.0, 85.0, 25.0)];
        _statusLb.layer.cornerRadius = mygap;
        _statusLb.layer.borderWidth = 1.0;
        _statusLb.layer.borderColor = SystemBlue.CGColor;
        [_statusLb setTitle:@"正在报名" forState:UIControlStateNormal];
        [_statusLb setTitleColor:SystemBlue forState:UIControlStateNormal];
        _statusLb.titleLabel.font = Btn_font;
        [_statusLb setTitle:@"报名结束" forState:UIControlStateSelected];
        [_statusLb setTitleColor:colorGreen forState:UIControlStateSelected];
        
    }
    return _statusLb;
}
- (UIImageView*)sportImageView{
    if (_sportImageView == nil) {
        //728*268
        _sportImageView = [[UIImageView alloc] initWithFrame:CGRectMake(mygap, _beginDateLb.bottom, BOUNDS.size.width-2*mygap, 268.0/728.0*(BOUNDS.size.width-2*mygap))];
        _sportImageView.backgroundColor = [UIColor whiteColor];
        [_sportImageView addSubview:self.grayView];
    }
    return _sportImageView;
}
- (UIView*)grayView{
    if (_grayView == nil) {
        _grayView = [[UIView alloc] initWithFrame:CGRectMake(0, _sportImageView.height-30.0, _sportImageView.width, 30.0)];
        _grayView.backgroundColor = [UIColor colorWithRed:0.165 green:0.165 blue:0.165 alpha:1.00];
        _grayView.alpha = 0.8;
        [_grayView addSubview:self.sportTypeImgView];
        [_grayView addSubview:self.signedLb];
        [_grayView addSubview:self.zanLb];
        [_grayView addSubview:self.commentLb];
        [_grayView addSubview:self.shareLb];
    }
    return _grayView;
}
- (UIImageView*)sportTypeImgView{
    if (_sportTypeImgView==nil) {
        _sportTypeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*3, mygap, 20.0, 20.0)];
        _sportTypeImgView.image = [UIImage imageNamed:@"typeIcon"];
    }
    return _sportTypeImgView;
}
- (UILabel*)signedLb{
    if (_signedLb == nil) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(_sportTypeImgView.right+mygap, mygap, 20.0, 20.0)];
        img.image = [UIImage imageNamed:@"signIcon@2x"];
        [_grayView addSubview:img];
        _signedLb = [[UILabel alloc] initWithFrame:CGRectMake(img.right, mygap, 40.0, 20.0)];
        _signedLb.textColor = [UIColor whiteColor];
        _signedLb.font = Content_lbfont;
        _signedLb.text = @"125";
        _signedLb.textAlignment = NSTextAlignmentCenter;
        _signedLb.backgroundColor = [UIColor clearColor];
    }
    return _signedLb;
}
- (UILabel*)zanLb{
    if (_zanLb == nil) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(_signedLb.right+mygap, mygap, 20.0, 20.0)];
        img.image = [UIImage imageNamed:@"zanIcon"];
        [_grayView addSubview:img];
        _zanLb = [[UILabel alloc] initWithFrame:CGRectMake(img.right, mygap, 40.0, 20.0)];
        _zanLb.textColor = [UIColor whiteColor];
        _zanLb.font = Content_lbfont;
        _zanLb.text = @"125";
        _zanLb.textAlignment = NSTextAlignmentCenter;
        _zanLb.backgroundColor = [UIColor clearColor];
    }
    return _zanLb;
}
- (UILabel*)commentLb{
    if (_commentLb == nil) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(_zanLb.right+mygap, mygap, 20.0, 20.0)];
        img.image = [UIImage imageNamed:@"comentIcon@2x"];
        [_grayView addSubview:img];
        _commentLb = [[UILabel alloc] initWithFrame:CGRectMake(img.right, mygap, 40.0, 20.0)];
        _commentLb.textColor = [UIColor whiteColor];
        _commentLb.font = Content_lbfont;
        _commentLb.text = @"125";
        _commentLb.textAlignment = NSTextAlignmentCenter;
        _commentLb.backgroundColor = [UIColor clearColor];
    }
    return _commentLb;
}
- (UILabel*)shareLb{
    if (_shareLb == nil) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(_commentLb.right+mygap, mygap, 20.0, 20.0)];
        img.image = [UIImage imageNamed:@"shareIcon@2x"];
        [_grayView addSubview:img];
        _shareLb = [[UILabel alloc] initWithFrame:CGRectMake(img.right, mygap, 40.0, 20.0)];
        _shareLb.textColor = [UIColor whiteColor];
        _shareLb.font = Content_lbfont;
        _shareLb.textAlignment = NSTextAlignmentCenter;
        _shareLb.backgroundColor = [UIColor clearColor];
        _shareLb.text = @"125";
    }
    return _shareLb;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
