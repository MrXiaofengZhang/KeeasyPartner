//
//  WPCApplyDetailVC.m
//  yuezhan123
//
//  Created by admin on 15/7/8.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCApplyDetailVC.h"

@interface WPCApplyDetailVC ()<UIScrollViewDelegate>{
    NSMutableDictionary *match;
    NSMutableDictionary *order;
    NSMutableDictionary *signup;
}

@property (nonatomic, strong)UIScrollView *scroll;
@property (nonatomic, strong)UIView *firstView;
@property (nonatomic, strong)UIView *secondView;
@property (nonatomic, strong)UIView *thirdView;
@property (nonatomic, strong)NSArray *keysArray;//返回的info里面的字典keys
@property (nonatomic, strong)NSArray *infoPreArray;//保存title
@property (nonatomic, strong)NSArray *teamPreArray;

@end

@implementation WPCApplyDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"报名详单";
    [self navgationBarLeftReturn];
    self.view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    match = [[NSMutableDictionary alloc] initWithCapacity:0];
    order = [[NSMutableDictionary alloc] initWithCapacity:0];
    signup = [[NSMutableDictionary alloc] initWithCapacity:0];
    _keysArray = [[NSArray alloc] initWithObjects:@"主办:",@"承办:",@"费用:",@"城市:",@"比赛时间:",@"报名截止:",@"联系电话:", nil];
    
    
    [self loadMatchOrderDetail];
}
//获取比赛订单详情
- (void)loadMatchOrderDetail{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:self.orderDic[@"id"] forKey:@"id"];
    [DataService requestWeixinAPI:getMatchOrderDetail parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"++++++%@",resultDic);
        if ([resultDic[@"statusCode"] isEqualToString:@"success"]) {
            [match setValuesForKeysWithDictionary:resultDic[@"match"]];
            [order setValuesForKeysWithDictionary:resultDic[@"order"]];
            [signup setValuesForKeysWithDictionary:resultDic[@"signup"]];
            [self initialInterface];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
- (void)initialInterface {
    NSString *bmfs = [LVTools mToString:signup[@"signupType"]];
    if ([bmfs isEqualToString:@"BMFS_0001"]) {
        _isTeamOrder = NO;
    }
    else if ([bmfs isEqualToString:@"BMFS_0002"]){
        _isTeamOrder = YES;
    }
    else{
        _isTeamOrder = NO;
    }
    
    if (_isTeamOrder) {
        _infoPreArray = [[NSArray alloc] initWithObjects:@"队名:",@"领队姓名:",@"领队手机号码:",@"队长姓名:",@"队长手机号码:",@"项目组别:",@"参赛人数:", nil];
    } else {
        _infoPreArray = [[NSArray alloc] initWithObjects:@"姓名:",@"性别:",@"手机号码:",@"服装尺码:",@"邮箱:",@"证件类型:",@"证件号:",@"项目组别:",@"紧急联系人:",@"紧急联系人电话:", nil];
    }
    
    _scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64)];
    _scroll.delegate = self;
    _scroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scroll];
    
    [self createFirstView];
    [_scroll addSubview:_firstView];
    
    [self createSecondView];
    [_scroll addSubview:_secondView];
    
    [self createThirdView];
    [_scroll addSubview:_thirdView];
    _scroll.contentSize = CGSizeMake(UISCREENWIDTH, _thirdView.bottom);
    _scroll.scrollEnabled = YES;
}

- (void)createFirstView {
    _firstView = [[UIView alloc] init];
    _firstView.backgroundColor = [UIColor whiteColor];
    NSString *titleString = [LVTools mToString:match[@"matchName"]];
    CGFloat titleWidth = [LVTools sizeWithStr:titleString With:17 With2:20];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, titleWidth, 20)];
    titleLab.text = match[@"matchName"];
    titleLab.font = [UIFont systemFontOfSize:17];
    [_firstView addSubview:titleLab];
    
    UIImageView *stateImg = [[UIImageView alloc] initWithFrame:CGRectMake(titleLab.right, 15, 65, 25)];
    if ([match[@"matchStatus"] isEqualToString:@"即将开赛"]) {
        stateImg.image = [UIImage imageNamed:@"BisaiBegin"];
    }
    else if ([match[@"matchStatus"] isEqualToString:@"比赛结束"]) {
        stateImg.image = [UIImage imageNamed:@"BisaiEnd"];
    }
    else if ([match[@"matchStatus"] isEqualToString:@"正在进行"]) {
        stateImg.image = [UIImage imageNamed:@"Bisaiing"];
    }
    else{
        stateImg.image = [UIImage imageNamed:@""];
    }
    [_firstView addSubview:stateImg];
    NSArray *preimageArray = @[@"zhuban_sport_wpc",@"chengban_sport_wpc",@"feiyong_sport_wpc",@"chengshi_sport_wpc",@"begin_sport_wpc",@"end_sport_wpc",@"phone_sport_wpc"];
    NSArray *contentArr = @[[LVTools mToString: match[@"hosted"]],[LVTools mToString: match[@"chief"]],[LVTools mToString: match[@"registrationFee"]],[LVTools mToString: match[@"cityMeaning"]],[LVTools mToString: match[@"startDate"]],[LVTools mToString: match[@"signUpDate"]],[LVTools mToString: match[@"phone"]]];
    for (int i = 0; i < _keysArray.count; i ++) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, titleLab.bottom+14+30*i, 16, 16)];
        img.layer.cornerRadius = 8;
        [img setImage:[UIImage imageNamed:preimageArray[i]]];
        img.layer.masksToBounds = YES;
        [_firstView addSubview:img];
        
        CGFloat width1 = [LVTools sizeWithStr:_keysArray[i] With:14 With2:16];
        UILabel *prelab = [[UILabel alloc] initWithFrame:CGRectMake(img.right+5, img.top, width1, 16)];
        prelab.text = _keysArray[i];
        prelab.font = [UIFont systemFontOfSize:14];
        [_firstView addSubview:prelab];
        
        CGFloat width2 = [LVTools sizeWithStr:contentArr[i] With:14 With2:16];
        UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(prelab.right, prelab.top, width2, 16)];
        contentLab.text = contentArr[i];
        contentLab.font = [UIFont systemFontOfSize:14];
        [_firstView addSubview:contentLab];
        if ([_keysArray[i] isEqualToString:@"联系电话:"]) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(contentLab.right, contentLab.top, 16, 16);
            [btn setImage:[UIImage imageNamed:@"callPhone"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(phoneClick) forControlEvents:UIControlEventTouchUpInside];
            [_firstView addSubview:btn];
        }
        if (i == _keysArray.count-1) {
            _firstView.frame = CGRectMake(0, 0, UISCREENWIDTH, prelab.bottom+5);
        }
    }
}

- (void)createSecondView {
    _secondView = [[UIView alloc] init];
    _secondView.backgroundColor = [UIColor whiteColor];
    NSArray *preArr = @[@"详单状态:",@"订单编号:"];
    
    for (int i = 0; i < 2; i ++) {
        UILabel *prelab = [[UILabel alloc] initWithFrame:CGRectMake(10, 15+48*i, 70, 18)];
        prelab.textColor = RGBACOLOR(145, 145, 145, 1);
        prelab.text = preArr[i];
        prelab.font = [UIFont systemFontOfSize:14];
        [_secondView addSubview:prelab];
        
        UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectMake(prelab.right+5, 15+48*i, 150, 18)];
        detailLab.font = [UIFont systemFontOfSize:14];
        
        if (i == 0) {

            detailLab.textColor = RGBACOLOR(70, 160, 217, 1);
            if ([[LVTools mToString:order[@"status"]] isEqualToString:DDZT_0001]) {
                if ([[LVTools mToString:signup[@"verifyStatus"]] isEqualToString:@"BMSH_0001"]) {//审核中
                    detailLab.text = @"审核中...";
                } else if ([[LVTools mToString:signup[@"verifyStatus"]] isEqualToString:@"BMSH_0002"]) {//通过
                    detailLab.text = @"审核通过";
                } else if ([[LVTools mToString:signup[@"verifyStatus"]] isEqualToString:@"BMSH_0003"]) {//审核未通过，只能在ddzt0003下
                    detailLab.text = @"审核未通过";
                } else if ([[LVTools mToString:signup[@"verifyStatus"]] isEqualToString:@"BMSH_0004"]) {
                    
                    if ([[LVTools mToString:match[@"isVerify"]] isEqualToString:@"SF_0001"]) {
                        detailLab.text = @"已申请";
                    } else if ([[LVTools mToString:match[@"isVerify"]] isEqualToString:@"SF_0002"]) {
                        detailLab.text = @"未付款";
                    }
                }
            }
            else if ([[LVTools mToString:order[@"status"]] isEqualToString:DDZT_0002]) {
                detailLab.text = @"报名成功";
            }
            else if ([[LVTools mToString:order[@"status"]] isEqualToString:DDZT_0003]) {
                detailLab.text = @"已作废";
            }
        } else {
            detailLab.text =[LVTools mToString: order[@"orderNum"]];
        }
        [_secondView addSubview:detailLab];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 48, UISCREENWIDTH, 0.5)];
        view.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        [_secondView addSubview:view];
    }
    _secondView.frame = CGRectMake(0, _firstView.bottom + 10, UISCREENWIDTH, 96);
}

- (void)createThirdView {
    _thirdView = [[UIView alloc] init];
    _thirdView.backgroundColor = [UIColor whiteColor];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 16, 16)];
    img.layer.cornerRadius = 8;
    [img setImage:[UIImage imageNamed:@"signup_info_wpc"]];
    img.layer.masksToBounds = YES;
    [_thirdView addSubview:img];
    
    UILabel *prelab = [[UILabel alloc] initWithFrame:CGRectMake(img.right+5, img.top, 100, 16)];
    prelab.text = @"报名信息";
    prelab.font = [UIFont systemFontOfSize:14];
    [_thirdView addSubview:prelab];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 40, UISCREENWIDTH, 0.5)];
    line.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [_thirdView addSubview:line];
    NSArray *contentArray = nil;
    if (_isTeamOrder) {
        contentArray = @[[LVTools mToString:signup[@"teamName"]],[LVTools mToString:signup[@"leaderName"]],[LVTools mToString:signup[@"leaderMobile"]],[LVTools mToString:signup[@"captainName"]],[LVTools mToString:signup[@"captainMobile"]],[LVTools mToString:signup[@"groupType"]],[LVTools mToString:signup[@"memberNum"]]];
        
    }
    else{
        NSString *genderStr = [[LVTools mToString:signup[@"gender"]] isEqualToString:@"XB_0002"]?@"女":@"男";
//        NSString *xmzb = @"";
//        if ([[LVTools mToString:signup[@"groupType"]] isEqualToString:@"SSZB_0001"]) {
//            xmzb = @"3V3";
//        }
//        else if ([[LVTools mToString:signup[@"groupType"]] isEqualToString:@"SSZB_0002"]) {
//            xmzb = @"5V5";
//        }
//        else if ([[LVTools mToString:signup[@"groupType"]] isEqualToString:@"SSZB_0003"]) {
//            xmzb = @"其他";
//        }
        contentArray = @[[LVTools mToString:signup[@"userName"]],genderStr,[LVTools mToString:signup[@"mobile"]],[LVTools mToString:signup[@"clothingSize"]],[LVTools mToString:signup[@"email"]],[LVTools mToString:signup[@"certificateType"]],[LVTools mToString:signup[@"certificateNum"]],[LVTools mToString:signup[@"groupType"]],[LVTools mToString:signup[@"leaderName"]],[LVTools mToString:signup[@"leaderMobile"]],];
    }
    
    
    
    NSLog(@"contentarray == %@",contentArray);
    for (int i = 0; i < _infoPreArray.count; i ++) {
        CGFloat width = [LVTools sizeWithStr:_infoPreArray[i] With:14 With2:16];
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 48+20*i, width, 16)];
        lab.text = _infoPreArray[i];
        lab.font = [UIFont systemFontOfSize:14];
        [_thirdView addSubview:lab];
        
        UILabel *detailab = [[UILabel alloc] initWithFrame:CGRectMake(lab.right+5, lab.top, UISCREENWIDTH-lab.right-50, 16)];
        detailab.text = contentArray[i];
        detailab.font = [UIFont systemFontOfSize:14];
        [_thirdView addSubview:detailab];
    }
    _thirdView.frame = CGRectMake(0, _secondView.bottom+10, UISCREENWIDTH, 260);
}


- (void)phoneClick {
    [WCAlertView showAlertWithTitle:nil message:[LVTools mToString:match[@"phone"]] customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LVTools mToString:match[@"phone"]]]];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
}

@end
