//
//  NearByTableViewCell.m
//  yuezhan123
//
//  Created by LV on 15/3/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "NearByTableViewCell.h"
#import "NearByModel.h"
#define maxHoppy 8
#define gapCell 5

@interface NearByTableViewCell ()
@property (nonatomic, strong)NearByModel * myModel;
@end

@implementation NearByTableViewCell
@synthesize plistArray;
/*
 @property (nonatomic, strong)UIView * bgView;
 @property (nonatomic, strong)UIButton *headerBtn;
 @property (nonatomic, strong)UILabel * agerLabel;
 @property (nonatomic, strong)UILabel * nameLabel;
 @property (nonatomic, strong)UILabel * habitLabel;
 @property (nonatomic, strong)UIImageView * genderImg;
 @property (nonatomic, strong)UILabel * locationLabel;
 @property (nonatomic, strong)UIButton * addFriedBtn;
 */

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeUI];
        self.plistArray = [LVTools sportStylePlist];
    }
    return self;
}

- (void)configModel:(NearByModel *)model{
    
    self.myModel = model;
    _nameLabel.text = model.nickName;
    [_nameLabel sizeToFit];

    _habitLabel.numberOfLines = -1;
    _habitLabel.text = [LVTools mToString:model.signature];
    if (_habitLabel.text.length==0) {
        _habitLabel.text = @"这个家伙很懒,什么也没写";
    }
    if (model.distance) {
        model.distance = [NSString stringWithFormat:@"%.2f",[model.distance doubleValue]];
        
        int number = [model.distance intValue];
        if (number>0) {
            _locationLabel.text = [NSString stringWithFormat:@"%@km",model.distance];
        }else{
            _locationLabel.text = [NSString stringWithFormat:@"%@km",model.distance];
        }
    }else{
        _locationLabel.text = @"定位失败";
    }
    [_genderView setGender:[LVTools mToString:model.gender]];
    NSString *age = @"0";
    NSString *birthday = [LVTools mToString:model.birthday];
    if(birthday.length==0){
        age = @"0";
    }
    else{
        age = [LVTools fromDateToAge:[NSDate dateWithTimeIntervalSince1970:[model.birthday floatValue]/1000]];
    }
    [_genderView setAge:[LVTools mToString:age]];
    [_headerBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,model.path]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    
    if ([model.isFriend isEqualToString:@"false"]) {
//        NSLog(@"没有选中");
        _addFriedBtn.selected = NO;
    }else{
//        NSLog(@"已经选中");
        _addFriedBtn.selected = YES;
        _addFriedBtn.userInteractionEnabled = NO;
        self.addFriedBtn.backgroundColor = [UIColor whiteColor];
        self.addFriedBtn.layer.borderColor = [[UIColor grayColor] CGColor];
        self.addFriedBtn.layer.borderWidth = 0.4;
    }
    [_headerBtn addTarget:self action:@selector(postMsgClick) forControlEvents:UIControlEventTouchUpInside];
    self.sportArray = [model.loveSportsMeaning  componentsSeparatedByString:@","];
    if ([LVTools mToString:model.lastlogin].length==0) {
        self.timeagoLabel.text = @"未知";
    }
    else{
        self.timeagoLabel.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[model.lastlogin longLongValue]/1000]];
    }
}

#pragma mark --
#pragma mark --进入个人中心
- (void)postMsgClick{
    self.chatFirend(self.myModel.userId,self.myModel.nickName);
}
-  (void)setSportArray:(NSArray *)sportArray{
    _sportArray = sportArray;
    NSLog(@"%@",_sportArray);
    for (NSInteger i=0;i<sportArray.count;i++) {
        if (i==maxHoppy-1) {
            break;
        }
        UIImageView *imageV = (UIImageView*)[self.contentView viewWithTag:100+i];
        imageV.image = [UIImage imageNamed:[sportArray objectAtIndex:i]];
        
    }
}

- (void)makeUI{
    [self.contentView addSubview:self.headerBtn];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.genderView];
    [self.contentView addSubview:self.habitLabel];
    [self.contentView addSubview:self.locationLabel];
    [self.contentView addSubview:self.timeagoLabel];
    //[self.bgView addSubview:self.addFriedBtn];
    for (NSInteger i=0;i<maxHoppy;i++) {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_genderView.right+mygap+i*25, _genderView.top-mygap, 20, 20)];
        //imageV.image = [UIImage imageNamed:[sportArray objectAtIndex:i]];
        imageV.tag = 100+i;
        [self.contentView addSubview:imageV];
    }

}

- (UIButton *)addFriedBtn{
    if (!_addFriedBtn) {
        _addFriedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addFriedBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)-75, CGRectGetHeight(self.contentView.frame)-20-gapCell*2, 75-gapCell, 20);
        _addFriedBtn.layer.cornerRadius = 4;
        _addFriedBtn.layer.masksToBounds = YES;
        _addFriedBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [_addFriedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addFriedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [_addFriedBtn setTitle:@"添加好友" forState:UIControlStateNormal];
        [_addFriedBtn setTitle:@"已添加" forState:UIControlStateSelected];
        if (_addFriedBtn.selected) {
            _addFriedBtn.backgroundColor = [UIColor whiteColor];
            _addFriedBtn.layer.borderColor = [[UIColor grayColor] CGColor];
            _addFriedBtn.layer.borderWidth = 0.4;
        }else{
            _addFriedBtn.backgroundColor = [UIColor grayColor];
        }
        [_addFriedBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addFriedBtn;
}
- (void)click:(UIButton *)btn
{
    
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    
    if ([isLogin isEqualToString:@"1"])//已添加
    {
       self.addFirend(YES,self.myModel.uid,self.myModel.userName);
       
    }else
    {
        //没有登录跳到登录界面
        self.addFirend(NO,@"",@"");
    }
    
}

- (UILabel *)locationLabel{
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(gapCell, gapCell, 0, 14)];
        _locationLabel.font = [UIFont systemFontOfSize:13];
        //_locationLabel.backgroundColor = [UIColor blueColor];
        _locationLabel.textAlignment = NSTextAlignmentLeft;
        _locationLabel.text = @"99.999km";
        [_locationLabel sizeToFit];
        _locationLabel.textColor = [UIColor lightGrayColor];
        _locationLabel.frame = CGRectMake(BOUNDS.size.width-_locationLabel.frame.size.width-gapCell-50, _nameLabel.top, _locationLabel.frame.size.width, 14);

        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_locationLabel.frame)-15, _locationLabel.top, 15, 15)];
        imageView.tag = 1001;
        imageView.image = [UIImage imageNamed:@"Marker"];
        //imageView.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:imageView];
    }
    return _locationLabel;
}
- (UILabel*)timeagoLabel{
    if (_timeagoLabel==nil) {
        _timeagoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_locationLabel.right+mygap, _locationLabel.top, 60, _locationLabel.height)];
        _timeagoLabel.font = _locationLabel.font;
        _timeagoLabel.textAlignment = NSTextAlignmentLeft;
        _timeagoLabel.text = @"10分钟前";
        _timeagoLabel.textColor = [UIColor lightGrayColor];
        
    }
    return _timeagoLabel;
}
- (ZHGenderView *)genderView {
    if (!_genderView) {
        _genderView = [[ZHGenderView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerBtn.frame)+10, CGRectGetMaxY(_nameLabel.frame)+3, 30, 15) WithGender:@"XB_0001" AndAge:@"25"];
    }
    return _genderView;
}

- (UILabel *)habitLabel{
    if (!_habitLabel) {
        _habitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerBtn.frame)+10, CGRectGetMaxY(_genderView.frame), BOUNDS.size.width*0.6, 14*2)];
        _habitLabel.text = @"";
        _habitLabel.textAlignment = NSTextAlignmentLeft;
        _habitLabel.font = [UIFont systemFontOfSize:13];
    }
    return _habitLabel;
}

//- (UILabel * )agerLabel{
//    if (!_agerLabel) {
//        _agerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerBtn.frame)+10, CGRectGetMaxY(_nameLabel.frame)+gapCell, 0, 14)];
//        _agerLabel.text = @"999999岁";
//        _agerLabel.font = [UIFont systemFontOfSize:14];
//        [_agerLabel sizeToFit];
//    }
//    return _agerLabel;
//}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerBtn.frame)+10, gapCell*2, CGRectGetWidth(BOUNDS)/2 - 20, 16)];
//        _nameLabel.backgroundColor = [UIColor orangeColor];
        _nameLabel.text = @"哈哈开会SD卡活动卡上的课教案上登记卡号大厦空间的";
        _nameLabel.font = Btn_font;
    }
    return _nameLabel;
}

- (UIButton *)headerBtn{
    if (!_headerBtn) {
        _headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _headerBtn.frame = CGRectMake(gapCell*2, gapCell*2, 55, 55);
        _headerBtn.layer.cornerRadius = _headerBtn.frame.size.width/2;
        _headerBtn.layer.masksToBounds = YES;
    }
    return _headerBtn;
}
//- (UIImageView*)genderImg{
//    if (_genderImg == nil) {
//        _genderImg = [[UIImageView alloc] initWithFrame:CGRectZero];
//    }
//    return _genderImg;
//}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
