//
//  ZHVenueOrderCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHVenueOrderCell.h"
#import "ZHVenueModel.h"
#define bordwidth 5.0
#define VenueCell_height 120.0
#define TitleLb_height 30.0
#define ContentLb_height 20.0
#define contentFont 13.0
#define boardWidth 0.4
#define contentTextColor [UIColor lightGrayColor]

@implementation ZHVenueOrderCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //[self createViews];//老版本布局
        [self customViews];
    }
    return self;
}
- (void)configVenueModel:(NSDictionary *)dict{
    self.btn.hidden = YES;
    self.invalidImg.hidden = YES;
    [self.mImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dict[@"url"] ]]] placeholderImage:[UIImage imageNamed:@"venue_plo"]];
    self.nameLb.text = [LVTools mToString:dict[@"orderName"]];
    self.dizhiLb.text = [NSString stringWithFormat:@"总价:%@  数量:%@",[LVTools mToString:dict[@"amount"]],[LVTools mToString:dict[@"quantity"]]];
    if ([[LVTools mToString:dict[@"status"]] isEqualToString:DDZT_0001]) {
        self.isfreeLb.text = @"未支付";
        self.btn.hidden = NO;
    } else if ([[LVTools mToString:dict[@"status"]] isEqualToString:DDZT_0002]) {//需加一个判断，是在退款截至日之前,并且是非团购的才行
        self.isfreeLb.text = @"已支付";
        if ([[LVTools mToString:dict[@"packageName"]] length] == 0) {
            NSString *dateString = [LVTools mToString:dict[@"bookStartDate"]];
            NSLog(@"datestring ==== %@",dateString);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
            NSDate *lastdate = [formatter dateFromString:dateString];
            NSTimeInterval finalInterval = [lastdate timeIntervalSince1970];
            
            NSDate *nowdate = [NSDate date];
            NSTimeInterval nowInterval = [nowdate timeIntervalSince1970];
            NSLog(@"now === %f",nowInterval);
            NSLog(@"last === %f",finalInterval);
            int time = [[LVTools mToString:dict[@"leadTime"]] intValue];
            
            if (nowInterval+3600*time<finalInterval) {
                self.btn.hidden = NO;
                [self.btn setTitle:@"申请退款" forState:UIControlStateNormal];
            }
        }
    } else if ([[LVTools mToString:dict[@"status"]] isEqualToString:DDZT_0003]) {
        self.invalidImg.hidden = NO;
        self.isfreeLb.text = @"无效";
    } else if ([[LVTools mToString:dict[@"status"]] isEqualToString:DDZT_0004]) {
        self.isfreeLb.text = @"退款申请中";
        self.btn.hidden = NO;
        [self.btn setTitle:@"退款流程" forState:UIControlStateNormal];
    } else if ([[LVTools mToString:dict[@"status"]] isEqualToString:DDZT_0005]) {
        self.isfreeLb.text = @"待评价";
        self.btn.hidden = NO;
        [self.btn setTitle:@"前往评价" forState:UIControlStateNormal];
    } else if ([[LVTools mToString:dict[@"status"]] isEqualToString:DDZT_0006]) {
        self.isfreeLb.text = @"已评价";
    } else if ([[LVTools mToString:dict[@"status"]] isEqualToString:DDZT_0007]) {
        self.isfreeLb.text = @"已退款";
    }
}
- (void)customViews{
    
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
    self.isfreeLb =[[UILabel alloc] initWithFrame:CGRectMake(self.nameLb.left, self.dizhiLb.bottom+20, _dizhiLb.width, ContentLb_height)];
    self.isfreeLb.text = @"100元起";
    self.isfreeLb.textColor = color_red_dan;
    self.isfreeLb.font = [UIFont systemFontOfSize:contentFont];
    
    self.invalidImg = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width-100, 20, 80, 55)];
    self.invalidImg.hidden = YES;
    self.invalidImg.image = [UIImage imageNamed:@"invalid"];
    [self.contentView addSubview:self.invalidImg];
    [self.contentView addSubview:self.isfreeLb];
    
    self.btn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-85, 60, 70, 20)];
    [self.btn setBackgroundColor:NavgationColor];
    self.btn.layer.cornerRadius = 5.0;
    [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn setTitle:@"立即支付" forState:UIControlStateNormal];
    self.btn.titleLabel.font = Content_lbfont;
    self.btn.hidden = YES;
    [self.contentView addSubview:self.btn];
    self.breakLine = [[UIView alloc] initWithFrame:CGRectMake(0, 100, BOUNDS.size.width, boardWidth)];
    self.breakLine.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [self.contentView addSubview:self.breakLine];
}
- (void)setScoreWith:(NSString*)score{
    CGFloat pingfen = [score floatValue];
    for (NSInteger i=0; i<pingfen; i++) {
        UIImageView *img = (UIImageView*)[self.contentView viewWithTag:100+i];
        img.image = [UIImage imageNamed:@"star"];
    }
}
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    //[self createViews];
    [self customViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
