//
//  ZHVenueCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/24.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHVenueCell.h"
#import "ZHVenueModel.h"
#define bordwidth 5.0
#define VenueCell_height 120.0
#define TitleLb_height 30.0
#define ContentLb_height 20.0
#define contentFont 13.0
#define boardWidth 0.4
#define contentTextColor [UIColor lightGrayColor]
@implementation ZHVenueCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self customViews];
    }
    return self;
}
- (void)configVenueModel:(ZHVenueModel *)venueModel{
    
    self.nameLb.text = [NSString stringWithFormat:@"%@",venueModel.venuesName];
    [self.mImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,venueModel.path]] placeholderImage:[UIImage imageNamed:@"venue_plo"]];
    self.locationLb.text = venueModel.distance;
    self.isYudingLb.text = venueModel.reservation;
    self.dizhiLb.text =[NSString stringWithFormat:@"%@%@",venueModel.cityMeaning,venueModel.areaMeaning];
    NSString *str = [LVTools mToString:venueModel.bottomPrice];
    if (str.length > 0) {
        str = [str stringByAppendingString:@"元起"];
        self.isfreeLb.text = str;
    }
    NSString *scoreStr = [LVTools mToString:venueModel.level];
    NSLog(@"scoreStr ========================== %@",scoreStr);
    
    if (scoreStr.length == 1) {
        [self setScoreWith:scoreStr];
    } else {
        [self setScoreWith:@"5"];//默认三星
    }
    if ([[LVTools mToString:venueModel.promote] isEqualToString:@"SF_0001"]) {
        self.jianView.hidden = NO;
    } else {
        self.jianView.hidden = YES;
    }
}

- (void)customViews{
    self.breakLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, boardWidth)];
    self.breakLine.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [self.contentView addSubview:self.breakLine];
    //图片
    self.mImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bordwidth*2, bordwidth*2, 110, 80)];
    self.mImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.mImageView];
    //name
    self.nameLb = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right+bordwidth*2, self.mImageView.top, BOUNDS.size.width-self.mImageView.right-bordwidth*2-30, ContentLb_height)];
    self.nameLb.text = @"天星华普高尔夫俱乐部";
    self.nameLb.font = Btn_font;
    self.nameLb.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.nameLb];
    //地区
    self.dizhiLb = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLb.left, self.nameLb.bottom, BOUNDS.size.width-(_mImageView.right+bordwidth*2), ContentLb_height)];
    self.dizhiLb.text = @"北京市朝阳区";
    self.dizhiLb.textColor = [UIColor lightGrayColor];
    self.dizhiLb.font = [UIFont systemFontOfSize:contentFont];
    [self.contentView addSubview:self.dizhiLb];
    //price
    self.isfreeLb =[[UILabel alloc] initWithFrame:CGRectMake(self.nameLb.left, self.dizhiLb.bottom, _dizhiLb.width, ContentLb_height)];
    self.isfreeLb.text = @"100元起";
    self.isfreeLb.textColor = contentTextColor;
    self.isfreeLb.font = [UIFont systemFontOfSize:contentFont];
    [self.contentView addSubview:self.isfreeLb];
    //评分
    self.Pingfen = [[UIView alloc] initWithFrame:CGRectMake(self.nameLb.left, self.isfreeLb.bottom, 150, ContentLb_height)];
    self.Pingfen.backgroundColor = [UIColor whiteColor];
    for (NSInteger i=0; i<5; i++) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(i*(15+bordwidth), 0, 15, 15)];
        img.tag = 100+i;
        img.image = [UIImage imageNamed:@"unstar"];
        [self.Pingfen addSubview:img];
    }
    [self.contentView addSubview:self.Pingfen];
    
    self.locationImg = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width - 80, self.Pingfen.top+mygap, 15, 15)];
    self.locationImg.image = [UIImage imageNamed:@"Marker"];
    [self.contentView addSubview:self.locationImg];
    
    self.locationLb = [[UILabel alloc] initWithFrame:CGRectMake(self.locationImg.frame.origin.x+self.locationImg.frame.size.width, self.locationImg.frame.origin.y-3.0, 60, 20)];
    self.locationLb.textColor = [UIColor lightGrayColor];
    self.locationLb.text = @"2.3km";
    self.locationLb.font = [UIFont systemFontOfSize:contentFont];
    [self.contentView addSubview:self.locationLb];
    
    //是否推荐
    self.jianView = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width-30, 0, 17, 17)];
    self.jianView.image = [UIImage imageNamed:@"venueJian"];
    [self.contentView addSubview:self.jianView];

}
- (void)setScoreWith:(NSString*)score{
    int pingfen = [score intValue];
    for (NSInteger i=0; i<pingfen; i++) {
        UIImageView *img = (UIImageView*)[self.Pingfen viewWithTag:100+i];
        img.image = [UIImage imageNamed:@"star"];
        NSLog(@"111111");
    }
    for (NSInteger i = pingfen; i < 5; i ++) {
        UIImageView *img = (UIImageView*)[self.Pingfen viewWithTag:100+i];
        img.image = [UIImage imageNamed:@"unstar"];
    }
}


@end
