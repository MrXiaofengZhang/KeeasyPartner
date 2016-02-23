//
//  ZHAppointItemCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/22.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHAppointItemCell.h"
#import "GetAppliesModel.h"
#define cellBackColor [UIColor colorWithRed:0.933f green:0.933f blue:0.933f alpha:1.00f]
#define spaceWidth 5.0
#define topHeight 44.0
#define midHeight 95.0
@implementation ZHAppointItemCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor grayColor];
        [self createCustomView];
    }
    return self;
}
- (void)configDefaultModel:(GetAppliesModel *)model{
    
    NSLog(@"%@",model.uid);
    self.zanCountLb.text =[LVTools mToString: model.praiseCount];
    self.commentCountLb.text =[LVTools mToString: model.msgCount];
    if ([[LVTools mToString:model.title] length] > 0) {
        self.appointnameLb.text = [LVTools mToString:model.title];
    }
    self.noZanCountLb.text = [LVTools mToString:model.applyCount];
    self.shareCountLb.text = [LVTools mToString:model.applyCount];
    self.timeLb.text = [LVTools mToString:model.introduce];
    self.cityLb.text =[[LVTools mToString: model.playTime] substringToIndex:10];
//    self.timeLb.text =[LVTools mToString: model.playTime];
//    self.cityLb.text =[NSString stringWithFormat:@"%@/%@", [LVTools mToString:model.cityMeaning],[LVTools mToString:model.areaMeaning]];
    [self.appointImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model.path]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model.userLogoPath]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    if (self.nameLb.text.length>0) {
        self.nameLb.text = model.username;
    }else{
        self.nameLb.text = @"";
    }
    [self.nameLb sizeToFit];
    
    self.statusImg.frame = CGRectMake(self.nameLb.right+spaceWidth, self.headImg.top+spaceWidth, 50, 20);
    NSArray * array = [LVTools sportStylePlist];
    for (NSDictionary * dic in array) {
        if ([model.sportsType isEqualToString:[LVTools mToString:dic[@"sport2"]]]) {
            self.sportTypeImg.image = [UIImage imageNamed:dic[@"img1"]];
        }
    }
    self.appointnameLb.text = [LVTools mToString:model.title];
    NSString * nowStr = [NSString getNowDateFormatter];
    NSLog(@"++++++++++%@",nowStr);
    NSLog(@"________%@",[LVTools mToString: model.playTime]);
    if ([nowStr compare:[LVTools mToString: model.playTime]] == NSOrderedDescending) {
       self.statusImg.text = @"已结束";
        self.statusImg.backgroundColor = [UIColor grayColor];
        //已结束
    }else{
        //集结中
        self.statusImg.text = @"集结中";
        self.statusImg.backgroundColor = color_red_dan;
    }
    self.distanceLb.text = [LVTools caculateDistanceFromLat:[LVTools mToString:model.latitude] andLng:[LVTools mToString:model.longitude]];
}
- (void)configDefaultDic:(NSDictionary *)dic{
   
    self.zanCountLb.text =[LVTools mToString:[LVTools mToString: dic[@"praiseCount"]]];
    self.commentCountLb.text =[LVTools mToString:[LVTools mToString:  dic[@"msgCount"]]];
    if ([[LVTools mToString:dic[@"title"]] length] > 0) {
        self.appointnameLb.text = [LVTools mToString:dic[@"title"]];
    }
    self.noZanCountLb.text = [LVTools mToString:dic[@"applyCount"]];
    self.shareCountLb.text = [LVTools mToString:dic[@"applyCount"]];
    self.timeLb.text = [LVTools mToString:dic[@"introduce"]];
    self.cityLb.text =[[LVTools mToString: dic[@"playTime"]] substringToIndex:10];
    //    self.timeLb.text =[LVTools mToString: model.playTime];
    //    self.cityLb.text =[NSString stringWithFormat:@"%@/%@", [LVTools mToString:model.cityMeaning],[LVTools mToString:model.areaMeaning]];
    [self.appointImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic[@"path"]]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic[@"userLogoPath"]]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    if (self.nameLb.text.length>0) {
        self.nameLb.text =[LVTools mToString: dic[@"username"]];
    }else{
        self.nameLb.text = @"";
    }
    [self.nameLb sizeToFit];
    
    self.statusImg.frame = CGRectMake(self.nameLb.right+spaceWidth, self.headImg.top+spaceWidth, 50, 20);
    NSArray * array = [LVTools sportStylePlist];
    for (NSDictionary * dic in array) {
        if ([dic[@"sportsType"] isEqualToString:[LVTools mToString:dic[@"sport2"]]]) {
            self.sportTypeImg.image = [UIImage imageNamed:dic[@"img1"]];
        }
    }
    self.appointnameLb.text = [LVTools mToString:dic[@"title"]];
}
- (void)createCustomView{
    self.contentView.backgroundColor = cellBackColor;
    //白色背景
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, spaceWidth, BOUNDS.size.width, topHeight)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:whiteView];
    
    self.headImg = [[UIButton alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
    
    [whiteView addSubview:self.headImg];
    
    self.nameLb = [[UILabel alloc] initWithFrame:CGRectMake(self.headImg.right+spaceWidth, self.headImg.top+spaceWidth, 80, 30)];
    self.nameLb.text = @"运动精灵";
    self.nameLb.font = Btn_font;
    [whiteView addSubview:self.nameLb];
    
    self.statusImg = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLb.right, self.headImg.top+spaceWidth, 50, 20)];
    self.statusImg.backgroundColor = [UIColor colorWithRed:0.949f green:0.294f blue:0.267f alpha:1.00f];
    self.statusImg.layer.masksToBounds = YES;
    self.statusImg.layer.cornerRadius = _statusImg.height/2.0;
    self.statusImg.textColor = [UIColor whiteColor];
    self.statusImg.textAlignment = NSTextAlignmentCenter;
    self.statusImg.font = Content_lbfont;
    [whiteView addSubview:self.statusImg];
    
    self.distanceLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-65-10, 7, 65, 30)];
    self.distanceLb.text = @"未定位";
    self.distanceLb.font = Content_lbfont;
    self.distanceLb.textColor = Content_lbColor;
    [whiteView addSubview:self.distanceLb];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_distanceLb.frame)-15, _distanceLb.top+7, 15, 15)];
    imageView.tag = 1001;
    imageView.image = [UIImage imageNamed:@"Marker"];
    //imageView.backgroundColor = [UIColor orangeColor];
    [whiteView addSubview:imageView];

    
    
    //灰色背景
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, whiteView.bottom, BOUNDS.size.width, midHeight)];
    grayView.backgroundColor = [UIColor colorWithRed:0.976f green:0.976f blue:0.976f alpha:1.00f];
    [self.contentView addSubview:grayView];
    //约战图片
    self.appointImg = [[UIImageView alloc] initWithFrame:CGRectMake(spaceWidth, 0, midHeight, midHeight)];
    self.appointImg.contentMode = UIViewContentModeScaleAspectFill;
    self.appointImg.clipsToBounds = YES;
    [grayView addSubview:self.appointImg];
    //约战名字
    self.appointnameLb =[[UILabel alloc] initWithFrame:CGRectMake(self.appointImg.right+spaceWidth, 0, BOUNDS.size.width-self.appointImg.right+spaceWidth*2, 30)];
    self.appointnameLb.text = @"足球挑战赛";
    self.appointnameLb.font = Btn_font;
    [grayView addSubview:self.appointnameLb];
    //约战时间
    self.timeLb = [[UILabel alloc] initWithFrame:CGRectMake(self.appointnameLb.left, self.appointnameLb.bottom, UISCREENWIDTH-10-self.appointnameLb.left, 20)];
    self.timeLb.text = @"2015.04.12-2015.04-12";
    self.timeLb.font = Content_lbfont;
    self.timeLb.textColor = Content_lbColor;
    [grayView addSubview:self.timeLb];
    //city
    self.cityLb = [[UILabel alloc] initWithFrame:CGRectMake(self.appointnameLb.left, self.timeLb.bottom, self.appointnameLb.width, 20)];
    self.cityLb.text = @"北京";
    self.cityLb.font = Content_lbfont;
    self.cityLb.textColor = Content_lbColor;
    [grayView addSubview:self.cityLb];
    //运动类型
    self.sportTypeImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.appointnameLb.left, self.cityLb.bottom, 20, 20)];
    [grayView addSubview:self.sportTypeImg];
    //参与人数
    UIImageView *joinCountImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.sportTypeImg.right+spaceWidth, self.sportTypeImg.top, self.sportTypeImg.height, self.sportTypeImg.height)];
    joinCountImg.image = [UIImage imageNamed:@"joinedCount"];
    [grayView addSubview:joinCountImg];
    self.noZanCountLb = [[UILabel alloc] initWithFrame:CGRectMake(joinCountImg.right+spaceWidth, joinCountImg.top, 20, 20)];
    self.noZanCountLb.text = @"12";
    self.noZanCountLb.textColor = Content_lbColor;
    self.noZanCountLb.font = Content_lbfont;
    [grayView addSubview:self.noZanCountLb];
    //点赞人数
    UIImageView *zanCountImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.noZanCountLb.right+spaceWidth, self.sportTypeImg.top, self.sportTypeImg.height, self.sportTypeImg.height)];
    zanCountImg.image = [UIImage imageNamed:@"zanCount"];
    [grayView addSubview:zanCountImg];
    self.zanCountLb = [[UILabel alloc] initWithFrame:CGRectMake(zanCountImg.right+spaceWidth, joinCountImg.top, 20, 20)];
    self.zanCountLb.text = @"12";
    self.zanCountLb.textColor = Content_lbColor;
    self.zanCountLb.font = Content_lbfont;
    [grayView addSubview:self.zanCountLb];
    
    //评论数
    UIImageView *commentCountImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.zanCountLb.right+spaceWidth, self.sportTypeImg.top, self.sportTypeImg.height, self.sportTypeImg.height)];
    commentCountImg.image = [UIImage imageNamed:@"comentCount"];
    [grayView addSubview:commentCountImg];
    self.commentCountLb = [[UILabel alloc] initWithFrame:CGRectMake(commentCountImg.right+spaceWidth, joinCountImg.top, 20, 20)];
    self.commentCountLb.text = @"12";
    self.commentCountLb.textColor = Content_lbColor;
    self.commentCountLb.font = Content_lbfont;
    [grayView addSubview:self.commentCountLb];
    //分享数
    UIImageView *shareCountImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.commentCountLb.right+spaceWidth, self.sportTypeImg.top, self.sportTypeImg.height, self.sportTypeImg.height)];
    shareCountImg.image = [UIImage imageNamed:@"shareCount"];
    
    [grayView addSubview:shareCountImg];
    self.shareCountLb = [[UILabel alloc] initWithFrame:CGRectMake(shareCountImg.right+spaceWidth, joinCountImg.top, 20, 20)];
    self.shareCountLb.text = @"12";
    self.shareCountLb.textColor= Content_lbColor;
    self.shareCountLb.font = Content_lbfont;
    [grayView addSubview:self.shareCountLb];
    
    UIView *bottomWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, grayView.bottom, UISCREENWIDTH, 5)];
    bottomWhiteView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bottomWhiteView];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
