//
//  WPCTeamCell.m
//  yuezhan123
//
//  Created by admin on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCTeamCell.h"
#import "TeamModel.h"
@implementation WPCTeamCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.separatorInset = UIEdgeInsetsMake(0, 184*propotion, 0, 0);
        [self makeUI];
    }
    return self;
}
- (void)configTeamModel:(TeamModel*)model{
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString: model.path]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    NSString *nameString = [LVTools mToString:model.teamName];
    CGFloat width = [LVTools sizeWithStr:nameString With:15 With2:32*propotion];
    if (width>BOUNDS.size.width-self.nameLab.left-130-20) {
        self.nameLab.width =BOUNDS.size.width-self.nameLab.left-130-20;
    }
    else{
    self.nameLab.width = width;
    }
    self.nameLab.text = nameString;
    self.typeImg.frame = CGRectMake(_nameLab.right, _nameLab.top, 32*propotion, 32*propotion);
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    NSArray *allTypes = [NSArray arrayWithContentsOfFile:path];
    NSString *imgStr = nil;
    for (int i = 0; i < allTypes.count; i ++) {
        if ([[LVTools mToString:model.sportsType] isEqualToString:allTypes[i][@"sport2"]]) {
            imgStr = allTypes[i][@"name"];
        }
    }
    //wpctodo
    self.typeImg.image = [UIImage imageNamed:imgStr];
    self.decleartionLab.text = [LVTools mToString:model.schoolName];
//    if ([[LVTools mToString:model.status] isEqualToString:@"1"]) {
//        _playingLab.hidden = NO;
//    } else if ([[LVTools mToString:model.status] isEqualToString:@"0"]) {
//        _playingLab.hidden = YES;
//    }
    if ([[LVTools mToString:model.matchStatus] isEqualToString:@"1"]) {
        _matchingLab.hidden = NO;
    } else if ([[LVTools mToString:model.matchStatus] isEqualToString:@"0"]) {
        _matchingLab.hidden = YES;
    }
    if ([LVTools mToString: model.distance].length>0) {
    CGFloat distance = [model.distance doubleValue];
    self.distanceLab.text = [NSString stringWithFormat:@"%.2fkm",distance];
    }
    else{
        self.distanceLab.text = @"定位失败";
    }
    NSInteger teamLevel = [model.teamLevel integerValue];
    if (teamLevel == 0) {
        [self.rankImg setBackgroundImage:[UIImage imageNamed:@"lv_3"]forState:UIControlStateNormal];
        [self.rankImg setTitle:@"1" forState:UIControlStateNormal];
    }
    else{
        
    if (teamLevel>0&&teamLevel<100) {
        [self.rankImg setBackgroundImage:[UIImage imageNamed:@"lv_2"]forState:UIControlStateNormal];
        [self.rankImg setTitle:[NSString stringWithFormat:@"%d",(int)teamLevel] forState:UIControlStateNormal];
    }
    else if(teamLevel>99&&teamLevel<1000){
        [self.rankImg setBackgroundImage:[UIImage imageNamed:@"lv_2"]forState:UIControlStateNormal];
        [self.rankImg setTitle:@"99+" forState:UIControlStateNormal];
    }
    else{
        [self.rankImg setBackgroundImage:[UIImage imageNamed:@"lv_1"]forState:UIControlStateNormal];
        [self.rankImg setTitle:@"" forState:UIControlStateNormal];
    }
    }
}
- (void)makeUI {
    _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(20*propotion, 20*propotion, 145*propotion, 145*propotion)];
    _headImg.layer.cornerRadius = 3;
    _headImg.layer.masksToBounds = YES;
    _headImg.contentMode = UIViewContentModeScaleAspectFill;
    _headImg.clipsToBounds = YES;
    [self.contentView addSubview:_headImg];
    
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.right+20*propotion, 30*propotion, 70, 32*propotion)];
    _nameLab.text = @"啦啦啦啦";
    _nameLab.font = Btn_font;
    [self.contentView addSubview:_nameLab];
    
    _typeImg = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLab.right, _nameLab.top, 32*propotion, 32*propotion)];
    [self.contentView addSubview:_typeImg];
    
    _decleartionLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.left, _nameLab.bottom+20*propotion, UISCREENWIDTH-_nameLab.left-5, 32*propotion)];
    _decleartionLab.text = @"i have a dream that one day my dream isn`t day-dream";
    _decleartionLab.textColor = RGBACOLOR(140, 140, 140, 1);
    _decleartionLab.font = Btn_font;
    [self.contentView addSubview:_decleartionLab];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(_nameLab.left, _decleartionLab.bottom+20*propotion, 15, 15);
//    btn.backgroundColor = [UIColor redColor];
    [btn setImage:[UIImage imageNamed:@"Marker"] forState:UIControlStateNormal];
    [self.contentView addSubview:btn];
    
    _distanceLab = [[UILabel alloc] initWithFrame:CGRectMake(btn.right, _decleartionLab.bottom+20*propotion, 60, 14)];
    _distanceLab.text = @"0.08km";
    _distanceLab.font = Content_lbfont;
    _distanceLab.textColor = RGBACOLOR(140, 140, 140, 1);
    [self.contentView addSubview:_distanceLab];
        
//    _playingLab = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-130, self.nameLab.top, 60, 20)];
//    _playingLab.layer.cornerRadius = 40*propotion/2;
//    _playingLab.layer.masksToBounds = YES;
//    _playingLab.text = @"约战ing";
//    _playingLab.textColor = [UIColor whiteColor];
//    _playingLab.hidden = YES;
//    _playingLab.textAlignment = NSTextAlignmentCenter;
//    _playingLab.font = [UIFont systemFontOfSize:12];
//    _playingLab.textColor = [UIColor whiteColor];
//    _playingLab.backgroundColor = NavgationColor;
//    [self.contentView addSubview:_playingLab];
    
    _matchingLab = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-65,self.nameLab.top, 60, 20)];
    _matchingLab.layer.cornerRadius = 40*propotion/2;
    _matchingLab.layer.masksToBounds = YES;
    _matchingLab.text = @"赛事ing";
    _matchingLab.hidden = YES;
    _matchingLab.textColor = [UIColor whiteColor];
    _matchingLab.textAlignment = NSTextAlignmentCenter;
    _matchingLab.font = [UIFont systemFontOfSize:12];
    _matchingLab.textColor = [UIColor whiteColor];
    _matchingLab.backgroundColor = SystemBlue;
    [self.contentView addSubview:_matchingLab];
    
    _rankImg = [[UIButton alloc] initWithFrame:CGRectMake(_headImg.right-15.0f, _headImg.bottom-15.0f, 20.0f, 20.0f)];
    _rankImg.contentMode = UIViewContentModeScaleAspectFit;
    _rankImg.titleLabel.textColor = [UIColor whiteColor];
    _rankImg.titleLabel.font = [UIFont systemFontOfSize:9];
    [self.contentView addSubview:_rankImg];
    
    _ownerImg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    [_ownerImg setBackgroundImage:[UIImage imageNamed:@"owner"] forState:UIControlStateNormal];
    _headImg.userInteractionEnabled = YES;
    [self.headImg addSubview:_ownerImg];
    
    _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-LEFTX-40.0f, _matchingLab.bottom+mygap*2, 30.0f, 30.0f)];
    [_addBtn setImage:[UIImage imageNamed:@"addAtt"] forState:UIControlStateNormal];
    _addBtn.hidden = YES;
    //[self.contentView addSubview:_addBtn];
}

@end
