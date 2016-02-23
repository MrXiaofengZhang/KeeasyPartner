//
//  ScoreCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/14.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "ScoreCell.h"

@implementation ScoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    return self;
}
- (void)createView{
    [self.contentView addSubview:self.dateLb];
    [self.contentView addSubview:self.monthLb];
    UILabel *grayLb = [[UILabel alloc] initWithFrame:CGRectMake(_monthLb.right+mygap*2, _dateLb.top, BOUNDS.size.width-_monthLb.right-mygap*3, 50.0)];
    grayLb.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.00];
    [self.contentView addSubview:grayLb];
    
    [self.contentView addSubview:self.sportLb];
    self.sportLb.frame = CGRectMake(_monthLb.right+mygap*2+mygap/2, _dateLb.top, grayLb.width-mygap/2, 30.0);
    [self.contentView addSubview:self.statusLb];
    self.statusLb.frame = CGRectMake(_monthLb.right+mygap*2+mygap/2, _dateLb.top+30.0, grayLb.width-mygap/2, 20.0);
}
- (void)configInfo:(NSDictionary*)dic{
    self.statusLb.text = [LVTools mToString:dic[@"info"]];
    self.sportLb.text = [LVTools mToString:dic[@"matchName"]];
   
    NSArray *dateStrArr = [[NSString stringIntervalSince1970:[dic[@"startTime"] floatValue]/1000] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": -"]];
    
    _dateLb.text = [dateStrArr objectAtIndex:2];
    _monthLb.text = [NSString stringWithFormat:@"%@月", [dateStrArr objectAtIndex:1]];
}
#pragma mark getter
- (UILabel*)dateLb{
    if (_dateLb == nil) {
        _dateLb = [[UILabel alloc] initWithFrame:CGRectMake(mygap, mygap*2, 50.0, 50.0)];
        _dateLb.font = [UIFont systemFontOfSize:40.0];
        _dateLb.text = @"18";
        _dateLb.textColor = [UIColor blackColor];
    }
    return _dateLb;
}
- (UILabel*)monthLb{
    if (_monthLb == nil) {
        _monthLb = [[UILabel alloc] initWithFrame:CGRectMake(_dateLb.right, _dateLb.top+25.0, 50.0, 25.0)];
        _monthLb.font = [UIFont systemFontOfSize:17.0];
        _monthLb.text = @"10月";
        _monthLb.textColor = [UIColor blackColor];
    }
    return _monthLb;
}
- (UILabel*)sportLb{
    if (_sportLb == nil) {
        _sportLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
        _sportLb.font = [UIFont systemFontOfSize:17.0];
        _sportLb.text = @"上海交通大学阳光篮球赛";
        _sportLb.textColor = [UIColor blackColor];
    }
    return _sportLb;
}
- (UILabel*)statusLb{
    if (_statusLb == nil) {
        _statusLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0, 20.0)];
        _statusLb.font = [UIFont systemFontOfSize:17.0];
        _statusLb.text = @"正在比赛";
        _statusLb.textColor = [UIColor colorWithRed:0.455 green:0.455 blue:0.455 alpha:1.00];
    }
    return _statusLb;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
