//
//  WPCTimeMachineCell.m
//  yuezhan123
//
//  Created by admin on 15/6/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCTimeMachineCell.h"
#import "ZHShuoModel.h"
#import "NSDate+Category.h"
@implementation WPCTimeMachineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.timelab = [[UILabel alloc] init];
        self.timelab.textColor = lightColor;
        self.timelab.textAlignment = NSTextAlignmentCenter;
        self.timelab.font = Content_lbfont;
        
        self.typeImg = [[UIImageView alloc] init];
        self.typeImg.layer.masksToBounds = YES;

        
        self.carryView = [[UIView alloc] init];
        self.verticalLineView = [[UIView alloc] init];
        self.verticalLineView.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        
        _contentlab = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentlab.font = [UIFont systemFontOfSize:13];
        _contentlab.numberOfLines = -1;
        [self.carryView addSubview:_contentlab];
        [self.contentView addSubview:self.timelab];
        [self.contentView addSubview:self.verticalLineView];
        [self.contentView addSubview:self.typeImg];
        [self.contentView addSubview:self.carryView];
        
        _img = [[UIImageView alloc] initWithFrame:CGRectZero];
        _img.backgroundColor = [UIColor purpleColor];
        [self.carryView addSubview:_img];
        
        _imgScanView = [[UIView alloc] initWithFrame:CGRectZero];
        _imgScanView.backgroundColor = [UIColor clearColor];
        [self.carryView addSubview:_imgScanView];
        
        self.countLab = [[UILabel alloc] init];
        self.countLab.textColor = RGBACOLOR(137, 137, 137, 1);
        self.countLab.font = [UIFont systemFontOfSize:13];
        [self.carryView addSubview:self.countLab];
    }
    return self;
}
- (void)makeUIByDictionaryInfo:(ZHShuoModel *)dic andCellHeight:(CGFloat)height{
    [_countLab removeFromSuperview];
    self.timelab.frame = CGRectMake(0, (height-20)/2, 75, 20);
    self.timelab.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[dic.time longLongValue]/1000]];
    
    self.verticalLineView.frame = CGRectMake(UISCREENWIDTH*176/750-0.5, 0, 0.5, height);
    
    self.typeImg.frame = CGRectMake(0, 0, 56*UISCREENWIDTH/750, 56*UISCREENWIDTH/750);
    self.typeImg.center = CGPointMake(UISCREENWIDTH*176/750-0.5, height/2);
    self.typeImg.backgroundColor = RGBACOLOR(220, 220, 220, 1);
    self.typeImg.layer.cornerRadius = self.typeImg.width/2;
    
    self.carryView.frame = CGRectMake(self.typeImg.right+10, 10, UISCREENWIDTH-self.typeImg.right-20, height-20);
    [_imgScanView removeFromSuperview];
    if (self.dynamicType == DynamicTypeString) {
        self.imgScanView.hidden = YES;
        self.typeImg.frame = CGRectMake(0, 0, 10, 10);
        self.typeImg.layer.cornerRadius = self.typeImg.width/2;
        self.typeImg.center = CGPointMake(UISCREENWIDTH*176/750-0.5, height/2);
        [_contentlab setFrame:self.carryView.bounds];
        NSString *str = [LVTools mToString:dic.info];
        _contentlab.text = str;
    } else if (self.dynamicType == DynamicTypeActivity) {
        [_img setFrame:CGRectMake(5, 5, self.carryView.height-10, self.carryView.height-10)];
        [_img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,dic.infoIcon]] placeholderImage:[UIImage imageNamed:@"systemIcon"]];
        _img.contentMode = UIViewContentModeScaleAspectFill;
        _img.clipsToBounds = YES;
        [_contentlab  setFrame:CGRectMake(_img.right+5, self.carryView.height/3, self.carryView.width-_img.right-10, self.carryView.height/2)];
//        NSString *textStr = @"";
//        if ([[LVTools mToString:dic.type] isEqualToString:@"2"]) {
//            textStr=[NSString stringWithFormat:@"发起约战－%@",[LVTools mToString:dic.info]];
//        }
//        else if ([[LVTools mToString:dic.type] isEqualToString:@"3"]) {
//            textStr=[NSString stringWithFormat:@"创建球队－%@",[LVTools mToString:dic.info]];
//        }
//        else if ([[LVTools mToString:dic.type] isEqualToString:@"4"]) {
//            textStr=[NSString stringWithFormat:@"报名赛事－%@",[LVTools mToString:dic.info]];
//        }
//        else if ([[LVTools mToString:dic.type] isEqualToString:@"5"]) {
//            textStr=[NSString stringWithFormat:@"分享链接－%@",[LVTools mToString:dic.info]];
//        }
//        else {
//            textStr=[NSString stringWithFormat:@"%@",[LVTools mToString:dic.info]];
//        }
        _contentlab.text = [LVTools mToString:dic.info];
        _contentlab.font = Btn_font;
        [self.carryView addSubview:_contentlab];
    } else {
        
        [_imgScanView setFrame:CGRectMake(0, 0, self.carryView.height, self.carryView.height)];
        _imgScanView.backgroundColor = [UIColor clearColor];
        [self.carryView addSubview:_imgScanView];
        
        //先只做有一张图片的，数据结构有了再做多图
        NSLog(@"dic---%@",dic.timeMachineList);
        if (dic.timeMachineList.count == 1) {
            NSDictionary *imgDic = [dic.timeMachineList objectAtIndex:0];
            UIImageView *img = [[UIImageView alloc] initWithFrame:_imgScanView.bounds];
            img.userInteractionEnabled = YES;
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.clipsToBounds = YES;
            [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[imgDic objectForKey:@"path"]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            [_imgScanView addSubview:img];
        } else {
            for (int i = 0; i < (dic.timeMachineList.count>4?4:dic.timeMachineList.count); i ++) {
                NSDictionary *imgDic = [dic.timeMachineList objectAtIndex:i];
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((i%2)*_imgScanView.width/2, (i/2)*_imgScanView.width/2, _imgScanView.width/2, _imgScanView.width/2)];
                img.contentMode = UIViewContentModeScaleAspectFill;
                img.clipsToBounds = YES;
               [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[imgDic objectForKey:@"path"]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
                [_imgScanView addSubview:img];
            }
        }
        
        NSString *str =[LVTools mToString:dic.info];
        CGFloat height = [LVTools sizeContent:str With:13 With2:self.carryView.width-self.carryView.height-5];
        CGFloat detailHeight = self.carryView.height-height-15>0 ? height : self.carryView.height-15;
        NSLog(@"%f",self.carryView.height);
        NSLog(@"%f",height);
        NSLog(@"%f",detailHeight);
        [_contentlab setFrame:CGRectMake(_imgScanView.right+5, 0, self.carryView.width-self.carryView.height-5, detailHeight)];
        _contentlab.font = [UIFont systemFontOfSize:13];
        _contentlab.numberOfLines = -1;
        _contentlab.text = str;
        [self.carryView addSubview:_contentlab];
        
        [_countLab setFrame:CGRectMake(_contentlab.left+5, self.carryView.height-15, 60, 15)];
        _countLab.textColor = RGBACOLOR(137, 137, 137, 1);
        _countLab.text =[NSString stringWithFormat:@"共%d张",(int)(dic.timeMachineList.count)];
        _countLab.font = [UIFont systemFontOfSize:13];
        [self.carryView addSubview:_countLab];
    }
}

@end
