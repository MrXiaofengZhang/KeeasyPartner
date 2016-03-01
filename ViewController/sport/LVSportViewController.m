//
//  LVSportViewController.m
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//
//                    _oo0oo_
//                   o8888888o
//                   88" . "88
//                   (| -_- |)
//                   0\  =  /0
//                 ___/`___'\___
//               .' \\|     |// '.
//              / \\|||  :  |||// \
//             / _||||| -:- |||||_ \
//            |   | \\\  _  /// |   |
//            | \_|  ''\___/''  |_/ |
//            \  .-\__  '_'  __/-.  /
//          ___'. .'  /--.--\  '. .'___
//        ."" '<  .___\_<|>_/___. '>' "".
//     | | :  `_ \`.;` \ _ / `;.`/ - ` : | |
//     \ \  `_.   \_ ___\ /___ _/   ._`  / /
//  ====`-.____` .__ \_______/ __. -` ___.`====
//                   `=-----='
//
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//         佛祖保佑                 永无BUG
//━━━━━━神兽出没━━━━━━
//　　　┏┓　　　┏┓
//　　┏┛┻━━━┛┻┓
//　　┃　　　　　　　┃
//　　┃　　　━　　　┃
//　　┃　┳┛　┗┳　┃
//　　┃　　　　　　　┃
//　　┃　　　┻　　　┃
//　　┃　　　　　　　┃
//　　┗━┓　　　┏━┛Code is far away from bug with the animal protecting
//　　　　┃　　　┃ 神兽保佑,代码无bug
//　　　　┃　　　┃
//　　　　┃　　　┗━━━┓
//　　　　┃　　　　　　　┣┓
//　　　　┃　　　　　　　┏┛
//　　　　┗┓┓┏━┳┓┏┛
//　　　　　┃┫┫　┃┫┫
//　　　　　┗┻┛　┗┻┛
//
//━━━━━━感觉萌萌哒━━━━━━
//
//                       .::::.
//                     .::::::::.
//                    :::::::::::
//                 ..:::::::::::'
//              '::::::::::::'
//                .::::::::::
//           '::::::::::::::..
//                ..::::::::::::.
//              ``::::::::::::::::
//               ::::``:::::::::'        .:::.
//              ::::'   ':::::'       .::::::::.
//            .::::'      ::::     .:::::::'::::.
//           .:::'       :::::  .:::::::::' ':::::.
//          .::'        :::::.:::::::::'      ':::::.
//         .::'         ::::::::::::::'         ``::::.
//     ...:::           ::::::::::::'              ``::.
//    ```` ':.          ':::::::::'                  ::::..
//                       '.:::::'                    ':'````..
//
//
#import "LVSportViewController.h"
#import "LVSportItemTableViewCell.h"
#import "GetMatchListModel.h"
#import "ZHNavgationSearchBar.h"
#import "LVScrollView.h"
#import "MJRefresh.h"
#import "WPCSportDetailVC.h"
#import "SMPageControl.h"
#import "ZHAppointBaomingController.h"
#import "ZHItem.h"
#import "EmpatyView.h"
#import "ZHCommentController.h"
#import "ZHSportDetailController.h"
#import "CityTableViewController.h"
#import "CitySchoolsController.h"
#define LeftWidth 10.0
#define ItemWidth ((CGRectGetWidth(BOUNDS)-2*LeftWidth)/5)
#define SiftWidth (CGRectGetWidth(BOUNDS)/4)

@interface LVSportViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ZHRefreshDelegate,SearchClickDelegate,UIActionSheetDelegate>
{
    UIView * bgView;
    LVScrollView * _selectSc;
    SMPageControl * _pageView;
    ZHNavgationSearchBar *_search;
    NSInteger selectPage;
    BOOL isScrolling;
    UIImageView *arrowImg;//上下箭头
    BOOL flag;
    NSString *matchName;//关键字搜索
    NSNumber *cityCode;//城市代码
    NSNumber *schoolId;//学校iD
    
    UIButton *rightBtn;
    UIButton *search;
    NSDictionary *cityInfo;
    NSDictionary *schoolInfo;
    NSMutableArray *banners;

    //引导图
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    NSTimer *timer;
}

@property (nonatomic, strong)UITableView * sportTableView;

@property (nonatomic, strong)NSArray * itemResource;
@property (nonatomic, strong)NSMutableArray * ListDataArray;

@property (nonatomic, strong)NSString * siftSportType;
@property (nonatomic, strong)NSString * siftSportStatus;
@property (nonatomic, strong) UILabel *cityLab;
@property (nonatomic, strong) UIView *leftView;
@end

static NSInteger page = 0;

@implementation LVSportViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化信息
    cityInfo = @{@"id":@"0",@"city":@"全国"};
    self.view.backgroundColor = [UIColor whiteColor];
    self.ListDataArray = [NSMutableArray arrayWithCapacity:0];
    cityCode = nil;
    schoolId = nil;
    self.siftSportType   = nil;
    self.siftSportStatus = nil;
    matchName = @"";
   // [self navgationbarRrightImg:@"select0_3" WithAction:@selector(showSeleted) WithTarget:self];
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"select0_3"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(showSeleted) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [self readPlist];
    
    [self createTableView];
    [self makeUI];
    [self loadBannerData];
    [self MJRrefresh];
    [self creatLeftView:@"全国"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LaunchFirst]) {
        //初始化配置
        [kUserDefault setObject:@"0" forKey:CityCacheTime];
        [kUserDefault setObject:@"0" forKey:SchoolCacheTime];
        [kUserDefault setBool:YES forKey:LaunchFirst];
        [kUserDefault synchronize];
        [self loadLandingView];
    }
    else{
        
    }
}
- (void)dealloc{
    [timer invalidate];
    timer = nil;
}
- (void)creatLeftView:(NSString *)str
{
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        _leftView.frame = CGRectMake(15, 5, 90, 35);
        _leftView.backgroundColor = [UIColor clearColor];
        _leftView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationOnClick:)];
        [_leftView addGestureRecognizer:tap];
        [self.navigationController.navigationBar addSubview:_leftView];
    }
    
    //lab
    if (!_cityLab) {
        _cityLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
        _cityLab.font = [UIFont systemFontOfSize:17];
        _cityLab.backgroundColor = [UIColor clearColor];
        _cityLab.textColor = SystemBlue;
        [_leftView addSubview:_cityLab];
    }
    _cityLab.text = str;
    [_cityLab sizeToFit];
    _leftView.frame = CGRectMake(15, 5, _cityLab.width+10, _cityLab.height+5);
    //arrow去掉
    
    if (!arrowImg) {
        arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(_cityLab.right, _cityLab.bottom-15, 10, 10)];
        UIImage *aImage = [UIImage imageNamed:@"upArrow"];
        arrowImg.image = aImage;
        [_leftView addSubview:arrowImg];
        flag = YES;
        if ([aImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            arrowImg.image = [aImage resizableImageWithCapInsets:UIEdgeInsetsMake(aImage.size.height/2, aImage.size.width/2, aImage.size.height/2, aImage.size.width/2)];
        } else {
            arrowImg.image = [aImage stretchableImageWithLeftCapWidth:aImage.size.width/2 topCapHeight:aImage.size.height/2];
        }
    }
    arrowImg.frame = CGRectMake(_cityLab.right, _cityLab.bottom-15, 10, 10);
    
    _search.searchTextField.frame = CGRectMake(_leftView.right+4, 5, UISCREENWIDTH-_leftView.right-45,30);
}
- (void)locationOnClick:(id)sender{
    //图片旋转
    if (flag) {
        arrowImg.transform=CGAffineTransformMakeRotation(M_PI);
        flag=NO;
    }
    else{
        arrowImg.transform=CGAffineTransformMakeRotation(M_PI*2);
        flag=YES;
    }
    CityTableViewController *cityVC =[[CityTableViewController alloc] init];
    cityVC.title = @"选择城市";
    cityVC.chuanBlock = ^(NSArray *arr){
        cityInfo = [arr objectAtIndex:0];
        _cityLab.text = cityInfo[@"city"];
        [search setTitle:@"选择大学>" forState:UIControlStateNormal];
        schoolId = nil;
        if([cityInfo[@"id"] boolValue]){
        cityCode = cityInfo[@"id"];
        }
        else{
            cityCode = nil;
        }
        [self loadDefaultData:0];
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:cityVC];
    [self presentViewController:navi animated:YES completion:nil];
//    SchoolsController *cityVC =[[SchoolsController alloc] init];
//    cityVC.title = @"选择所在院校";
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:cityVC];
//    [self presentViewController:navi animated:YES completion:nil];
//    CityListViewController *cityVC = [[CityListViewController alloc] init];
//    cityVC.title = @"当前城市";
//    cityVC.hasAllCountry = YES;
//    cityVC.delegate = self;
//    cityVC.citydelegate = self;
//    UINavigationController *navi  =[[UINavigationController alloc] initWithRootViewController:cityVC];
//    [self presentViewController:navi animated:YES completion:^{
//        //
//    }];
//    ZHCommentController *vc =[[ZHCommentController alloc] init];
//    vc.fromStyle = StyleResultMatch;
//        vc.idstring = @"100";
//        vc.title = @"写评论";
//        vc.count = 3;
//    [self.navigationController pushViewController:vc animated:YES];
}

//#pragma mark -- cityDelegate
- (void)sendCityAreas:(NSDictionary *)dic {
    cityCode = dic[@"regionId"];
    [self loadDefaultData:0];
}

- (void)wholeContryClick {
    cityCode = nil;
    [self creatLeftView:@"全国"];
    [self loadDefaultData:0];
}

- (void)collectionClickAtCode:(NSString *)code andName:(NSString *)name andInfo:(NSDictionary *)dic{
    cityCode = @0;
    [self creatLeftView:name];
    [self loadDefaultData:0];
}

- (void)sendMsg:(NSString*)msg{
    _cityLab.text = msg;
    [_cityLab sizeToFit];
    _leftView.frame = CGRectMake(15, 5, _cityLab.width+10, _cityLab.height+5);
    arrowImg.frame = CGRectMake(_cityLab.right, _cityLab.bottom-15, 10, 10);
    _search.searchTextField.frame = CGRectMake(_leftView.right+4, 5, UISCREENWIDTH-_leftView.right-45,30);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication].keyWindow addSubview:self.scroTopBtn];
    _cityLab.hidden = NO;
    _leftView.hidden = NO;

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.scroTopBtn removeFromSuperview];
    _cityLab.hidden = YES;
    _leftView.hidden = YES;

}
- (void)scroTopClick{
    [UIView animateWithDuration:0.3 animations:^{
        //
        _sportTableView.contentOffset = CGPointMake(0, 0);
    }];
    
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)MJRrefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.sportTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.ListDataArray removeAllObjects];
        [weakSelf.sportTableView reloadData];
        [weakSelf loadDefaultData:0];
        
    }];
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _sportTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (request != nil) {
            
        }
        else{
        [weakSelf loadDefaultData:1];
        }
    }];
    [_sportTableView.mj_header beginRefreshing];
}

#pragma mark --自动滑动上面
- (void)moveToTop{
    if(_sportTableView.contentOffset.y!=0){
        [UIView animateWithDuration:0.3 animations:^{
            _sportTableView.contentOffset = CGPointMake(0, 0);
        }];
    }
}
#pragma  mark --［运动类型筛选］
- (void)itemClick:(UIButton *)button{
    if (isScrolling == YES) {
        return;
    }
    
    for (NSInteger i = 0; i<self.itemResource.count; i++)
    {
        LVButton * button = (LVButton *)[self.view viewWithTag:Sport_Select_Item_Tag+i];
        button.selected = NO;
        [button selectedOrNo:button.selected WithNum:1];
    }
    button.selected = YES;
    [(LVButton*)button selectedOrNo:button.selected WithNum:1];
    self.siftSportType = self.itemResource[button.tag - Sport_Select_Item_Tag][@"sport1"];
    [self.ListDataArray removeAllObjects];
    if (button.tag == Sport_Select_Item_Tag) {
        //全部类型
        self.siftSportType = nil;
    }
    matchName = @"";
    [self loadDefaultData:0];
}

#pragma  mark -- ［综合筛选］
- (void)siftClick:(UIButton *)button{
    if (isScrolling == YES) {
        return;
    }
    for (NSInteger i = 0; i<4; i++)
    {
        LVButton * button = (LVButton *)[bgView viewWithTag:1450+i];
        button.selected = NO;
        [button selectedOrNo:button.selected WithNum:2];
    }
    button.selected = YES;
    [(LVButton*)button selectedOrNo:button.selected WithNum:2];
    if (button.tag-1450 >0) {
        self.siftSportStatus = [NSString stringWithFormat:@"%ld",(long)button.tag - 1450];
    }else{
        self.siftSportStatus = nil;
    }
    [self.ListDataArray removeAllObjects];
    [self loadDefaultData:0];
}
- (void)loadBannerData{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [DataService requestWeixinAPI:selectBanner parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([result[@"status"] boolValue]) {
            if (banners == nil) {
                banners = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            for (NSDictionary * dic in result[@"data"][@"banners"]) {
                GetMatchListModel * model = [[GetMatchListModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [banners addObject:model];
            }

            [self setBanner];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];

}
/**
 参数不是页数,而是标记上下拉刷新
 */
- (void)loadDefaultData:(NSInteger)number{

    NSMutableDictionary * dic = [LVTools getTokenApp];
    if (_siftSportType) {
        [dic setValue:[NSNumber numberWithInt: [_siftSportType intValue]] forKey:@"type"];
    }
    if (_siftSportStatus) {
        [dic setValue:[NSNumber numberWithInt: [_siftSportStatus intValue]] forKey:@"status"];
    }
    if (cityCode) {
        [dic setValue:cityCode forKey:@"cityId"];
    }
    if (schoolId) {
        [dic setValue:schoolId forKey:@"schoolId"];
    }
        page ++;
        [dic setValue:[NSNumber numberWithInt:5] forKey:@"rows"];
    if (request) {
        [request clearDelegatesAndCancel];
    }
    if (number == 0)
    {
        //下拉刷新
        page = 1;
        [dic setValue:[NSNumber numberWithInt:(int)page] forKey:@"page"];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
       [DataService requestWeixinAPI:getMatchList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
           NSLog(@"datas  ＝＝＝%@",result);
           self.view.userInteractionEnabled = YES;
           [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
            [_sportTableView.mj_header endRefreshing];
            NSDictionary * resultDic = (NSDictionary *)result;
           if (!resultDic[@"error"]) {
            if ([resultDic[@"status"] boolValue])
            {
                [self.ListDataArray removeAllObjects];
                if ([resultDic[@"data"] count]==0) {
                    [self showHint:EmptyList];
                }
                else{
                for (NSDictionary * dic in resultDic[@"data"]) {
                    GetMatchListModel * model = [[GetMatchListModel alloc] init];
                    [model setValuesForKeysWithDictionary:dic];
                    [self.ListDataArray addObject:model];
                }
                }
                [self moveToTop];
                [_sportTableView reloadData];
                if ([resultDic[@"moreData"] boolValue]) {
                    
                }
                else{
                    _sportTableView.mj_footer = nil;
                }
                //所选赛事状态
//                if (self.ListDataArray.count==0) {
//                    _sportTableView.hidden = YES;
//                }
//                else{
//                    _sportTableView.hidden = NO;
//                }
            }
            else{
                [self showHint:resultDic[@"info"]];
            }
           }
           else{
               [self showHint:ErrorWord];
           }
        }];
    }else if (number == 1){
        //上拉刷新
       [dic setValue:[NSNumber numberWithInt:(int)page] forKey:@"page"];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
      request =  [DataService requestWeixinAPI:getMatchList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
          request = nil;
            [_sportTableView.mj_footer endRefreshing];
          NSLog(@"datas  ＝＝＝%@",result);
          self.view.userInteractionEnabled = YES;
          [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
            NSDictionary * resultDic = (NSDictionary *)result;
            if (!resultDic[@"error"])
            {
                
                if ([resultDic[@"status"] boolValue]) {
                    if ([resultDic[@"data"] count]!=0) {
                    for (NSDictionary * dic in resultDic[@"data"]) {
                        GetMatchListModel * model = [[GetMatchListModel alloc] init];
                        [model setValuesForKeysWithDictionary:dic];
                        [self.ListDataArray addObject:model];
                    }
                        [_sportTableView reloadData];
                    }
                    else{
                        [self showHint:EmptyList];
                        
                    }
                    if ([resultDic[@"moreData"] boolValue]) {
                        
                    }
                    else{
                        _sportTableView.mj_footer = nil;
                    }

                }
                else{
                    [self showHint:resultDic[@"info"]];
                }
                
            }
            else{
                [self showHint:ErrorWord];
            }
        }];
    }
}
#pragma mark [获取报名中用到的list]
- (void)loadListWith:(BaomingType)type{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:@"208" forKey:@"id"];
    [dic setValue:[LVTools mToString:[kUserDefault objectForKey:kUserId]] forKey:@"uid"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:toSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"]) {
            //获取成功跳转报名页面
            NSMutableArray *sexArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in resultDic[@"genderList"]) {
                ZHItem *sModel = [[ZHItem alloc] init];
                [sModel setValuesForKeysWithDictionary:dict];
                [sexArray addObject:sModel];
            }
            NSMutableArray *cardArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in resultDic[@"cardTypeList"]) {
                ZHItem *sModel = [[ZHItem alloc] init];
                [sModel setValuesForKeysWithDictionary:dict];
                [cardArray addObject:sModel];
            }
            
            NSMutableArray *saizhiArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in resultDic[@"matchGroupList"]) {
                ZHItem *sModel = [[ZHItem alloc] init];
                [sModel setValuesForKeysWithDictionary:dict];
                [saizhiArray addObject:sModel];
            }
            GetMatchListModel *model = [[GetMatchListModel alloc] init];
            [model setValuesForKeysWithDictionary:resultDic[@"match"]];
            ZHAppointBaomingController *baomingVC = [[ZHAppointBaomingController alloc] init];
            baomingVC.baoMingtype = type;
            if (type == BaomingInfo) {
                baomingVC.title = @"下载报名表";
            }
            else if(type == BaomingPersonal){
                baomingVC.title = @"个人报名";
            }
            else{
                baomingVC.title = @"团队报名";
            }
            baomingVC.chuanBlock = ^(NSArray *arr){
                // _baomingBtn.enabled = NO;
            };
            baomingVC.matchModel =model;
            baomingVC.sexList = sexArray;
            baomingVC.cardList = cardArray;
            baomingVC.msaizhiList = saizhiArray;
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:baomingVC animated:YES];
        }
        else{
            [self showHint:@"请重试"];
        }
    }];
}

#pragma mark --createTableView
- (void)createTableView{
    _sportTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame), CGRectGetWidth(BOUNDS),CGRectGetHeight(BOUNDS)-CGRectGetMaxY(bgView.frame)-64) style:UITableViewStylePlain];
    _sportTableView.delegate = self;
    _sportTableView.dataSource = self;
    _sportTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //空列表
    //[self.view addSubview:[[EmpatyView alloc]initWithImg:@"emptySport" AndText:@"暂无相关赛事信息"]];
    

    [self.view addSubview:_sportTableView];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor whiteColor];
    _sportTableView.tableFooterView = view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * sportIdenfier = @"sportIdenfier";
    LVSportItemTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:sportIdenfier];
    if (!cell) {
        cell = [[LVSportItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sportIdenfier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    GetMatchListModel * model = self.ListDataArray[indexPath.row];
    [cell configMatchModel:model];
    cell.baomingBtn.tag = indexPath.row + 500;
    [cell.baomingBtn addTarget:self action:@selector(quickbaomingOnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
//    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"sportIde"];
//   
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sportIde"];
//        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(347.0/750.0))];
//        if(indexPath.row%2==0){
//        img.image = [UIImage imageNamed:@"新—赛事校内版__02"];
//        }
//        else{
//            img.image = [UIImage imageNamed:@"新—赛事校内版_"];
//        }
//        [cell.contentView addSubview:img];
//    }
//    return cell;
}
- (void)quickbaomingOnClick:(UIButton *)sender{
    NSInteger index = sender.tag - 500;
    GetMatchListModel * model = self.ListDataArray[index];
    NSString *str = [LVTools mToString:model.signUpType];
    NSArray *arr = [str componentsSeparatedByString:@","];
    if ([arr[0] isEqualToString:@"BMFS_0001"]) {
        [self loadListWith:BaomingPersonal];
    } else if ([arr[0] isEqualToString:@"BMFS_0002"]) {
        [self loadListWith:BaomingTeamal];
    } else {
        [self loadListWith:BaomingInfo];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return BOUNDS.size.width*(347.0/750.0);
//    if (BOUNDS.size.width==320.f) {
//        return 216.0/375.0*BOUNDS.size.width+13.0;
//    }
//    else if (BOUNDS.size.width==375){
//    return 216.0/375.0*BOUNDS.size.width;
//    }
//    else{
//        return 216.0/375.0*BOUNDS.size.width-5;
//    }
    return 268.0/728.0*(BOUNDS.size.width-2*mygap)+50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ListDataArray.count;
}

-(void)searchBarShow
{
    if (!_search) {
        _search=[[ZHNavgationSearchBar alloc]init];
        _search.delegate = self;
        _search.searchTextField.frame = CGRectMake(_leftView.right+4, 5, UISCREENWIDTH-_leftView.right-50,30);
        _search.searchTextField.placeholder = @"请输入关键字进行搜索";
        [self.navigationController.navigationBar addSubview:_search];
        [self.view addSubview:_search.searchView];
        [self.navigationController.navigationBar addSubview:_search.clearBtn];
        [_search.searchTextField becomeFirstResponder];
        _search.searchTextField.delegate=self;
    }
}
- (void)showSeleted{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"全部",@"篮球",@"足球", nil];
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
       
    }
    else if(buttonIndex == 1){
//        篮球;
        _siftSportType = @"1";
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"select1_3"] forState:UIControlStateNormal];
        [self loadDefaultData:0];
    }
    else if(buttonIndex == 2){
//        足球
        _siftSportType = @"2";
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"select2_3"] forState:UIControlStateNormal];
        [self loadDefaultData:0];
    }
    else{
//       全部
        _siftSportType = nil;
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"select0_3"] forState:UIControlStateNormal];
        [self loadDefaultData:0];
    }
}
- (void)assignSelfToBeNil {
    _search.delegate = nil;
    _search = nil;
}
- (void)searchClickEvent
{
    //网络请求
    matchName = _search.searchTextField.text;
    [self loadDefaultData:0];
    [_search.searchTextField resignFirstResponder];
    _search.delegate = nil;
    [_search.searchView removeFromSuperview];
    [_search removeFromSuperview];
    [_search.clearBtn removeFromSuperview];
    _search = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //网络请求
    matchName = textField.text;
    [self loadDefaultData:0];
    [textField resignFirstResponder];
    _search.delegate = nil;
    [_search.searchView removeFromSuperview];
    [_search removeFromSuperview];
    [_search.clearBtn removeFromSuperview];
    _search = nil;
    return YES;
}

//ZXF adder
#pragma mark UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    WPCSportDetailVC *vc = [[WPCSportDetailVC alloc] init];
//    vc.MatchModel = [self.ListDataArray objectAtIndex:indexPath.row];
//    LVSportItemTableViewCell *cell =(LVSportItemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//    vc.sportImg = cell.sportImgView.image;
//    vc.hidesBottomBarWhenPushed = YES;
//    
//    [self.navigationController pushViewController:vc animated:YES];
    ZHSportDetailController *zhVC =[[ZHSportDetailController alloc] init];
    zhVC.hidesBottomBarWhenPushed = YES;
    zhVC.matchInfo = self.ListDataArray[indexPath.row];
    [self.navigationController pushViewController:zhVC animated:YES];
}
- (void)makeUI{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(321.0/750.0))];
    _selectSc = [[LVScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(BOUNDS), BOUNDS.size.width*(321.0/750.0))];
    _selectSc.delegate = self;
    [v addSubview:_selectSc];
    _sportTableView.tableHeaderView = v;
    //创建球类
//    for (int i = 0; i<self.itemResource.count; i++)
//    {
//        LVButton * itemBtn = [[LVButton alloc]
//                              initWithFrame:CGRectMake((NSInteger)CGRectGetWidth(BOUNDS)*(i/5)+LeftWidth+mygap+(NSInteger)(i%5)*ItemWidth, 0, ItemWidth*0.7, _selectSc.height)
//                              selectWithImage:self.itemResource[i][@"img1"]
//                              UnSelectWithImag:self.itemResource[i][@"img2"]
//                              WithTitle:self.itemResource[i][@"name"]
//                              WithTag:Sport_Select_Item_Tag+i];
//        if (i == 0) {
//            [itemBtn setlabelText:@"全部"];
//        }
//        [itemBtn setLabelFont:[UIFont systemFontOfSize:12.0]];
//        [itemBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_selectSc addSubview:itemBtn];
//    }
//    NSArray *imageStr = @[@"图层-13",@"banner2",@"banner3",@"benner4"];
//    _selectSc.contentSize = CGSizeMake(CGRectGetWidth(BOUNDS)*imageStr.count, 0);
//
//    for (NSInteger i=0; i<imageStr.count; i++) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*BOUNDS.size.width, 0, BOUNDS.size.width, BOUNDS.size.width*(321.0/750.0))];
//        imageView.image = [UIImage imageNamed:[imageStr objectAtIndex:i]];
//        [_selectSc addSubview:imageView];
//    }
    
    _pageView=[[SMPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_selectSc.frame)-10, UISCREENWIDTH, 10)];
//    _pageView.numberOfPages=imageStr.count;
    [_pageView setPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];
    [_pageView setCurrentPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
    [_pageView addTarget:self action:@selector(changePageOnClick:) forControlEvents:UIControlEventValueChanged];
    [v addSubview:_pageView];
    
    
//    _selectSc.backgroundColor = [UIColor redColor];
}
- (void)setBanner{
    _selectSc.contentSize = CGSizeMake(CGRectGetWidth(BOUNDS)*(banners.count+1), 0);
    
    for (NSInteger i=0; i<banners.count; i++) {
        GetMatchListModel *model =[banners objectAtIndex:i];
        UIButton *imageView = [[UIButton alloc] initWithFrame:CGRectMake(i*BOUNDS.size.width, 0, BOUNDS.size.width, BOUNDS.size.width*(321.0/750.0))];
        [imageView sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,model.matchShow]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"match_plo"]];
        [imageView addTarget:self action:@selector(imageOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectSc addSubview:imageView];
    }
    GetMatchListModel *model =[banners objectAtIndex:0];
    UIButton *imageView = [[UIButton alloc] initWithFrame:CGRectMake(banners.count*BOUNDS.size.width, 0, BOUNDS.size.width, BOUNDS.size.width*(321.0/750.0))];
    [imageView sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,model.matchShow]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"match_plo"]];
    [imageView addTarget:self action:@selector(imageOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_selectSc addSubview:imageView];
    _pageView.numberOfPages = banners.count;
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(bannerAnimated) userInfo:nil repeats:YES];
}
- (void)bannerAnimated{
    
    if (_selectSc.contentOffset.x>=BOUNDS.size.width*banners.count) {
        _selectSc.contentOffset = CGPointMake(0, 0);
        [UIView animateWithDuration:0.3f animations:^{
            CGPoint p = _selectSc.contentOffset;
            p.x+=BOUNDS.size.width;
            _selectSc.contentOffset = p;
        }];
    }
    else{
    [UIView animateWithDuration:0.3f animations:^{
        CGPoint p = _selectSc.contentOffset;
        p.x+=BOUNDS.size.width;
        _selectSc.contentOffset = p;
    }];
    }
}
- (void)imageOnClick:(UIButton*)btn{
    
    ZHSportDetailController *zhVC =[[ZHSportDetailController alloc] init];
    zhVC.hidesBottomBarWhenPushed = YES;
    zhVC.matchInfo = banners[(int)(btn.frame.origin.x/BOUNDS.size.width)];
    [self.navigationController pushViewController:zhVC animated:YES];
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSArray * array = @[@"全部赛事",@"即将开赛",@"正在比赛",@"比赛结束"];
    if (bgView == nil) {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(BOUNDS), 31.0+BOUNDS.size.width*(72.0/750.0))];
        bgView.backgroundColor = [UIColor whiteColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.width*(72.0/750.0), BOUNDS.size.width, 0.5)];
        line.backgroundColor = BackGray_dan;
        [bgView addSubview:line];
        for (int i = 0; i < 4; i++){
        LVButton * siftBtn = [[LVButton alloc] initWithFrame:CGRectMake(i*SiftWidth, 0.5+BOUNDS.size.width*(72.0/750.0), SiftWidth, 30.0) Sifttile:array[i] WithTag:1450+i];
        [siftBtn addTarget:self action:@selector(siftClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgView  addSubview:siftBtn];
        }
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame)-0.4, CGRectGetWidth(BOUNDS), 0.4)];
        label.backgroundColor = [UIColor lightGrayColor];
        [bgView addSubview:label];
    }
    if (search == nil) {
        search = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(72.0/750.0))];
        search.imageView.frame = search.bounds;
        [search setBackgroundImage:[UIImage imageNamed:@"btnSchool"] forState:UIControlStateNormal];
        [search setTitle:@"选择大学>" forState:UIControlStateNormal];
        [search setTitleColor:SystemBlue forState:UIControlStateNormal];
        search.titleLabel.font = Btn_font;
        [search addTarget:self action:@selector(selectschool) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:search];
    }
   
    for (int i = 0; i < 4; i++){
        LVButton * siftBtn = (LVButton *)[bgView viewWithTag:1450+i];
               if (_siftSportStatus) {
            if (i == [_siftSportStatus intValue]) {
                [siftBtn selectedOrNo:YES WithNum:2];
            }
        }
        else{
            if (i == 0) {
                [siftBtn selectedOrNo:YES WithNum:2];
            }
        }
            }

    return bgView;
}
- (void)selectschool{
    CitySchoolsController *city = [[CitySchoolsController alloc] init];
    city.title = @"选择大学";
    city.cityInfo = cityInfo;
    city.chuanBlock = ^(NSArray *arr){
        schoolInfo = [arr objectAtIndex:0];
        [search setTitle:schoolInfo[@"name"] forState:UIControlStateNormal];
        cityCode = nil;
        if ([schoolInfo[@"id"] boolValue]) {
            schoolId = schoolInfo[@"id"];
        }
        else{
            schoolId = nil;
        }
        
        [self loadDefaultData:0];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:city] animated:YES completion:nil];

//    CityListViewController *city = [[CityListViewController alloc] init];
//    city.isUniversityList = YES;
//    city.chuanBlock = ^(NSArray *arr){
//        //_textField6.text = arr[0];
//        [search setTitle:arr[0] forState:UIControlStateNormal];
//    };
//    city.title = @"选择大学";
//    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:city] animated:YES completion:nil];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 31.0f+BOUNDS.size.width*(72.0/750.0);
}
- (void)changePageOnClick:(SMPageControl*)pageControl{
//    NSLog(@"当前第%d页",(int)pageControl.currentPage);
    [UIView animateWithDuration:0.3 animations:^{
        _selectSc.contentOffset = CGPointMake(pageControl.currentPage*_selectSc.width, 0);
    }];
    
}
#pragma mark ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    isScrolling = NO;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        
    }
    else{
    isScrolling = NO;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _selectSc) {
        NSInteger number=  (NSInteger)(scrollView.contentOffset.x/UISCREENWIDTH)%banners.count;
        _pageView.currentPage=number;
       
    }
    if (scrollView.contentOffset.y==0) {
        isScrolling = NO;
    }
    else{
    isScrolling = YES;
    }
    if (scrollView == _sportTableView) {
        if (scrollView.contentOffset.y != 0) {
            self.scroTopBtn.hidden = NO;
        } else {
            self.scroTopBtn.hidden = YES;
        }
    }
    if (scrollView == _scrollView) {
        _pageControl.currentPage = _scrollView.contentOffset.x/UISCREENWIDTH;
        if (_scrollView.contentOffset.x>UISCREENWIDTH*4.01) {
            [self gotoRegisterPage];
        }

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)readPlist{
    self.itemResource = [LVTools getAllSportsList];
    selectPage = self.itemResource.count/5;
    if (self.itemResource.count%5!=0) {
        selectPage=selectPage+1;
    }
}
#pragma mark 引导页
// 加载引导页
- (void)loadLandingView{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height)];
    _scrollView.contentSize = CGSizeMake(BOUNDS.size.width * 5, BOUNDS.size.height);
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    //设置scrollview的内容大小
    
    //设置分页滑动
    _scrollView.pagingEnabled = YES;
    //设置是否显示水平滑动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    //设置是否显示垂直滑动条
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _scrollView.delegate = self;
    
    for (int i = 0; i < 5; i++)
    {
        NSString *imageName=nil;
        if (UISCREENHEIGHT == 480) {
            imageName= [NSString stringWithFormat:@"4-%d",i + 1];
        }
        else{
            imageName= [NSString stringWithFormat:@"6plus-%d",i + 1];
        }
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH * i, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        imageView.tag = 100+i;
        imageView.image = image;
        imageView.userInteractionEnabled = YES;
        if (i==0) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-60, 30, 40, 40)];
            [btn setTitle:@"跳过" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor clearColor]];
            btn.alpha = 0.6;
            btn.layer.cornerRadius = 20;
            btn.titleLabel.font = Content_lbfont;
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.layer.borderWidth = 0.5;
            [btn addTarget:self action:@selector(gotoRegisterPage) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:btn];
        }
        [_scrollView addSubview:imageView];
    }
    [[[UIApplication sharedApplication].delegate window] addSubview:_scrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, UISCREENHEIGHT-50, UISCREENWIDTH, 50)];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.796f green:0.114f blue:0.145f alpha:1.00f];
    CGPoint p = self.view.center;
    p.y = _pageControl.center.y;
    _pageControl.center=p;
    //设置pagecontrol有多少个点
    _pageControl.numberOfPages = 5;
    //设置pagecontrol点的位置
    _pageControl.currentPage = 0;
    //绑定方法  单击点的时候 图片会向左或向右移动
    [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    //[self.view addSubview:_pageControl];
    
    
}
- (void)pageChanged:(id)sender
{
    //设置偏移量，带动画
    [_scrollView setContentOffset:CGPointMake(_pageControl.currentPage * UISCREENWIDTH, 0) animated:YES];
}
#pragma mark UISrollView代理方法
//- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
//{
//    _pageControl.currentPage = _scrollView.contentOffset.x/UISCREENWIDTH;
//    if (_scrollView.contentOffset.x>UISCREENWIDTH*4.01) {
//        [self gotoRegisterPage];
//    }
//}
#pragma mark - 开始按钮
- (void)gotoRegisterPage{
    [UIView animateWithDuration:1.0 animations:^{
        _scrollView.alpha = 0;
    }];
}
@end
