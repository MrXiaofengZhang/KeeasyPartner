//
//  ZHInviteCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHInviteCell.h"
#import "NearByModel.h"
#import "ZHGenderView.h"
#define spaceWidth 5.0f
#define maxHoppy 8
@implementation ZHInviteCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier menbertype:(MemberType)type{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.menberType = type;
        self.plistArray = [LVTools sportStylePlist];
        [self createView];
        if (type == MenberInviteFriendType) {
            self.separatorInset = UIEdgeInsetsMake(0, 110, 0, 0);
        } else {
            self.separatorInset = UIEdgeInsetsMake(0, 85, 0, 0);
        }
        
    }
    return self;
}
-  (void)setSportArray:(NSArray *)sportArray{
    _sportArray = sportArray;
    for (NSInteger i=0;i<(sportArray.count>6?6:sportArray.count);i++) {
        if (i==maxHoppy-1) {
            break;
        }
        UIImageView *imageV = (UIImageView*)[self.contentView viewWithTag:100+i];
        imageV.image = [UIImage imageNamed:[sportArray objectAtIndex:i]];
        
    }
}
- (void)configModel:(NearByModel*)model{
      
    [_selectedBtn setSelected:model.selected];
    
    NSString *birthday = [LVTools mToString:model.birthday];
    NSString *age = nil;
    if(birthday.length==0){
        age = @"0";
    }
    else{
        age = [LVTools fromDateToAge:[NSDate dateWithTimeIntervalSince1970:[model.birthday longLongValue]/1000]];
    }

    [self.genderImg setAge:[LVTools mToString: age]];
    [self.genderImg setGender:[LVTools mToString: model.gender]];
    
    CGFloat width = [LVTools sizeWithStr:model.nickName With:15 With2:30];
    _nameLb.frame = CGRectMake(self.headimg.right+10, spaceWidth*2, width, 20);
    _nameLb.text = model.nickName;
    self.statusLab.hidden = YES;
//    if ([[LVTools mToString:model.uid] isEqualToString:[LVTools mToString:self.teamModel.captainId]]) {
//        cell.statusLab.hidden = NO;
//        cell.statusLab.text = @"(队长)";
//    }
    if ([[LVTools mToString:model.followStatus] isEqualToString:@"0"]) {
        self.newfans.hidden = NO;
    }
    else{
        self.newfans.hidden = YES;
    }
    _hobbyLb.text = [LVTools mToString:model.signature];
    if (_hobbyLb.text.length==0) {
        _hobbyLb.text = @"这个家伙很懒,什么也没写";
    }
    self.sportArray = [model.loveSports  componentsSeparatedByString:@","];//运动图片
    if ([LVTools mToString:model.path].length>0) {
    [_headimg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model.path]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    }
    else{
        [_headimg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model.face]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    }
    
    if ([LVTools mToString: model.distance].length>0) {
        CGFloat distance = [model.distance doubleValue];
        self.distanceLb.text = [NSString stringWithFormat:@"%.2fkm",distance];
    }
    else{
        self.distanceLb.text = @"定位失败";
    }
    if ([LVTools mToString:model.lastlogin].length>0) {
       self.timeLb.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[model.lastlogin longLongValue]/1000]];
    }
    else{
        self.timeLb.text = @"未知";
    }
}

- (UIImageView *)statusLab {
    if (!_statusLab) {
        self.statusLab = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width-35, self.genderImg.top+20, 20, 20)];
        self.statusLab.hidden = YES;
        self.statusLab.image  = [UIImage imageNamed:@"leader"];
        [self.contentView addSubview:self.statusLab];
    }
    return _statusLab;
}
- (UIButton*)applyStatus{
    if (_applyStatus == nil) {
        _applyStatus = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-70, self.genderImg.top, 60, 20)];
        [_applyStatus setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_applyStatus setTitle:@"已确认" forState:UIControlStateNormal];
        [_applyStatus setBackgroundColor:SystemBlue];
        _applyStatus.titleLabel.font = Content_lbfont;
        _applyStatus.hidden = YES;
    }
    return _applyStatus;
}
- (void)createView{
    if (self.menberType == MenberInviteFriendType) {
        //选中按钮
        self.selectedBtn = [[UIButton alloc] initWithFrame:CGRectMake(spaceWidth*2, kFriendCellHeight/2.0-10, 20,20)];
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"friendUnselected"] forState:UIControlStateNormal];
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"friendSelected"] forState:UIControlStateSelected];
        [self.contentView addSubview:self.selectedBtn];
    }
    //头像
    self.headimg = [[UIImageView alloc] initWithFrame:CGRectMake(self.selectedBtn.right+spaceWidth*2, spaceWidth, kFriendCellHeight-spaceWidth*2, kFriendCellHeight-spaceWidth*2)];
    self.headimg.layer.masksToBounds = YES;
    self.headimg.layer.cornerRadius = (kFriendCellHeight -spaceWidth*2)/2.0;
    [self.contentView addSubview:self.headimg];
    
    self.newfans = [[UILabel alloc] initWithFrame:CGRectMake(self.headimg.right-self.headimg.width/3, 0, self.headimg.width/3, 10)];
    self.newfans.layer.cornerRadius = mygap;
    self.newfans.layer.masksToBounds = YES;
    self.newfans.text = @"NEW";
    self.newfans.font = Content_lbfont;
    self.newfans.textColor = [UIColor whiteColor];
//    self.newfans.hidden = YES;
    [self.contentView addSubview:self.newfans];

    //用户昵称
    self.nameLb = [[UILabel alloc] initWithFrame:CGRectMake(self.headimg.right+10, spaceWidth, 80, 20)];
    self.nameLb.font = Btn_font;
    [self.contentView addSubview:self.nameLb];
    
//    if (self.menberType != MenberInviteFriendType) {
//        //身份标识
//        self.statusLab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLb.right, self.nameLb.top, 60, 30)];
//        self.statusLab.font = Btn_font;
//        self.statusLab.textColor = [UIColor redColor];
//        self.statusLab.text = @"(队员)";
//        [self.contentView addSubview:self.statusLab];
//    }
    
    //距离 时间
    
    self.timeLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-65, self.nameLb.top, 55, self.nameLb.height)];
    self.timeLb.text = @"43分钟前";
    self.timeLb.font = [UIFont systemFontOfSize:12.0];
    self.timeLb.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.timeLb];
    
    self.distanceLb = [[UILabel alloc] initWithFrame:CGRectMake(self.timeLb.left-50-spaceWidth, self.nameLb.top, 50, self.nameLb.height)];
    self.distanceLb.text = @"0.08km";
    self.distanceLb.font = [UIFont systemFontOfSize:12.0];
    self.distanceLb.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.distanceLb];
     
    //性别
    self.genderImg = [[ZHGenderView alloc] initWithFrame:CGRectMake(self.nameLb.left, self.nameLb.bottom+spaceWidth*1.5, 30, 15) WithGender:@"XB_001" AndAge:@"25"];
    [self.contentView addSubview:self.genderImg];
    //运动
    
    //个性签名
    self.hobbyLb = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLb.left, self.genderImg.bottom+spaceWidth*1.5, BOUNDS.size.width-self.nameLb.left, 20)];
    self.hobbyLb.text = @"这个人很懒,什么也没留下";
    self.hobbyLb.font = Content_lbfont;
    self.hobbyLb.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.hobbyLb];
    
    for (NSInteger i=0;i<maxHoppy;i++) {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_genderImg.right+mygap+i*25, _genderImg.top-mygap*0.5, 20, 20)];
        //imageV.image = [UIImage imageNamed:[sportArray objectAtIndex:i]];
        imageV.tag = 100+i;
        [self.contentView addSubview:imageV];
    }

    [self.contentView addSubview:self.applyStatus];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
