//
//  TeamCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/11.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "TeamCell.h"

@implementation TeamCell

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
    [self.contentView addSubview:self.teamImg];
    [self.contentView addSubview:self.teamLevelImg];
    [self.contentView addSubview:self.teamNameLb];
    [self.contentView addSubview:self.zanCountLb];
    [self.contentView addSubview:self.zanBtn];
    [self.contentView addSubview:self.contentLb];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, 34.0, BOUNDS.size.width*(711.0/750.0), 1)];
    [line setImage:[UIImage imageNamed: @"xuxian"]];
    [self.contentView addSubview:line];

}
- (void)configWithTeamInfoDic:(NSDictionary*)dic{
    [self.teamImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"teamFace"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    NSInteger teamLevel = [dic[@"teamLevel"] integerValue];
    if (teamLevel == 0) {
        [self.teamLevelImg setImage:[UIImage imageNamed:@"lv_3"]];
    }
    else{
        
        if (teamLevel>0&&teamLevel<100) {
            [self.teamLevelImg setImage:[UIImage imageNamed:@"lv_2"]];
        }
        else if(teamLevel>99&&teamLevel<1000){
            [self.teamLevelImg setImage:[UIImage imageNamed:@"lv_2"]];
        }
        else{
            [self.teamLevelImg setImage:[UIImage imageNamed:@"lv_1"]];
        }
    }

    self.teamNameLb.text = [LVTools mToString:dic[@"teamName"]];
    self.contentLb.text = [LVTools mToString:dic[@"scores"]];
    if ([dic[@"isAdmire"] intValue]>0) {
        self.zanBtn.selected = YES;
    }
    else{
        self.zanBtn.selected = NO;
    }
    self.zanCountLb.text = [LVTools mToString:dic[@"admireNum"]];
}
- (void)configWithUserInfoDic:(NSDictionary*)dic{
    [self.teamImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"face"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    self.teamNameLb.text = [LVTools mToString:dic[@"userName"]];
    self.contentLb.text = [LVTools mToString:dic[@"scores"]];
    if ([dic[@"isAdmire"] intValue]>0) {
        self.zanBtn.selected = YES;
    }
    else{
        self.zanBtn.selected = NO;
    }
    self.zanCountLb.text = [LVTools mToString:dic[@"admireNum"]];
}

#pragma mark getter
- (UIButton*)teamImg{
    if (_teamImg == nil) {
        _teamImg = [[UIButton alloc] initWithFrame:CGRectMake(mygap*4, mygap, 25.0, 25.0)];
        _teamImg.layer.masksToBounds = YES;
        _teamImg.layer.cornerRadius = mygap;
        _teamImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _teamImg.layer.borderWidth = 0.5;
    }
    return _teamImg;
}
- (UIImageView*)teamLevelImg{
    if (_teamLevelImg == nil) {
        _teamLevelImg = [[UIImageView alloc] initWithFrame:CGRectMake(_teamImg.right-8, _teamImg.bottom-8, 10.0, 10.0)];
    }
    return _teamLevelImg;
}
- (UILabel*)teamNameLb{
    if (_teamNameLb == nil) {
        _teamNameLb = [[UILabel alloc] initWithFrame:CGRectMake(_teamImg.right+mygap, 0, BOUNDS.size.width*0.4, 35.0)];
        _teamNameLb.font = Btn_font;
        _teamNameLb.text = @"北京首钢";
    }
    return _teamNameLb;
}
- (UILabel*)zanCountLb{
    if (_zanCountLb == nil) {
        _zanCountLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-40.0, 7.0, 35.0, 20.0)];
        _zanCountLb.font = Btn_font;
        _zanCountLb.text = @"9";
        _zanCountLb.textColor = [UIColor colorWithRed:0.557 green:0.561 blue:0.565 alpha:1.00];
        _zanCountLb.textAlignment = NSTextAlignmentCenter;
    }
    return _zanCountLb;
}
- (UIButton*)zanBtn{
    if (_zanBtn == nil) {
        _zanBtn = [[UIButton alloc] initWithFrame:CGRectMake(_zanCountLb.left-25.0, 7.0, 20.0, 20.0)];
        [_zanBtn setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
        [_zanBtn setBackgroundImage:[UIImage imageNamed:@"zaned"] forState:UIControlStateSelected];
        
    }
    return _zanBtn;
}
- (UILabel*)contentLb{
    if (_contentLb == nil) {
        _contentLb = [[UILabel alloc] initWithFrame:CGRectMake(_zanBtn.left-100.0, mygap, 60.0, 25.0)];
        _contentLb.text = @"未开赛";
        _contentLb.textAlignment = NSTextAlignmentCenter;
        _contentLb.font = Btn_font;
    }
    return _contentLb;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
