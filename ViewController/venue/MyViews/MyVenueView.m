//
//  MyVenueView.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "MyVenueView.h"
#import "VenueSerView.h"//场馆服务
#define boradWidth 0.5f
#define LeftWidth 20
#define lableHeight 30
#define smallFont [UIFont systemFontOfSize:13.0]

@implementation MyVenueView
- (id)init{
    if (self = [super init]) {

    }
    return self;
}
- (id)initWithTitle:(NSString *)title AndFirstContent:(NSString *)FContent AndSecContent:(NSString *)SContent AndThirdContent:(NSString *)TContent andBaseInfo:(NSDictionary *)info{
    if (self = [super init]) {
        [self addSubview:self.mImgView];
        [self addSubview:self.titleLb];
        [self addSubview:self.FirstLb];
        [self addSubview:self.SecondLb];
        [self addSubview:self.ThirdLb];
        self.infoDic = [NSDictionary dictionaryWithDictionary:info];
        NSLog(@"infodic === %@",self.infoDic);
        _titleLb.text = [LVTools mToString:info[@"venuesName"]];
        _FirstLb.text = [[LVTools mToString:info[@"cityMeaning"]] stringByAppendingString:[LVTools mToString:info[@"areaMeaning"]]];
        _SecondLb.text = [NSString stringWithFormat:@"¥%@/人",info[@"bottomPrice"]];
        [self setScoreWith:[LVTools mToString:info[@"info"]]];
        
        
        self.distanceImg = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width - 80, self.ThirdLb.top+5, 15, 15)];
        self.distanceImg.image = [UIImage imageNamed:@"Marker"];
        
        [self addSubview:self.distanceImg];
        
        self.distanceLb = [[UILabel alloc] initWithFrame:CGRectMake(self.distanceImg.frame.origin.x+self.distanceImg.frame.size.width, self.distanceImg.frame.origin.y-3, 60, 18)];
        self.distanceLb.textColor = [UIColor lightGrayColor];
        self.distanceLb.font = Content_lbfont;
        self.distanceLb.text = [LVTools caculateDistanceFromLat:info[@"latitude"] andLng:info[@"longitude"]];
        [self addSubview:self.distanceLb];

        [self addSubview:self.serviceiew];
        
        NSString *str = [LVTools mToString:info[@"leadTime"]];
        if (str.length != 0) {
            _tipsLab.text = [NSString stringWithFormat:@"提示:如需选场退款申请,请提前%@小时申请",str];
        } else {
            _tipsLab.text = @"提示:场馆预选后不可退款,请仔细选择";
        }
        
        self.frame =CGRectMake(0, 0, BOUNDS.size.width, self.serviceiew.bottom);
    }
    return self;
}
- (UIImageView*)mImgView{
    if (_mImgView == nil) {
        _mImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2*mygap, 2*mygap, 100, 80)];
        _mImgView.image = [UIImage imageNamed:@"applies_plo"];
        _mImgView.contentMode = UIViewContentModeScaleAspectFill;
        _mImgView.clipsToBounds = YES;
        _mImgView.userInteractionEnabled = YES;
        [_mImgView addSubview:self.imgCountLb];
        self.imgCountLb.text = @"0";
    }
    return _mImgView;
}
- (UILabel*)imgCountLb{
    if (_imgCountLb == nil) {
        _imgCountLb = [[UILabel alloc] initWithFrame:CGRectMake(80, 60,20, 20)];
        _imgCountLb.backgroundColor = [UIColor blackColor];
        _imgCountLb.alpha = 0.5;
        _imgCountLb.layer.cornerRadius = 10.0;
        _imgCountLb.textColor = [UIColor whiteColor];
        _imgCountLb.layer.masksToBounds = YES;
        _imgCountLb.textAlignment = NSTextAlignmentCenter;
        _imgCountLb.userInteractionEnabled = YES;
        _imgCountLb.font = Content_lbfont;
    }
    return _imgCountLb;
}
- (UILabel*)titleLb{
    if (_titleLb == nil) {
        _titleLb = [[UILabel alloc] initWithFrame:CGRectMake(_mImgView.right+mygap, _mImgView.top, BOUNDS.size.width-(_mImgView.right+mygap-mygap), 20)];
        _titleLb.text = @"个人专场套餐";
        _titleLb.textAlignment = NSTextAlignmentLeft;
        _titleLb.font = Btn_font;
    }
    return _titleLb;
}
- (UILabel*)FirstLb{
    if (_FirstLb == nil) {
        _FirstLb = [[UILabel alloc] initWithFrame:CGRectMake(_titleLb.left, _titleLb.bottom, _titleLb.width, _titleLb.height)];
        _FirstLb.text = @"北京市海淀区";
        _FirstLb.textColor = [UIColor lightGrayColor];
        _FirstLb.font = smallFont;
        _FirstLb.textAlignment = NSTextAlignmentLeft;
    }
    return _FirstLb;
}
- (UILabel*)SecondLb{
    if (_SecondLb == nil) {
        _SecondLb = [[UILabel alloc] initWithFrame:CGRectMake(_titleLb.left, _FirstLb.bottom, _titleLb.width, _titleLb.height)];
        _SecondLb.textAlignment = NSTextAlignmentLeft;
       _SecondLb.text = @"¥50/人";
        _SecondLb.textColor = [UIColor redColor];
        _SecondLb.font = smallFont;
    }
    return _SecondLb;
}
- (UILabel*)ThirdLb{
    //评分
    if (_ThirdLb == nil) {
        _ThirdLb = [[UILabel alloc] initWithFrame:CGRectMake(_titleLb.left, _SecondLb.bottom, _titleLb.width, _titleLb.height)];
        for (NSInteger i=0; i<5; i++) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(i*(15+mygap), 0, 15, 15)];
            img.tag = 100+i;
            img.image = [UIImage imageNamed:@"unstar"];
            [self.ThirdLb addSubview:img];
        }

        _ThirdLb.font = smallFont;
    }
    return _ThirdLb;
}
- (void)setScoreWith:(NSString*)score{
    CGFloat pingfen = [score floatValue];
    for (NSInteger i=0; i<pingfen; i++) {
        UIImageView *img = (UIImageView*)[self.ThirdLb viewWithTag:100+i];
        img.image = [UIImage imageNamed:@"star"];
    }
}

- (UIView*)serviceiew{
    if (_serviceiew == nil) {
        _serviceiew = [[UIView alloc] initWithFrame:CGRectMake(-1, _ThirdLb.bottom+2*mygap, BOUNDS.size.width+2, 80)];
        _serviceiew.layer.borderColor = RGBACOLOR(222, 222, 222, 1).CGColor;
        _serviceiew.layer.borderWidth = 0.5;
        NSString *services = [LVTools mToString:self.infoDic[@"services"]];
        NSArray *optionalArr = [services componentsSeparatedByString:@","];
        NSArray *contentArray = @[@"停车场",@"柜子租赁",@"休息区域",@"洗浴设施",@"器材租赁",@"球馆卖品"];

        for(int i=0;i<4;i++){
            NSString *imgStr = nil;
            NSString *serviceStr = [NSString stringWithFormat:@"FW_000%d",i+1];
            if ([optionalArr containsObject:serviceStr]) {
                imgStr = [NSString stringWithFormat:@"service_%.2d",(int)(i+1)];
            } else {
                imgStr = [NSString stringWithFormat:@"service_%d",i+1];
            }
            VenueSerView *v =[[VenueSerView alloc] initWithFrame:CGRectMake(mygap*2+1+80*i, 5, 80, 20) Title:contentArray[i] AndImg:imgStr];
            v.tag=100+i;
            [_serviceiew addSubview:v];
           
        }
        
        for (int i=0; i<2; i++) {
            
            NSString *imgStr = nil;
            NSString *serviceStr = [NSString stringWithFormat:@"FW_000%d",i+5];
            if ([optionalArr containsObject:serviceStr]) {
                imgStr = [NSString stringWithFormat:@"service_%.2d",(int)(i+1+4)];
            } else {
                imgStr = [NSString stringWithFormat:@"service_%d",i+1+4];
            }
            VenueSerView *v =[[VenueSerView alloc] initWithFrame:CGRectMake(mygap*2+1+80*i, 30, 80, 20) Title:contentArray[i+4] AndImg:imgStr];
            v.tag=104+i;
            
            [_serviceiew addSubview:v];
        }
        [_serviceiew addSubview:self.tipsLab];
    }
    return _serviceiew;
}

- (UILabel *)tipsLab {
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 57, UISCREENWIDTH-20, 15)];
        _tipsLab.font = Content_lbfont;
        _tipsLab.textColor = RGBACOLOR(100, 100, 100, 1);
    }
    return _tipsLab;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
