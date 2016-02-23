//
//  WPCCommentCell.m
//  yuezhan123
//
//  Created by admin on 15/6/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCCommentCell.h"
#import "WPCImageView.h"
#define TIMELABEL_WIDTH 50
@implementation WPCCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier commentType:(WPCCommentType)type
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _commentType = type;
        
        _headImgView = [UIButton buttonWithType:UIButtonTypeCustom];
        _nickNameLb = [[UILabel alloc] init];
        _genderImg = [[UIImageView alloc] init];
        
        _contentLab = [[UILabel alloc] init];
        _timeLab = [[UILabel alloc] init];
        
        [self.contentView addSubview:_headImgView];
        [self.contentView addSubview:_nickNameLb];
        [self.contentView addSubview:_genderImg];
        
        [self.contentView addSubview:_contentLab];
        //[self.contentView addSubview:_timeLab];
        if(type !=WPCAppointCommentType){
            _floorLb = [[UILabel alloc] init];
            [self.contentView addSubview:_floorLb];
            _morActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_morActionBtn setImage:[UIImage imageNamed:@"moreBtn"] forState:UIControlStateNormal];
            _morActionBtn.frame = CGRectMake(UISCREENWIDTH-45, 12.5, 15.0, 15.0);
            _morActionBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:_morActionBtn];
            
            _replyActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_replyActionBtn setImage:[UIImage imageNamed:@"replyBtn"] forState:UIControlStateNormal];
            _replyActionBtn.frame = CGRectMake(UISCREENWIDTH-75, 10, 20.0, 20.0);
            _replyActionBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:_replyActionBtn];
        }
        
        self.line = [[UIImageView alloc] initWithFrame:CGRectMake(55.0, 0, BOUNDS.size.width*(711.0/750.0)-45.0, 0.5)];
        self.line.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.line];

    }
    return self;
}

- (void)configTheCellContent:(NSDictionary *)dic
{
    //dic= @{@"iconPath":@"/upload/pic/business/personal/myLogo/20150625094724.jpg",@"userName":@"seven",@"info":@"怒发冲冠，凭阑处、潇潇雨歇。抬望眼、仰天长啸，壮怀激烈。三十功名尘与土，八千里路云和月。莫等闲，白了少年头，空悲切。靖康耻，犹未雪；臣子恨，何时灭。驾长车，踏破贺兰山缺。壮志饥餐胡虏肉，笑谈渴饮匈奴血。待从头、收拾旧山河，朝天阙。",};
    //头像按钮
    _headImgView.frame = CGRectMake(10, 10, 40, 40);
    _headImgView.layer.cornerRadius = mygap;
    _headImgView.layer.masksToBounds = YES;
    [_headImgView sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"face"]]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    
    //
    _nickNameLb.frame = CGRectMake(CGRectGetMaxX(self.headImgView.frame)+10, 10, 150, 20);
    _nickNameLb.textColor = NavgationColor;
    _nickNameLb.text = [LVTools mToString:dic[@"userName"]];
    _nickNameLb.font = Btn_font;
    [_nickNameLb sizeToFit];
    //
    _genderImg.frame = CGRectMake(_nickNameLb.right+mygap, _nickNameLb.top+mygap/2.0, _nickNameLb.height-mygap, _nickNameLb.height-mygap);
    if ([dic[@"gender"] boolValue]) {
        _genderImg.image = [UIImage imageNamed:@"icon_nan"];
        _genderImg.backgroundColor = [UIColor colorWithRed:0.298f green:0.635f blue:0.863f alpha:1.00f];
    }
    else{
    _genderImg.image = [UIImage imageNamed:@"icon_nv"];
        _genderImg.backgroundColor = [UIColor colorWithRed:0.988f green:0.608f blue:0.576f alpha:1.00f];
    }
    _genderImg.layer.cornerRadius = _genderImg.height/2.0;
    _genderImg.contentMode = UIViewContentModeScaleAspectFit;
    
    //
    _floorLb.frame = CGRectMake(_nickNameLb.left, _nickNameLb.bottom, 100.0, _nickNameLb.height);
    _floorLb.font = [UIFont systemFontOfSize:11.0];
    _floorLb.textColor = [UIColor lightGrayColor];
    
    _floorLb.text =[NSString stringWithFormat:@"第%d楼 %@",(int)(_index.section-3), [NSString getCreateTime:[NSString stringWithFormat:@"%ld", [dic[@"createtime"] longValue]/1000]]];
    //
    if (_commentType == WPCVenueCommentType) {
        int starNum = 3;
        for (int i = 0; i < 5; i ++) {
            UIImageView *starImage = [[UIImageView alloc] initWithFrame:CGRectMake(_nickNameLb.left+14*i, _nickNameLb.bottom+3, 12, 12)];
            if (i < starNum) {
                [starImage setImage:[UIImage imageNamed:@"star"]];
            } else {
                [starImage setImage:[UIImage imageNamed:@"unstar"]];
            }
            [self.contentView addSubview:starImage];
        }
    }
    
    //内容标签
    NSString *tempStr;
    if ([[LVTools mToString:[dic objectForKey:@"parentId"]] isEqualToString:@""]) {
        tempStr = [NSString stringWithFormat:@"%@",[LVTools mToString:[dic objectForKey:@"message"]]];
    }
    else{
        tempStr = [NSString stringWithFormat:@"@%@:%@",[LVTools mToString:[dic objectForKey:@"parentName"]],[LVTools mToString:[dic objectForKey:@"message"]]];
    }
    CGFloat height = [LVTools sizeContent:tempStr With:14 With2:(UISCREENWIDTH-60-60)];
    _contentLab.text = tempStr;
    _contentLab.numberOfLines = 0;
    _contentLab.font = [UIFont systemFontOfSize:14];
    if (_commentType == WPCVenueCommentType) {
        _contentLab.frame = CGRectMake(60, CGRectGetMaxY(_nickNameLb.frame)+18+15.0, UISCREENWIDTH-70-5, height+5);
    } else {
        _contentLab.frame = CGRectMake(60, CGRectGetMaxY(_nickNameLb.frame)+15.0, UISCREENWIDTH-70-5, height+5);
    }
    
    
    //判断是否有图片
    if ([dic[@"commentImages"] count] > 0) {
        for (int i = 0; i < [dic[@"commentImages"] count]; i ++) {
            WPCImageView *image = [[WPCImageView alloc] initWithFrame:CGRectMake(60+i*85, _contentLab.bottom, 80, 80)];
            [image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic[@"commentImages"][i] valueForKey:@"path"]]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            image.tag = 400+i;
            image.contentMode = UIViewContentModeScaleAspectFill;
            image.clipsToBounds = YES;
            [self.contentView addSubview:image];
        }
        _timeLab.frame = CGRectMake(60, _contentLab.bottom+50, 100, 15);
    } else {
        _timeLab.frame = CGRectMake(60, _contentLab.bottom, 100, 15);
    }
    NSDate *sendTime = [NSDate dateWithTimeIntervalSince1970:[[LVTools mToString:[dic objectForKey:@"time"]] longLongValue]/1000];
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterMediumStyle];
    [format setTimeStyle:NSDateFormatterShortStyle];
    [format setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    _timeLab.font = Content_lbfont;
    _timeLab.text = [LVTools mToString:[LVTools compareCurrentTime:sendTime]];
    _timeLab.textColor = [UIColor lightGrayColor];
}

- (void)configTheplayContent:(NSDictionary *)dic {
    _headImgView.frame = CGRectMake(10, 10, 40, 40);
    _headImgView.layer.cornerRadius = 20;
    _headImgView.layer.masksToBounds = YES;
    [_headImgView sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"iconPath"]]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    
    //
    _nickNameLb.frame = CGRectMake(CGRectGetMaxX(self.headImgView.frame)+10, 10, 150, 20);
    _nickNameLb.textColor = NavgationColor;
    _nickNameLb.text = [LVTools mToString:dic[@"userName"]];
    _nickNameLb.font = Btn_font;
    
    //
    if (_commentType == WPCVenueCommentType) {
        int starNum = [[LVTools mToString:dic[@"level"]] intValue];
        for (int i = 0; i < 5; i ++) {
            UIImageView *starImage = [[UIImageView alloc] initWithFrame:CGRectMake(_nickNameLb.left+14*i, _nickNameLb.bottom+3, 12, 12)];
            if (i < starNum) {
                [starImage setImage:[UIImage imageNamed:@"star"]];
            } else {
                [starImage setImage:[UIImage imageNamed:@"unstar"]];
            }
            [self.contentView addSubview:starImage];
        }
    }
    
    //内容标签
    NSString *tempStr;
    if ([[LVTools mToString:[dic objectForKey:@"parentId"]] isEqualToString:@""]) {
        tempStr = [NSString stringWithFormat:@"%@",[LVTools mToString:[dic objectForKey:@"message"]]];
    }
    else{
        tempStr = [NSString stringWithFormat:@"@%@:%@",[LVTools mToString:[dic objectForKey:@"parentName"]],[LVTools mToString:[dic objectForKey:@"message"]]];
    }
    CGFloat height = [LVTools sizeContent:tempStr With:14 With2:(UISCREENWIDTH-60-60)];
    _contentLab.text = tempStr;
    _contentLab.numberOfLines = 0;
    _contentLab.font = [UIFont systemFontOfSize:14];
    if (_commentType == WPCVenueCommentType) {
        _contentLab.frame = CGRectMake(60, CGRectGetMaxY(_nickNameLb.frame)+18, UISCREENWIDTH-70-5, height+5);
    } else {
        _contentLab.frame = CGRectMake(60, CGRectGetMaxY(_nickNameLb.frame), UISCREENWIDTH-70-5, height+5);
    }
    
    
    //判断是否有图片
    if ([dic[@"commentShowList"] count] > 0) {
        for (int i = 0; i < [dic[@"commentShowList"] count]; i ++) {
            WPCImageView *image = [[WPCImageView alloc] initWithFrame:CGRectMake(60+i*85, _contentLab.bottom, 80, 80)];
            [image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic[@"commentShowList"][i] valueForKey:@"path"]]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            image.contentMode = UIViewContentModeScaleAspectFill;
            image.clipsToBounds = YES;
            image.tag = 400+i;
            [self.contentView addSubview:image];
        }
        _timeLab.frame = CGRectMake(60, _contentLab.bottom+50, 100, 15);
    } else {
        _timeLab.frame = CGRectMake(60, _contentLab.bottom, 100, 15);
    }
    NSDate *sendTime = [NSDate dateWithTimeIntervalSince1970:[[LVTools mToString:[dic objectForKey:@"interactTime"]] longLongValue]/1000];
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterMediumStyle];
    [format setTimeStyle:NSDateFormatterShortStyle];
    [format setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    _timeLab.font = Content_lbfont;
    _timeLab.text = [LVTools mToString:[LVTools compareCurrentTime:sendTime]];
    _timeLab.textColor = [UIColor lightGrayColor];
}

@end
