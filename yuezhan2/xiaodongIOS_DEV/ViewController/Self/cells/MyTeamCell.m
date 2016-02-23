//
//  MyTeamCell.m
//  yuezhan123
//
//  Created by admin on 15/8/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "MyTeamCell.h"

@implementation MyTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.separatorInset = UIEdgeInsetsMake(0, 65, 0, 0);
        
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        _headImg.contentMode = UIViewContentModeScaleAspectFill;
        _headImg.clipsToBounds = YES;
        [self.contentView addSubview:_headImg];
        
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 200, 16)];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textColor = NavgationColor;
        [self.contentView addSubview:_titleLab];
        
        _slogonLab = [[UILabel alloc] initWithFrame:CGRectMake(70, _titleLab.bottom+5, UISCREENWIDTH-80, 18)];
        _slogonLab.font = Content_lbfont;
        [self.contentView addSubview:_slogonLab];
        
        _typeImg = [[UIImageView alloc] initWithFrame:CGRectMake(_titleLab.right, 5, 16, 16)];
        _typeImg.layer.cornerRadius = 8;
        _typeImg.layer.masksToBounds = YES;
        [self.contentView addSubview:_typeImg];
        
        _countLab = [[UILabel alloc] initWithFrame:CGRectMake(70, _slogonLab.bottom+5, 55, 16)];
        _countLab.textColor = RGBACOLOR(130, 130, 130, 1);
        _countLab.font = Content_lbfont;
        [self.contentView addSubview:_countLab];
        
        _stateLab = [[UILabel alloc] initWithFrame:CGRectMake(_countLab.right, _countLab.top, 50, 16)];
        _stateLab.textColor = RGBACOLOR(240, 40, 40, 1);
        _stateLab.font = Content_lbfont;
        _stateLab.hidden = YES;
        [self.contentView addSubview:_stateLab];
    }
    return self;
}

- (void)configMyTeamWithDicinfo:(NSDictionary *)info {
    [_headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,info[@"iconPath"]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    CGFloat width = [LVTools sizeWithStr:info[@"teamName"] With:14 With2:16];
    _titleLab.width = width;
    _titleLab.text = info[@"teamName"];
    _typeImg.frame = CGRectMake(_titleLab.right, 5, 16, 16);
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    NSArray *allTypes = [NSArray arrayWithContentsOfFile:path];
    for (int i = 0; i < allTypes.count; i ++) {
        if ([allTypes[i][@"sport2"] isEqualToString:info[@"sportsType"]]) {
            _typeImg.image = [UIImage imageNamed:allTypes[i][@"name"]];
        }
    }
    _slogonLab.text = [LVTools mToString:info[@"slogan"]];
    _countLab.text = [NSString stringWithFormat:@"人数:%@",info[@"memberNum"]];
    _stateLab.hidden = YES;
}

- (void)configMyApplyWithDicInfo:(NSDictionary *)info {
    [_headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,info[@"teamDto"][@"iconPath"]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    NSString *teamName = [LVTools mToString: info[@"teamDto"][@"teamName"]];
    CGFloat width = [LVTools sizeWithStr:teamName With:14 With2:16];
    _titleLab.width = width;
    _titleLab.text = teamName;
    _typeImg.frame = CGRectMake(_titleLab.right, 5, 16, 16);
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    NSArray *allTypes = [NSArray arrayWithContentsOfFile:path];
    for (int i = 0; i < allTypes.count; i ++) {
        if ([allTypes[i][@"sport2"] isEqualToString:info[@"teamDto"][@"sportsType"]]) {
            _typeImg.image = [UIImage imageNamed:allTypes[i][@"name"]];
        }
    }
    _slogonLab.text = [LVTools mToString:info[@"teamDto"][@"slogan"]];
    _countLab.text = [NSString stringWithFormat:@"人数:%@",info[@"teamDto"][@"memberNum"]];
    _stateLab.hidden = NO;
    _stateLab.text = info[@"status"];
}

@end
