//
//  ZHVenueTaocanController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHVenueTaocanController.h"
#import "ZHVenueModel.h"
#import "MyVenueView.h"
#import "ZHTaocanModel.h"
#import "ZHNavigation.h"
#import "WPCCommentCell.h"
#import "LVShareManager.h"
#import "LoginHomeZhViewController.h"
#import "ZHVenueTaocanCell.h"
#import "WPCComfirmVenueVC.h"
#import "ImgShowViewController.h"
#import "WPCMyOwnVC.h"
#import "WPCFriednMsgVC.h"
#import "WPCImageView.h"
//#import "BNCoreServices.h"
//#import "Amappilot.h"
@interface ZHVenueTaocanController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{
    NSMutableArray *taocanArray;
    NSMutableArray *imageArray;
    NSMutableArray *commentArray;
}
@property (nonatomic,strong) MyVenueView *headView;
@property (nonatomic,strong) UIScrollView *imgScrollview;
@property (nonatomic,strong) UIImageView *acviticyRedLine;
@property (nonatomic,strong) UIScrollView *contentScrollview;
@property (nonatomic,strong) UITextView *contentView;
@property (nonatomic,strong) UITextView *xuzhiTextView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) UILabel *expireLb;//有效期
@property (nonatomic,strong) UILabel *duringLb;//使用时间
@property (nonatomic,strong) UILabel *ruleLb;//使用规则

//复用该视图，更改中间的部分
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation ZHVenueTaocanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"团购详情";
    taocanArray = [[NSMutableArray alloc] initWithCapacity:0];
    imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    commentArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self loadDefaultData];
    //[self loadImagesdata];
    [self navgationbarRrightImg:@"share" WithAction:@selector(sharOnClick) WithTarget:self];
    
    [self navgationBarLeftReturn];
    
    NSLog(@"notice ======================= %@",self.taocanModel.notice);
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
    [LVShareManager shareText:kShareText Targert:self AndImg:self.venueImg];
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}

//场地详情
- (void)loadDefaultData{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setObject:self.vennueModel.id forKey:@"venuesId"];
    [DataService requestWeixinAPI:getVenuesDetail parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
        if ([resultDic[@"statusCode"] isEqualToString:@"success"]) {
            for (NSDictionary * dic in resultDic[@"venuesPackageList"]) {
                ZHTaocanModel *model = [[ZHTaocanModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [taocanArray addObject:model];
            }
            [self.vennueModel setValuesForKeysWithDictionary:resultDic[@"venues"]];
            [imageArray addObjectsFromArray:resultDic[@"venuesPicList"]];
            
            
            
            NSArray *commentTempArr = [NSArray arrayWithArray:resultDic[@"comments"]];
            if (commentTempArr.count > 0) {
                NSMutableArray *temp = [NSMutableArray array];
                
                for (int i = 0; i < [commentTempArr count]; i ++) {
                    [temp addObject:[LVTools mToString:[commentTempArr[i] valueForKey:@"id"]]];
                }
                
                [LVTools sortArrayWithArray:temp andAscend:NO];
                for (int i = 0; i < temp.count; i ++) {
                    for (int j = 0; j <  [commentTempArr count]; j ++) {
                        if ([[LVTools mToString:[commentTempArr objectAtIndex:j][@"id"]] isEqualToString:temp[i]]) {
                            [commentArray addObject:commentTempArr[j]];
                        }
                    }
                }
            }
            
            [self.view addSubview:self.mTableView];
        }
    }];
}

- (void)callOnclick{
//    [LVTools callPhoneToNumber:[LVTools mToString:self.vennueModel.phone] InView:self.view];
    [WCAlertView showAlertWithTitle:nil message:[LVTools mToString:self.vennueModel.phone] customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            [LVTools callPhoneToNumber:[LVTools mToString:self.vennueModel.phone] InView:self.view];
            NSMutableDictionary *dic = [LVTools getTokenApp];
            [dic setValue:[LVTools mToString:self.vennueModel.phone] forKey:@"venuesPhoneNumber"];
            [dic setValue:[LVTools mToString:self.vennueModel.id] forKey:@"venuesId"];
            [dic setValue:[LVTools mToString:self.vennueModel.venuesName] forKey:@"venuesName"];
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
- (void)contentOnClick:(UIButton*)btn{
    CGRect frame = _acviticyRedLine.frame;
    frame.origin.x = (btn.tag - 400)*80;
    _acviticyRedLine.frame = frame;
    _contentScrollview.contentOffset = CGPointMake(BOUNDS.size.width*(btn.tag-400), 0);
}
- (void)locationOnClick{
    //    Amappilot *amappilot = [[Amappilot alloc] init];
    if ( [[LVTools mToString:self.vennueModel.latitude] isEqualToString:@""]||[[LVTools mToString:self.vennueModel.longitude] isEqualToString:@""]) {
        [self showHint:@"抱歉,还没有相关数据,详情请致电"];
    }
    else{
        //    [amappilot firstNaviLat:self.vennueModel.latitude WithLng:self.vennueModel.longitude WithTargr:self];
        //[amappilot firstNaviLat:@"116.3" WithLng:@"39.9" WithTargr:self];
        ZHNavigation *_zhnavigation;
        _zhnavigation=[[ZHNavigation alloc]initWithBkDelegate:self];
        CLLocationCoordinate2D OriginLocation,DestinationLocation;
        OriginLocation.latitude=[[kUserDefault objectForKey:kLocationLat] floatValue];
        
        OriginLocation.longitude=[[kUserDefault objectForKey:kLocationlng] floatValue];
        NSLog(@"latitude=%f", OriginLocation.latitude);
        NSLog(@"longitude=%f", OriginLocation.longitude);
        DestinationLocation.latitude=[self.vennueModel.latitude floatValue];
        DestinationLocation.longitude=[self.vennueModel.longitude floatValue];
        
        [_zhnavigation showNavigationWithOriginLocation:OriginLocation WithDestinationLocation:DestinationLocation WithOriginTilte:nil WithDestinationTitle:nil];
    }
}

//#pragma mark [导航代理]
//- (void)routePlanDidFinished:(NSDictionary *)userInfo{
//    [BNCoreServices_Strategy setDayNightType:BNDayNight_CFG_Type_Day];
//    [BNCoreServices_UI showNaviUI:BN_NaviTypeReal delegete:self isNeedLandscape:YES];
//}

#pragma mark Getter
- (MyVenueView*)headView{
    if (_headView == nil) {
        _headView = [[MyVenueView alloc] initWithTitle:nil AndFirstContent:nil AndSecContent:nil AndThirdContent:nil andBaseInfo:self.venuesInfoDic];
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
        [_headView setScoreWith:[LVTools mToString:self.vennueModel.level]];
    }
    return _headView;
}

- (void)imgsOnClick {
    NSMutableArray *arr = [NSMutableArray array];
    NSLog(@"imagear ====  %@",imageArray);
    for (int i = 0; i < imageArray.count; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,imageArray[i][@"path"]];
        [arr addObject:str];
    }
    ImgShowViewController *imgShowVC =[[ImgShowViewController alloc]initWithSourceData:arr withIndex:0 hasUseUrl:YES];
    [self.navigationController pushViewController:imgShowVC animated:YES];
}

- (UIScrollView*)imgScrollview{
    if (_imgScrollview == nil) {
        _imgScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 5, BOUNDS.size.width-2*5, BOUNDS.size.width*0.51)];
        _imgScrollview.showsHorizontalScrollIndicator = NO;
        _imgScrollview.pagingEnabled = YES;
        _imgScrollview.delegate=self;
        
    }
    return _imgScrollview;
}
- (UIPageControl*)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageIndicatorTintColor = NavgationColor;
    }
    return _pageControl;
}

- (UIImageView*)acviticyRedLine{
    if (_acviticyRedLine == nil) {
        _acviticyRedLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, _imgScrollview.bottom+50-4, 80, 4)];
        _acviticyRedLine.image = [UIImage imageNamed:@"selectLine"];
    }
    return _acviticyRedLine;
}
- (UIScrollView*)contentScrollview{
    if (_contentScrollview ==nil) {
        _contentScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _imgScrollview.bottom+50, BOUNDS.size.width, 150)];
        _contentScrollview.contentSize =CGSizeMake(BOUNDS.size.width*2, 150) ;
        _contentScrollview.bounces = NO;
        _contentScrollview.pagingEnabled = YES;
        _contentScrollview.delegate =self;
    }
    return _contentScrollview;
}
- (UITextView*)contentView{
    if (_contentView == nil) {
        _contentView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, _contentScrollview.height)];
        _contentView.text = @"场馆简介";
        _contentView.editable = NO;
    }
    return _contentView;
}
- (UITextView*)xuzhiTextView{
    if (_xuzhiTextView == nil) {
        _xuzhiTextView = [[UITextView alloc] initWithFrame:CGRectMake(BOUNDS.size.width, 0, BOUNDS.size.width, _contentScrollview.height)];
        _xuzhiTextView.text = @"场馆须知";
        _xuzhiTextView.editable = NO;
    }
    return _xuzhiTextView;
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.tableHeaderView = self.headView;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
    }
    return _mTableView;
}
- (void)jumpToConfirmVC:(UIButton *)sender {
    //先判断是否登陆
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        WPCComfirmVenueVC *vc = [[WPCComfirmVenueVC alloc] init];
        vc.taocanModel=self.taocanModel;
        vc.vennueModel=self.vennueModel;
        vc.ordertype = @"2";
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self jumpToLoginVC];
    }
}

- (void)jumpToLoginVC{
    LoginHomeZhViewController *loginVC = [[LoginHomeZhViewController alloc] init];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
}

#pragma mark UITableViewDatasourse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        return 1;
    }
    else{
        return commentArray.count;
    }
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        static NSString *infocell =@"infocell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
        }
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"地址:%@",self.vennueModel.address];
            cell.textLabel.font = Btn_font;
            img.image = [UIImage imageNamed:@"redMarker"];
            cell.accessoryView = img;
        }
        else{
            cell.textLabel.text = [NSString stringWithFormat:@"电话:%@",self.vennueModel.phone];
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
        
        ZHTaocanModel *model = _taocanModel;
        [cell.yishouLb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.yishouLb setTitle:@"立即抢购" forState:UIControlStateNormal];
        [cell.yishouLb setBackgroundColor:NavgationColor];
        [cell.yishouLb addTarget:self action:@selector(jumpToConfirmVC:) forControlEvents:UIControlEventTouchUpInside];
        cell.yishouLb.top = 20;
        cell.yishouLb.width = 70;
        cell.yishouLb.height = 25;
        cell.yishouLb.titleLabel.font = Content_lbfont;
        cell.yishouLb.layer.cornerRadius = 5;
        [cell configTaocanModel:model];
        return cell;
    }
    else{
        static NSString *idet = @"commentCell";
        WPCCommentCell *cell = (WPCCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idet commentType:WPCVenueCommentType];
        }
        for (UIView *view in cell.contentView.subviews) {
            view.clipsToBounds = YES;
        }
        [cell configTheplayContent:[commentArray objectAtIndex:indexPath.row]];
        cell.headImgView.tag = indexPath.row +100;
        [cell.headImgView addTarget:self action:@selector(userInfoOnclick:) forControlEvents:UIControlEventTouchUpInside];
        cell.morActionBtn.hidden = YES;
        
        if ([[commentArray objectAtIndex:indexPath.row][@"commentShowList"] count] > 0) {
            for (int i = 0; i < [[commentArray objectAtIndex:indexPath.row][@"commentShowList"] count]; i++) {
                WPCImageView *image = (WPCImageView *)[cell.contentView viewWithTag:400+i];
                image.row = indexPath.row;
                image.userInteractionEnabled = YES;
                UITapGestureRecognizer *commentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImagesFromComment:)];
                [image addGestureRecognizer:commentImgTap];
            }
        }
        return cell;
    }
}

- (void)scanImagesFromComment:(UITapGestureRecognizer *)sender {
    //ImgShowViewController
    WPCImageView *view = (WPCImageView *)sender.view;
    NSMutableArray *imagearr = [NSMutableArray array];
    for (int i = 0; i < [[commentArray objectAtIndex:view.row][@"commentShowList"] count]; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,[[commentArray objectAtIndex:view.row][@"commentShowList"][i] valueForKey:@"path"]];
        [imagearr addObject:str];
    }
    
    ImgShowViewController *vc = [[ImgShowViewController alloc] initWithSourceData:imagearr withIndex:sender.view.tag-400 hasUseUrl:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 35;
    }
    else if(indexPath.section == 1)
    {
        return 70;
    }
    else{
        NSDictionary *dic = [commentArray objectAtIndex:indexPath.row];
        NSString *tempStr;
        if ([[LVTools mToString:[dic objectForKey:@"parentId"]] isEqualToString:@""]) {
            tempStr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
        }
        else{
            tempStr = [NSString stringWithFormat:@"@%@:%@",[dic objectForKey:@"parentName"],[dic objectForKey:@"message"]];
        }
        CGFloat height = [LVTools sizeContent:tempStr With:14 With2:(UISCREENWIDTH-60-50)];
        if ([dic[@"commentShowList"] count] > 0) {
            height += 50;
        }
        return height + 55+18;

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 0;
    }
    else if (section == 2){
        return 30;
    }
    else{
        return 0;
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        CGFloat height1= [[LVTools mToString:self.taocanModel.valid] boundingRectWithSize:CGSizeMake(BOUNDS.size.width-4*mygap, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.expireLb.font} context:nil].size.height;
        CGFloat height2= [[LVTools mToString:self.taocanModel.openTime] boundingRectWithSize:CGSizeMake(BOUNDS.size.width-4*mygap, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.duringLb.font} context:nil].size.height;
        CGFloat height3 = [LVTools sizeContent:[LVTools mToString:self.taocanModel.notice] With:15 With2:UISCREENWIDTH-mygap*4];
        NSLog(@"footer height == %f",100+height1+height2+height3);
        return 100+height1+height2+height3;
    }
    else{
        return 0;
    }
    
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    else if(section == 1){
        
        UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30)];
        v.backgroundColor = [UIColor whiteColor];
        UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(mygap*2, 5, 60, 20)];
        lab.text= [NSString stringWithFormat:@"团购%ld",(long)[taocanArray count]];
        lab.font = Btn_font;
        [v addSubview:lab];
        lab.textColor = [UIColor whiteColor];
        lab.backgroundColor = NavgationColor;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = Btn_font;
        lab.layer.cornerRadius = 5;
        UIView *line =[[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 0.5)];
        line.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        [v addSubview:line];
        return v;
    }
    else{
        UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(-1, 0, BOUNDS.size.width+2, 30)];
        lab.textAlignment = NSTextAlignmentLeft;
        lab.layer.borderColor = RGBACOLOR(222, 222, 222, 1).CGColor;
        lab.layer.borderWidth = 0.5;
        lab.font = Btn_font;
        lab.text = [NSString stringWithFormat:@"  评论%ld",(long)[commentArray count]];
        return lab;
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
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
        CGFloat height3 = [LVTools sizeContent:noticeString With:15 With2:UISCREENWIDTH-mygap*4];
        UILabel *ruleTextView = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, lb3.bottom, UISCREENWIDTH-mygap*4, height3)];
        ruleTextView.textColor = Content_lbColor;
        ruleTextView.numberOfLines = -1;
        ruleTextView.font = Btn_font;
        ruleTextView.text = noticeString;
        [v addSubview:ruleTextView];
        
        v.frame = CGRectMake(0, 0, UISCREENWIDTH, ruleTextView.bottom+mygap);
        return v;
    }
    return nil;
}
#pragma mark UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self locationOnClick];
        } else {
            [self callOnclick];
        }
    }

}
#pragma mark UIscrollviewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidEndDecelerating");
    if ([scrollView isEqual:_imgScrollview]) {
        NSInteger pageNumber = scrollView.contentOffset.x/_imgScrollview.width;
        _pageControl.currentPage = pageNumber;
    }
    if ([scrollView isEqual:_contentScrollview]) {
        NSLog(@"%f",scrollView.contentOffset.x);
        NSInteger pageNumber = scrollView.contentOffset.x/BOUNDS.size.width;
        CGRect frame =_acviticyRedLine.frame;
        frame.origin.x= 80*pageNumber+5
        ;
        _acviticyRedLine.frame = frame;
        
    }
}
#pragma mark [个人信息]
- (void)userInfoOnclick:(UIButton*)btn{
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        NSDictionary *info=nil;
        info=[commentArray objectAtIndex:btn.tag-100];
        NSString *useId =[LVTools mToString: [info objectForKey:@"userId"]];
        NSString *selfid = [LVTools mToString:[kUserDefault objectForKey:kUserId]];
        if (![useId isEqualToString:selfid]) {
            WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
            vc.uid = useId;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            //进入自己的个人中心心
            WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
            vc.basicVC = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [self jumpToLoginVC];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
