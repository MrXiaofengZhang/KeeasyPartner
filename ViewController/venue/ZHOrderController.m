//  ZHOrderController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/7.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHOrderController.h"
#import "ZHOrderController.h"
#import "ZHVenueModel.h"
#import "MyVenueView.h"
#import "ZHTaocanModel.h"
#import "ZHNavigation.h"
#import "LVShareManager.h"
#import "ZHVenueTaocanCell.h"
#import "ZHPayResultController.h"
#import "WPCComfirmVenueVC.h"
#import "ZHCommentController.h"
#import "ImgShowViewController.h"
@interface ZHOrderController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{

    CGFloat detailHeight;
    NSArray *imageArray;
    NSDictionary *venueInfo;
    NSDictionary *packageInfo;
    NSDictionary *bigOrder;
    NSArray *smallOrder;
    
    
}
@property (nonatomic,strong) MyVenueView *headView;
@property (nonatomic,strong) UILabel *expireLb;//有效期
@property (nonatomic,strong) UILabel *duringLb;//使用时间
@property (nonatomic,strong) UILabel *ruleLb;//使用规则
@property (nonatomic,assign) BOOL isTeamBy;
@property (nonatomic,strong) UIButton *commentBtn;
//复用该视图，更改中间的部分
@property (nonatomic,strong) UITableView *mTableView;


@end

@implementation ZHOrderController
//- (void)commentOnclick{
//    ZHCommentController *comentVC =[[ZHCommentController alloc] init];
//    comentVC.fromStyle = StyelResultVenueComment;
//    [self.navigationController pushViewController:comentVC animated:YES];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    detailHeight=240;
    self.title = @"订单详情";
    imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self loadDefaultData];
    
    [self navgationbarRrightImg:@"share" WithAction:@selector(sharOnClick) WithTarget:self];
    
    [self navgationBarLeftReturn];
    
}
- (UILabel*)expireLb{
    if (_expireLb==nil) {
        _expireLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _expireLb.textAlignment = NSTextAlignmentLeft;
        _expireLb.font = Btn_font;
        _expireLb.textColor = Content_lbColor;
    }
    return _expireLb;
}
- (UILabel*)duringLb{
    if (_duringLb==nil) {
        _duringLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _duringLb.textAlignment = NSTextAlignmentLeft;
        _duringLb.font = Btn_font;
        _duringLb.textColor = Content_lbColor;
    }
    return _duringLb;
}
- (UILabel*)ruleLb{
    if (_ruleLb==nil) {
        _ruleLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _ruleLb.textAlignment = NSTextAlignmentLeft;
        _ruleLb.font = Btn_font;
        _ruleLb.textColor = Content_lbColor;
    }
    return _ruleLb;
}

- (void)sharOnClick{
    [LVShareManager shareText:kShareText Targert:self AndImg:nil];
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}

//场地详情
- (void)loadDefaultData{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:self.idString forKey:@"id"];
    NSLog(@"%@",dic);
    [DataService requestWeixinAPI:getVenuesOrderDetail parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"result ======================== %@",result);
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            venueInfo = [NSDictionary dictionaryWithDictionary:result[@"venues"]];
            bigOrder = [NSDictionary dictionaryWithDictionary:result[@"order"]];
            smallOrder = [NSArray arrayWithArray:result[@"detailOrder"]];
            if ([bigOrder[@"orderType"] isEqualToString:@"DDLX_0004"]) {//选座的订单
                _isTeamBy = NO;
                packageInfo = nil;
            } else {//团购的订单
                _isTeamBy = YES;
                if ([result[@"venuesPackages"] isKindOfClass:[NSNull class]]) {
                    
                }
                else{
                packageInfo = [NSDictionary dictionaryWithDictionary:result[@"venuesPackages"]];
                }
            }
            _taocanModel = [[ZHTaocanModel alloc] init];
            [_taocanModel setValuesForKeysWithDictionary:packageInfo];
            imageArray = [NSArray arrayWithArray:result[@"venuesPicList"]];
            [self.view addSubview:self.mTableView];
        } else {
            [self showHint:@"订单获取失败，请重试"];
        }
    }];
}

- (void)callOnclick{
//    [LVTools callPhoneToNumber:[LVTools mToString:venueInfo[@"phone"]] InView:self.view];
    [WCAlertView showAlertWithTitle:nil message:[LVTools mToString:venueInfo[@"phone"]] customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            NSLog(@"venueinfo === %@",venueInfo);
            [LVTools callPhoneToNumber:[LVTools mToString:venueInfo[@"phone"]] InView:self.view];
            NSMutableDictionary *dic = [LVTools getTokenApp];
            [dic setValue:[LVTools mToString:venueInfo[@"phone"]] forKey:@"venuesPhoneNumber"];
            [dic setValue:[LVTools mToString:venueInfo[@"id"]] forKey:@"venuesId"];
            [dic setValue:[LVTools mToString:venueInfo[@"venuesName"]] forKey:@"venuesName"];
            if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
                [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
                [dic setValue:[kUserDefault valueForKey:kUserName] forKey:@"userName"];
                [dic setValue:[LVTools mToString:[kUserDefault valueForKey:KUserMobile]] forKey:@"userPhoneNumber"];
            } else {
                [dic setValue:@"" forKey:@"userId"];
                [dic setValue:@"" forKey:@"userName"];
                [dic setValue:@"" forKey:@"userPhoneNumber"];
            }
            
            [DataService requestWeixinAPI:callStatic parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                
            }];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
}

- (void)locationOnClick{
    //    Amappilot *amappilot = [[Amappilot alloc] init];
    if ( [[LVTools mToString:venueInfo[@"latitude"]] isEqualToString:@""]||[[LVTools mToString:venueInfo[@"longitude"]] isEqualToString:@""]) {
        [self showHint:@"抱歉,还没有相关数据,详情请致电"];
    }
    else{
        //[amappilot firstNaviLat:self.vennueModel.latitude WithLng:self.vennueModel.longitude WithTargr:self];
        //[amappilot firstNaviLat:@"116.3" WithLng:@"39.9" WithTargr:self];
        ZHNavigation *_zhnavigation;
        _zhnavigation=[[ZHNavigation alloc]initWithBkDelegate:self];
        CLLocationCoordinate2D OriginLocation,DestinationLocation;
        OriginLocation.latitude=[[kUserDefault objectForKey:kLocationLat] floatValue];
        
        OriginLocation.longitude=[[kUserDefault objectForKey:kLocationlng] floatValue];
        NSLog(@"latitude=%f", OriginLocation.latitude);
        NSLog(@"longitude=%f", OriginLocation.longitude);
        DestinationLocation.latitude=[[LVTools mToString:venueInfo[@"latitude"]] floatValue];
        DestinationLocation.longitude=[[LVTools mToString:venueInfo[@"longitude"]] floatValue];
        
        [_zhnavigation showNavigationWithOriginLocation:OriginLocation WithDestinationLocation:DestinationLocation WithOriginTilte:nil WithDestinationTitle:nil];
    }
}

#pragma mark Getter
- (void)imgsOnClick {
    //点击看图集
    NSMutableArray *arr = [NSMutableArray array];
    NSLog(@"imagear ====  %@",imageArray);
    for (int i = 0; i < imageArray.count; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,imageArray[i][@"path"]];
        [arr addObject:str];
    }
    ImgShowViewController *imgShowVC =[[ImgShowViewController alloc]initWithSourceData:arr withIndex:0 hasUseUrl:YES];
    [self.navigationController pushViewController:imgShowVC animated:YES];
}
- (MyVenueView*)headView{
    if (_headView == nil) {
        _headView = [[MyVenueView alloc] initWithTitle:nil AndFirstContent:nil AndSecContent:nil AndThirdContent:nil andBaseInfo:venueInfo];
        _headView.backgroundColor = [UIColor whiteColor];
        if (imageArray.count > 0) {
            NSString *str =[NSString stringWithFormat:@"%@%@",preUrl,imageArray[0][@"path"]];
            [_headView.mImgView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            if ([[NSString stringWithFormat:@"%ld",(long)imageArray.count] length] > 0) {
                _headView.imgCountLb.text = [NSString stringWithFormat:@"%ld",(long)imageArray.count];
                UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgsOnClick)];
                [_headView.mImgView addGestureRecognizer:tap];
            } else {
                _headView.imgCountLb.text = @"0";
            }
        }
    }
    return _headView;
}

- (void)commentAction {
    ZHCommentController *vc = [[ZHCommentController alloc] init];
    vc.fromStyle = StyelResultVenueComment;
    vc.count = 3;
    vc.chuanComment = ^(NSDictionary *dic) {
        _commentBtn.hidden = YES;
        _mTableView.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64);
    };
    vc.idstring = [LVTools mToString:bigOrder[@"id"]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
       
        if ([bigOrder[@"status"] isEqualToString:DDZT_0005]) {
            _mTableView.height = _mTableView.height - kBottombtn_height;
            _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_commentBtn setImage:[UIImage imageNamed:@"comment_venue_wpc"] forState:UIControlStateNormal];
            _commentBtn.frame = CGRectMake(0, _mTableView.bottom, UISCREENWIDTH, kBottombtn_height);
            _commentBtn.layer.borderWidth = 0.5;
            _commentBtn.layer.borderColor = [RGBACOLOR(222, 222, 222, 1) CGColor];
            [_commentBtn addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_commentBtn];
        }
        [_mTableView setSeparatorInset:UIEdgeInsetsZero];
        _mTableView.tableHeaderView = self.headView;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
    }
    return _mTableView;
}
- (void)yuyueOnClick:(id)sender{
    
}
#pragma mark UITableViewDatasourse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        if (_isTeamBy) {
            return 1;
        }
        else{
            return 0;
        }
    }
    else if (section == 2) {
        return smallOrder.count+1;
    }
    else{
        return 2;
    }
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        static NSString *infocell =@"infocell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"电话:%@",[LVTools mToString:venueInfo[@"venuesName"]]];
            cell.textLabel.font = Btn_font;
            img.image = [UIImage imageNamed:@"redMarker"];
            cell.accessoryView = img;
        }
        else{
            cell.textLabel.text = [NSString stringWithFormat:@"电话:%@",[LVTools mToString:venueInfo[@"phone"]]];
            cell.textLabel.font = Btn_font;
            img.image = [UIImage imageNamed:@"callphone1"];
            cell.accessoryView = img;
        }
        return cell;
    }
    else if(indexPath.section == 1){
        static NSString *venueCell =@"taocanCell";
        ZHVenueTaocanCell *cell = [tableView dequeueReusableCellWithIdentifier:venueCell];
        if (cell == nil) {
            cell = [[ZHVenueTaocanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:venueCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell configTaocanModel:_taocanModel];
        return cell;
    }
    else if(indexPath.section == 2){
        if (indexPath.row==0) {
            static NSString *idet = @"Cell0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idet];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idet];
            }
            if (_isTeamBy) {
                cell.textLabel.text = @"团购券";
                cell.detailTextLabel.text = [LVTools mToString:_taocanModel.openTime];
            } else {
                cell.textLabel.text = @"订单详细";
            }
            return cell;
        }
        else{
            static NSString *idet = @"Cell1";
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:idet];
            }
            NSLog(@"small order == %@",smallOrder);
            NSString *secretString = [LVTools mToString:[[smallOrder objectAtIndex:(indexPath.row-1)] objectForKey:@"orderKeyword"]];
            NSLog(@"sectrt ======== %@",secretString);
            NSString *str1 = [NSString stringWithFormat:@"密码%ld:%@",(long)indexPath.row,secretString];
            
            NSLog(@"str1 ===== %@",str1);
            UILabel *headLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 200, 18)];
            headLab.text = str1;
            
            headLab.font = Btn_font;
            [cell.contentView addSubview:headLab];
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH-70, 12, 50, 18)];
            statusLabel.textAlignment = NSTextAlignmentCenter;
            statusLabel.layer.cornerRadius = 2;
            statusLabel.layer.masksToBounds = YES;
            statusLabel.font = Btn_font;
            if ([[LVTools mToString:smallOrder[indexPath.row-1][@"status"]] isEqualToString:@"0"]) {
                statusLabel.backgroundColor = [UIColor redColor];
                statusLabel.text = @"未支付";
                statusLabel.textColor = [UIColor whiteColor];
            } else if ([[LVTools mToString:smallOrder[indexPath.row-1][@"status"]] isEqualToString:@"1"]) {
                statusLabel.backgroundColor = NavgationColor;
                statusLabel.text = @"未消费";
                statusLabel.textColor = [UIColor whiteColor];
            } else {
                statusLabel.backgroundColor = [UIColor lightGrayColor];
                statusLabel.text = @"已消费";
                statusLabel.textColor = RGBACOLOR(80, 80, 80, 1);
            }
            [cell.contentView addSubview:statusLabel];
            if (!_isTeamBy) {
                for (int j = 0; j < 3; j ++) {
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/5*2+UISCREENWIDTH/5*j, 40, UISCREENWIDTH/5, 22)];
                    lab.font = [UIFont systemFontOfSize:15];
                    lab.textAlignment = NSTextAlignmentCenter;
                    if (j == 0) {
                        lab.text = [LVTools mToString:smallOrder[indexPath.row-1][@"time"]];
                    } else if (j == 1) {
                        lab.text = smallOrder[indexPath.row-1][@"place"];
                    } else {
                        NSString *priceString = [NSString stringWithFormat:@"%@元",[LVTools mToString:smallOrder[indexPath.row-1][@"price"]]];
                        lab.text = priceString;
                    }
                    lab.backgroundColor = [UIColor clearColor];
                    lab.textColor = [UIColor blackColor];
                    [cell.contentView addSubview:lab];
                }
            }
            return cell;
        }
    }
    else{
        if (indexPath.row==0) {
            static NSString *idet = @"Cell3";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idet];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idet];
            }
            NSDictionary *statusDic = @{DDZT_0001:@"未支付",DDZT_0002:@"未消费",DDZT_0003:@"作废",DDZT_0004:@"申请退款",DDZT_0005:@"待评价",DDZT_0006:@"已评价"};
            NSString *statusString = [statusDic valueForKey:bigOrder[@"status"]];
            cell.textLabel.text = [NSString stringWithFormat:@"订单信息(%@)",statusString];
            if (!_isTeamBy) {
                if (smallOrder.count!=0) {
                cell.textLabel.text = [NSString stringWithFormat:@"订单信息(%@)  %@",statusString,[LVTools mToString:smallOrder[0][@"date"]]];
                }
                else{
                    cell.textLabel.text = @"无";
                }
            }
            return cell;
        }
        else{
            static NSString *idet = @"Cell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idet];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:idet];
            }
            NSArray *arr = @[@"订单号：",@"订单状态：",@"手机号：",@"数量：",@"总价："];
            for (int i = 0; i < 5; i ++) {
                UILabel *prelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5+25*i, 100, 25)];
                prelabel.font = Btn_font;
                prelabel.text = arr[i];
                prelabel.textAlignment = NSTextAlignmentRight;
                [cell.contentView addSubview:prelabel];
            }
            NSDictionary *statusDic = @{DDZT_0001:@"未支付",DDZT_0002:@"未消费",DDZT_0003:@"作废",DDZT_0004:@"申请退款",DDZT_0005:@"待评价",DDZT_0006:@"已评价"};
            
            NSString *statusString = [statusDic valueForKey:bigOrder[@"status"]];
            NSArray *contentArr = @[[LVTools mToString:bigOrder[@"orderNum"]],statusString,[LVTools mToString:[kUserDefault valueForKey:KUserMobile]],[LVTools mToString:bigOrder[@"quantity"]],[NSString stringWithFormat:@"%@元",[LVTools mToString:bigOrder[@"amount"]]]];
            for (int i = 0; i < 5; i ++) {
                UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5+25*i, 200, 25)];
                contentLabel.font = Btn_font;
                contentLabel.text = contentArr[i];
                [cell.contentView addSubview:contentLabel];
            }
            return cell;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 35;
    }
    else if(indexPath.section == 1)
    {
        return 70;
    }
    else if(indexPath.section == 2){
        if (indexPath.row==0) {
            return 50.0;
        }
        else{
            if (!_isTeamBy) {
                
                return 66;
            } else {
                return 44.0;
            }
        }
    }
    else{
        if (indexPath.row == 0) {
            return 44.0;
        }
        else{
            return 140;
        }
    }
}




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2||section == 3){
        return 15;
    }
    else{
        return 0;
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (_isTeamBy) {
            return detailHeight;
        }
        return 0;
    }
    else{
        return 0;
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0||section == 1) {
        return nil;
    }
    else{
        UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(-1, 0, BOUNDS.size.width+2, 15)];
        lab.backgroundColor = BackGray_dan;
        return lab;
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (_isTeamBy) {
            UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 200)];
            v.backgroundColor = [UIColor whiteColor];
            UILabel *lb0 =[[UILabel alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, BOUNDS.size.width-4*mygap, 20)];
            lb0.text = @"购买须知";
            lb0.textColor = [UIColor blackColor];
            lb0.font = Btn_font;
            [v addSubview:lb0];
            
            
            UILabel *lb1 =[[UILabel alloc] initWithFrame:CGRectMake(mygap*2, lb0.bottom, lb0.width, lb0.height)];
            lb1.text = @"有效期:";
            lb1.textColor = color_red_dan;
            lb1.font = Content_lbfont;
            [v addSubview:lb1];
            [v addSubview:self.expireLb];
            self.expireLb.text = [LVTools mToString:self.taocanModel.valid];
            CGFloat height1= [self.expireLb.text boundingRectWithSize:CGSizeMake(BOUNDS.size.width-4*mygap, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.expireLb.font} context:nil].size.height;
            self.expireLb.frame = CGRectMake(lb1.left, lb1.bottom, BOUNDS.size.width-4*mygap, height1);
            
            UILabel *lb2 =[[UILabel alloc] initWithFrame:CGRectMake(mygap*2, self.expireLb.bottom+mygap, lb0.width, lb0.height)];
            lb2.text = @"使用时间:";
            lb2.textColor = color_red_dan;
            lb2.font = Content_lbfont;
            [v addSubview:lb2];
            [v addSubview:self.duringLb];
            self.duringLb.text = [LVTools mToString:self.taocanModel.openTime];
            CGFloat height2= [self.duringLb.text boundingRectWithSize:CGSizeMake(BOUNDS.size.width-4*mygap, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.duringLb.font} context:nil].size.height;
            self.duringLb.frame = CGRectMake(lb1.left, lb2.bottom, BOUNDS.size.width-4*mygap, height2);
            
            UILabel *lb3 =[[UILabel alloc] initWithFrame:CGRectMake(mygap*2, self.duringLb.bottom+mygap, lb0.width, lb0.height)];
            lb3.text = @"使用规则:";
            lb3.textColor = color_red_dan;
            lb3.font = Content_lbfont;
            [v addSubview:lb3];
            
            NSString *noticeString = [LVTools mToString:self.taocanModel.notice];
            UITextView *ruleTextView = [[UITextView alloc] initWithFrame:CGRectMake(mygap*2, lb3.bottom, UISCREENWIDTH-mygap*4, 100)];
            ruleTextView.showsVerticalScrollIndicator = NO;
            ruleTextView.editable = NO;
            ruleTextView.textColor = Content_lbColor;
            ruleTextView.font = Btn_font;
            ruleTextView.text = noticeString;
            [v addSubview:ruleTextView];
            
            v.frame = CGRectMake(0, 0, UISCREENWIDTH, ruleTextView.bottom+mygap);
            detailHeight = v.height;
            NSLog(@"f== %f",detailHeight);
            return v;
        }
        return nil;
    }
    return nil;
}
#pragma mark UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self locationOnClick];
        } else {
            [self callOnclick];
        }
    }

}


@end
