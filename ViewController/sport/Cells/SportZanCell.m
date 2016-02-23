//
//  SportZanCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/20.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "SportZanCell.h"
#import "ZHGenderView.h"
@implementation SportZanCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createViews];
    }
    return self;
}
- (void)createViews{
    [self.contentView addSubview:self.userIcon];
    [self.contentView addSubview:self.userNameLb];
    [self.contentView addSubview:self.userGenderV];
    [self.contentView addSubview:self.timeLb];
    [self.contentView addSubview:self.distanceLb];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, 49.0, BOUNDS.size.width*(711.0/750.0), 1)];
    [line setImage:[UIImage imageNamed: @"xuxian"]];
    [self.contentView addSubview:line];
}
- (void)configWithUserInfoDic:(NSDictionary*)dic{
    [self.userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"path"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    self.userNameLb.text = [LVTools mToString:dic[@"nickName"]];
    [self.userNameLb sizeToFit];
    NSString *age = @"0";
    NSString *birthday = [LVTools mToString:dic[@"birthday"]];
    if(birthday.length==0){
        age = @"0";
    }
    else{
        age = [LVTools fromDateToAge:[NSDate dateWithTimeIntervalSince1970:[dic[@"birthday"] floatValue]/1000]];
    }
    self.userGenderV.frame = CGRectMake(_userNameLb.right+mygap, 17, 30, 15);
    [self.userGenderV setAge:age];
    [self.userGenderV setGender:[LVTools mToString: dic[@"gender"]]];
    if ([LVTools mToString: dic[@"distance"]].length>0) {
        CGFloat distance = [dic[@"distance"] doubleValue];
        self.distanceLb.text = [NSString stringWithFormat:@"%.2fkm",distance];
    }
    else{
        self.distanceLb.text = @"定位失败";
    }
    if ([LVTools mToString:dic[@"lastlogin"]].length>0) {
        self.timeLb.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[dic[@"lastlogin"] longLongValue]/1000]];
    }
    else{
        self.timeLb.text = @"未知";
    }

}

#pragma mark getter
- (UIButton*)userIcon{
    if (_userIcon == nil) {
        _userIcon = [[UIButton alloc] initWithFrame:CGRectMake(mygap*4, mygap, 40.0, 40.0)];
        _userIcon.layer.masksToBounds = YES;
        _userIcon.layer.cornerRadius = mygap;
        _userIcon.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _userIcon.layer.borderWidth = 0.5;
    }
    return _userIcon;
}
- (UILabel*)userNameLb{
    if (_userNameLb == nil) {
        _userNameLb = [[UILabel alloc] initWithFrame:CGRectMake(_userIcon.right+mygap, 15, BOUNDS.size.width*0.4, 20)];
        _userNameLb.font = Btn_font;
        _userNameLb.text = @"北京首钢";
    }
    return _userNameLb;
}
- (ZHGenderView*)userGenderV{
    if (_userGenderV == nil) {
        _userGenderV = [[ZHGenderView alloc] initWithFrame:CGRectMake(_userNameLb.right+mygap, 17.0, 30, 15) WithGender:@"1" AndAge:@"0"];
    }
    return _userGenderV;
}
- (UILabel*)timeLb{
    if (_timeLb == nil) {
        _timeLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-60.0, 10, 60.0, 30)];
        _timeLb.textColor = [UIColor lightGrayColor];
        _timeLb.font = Content_lbfont;
    }
    return _timeLb;
}
- (UILabel*)distanceLb{
    if (_distanceLb == nil) {
        _distanceLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-120.0, 10, 60.0, 30.0)];
        _distanceLb.textColor = [UIColor lightGrayColor];
        _distanceLb.font = Content_lbfont;
    }
    return _distanceLb;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
