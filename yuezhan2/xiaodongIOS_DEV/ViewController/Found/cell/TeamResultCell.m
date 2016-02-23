//
//  TeamResultCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/20.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "TeamResultCell.h"

@implementation TeamResultCell

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
    [self.contentView addSubview:self.teamNameLb];
    [self.contentView addSubview:self.teamLevelImg];
    self.rankLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-75.0, 7.0, 20.0, 20.0)];
    self.rankLb.layer.cornerRadius = 10.0;
    self.rankLb.layer.masksToBounds = YES;
    self.rankLb.font = Content_lbfont;
    self.rankLb.textColor =[UIColor whiteColor];
    self.rankLb.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rankLb];
//    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, 0, BOUNDS.size.width*(711.0/750.0), 1)];
//    [line setImage:[UIImage imageNamed: @"xuxian"]];
//    [self.contentView addSubview:line];
    
}
- (void)configWithTeamInfoDic:(NSDictionary*)dic{
    [self.teamImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"teamFace"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    self.teamNameLb.text = [LVTools mToString:dic[@"teamName"]];
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
        _teamLevelImg.layer.masksToBounds = YES;
        _teamLevelImg.layer.cornerRadius = _teamLevelImg.width/2.0;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
