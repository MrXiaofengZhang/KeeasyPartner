//
//  ZHSportOrderCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHSportOrderCell.h"
#import "GetMatchListModel.h"
@implementation ZHSportOrderCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createViews];
    }
    return self;
}
- (void)createViews{
    self.contentView.backgroundColor = [UIColor colorWithRed:0.929f green:0.933f blue:0.937f alpha:1.00f];
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 90)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:whiteView];
    
    self.SportImg = [[UIImageView alloc] initWithFrame:CGRectMake(mygap, mygap, BOUNDS.size.width*0.4, 90-10)];
    self.SportImg.contentMode = UIViewContentModeScaleAspectFill;
    self.SportImg.clipsToBounds = YES;
    self.sportStatus = [[UIImageView alloc] initWithFrame:CGRectMake(self.SportImg.width-60, 60, 46, 16)];
    self.sportStatus.image = [UIImage imageNamed:@"BisaiBegin"];
    [self.SportImg addSubview:self.sportStatus];
    [whiteView addSubview:self.SportImg];
    
    self.moneyLb = [[UILabel alloc] initWithFrame:CGRectMake(self.SportImg.right+mygap, self.SportImg.top, BOUNDS.size.width-self.SportImg.right-mygap*2, 40)];
    self.moneyLb.text = @"报名费:150元/人";
    self.moneyLb.font = Btn_font;
    self.moneyLb.numberOfLines = 2;
    [whiteView addSubview:self.moneyLb];
    
    self.countLb = [[UILabel alloc] initWithFrame:CGRectMake(self.moneyLb.left, self.moneyLb.bottom+2, self.moneyLb.width, self.moneyLb.height)];
    self.countLb.text = @"数量:12";
    self.countLb.font = Content_lbfont;
    self.countLb.textColor = [UIColor lightGrayColor];
    [whiteView addSubview:self.countLb];
    
    self.accountLb = [[UILabel alloc] initWithFrame:CGRectMake(self.moneyLb.left, self.countLb.bottom+2, self.moneyLb.width, self.moneyLb.height)];
    //self.accountLb.text = @"总计:2250元";
    self.accountLb.font = Content_lbfont;
    [whiteView addSubview:self.accountLb];
    
    
    self.stateLb = [[UILabel alloc] initWithFrame:CGRectMake(self.moneyLb.left, self.accountLb.bottom+2, self.moneyLb.width, self.moneyLb.height)];
    self.stateLb.textColor = color_red_dan;
    //self.stateLb.text = @"未付款";
    self.stateLb.font = Content_lbfont;
    [whiteView addSubview:self.stateLb];
    
//    self.payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.payBtn setFrame:CGRectMake(BOUNDS.size.width-90, self.stateLb.top-mygap*2, 80, 20)];
//    [self.payBtn setTitle:@"立即支付" forState:UIControlStateNormal];
//    [self.payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.payBtn setBackgroundColor:NavgationColor];
//    self.payBtn.titleLabel.font = Content_lbfont;
//    self.payBtn.hidden = YES;
//    self.payBtn.layer.cornerRadius = 5.0;
//    
//    [whiteView addSubview:self.payBtn];
}
- (void)configMatchModel:(GetMatchListModel*)model{
    [self.SportImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model.matchPath]]] placeholderImage:[UIImage imageNamed:@"match_plo"]];
    self.moneyLb.text = [LVTools mToString:model.matchName];
    self.countLb.text =[NSString stringWithFormat:@"%@至%@", [LVTools mToString:model.startDate],[LVTools mToString:model.endDate]];
    self.stateLb.textColor = NavgationColor;
    self.stateLb.text = @"报名成功";
}
- (void)configMatchDic:(NSDictionary *)dic{
    self.payBtn.hidden = YES;
    [self.SportImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic[@"matchShow"]]]] placeholderImage:[UIImage imageNamed:@"match_plo"]];
    self.moneyLb.text =[LVTools mToString:dic[@"name"]];
    NSString *beginTime = [NSString getCreateTime:[NSString stringWithFormat:@"%lld", [dic[@"starttime"] longLongValue]/1000]];
    NSString *endTime = [NSString getCreateTime:[NSString stringWithFormat:@"%lld", [dic[@"endtime"] longLongValue]/1000]];
    self.countLb.text = [NSString stringWithFormat:@"%@-%@",beginTime,endTime];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"starttime"] floatValue]/1000];
    
    if ([startDate compare:[NSDate date]]==NSOrderedDescending) {
        //即将开赛
        self.sportStatus.image = [UIImage imageNamed:@"BisaiBegin"];
    }
    else{
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"endtime"] floatValue]/1000];
        if ([endDate compare:[NSDate date]]==NSOrderedDescending) {
            //比赛中
            self.sportStatus.image = [UIImage imageNamed:@"Bisaiing"];
        }
        else{
            //比赛结束
            self.sportStatus.image = [UIImage imageNamed:@"BisaiEnd"];
        }
    }
    NSString *stateStr =[LVTools mToString:dic[@""]];
    if ([stateStr isEqualToString:@"0"]) {
        self.stateLb.text = @"已报名";
        self.stateLb.textColor = NavgationColor;
    }
    else if([stateStr isEqualToString:@"1"]){
        self.stateLb.text = @"报名成功";
        self.textLabel.textColor = NavgationColor;
    }
    else if([stateStr isEqualToString:@"2"]){
        self.stateLb.text = @"报名未通过";
        self.textLabel.textColor  = color_red_dan;
    }
    else{
        self.stateLb.text = @"未知错误";
        self.textLabel.textColor = color_red_dan;
    }
//    self.accountLb.text = [NSString stringWithFormat:@"总计:%.2f元",[dic[@"amount"] doubleValue]];
//    
//    //计算报名截止时间差
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *startPay = [formatter dateFromString:[LVTools mToString:dic[@"matchVerifyUptoTime"]]];
//    NSTimeInterval start = [startPay timeIntervalSince1970];
//    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSTimeInterval now = [date timeIntervalSince1970];
//    NSTimeInterval startcha = now - start;
//    
//    NSDate *endPay = [formatter dateFromString:[LVTools mToString:dic[@"payUptoTime"]]];
//    NSTimeInterval end = [endPay timeIntervalSince1970];
//    NSTimeInterval endcha = now - end;
//    
//    if (startcha > 0 && endcha < 0) {
//        _duringPay = YES;
//    }
//    
//    NSDate *matchEnd = [formatter dateFromString:[LVTools mToString:dic[@"matchEndTime"]]];
//    NSTimeInterval matchend = [matchEnd timeIntervalSince1970];
//    NSTimeInterval matchendCha = now - matchend;
//    if (matchendCha > 0) {
//        _matchHasEnd = YES;
//    }
//    
//    if (_matchHasEnd) {
//        self.stateLb.text = @"赛事已完结";
//    }
//    
//    if ([[LVTools mToString:dic[@"status"]] isEqualToString:DDZT_0001]) {
//        if ([[LVTools mToString:dic[@"verifyStatus"]] isEqualToString:@"BMSH_0001"]) {//审核中
//            self.stateLb.text = @"审核中";
//        } else if ([[LVTools mToString:dic[@"verifyStatus"]] isEqualToString:@"BMSH_0002"]) {//通过
//            self.stateLb.text = @"审核通过";
//            //判断当前时间是否在支付时间内。
//            if (_duringPay) {
//                self.payBtn.hidden = NO;
//            }
//        } else if ([[LVTools mToString:dic[@"verifyStatus"]] isEqualToString:@"BMSH_0003"]) {//审核未通过，只能在ddzt0003下
//            self.stateLb.text = @"审核未通过";
//        } else if ([[LVTools mToString:dic[@"verifyStatus"]] isEqualToString:@"BMSH_0004"]) {
//            if ([dic[@"isVerify"] isEqualToString:@"SF_0001"]) {
//                self.stateLb.text = @"已申请";
//            } else if ([dic[@"isVerify"] isEqualToString:@"SF_0002"]) {
//                self.stateLb.text = @"未付款";
//                self.payBtn.hidden = NO;
//            }
//        }
//    } else if ([[LVTools mToString:dic[@"status"]] isEqualToString:DDZT_0002]) {
//        self.stateLb.text = @"报名成功";
//    } else if ([[LVTools mToString:dic[@"status"]] isEqualToString:DDZT_0003]) {
//        self.stateLb.text = @"已作废";
//    }
}
- (void)awakeFromNib {
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
