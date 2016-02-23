//
//  ZHApplyJoinCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHApplyJoinCell.h"

@implementation ZHApplyJoinCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
        self.textLabel.font = Btn_font;
        self.imageView.layer.masksToBounds = YES;
        
        self.timeLb =[[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-100, 0, 80, 30)];
        self.timeLb.font = Content_lbfont;
        self.timeLb.textAlignment = NSTextAlignmentRight;
        self.timeLb.textColor = [UIColor grayColor];
        self.timeLb.hidden = YES;
        [self.contentView addSubview:self.timeLb];
        
        self.agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.agreeBtn.frame = CGRectMake(UISCREENWIDTH-60, 10, 50, 25);
        [self.agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        self.agreeBtn.titleLabel.font = Btn_font;
        [self.agreeBtn setBackgroundColor:SystemBlue];
        [self.agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.agreeBtn.layer.cornerRadius = mygap;
        self.agreeBtn.hidden = YES;
        [self.contentView addSubview:self.agreeBtn];
        
        self.rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rejectBtn.frame = CGRectMake(UISCREENWIDTH-120, 10, 50, 25);
        [self.rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        self.rejectBtn.titleLabel.font = Btn_font;
        [self.rejectBtn setBackgroundColor:color_red_dan];
        [self.rejectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rejectBtn.layer.cornerRadius = mygap;
        self.rejectBtn.hidden = YES;
        [self.contentView addSubview:self.rejectBtn];
        
        UIView *line =[[UIView alloc] initWithFrame:CGRectMake(0, 59.0, BOUNDS.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:line];
    }
    return self;
}
- (void)configDic:(NSDictionary*)dic{
    if ([[LVTools mToString: dic[@"msgType"]] isEqualToString:@"4"]||[[LVTools mToString: dic[@"msgType"]] isEqualToString:@"5"]||[[LVTools mToString: dic[@"msgType"]] isEqualToString:@"3"]) {
        //申请加入球队
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"path"]]] placeholderImage:[UIImage imageNamed:@"systemIcon"]];
        self.textLabel.text =[LVTools mToString: dic[@"name"]];
        self.detailTextLabel.text =[LVTools mToString:dic[@"content"]];
        if ([LVTools mToString: dic[@"inviteStatus"]].length>0) {
            self.timeLb.hidden = NO;
            if ([dic[@"inviteStatus"] boolValue]) {
                self.timeLb.text = @"已同意";
            }
            else{
                self.timeLb.text = @"已拒绝";
            }
            self.agreeBtn.hidden = YES;
            self.rejectBtn.hidden = YES;
        }
        else{
        self.agreeBtn.hidden = NO;
        self.rejectBtn.hidden = NO;
        self.timeLb.hidden = YES;
        }
    }
    else if([[LVTools mToString: dic[@"msgType"]] isEqualToString:@"1"]||[[LVTools mToString: dic[@"msgType"]] isEqualToString:@"2"]||[[LVTools mToString: dic[@"msgType"]] isEqualToString:@"6"]){
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"path"]]] placeholderImage:[UIImage imageNamed:@"systemIcon"]];
        self.textLabel.text =[LVTools mToString: dic[@"name"]];
        self.detailTextLabel.text =[LVTools mToString:dic[@"content"]];
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(mygap*2, mygap, 50.0, 50.0);
    self.textLabel.frame = CGRectMake(self.imageView.right+mygap, self.imageView.top, BOUNDS.size.width-100, 30);
    self.detailTextLabel.frame = CGRectMake(self.textLabel.left, self.textLabel.bottom, self.textLabel.width, 20) ;
    self.imageView.layer.cornerRadius = self.imageView.height/2.0;
}

@end
