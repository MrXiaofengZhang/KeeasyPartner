//
//  WPCApointInfoTableViewCell.m
//  yuezhan123
//
//  Created by admin on 15/5/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCApointInfoTableViewCell.h"

@implementation WPCApointInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *carryView = [[UIView alloc] init];
        carryView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:carryView];
        
        self.iconImage = [[UIImageView alloc] init];
        self.titleLab = [[UILabel alloc] init];
        self.dateLab = [[UILabel alloc] init];
        self.appliedNumLab = [[UILabel alloc] init];
        self.contentImage = [[UIImageView alloc] init];
        self.appliedNumLab.textAlignment = NSTextAlignmentLeft;
        self.appliedNumLab.textColor = [UIColor redColor];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.text = @"已报名人数:";
        lab.textColor = [UIColor colorWithRed:135/255.0f green:135/255.0f blue:135/255.0f alpha:1];
        lab.textAlignment = NSTextAlignmentRight;
        
        
        if (UISCREENWIDTH == 320) {
            self.bounds = CGRectMake(0, 0, UISCREENWIDTH, 170);
            carryView.frame = CGRectMake(5, 0, UISCREENWIDTH-10, self.bounds.size.height);
            self.iconImage.frame = CGRectMake(5, 8, 35, 35);
            self.titleLab.frame = CGRectMake(45, 8, 200, 18);
            self.dateLab.frame = CGRectMake(45, 28, 160, 16);
            lab.frame = CGRectMake(180, 28, 80, 16);
            self.appliedNumLab.frame = CGRectMake(260, 28, 55, 16);
            self.contentImage.frame = CGRectMake(0, 50, carryView.bounds.size.width, 130);
            self.titleLab.font = [UIFont systemFontOfSize:15];
            self.dateLab.font = [UIFont systemFontOfSize:14];
            self.appliedNumLab.font = [UIFont systemFontOfSize:14];
            lab.font = [UIFont systemFontOfSize:14];
        } else if (UISCREENWIDTH == 375) {
            self.bounds = CGRectMake(0, 0, UISCREENWIDTH, 200);
            carryView.frame = CGRectMake(5, 0, UISCREENWIDTH-10, self.bounds.size.height);
            self.iconImage.frame = CGRectMake(5, 10, 40, 40);
            self.titleLab.frame = CGRectMake(50, 10, 220, 19);
            self.dateLab.frame = CGRectMake(50, 34, 180, 16);
            lab.frame = CGRectMake(200, 34, 100, 16);
            self.appliedNumLab.frame = CGRectMake(300, 34, 55, 16);
            self.contentImage.frame = CGRectMake(0, 60, carryView.bounds.size.width, 140);
            self.titleLab.font = [UIFont systemFontOfSize:16];
            self.dateLab.font = [UIFont systemFontOfSize:15];
            self.appliedNumLab.font = [UIFont systemFontOfSize:15];
            lab.font = [UIFont systemFontOfSize:15];
        } else {
            self.bounds = CGRectMake(0, 0, UISCREENWIDTH, 230);
            carryView.frame = CGRectMake(8, 0, UISCREENWIDTH-16, self.bounds.size.height);
            self.iconImage.frame = CGRectMake(8, 10, 45, 45);
            self.titleLab.frame = CGRectMake(64, 10, 230, 22);
            self.dateLab.frame = CGRectMake(64, 34, 180, 19);
            lab.frame = CGRectMake(240, 34, 100, 19);
            self.appliedNumLab.frame = CGRectMake(340, 34, 65, 19);
            self.contentImage.frame = CGRectMake(0, 65, carryView.bounds.size.width, 165);
            self.titleLab.font = [UIFont systemFontOfSize:17];
            self.dateLab.font = [UIFont systemFontOfSize:16];
            self.appliedNumLab.font = [UIFont systemFontOfSize:16];
            lab.font = [UIFont systemFontOfSize:16];
        }
        
        self.dateLab.textColor = [UIColor colorWithRed:130/255.0f green:130/255.0f blue:130/255.0f alpha:1];
        
        self.iconImage.backgroundColor = [UIColor redColor];
        self.titleLab.text = @"2014北京现代国际马拉松";
        self.dateLab.text = @"2015.4.4-2015.5.5";
        self.appliedNumLab.text = @"22/100";
        self.contentImage.backgroundColor = [UIColor blueColor];
        
        [carryView addSubview:self.iconImage];
        [carryView addSubview:self.titleLab];
        [carryView addSubview:self.dateLab];
        [carryView addSubview:lab];
        [carryView addSubview:self.appliedNumLab];
        [carryView addSubview:self.contentImage];
        
    }
    return self;
}

- (void)configCellContentWithDic:(NSDictionary *)dic
{
    //通过dic对cell contentview进行赋值
    NSArray *array = [LVTools sportStylePlist];
    NSString *sportsType = [LVTools mToString:dic[@"sportsType"]];
    for (int i = 0; i < array.count; i ++) {
        if ([sportsType isEqualToString:array[i][@"sport1"]]) {
            self.iconImage.image = [UIImage imageNamed:array[i][@"img1"]];
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
