//
//  LVAppointViewController.m
//  yuezhan123
//
//  Created by apples on 15/3/20.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVAppointViewController.h"
#import "ZHAppointItemCell.h"
#import "GetAppliesModel.h"
#import "MJRefresh.h"
#import "ZHAppointBuildController.h"
#import "LoginLoginZhViewController.h"
#import "WPCFriednMsgVC.h"
//ZXF added
#import "ZHAppointDetailController.h"
#import "RCDraggableButton.h"
#import "ZHNavgationSearchBar.h"
#import "WPCAreaView.h"
#import "CityListViewController.h"
#import "WPCMyOwnVC.h"
//下拉列表
#import "AreaModel.h"
#import "WPCTopView.h"
#import "WPCAreaSelectCell.h"
#import "ZHReverseCode.h"
#import "BMapKit.h"
#import "EmpatyView.h"
#import "LVScrollView.h"
#define MKKEY @"qGrc6jMYNRi7I6PluB82kT2m"
static NSString *collectionIdentier = @"cell10";

@interface LVAppointViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,WpcAreaDelegate,ZHRefreshDelegate,WPCTopViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,BMKLocationServiceDelegate,SearchClickDelegate,CityDelegate>
{
    UIView * bgView;
    LVScrollView * _selectSc;
    BOOL isMe;//是否点击离我最近按钮
    ZHNavgationSearchBar *_search;
    WPCTopView *topView;
    UIImageView *arrowImg;//上下箭头
    BOOL flag;
    UIView *backGround;
    UIImageView *firstImg;
}

@property (nonatomic,strong)UICollectionView *sportCollection;//点击运动类型时弹出的collectionview
@property (nonatomic,copy)NSString *selectedSport;//选择的运动类型字符串

@property (nonatomic,strong)NSMutableArray * itemResource;   //plist文件信息//运动类型
@property (nonatomic,strong)NSString * siftSportType; //筛选运动类型

@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) NSMutableArray * appliesArray;  //数据
@property (nonatomic,strong) NSString *provinceId;//省
@property (nonatomic,strong) NSString *cityId;//市
@property (nonatomic,strong) NSString *areaId;//区
@property (nonatomic,strong) UIImageView *guideImg;//用户引导
@property (nonatomic,strong) RCDraggableButton * postMatch;

@property (nonatomic, strong) WPCAreaView *wpcAreaView;
@property (nonatomic, strong) UILabel *cityLab;
@property (nonatomic, strong) UIView *leftView;
@property (strong, nonatomic) BMKLocationService* locatonService;
@property (strong, nonatomic) BMKMapManager * locationManager;
@property (strong, nonatomic) NSDictionary *areadic;
@end

static NSInteger page = 0;
@implementation LVAppointViewController


//首页缓存，存进沙盒里面

- (void)disappearFirstImg:(UIGestureRecognizer *)gesture {
    [firstImg removeFromSuperview];
    firstImg = nil;
    [backGround removeFromSuperview];
    backGround = nil;
    [kUserDefault setBool:YES forKey:@"notFirstTime"];
}

- (void)disappearFirstImg {
    [firstImg removeFromSuperview];
    firstImg = nil;
    [backGround removeFromSuperview];
    backGround = nil;
    [kUserDefault setBool:YES forKey:@"notFirstTime"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appliesArray = [NSMutableArray arrayWithCapacity:0];
    self.siftSportType = @"";
    isMe = NO;
    [kUserDefault setValue:[NSString stringWithFormat:@"%d",0] forKey:kSelectIndex];
    [self creatLeftView:@"全国"];
    [self navgationbarRrightImg:@"searchbar" WithAction:@selector(searchBarShow) WithTarget:self];
    [self readPlist];
    [self makeUI];
    [self MJRefresh];
    //获取城市信息
    self.cityId = @"";
    self.areaId = @"";
    //获取地区信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedirection) name:ARROW_CHANGE_DIRECTION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:NotificationRefreshAppoint object:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)resetData:(NSNotification*)noti{
    [self loadDefaultData:0];
}
#pragma mark -- ARROW_CHANGE_DIRECTION_NOTIFICATION
- (void)changedirection
{
    arrowImg.transform=CGAffineTransformMakeRotation(M_PI*2);
    flag=YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _mTableView) {
        if (scrollView.contentOffset.y != 0) {
            self.scroTopBtn.hidden = NO;
        } else {
            self.scroTopBtn.hidden = YES;
        }
    }
}

-(void)searchBarShow
{
    if (_sportCollection) {
        [self disappearTheSportCollection];
    }
    
    if (_wpcAreaView.open == YES) {
        [_wpcAreaView disappearImmediately];
    }
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
- (void)assignSelfToBeNil {
    _search.delegate = nil;
    _search = nil;
}
- (void)searchClickEvent
{
    //网络请求
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
    [self loadDefaultData:0];
    [textField resignFirstResponder];
    _search.delegate = nil;
    [_search.searchView removeFromSuperview];
    [_search removeFromSuperview];
    [_search.clearBtn removeFromSuperview];
    _search = nil;
    return YES;
}

#pragma mark --自动滑动上面
- (void)moveToTop{
    if(_mTableView.contentOffset.y!=0){
        [UIView animateWithDuration:0.3 animations:^{
            _mTableView.contentOffset = CGPointMake(0, 0);
        }];
    }
}

//发起约战按钮
- (void)viewWillAppear:(BOOL)animated{
    //发起约战
    [super viewWillAppear:animated];
    _cityLab.hidden = NO;
    _leftView.hidden = NO;
    arrowImg.hidden = NO;
    self.tabBarController.tabBar.hidden=NO;
    [self postMatch];
    
    if (!_postMatch.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:_postMatch];
        [[UIApplication sharedApplication].keyWindow addSubview:self.scroTopBtn];
    }
    if ([kUserDefault boolForKey:@"notFirstTime"] == NO) {
        backGround = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backGround.backgroundColor = [UIColor blackColor];
        backGround.alpha = 0.7;
        backGround.userInteractionEnabled = YES;
        [[[UIApplication sharedApplication] keyWindow] addSubview:backGround];
        
        CGFloat rate = 412.0/550.0;
        firstImg = [[UIImageView alloc] initWithFrame:CGRectMake(11.5, UISCREENHEIGHT-(68-32.0*UISCREENWIDTH/550.0)-72.0*550.0/132.0*rate, 72.0*550.0/132.0, 72.0*550.0/132.0*rate)];
        firstImg.image = [UIImage imageNamed:@"guide"];
        firstImg.userInteractionEnabled = YES;
        [[[UIApplication sharedApplication] keyWindow] addSubview:firstImg];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappearFirstImg:)];
        [backGround addGestureRecognizer:tap];
        [firstImg addGestureRecognizer:tap];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_wpcAreaView.open == YES) {
        [_wpcAreaView disappearImmediately];
    }
    _leftView.hidden = YES;
    _cityLab.hidden = YES;
    arrowImg.hidden = YES;
    [self.postMatch removeFromSuperview];
    [self.scroTopBtn removeFromSuperview];
}
- (void)scroTopClick{
    [UIView animateWithDuration:0.3 animations:^{
        _mTableView.contentOffset = CGPointMake(0, 0);
    }];
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
        _cityLab.textColor = [UIColor whiteColor];
        [_leftView addSubview:_cityLab];
    }
    _cityLab.text = str;
    [_cityLab sizeToFit];
    _leftView.frame = CGRectMake(15, 5, _cityLab.width+10, _cityLab.height+5);
    //arrow
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

//创建tableview
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44.0, BOUNDS.size.width, CGRectGetHeight(BOUNDS)-44.0- 64 - 49) style:UITableViewStylePlain];
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
    }
    return _mTableView;
}
#pragma  mark --刷新
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.mTableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf loadDefaultData:0];
    }];
    
    self.mTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadDefaultData:1];
    }];
    [self.mTableView.mj_header beginRefreshing];
}

#pragma mark --初始化请求数据
- (void)loadDefaultData:(NSInteger)number{
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    NSLog(@"-----------%@",dic);
    [dic setValue:[LVTools mToString:_siftSportType] forKey:@"sportsType"];
    [dic setValue:[LVTools mToString:_search.searchTextField.text] forKey:@"keyword"];
    [dic setValue:[LVTools mToString:self.cityId] forKey:@"city"];
    [dic setValue:[LVTools mToString:self.areaId] forKey:@"area"];
    [dic setValue:@"" forKey:@"province"];
    if (isMe) {
        NSString * lat =[LVTools mToString: [kUserDefault objectForKey:kLocationLat]];
        NSString * lng =[LVTools mToString: [kUserDefault objectForKey:kLocationlng]];
        [dic setValue:@"1" forKey:@"sort"];
        [dic setValue:lat forKey:@"latitude"];
        [dic setValue:lng forKey:@"longitude"];
    }else{
        [dic setValue:@"0" forKey:@"sort"];
    }
    page ++;
    if (number == 0) {//表头刷新
        page = 1;
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
        
        [DataService requestWeixinAPI:getApplies parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSDictionary * resultDic = (NSDictionary *)result;
            [self.mTableView.mj_footer endRefreshing];
//            NSLog(@"resultdic ====================== %@",resultDic);
            if ([resultDic[@"statusCode"] isEqualToString:@"success"])
            {
                [self.appliesArray removeAllObjects];//异步加载
                
                NSLog(@"count === %ld",(long)[resultDic[@"playApplyList"] count]);
                for (NSDictionary * dic in resultDic[@"playApplyList"])
                {
                    GetAppliesModel *model = [[GetAppliesModel alloc] init];
                    [model setValuesForKeysWithDictionary:dic];
                    [self.appliesArray addObject:model];
                }
                [self moveToTop];
                [self.mTableView reloadData];
                if (self.appliesArray.count==0) {
                    self.mTableView.hidden=YES;
                }
                else{
                    self.mTableView.hidden = NO;
                }
            }
            else{
                [self showHint:ErrorWord];
            }
        }];
    }
    else if (number == 1){//上拉刷新的请求
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
        [DataService requestWeixinAPI:getApplies parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSDictionary * resultDic = (NSDictionary *)result;
            [self.mTableView.mj_footer endRefreshing];
            if ([resultDic[@"statusCode"] isEqualToString:@"success"])
            {
                if ([resultDic[@"playApplyList"] count] == 0) {
                    [self showHint:EmptyList];
                }
                for (NSDictionary * dic in resultDic[@"playApplyList"])
                {
                    GetAppliesModel *model = [[GetAppliesModel alloc] init];
                    [model setValuesForKeysWithDictionary:dic];
                    [self.appliesArray addObject:model];
                }
                [self.mTableView reloadData];
                [self.mTableView.mj_footer endRefreshing];
            }
        }];
    }
}
#pragma mark UITableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.appliesArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *appointIde = @"appointide";
    ZHAppointItemCell *cell = [tableView dequeueReusableCellWithIdentifier:appointIde];
    if (cell==nil) {
        cell = [[ZHAppointItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:appointIde];
    }
    GetAppliesModel *model = [self.appliesArray objectAtIndex:indexPath.row];
    [cell configDefaultModel:model];
    cell.headImg.tag = 1200 + indexPath.row;
    [cell.headImg addTarget:self action:@selector(headImgClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 5.0+44.0+90.0+15;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZHAppointDetailController *zhappointDetailVC =[[ZHAppointDetailController alloc] init];
    zhappointDetailVC.model = [self.appliesArray objectAtIndex :indexPath.row];
    zhappointDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:zhappointDetailVC animated:YES];
}

- (void)headImgClick:(UIButton *)sender
{

   
        
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        GetAppliesModel *model = [self.appliesArray objectAtIndex:sender.tag-1200];
        //先判断这个uid和自己是不是同一个人，不是，才进入查看资料
        NSLog(@"------%ld",(long)[kUserDefault objectForKey:kUserId]);
        NSLog(@"-----********-%@",[LVTools mToString:model.uid]);
        if ([[kUserDefault objectForKey:kUserId] isEqual:[LVTools mToString:model.uid]]) {
            //进入自己的个人中心心
            WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
            vc.basicVC = NO;
            [self.navigationController pushViewController:vc animated:YES];

        } else {
            WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
            vc.uid = model.uid;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }

    } else {
        [self jumpToLoginVC];
    }
    
}

- (void)jumpToLoginVC{
    LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
}

- (void)makeUI{
    //空列表
    [self.view addSubview:[[EmpatyView alloc]initWithImg:@"emptyAppoint" AndText:@"暂无相关约战信息,赶快去约战吧"]];
    // 添加下拉菜单
    topView = [[WPCTopView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 44) andArray:@[@"综合排序",@"离我最近",@"运动类型"]];
    topView.delegate = self;
    [self.view addSubview:topView];
    
    //列表
    [self.view addSubview:self.mTableView];
}

- (void)menuClickWithIndex:(NSInteger)index
{
    //todo
    if (index == 2) {
        if (topView.flagForCollection == NO) {
            if (!_sportCollection) {
                CGFloat cellWidth = UISCREENWIDTH/3.6;
                UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
                flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
                flowLayout.minimumInteritemSpacing = 10;
                flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
                flowLayout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
                _sportCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, UISCREENWIDTH, UISCREENHEIGHT-44-64) collectionViewLayout:flowLayout];
                _sportCollection.dataSource = self;
                _sportCollection.delegate = self;
                _sportCollection.backgroundColor = BackGray_dan;
                [_sportCollection registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:collectionIdentier];
                [self.view addSubview:_sportCollection];
                topView.flagForCollection = YES;
                //在collection出现时，把自身的tabbar隐藏了
                self.tabBarController.tabBar.hidden = YES;
            }
        } else {
            [_sportCollection removeFromSuperview];
            _sportCollection = nil;
            topView.flagForCollection = NO;
            self.tabBarController.tabBar.hidden = NO;
        }
    } else {
        if (_sportCollection) {
            [_sportCollection removeFromSuperview];
            _sportCollection = nil;
            topView.flagForCollection = NO;
            self.tabBarController.tabBar.hidden = NO;
        }
        if (index == 0) {
            isMe = NO;
            _siftSportType = @"";
            UILabel *lab = (UILabel *)[topView viewWithTag:5557];
            lab.text = @"运动类型";
            //同时要记住用户选择这个
            [kUserDefault setValue:[NSString stringWithFormat:@"%d",0] forKey:kSelectIndex];
            [self loadDefaultData:0];
        } else {
            isMe = YES;
            [self loadDefaultData:0];
        }
    }
}

#pragma mark -- 运动类型选择的视图消失方法
- (void)disappearTheSportCollection
{
    [_sportCollection removeFromSuperview];
    _sportCollection = nil;
    topView.flagForCollection = NO;
    self.tabBarController.tabBar.hidden = NO;
    //发送运动类型箭头向上的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SPORT_TYPE_CHANGE_NOTIFICATION object:nil];
}

#pragma mark -- uicollection delegate    datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemResource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPCAreaSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentier forIndexPath:indexPath];
    NSDictionary *dict = [self.itemResource objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [RGBACOLOR(215, 215, 215, 1) CGColor];
    cell.titleLab.textColor = RGBACOLOR(135, 136, 136, 1);
    cell.titleLab.text = dict[@"name"];
    if (indexPath.row == [[kUserDefault valueForKey:kSelectIndex] integerValue]) {
        cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //todo,改变第3个sor标签的内容
    WPCAreaSelectCell *cell = (WPCAreaSelectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UILabel *lab = (UILabel *)[topView viewWithTag:5557];
    
    lab.text = cell.titleLab.text;
    if (indexPath.row == 0) {
        lab.text = @"运动类型";
    }
    //同时要记住用户选择这个
    [kUserDefault setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:kSelectIndex];
    
    _siftSportType = [self.itemResource objectAtIndex:indexPath.row][@"sport2"];
    
    [self loadDefaultData:0];
    
    //用户点击某种运动类型后，将这个collection移除
    if (_sportCollection) {
        [self disappearTheSportCollection];
    }
}

- (void)locationOnClick:(id)sender{
        //图片旋转
//    if (flag) {
//        arrowImg.transform=CGAffineTransformMakeRotation(M_PI);
//        flag=NO;
//    }
//    else{
//        arrowImg.transform=CGAffineTransformMakeRotation(M_PI*2);
//        flag=YES;
//    }
    
    //如果运动类型的collection还显示在界面的话，要做移除处理
    if (_sportCollection) {
        [self disappearTheSportCollection];
    }
    CityListViewController *cityVC = [[CityListViewController alloc] init];
    cityVC.title = @"当前城市";
    cityVC.hasAllCountry = YES;
    cityVC.citydelegate = self;
    UINavigationController *navi  =[[UINavigationController alloc] initWithRootViewController:cityVC];
    [self presentViewController:navi animated:YES completion:^{
        //
    }];
    
//    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:LISTFILEPATH];
//    self.areadic = dic[@"B"][0];
//    NSMutableArray *arr = [NSMutableArray array];
//    NSString *str1 = @"全城";
//    [arr addObject:str1];
//    for (int i = 0; i < [[self.areadic objectForKey:@"area"] count]; i ++) {
//        NSString *str = [NSString stringWithFormat:@"%@",[self.areadic objectForKey:@"area"][i][@"regionName"]];
//        [arr addObject:str];
//    }
//    
//    if (!_wpcAreaView) {
//        _wpcAreaView = [[WPCAreaView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64-49) dataSource:arr city:@"北京市" viewController:self];
//        _wpcAreaView.areaType = TypeAppoint;
//    }
//    if (_wpcAreaView.open == NO) {
//        
//        [_wpcAreaView appearTheCustomView];
//    } else {
//        [_wpcAreaView desappearTheCustomView];
//    }
}

/*
#pragma mark -- WpcAreaDelegate
- (void)collectionCellClickAtIndex:(NSInteger)index
{
    if (index != 0) {
        self.areaId = [self.areadic[@"area"] objectAtIndex:index-1][@"regionId"];
        [self loadDefaultData:0];
    } else {
        self.areaId = @"";
        [self loadDefaultData:0];
    }
}

- (void)changeBtnClick
{
    NSLog(@"hahahahah");
    CityListViewController *cityVC = [[CityListViewController alloc] init];
    cityVC.title = @"当前城市";
    cityVC.citydelegate = self;
    UINavigationController *navi  =[[UINavigationController alloc] initWithRootViewController:cityVC];
    [self presentViewController:navi animated:YES completion:^{
        //
    }];
}
 */
- (UIImageView*)guideImg{
    if (_guideImg == nil) {
        _guideImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 200, 275.0, 206)];
        _guideImg.image = [UIImage imageNamed:@"buildGuide@2x"];
    }
    return _guideImg;
}
- (RCDraggableButton *)postMatch{
    if (!_postMatch) {
        _postMatch = [[RCDraggableButton alloc] initInKeyWindowWithFrame:CGRectMake(10, CGRectGetHeight(BOUNDS)-140, 72, 72) WithMatch:NO];
        __weak typeof(self) weakSelf =self;
        _postMatch.layer.borderWidth = 0;
        __weak WPCAreaView *temp = _wpcAreaView;
        [_postMatch setTapBlock:^(RCDraggableButton *_postMatch) {
            //判断是否登录
            if ([kUserDefault boolForKey:@"notFirstTime"] == NO) {
                [weakSelf performSelector:@selector(disappearFirstImg) withObject:weakSelf];
            } else {
                if (temp.open == YES) {
                    [temp disappearImmediately];
                }
                if([[LVTools mToString:[kUserDefault objectForKey:kUserId]] isEqualToString:@""]){
                    [weakSelf showHint:@"登录后才能发起约战"];
                    return ;
                }
                if ([[weakSelf.navigationController.viewControllers lastObject] isKindOfClass:[ZHAppointBuildController class]]) {
                    
                }
                else{
                    ZHAppointBuildController *buildVC = [[ZHAppointBuildController alloc] init];
                    buildVC.title = @"发起约战";
                    buildVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf.postMatch removeFromSuperview];
                    [weakSelf.navigationController pushViewController:buildVC animated:YES];
                }
            }
        }];
        [_postMatch setLongPressBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow ===  LongPress!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setDoubleTapBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow ===  DoubleTap!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setDraggingBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === Dragging!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setDragDoneBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === DragDone!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setAutoDockingBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === AutoDocking!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setAutoDockingDoneBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === AutoDockingDone!!! ===");
            //More todo here.
            
        }];
        
    }
    return _postMatch;
}

- (void)readPlist{
    //运动
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    self.itemResource =[[NSMutableArray alloc] initWithCapacity:0];
    [self.itemResource addObjectsFromArray:[NSArray arrayWithContentsOfFile:path]];
}

#pragma mark ZHRefreshDelegate
- (void)sendMsg:(NSString *)msg{
//    _wpcAreaView.currentCityLab.text = [NSString stringWithFormat:@"当前城市：%@",msg];
    [self creatLeftView:msg];
}
//#pragma mark -- cityDelegate
- (void)sendCityAreas:(NSDictionary *)dic {
    self.areadic = [NSDictionary dictionaryWithDictionary:dic];
    self.cityId = self.areadic[@"regionId"];
    [self loadDefaultData:0];
//    NSMutableArray *arr = [NSMutableArray array];
//    NSString *str1 = @"全城";
//    [arr addObject:str1];
//    for (int i = 0; i < [[self.areadic objectForKey:@"area"] count]; i ++) {
//        NSString *str = [NSString stringWithFormat:@"%@",[self.areadic objectForKey:@"area"][i][@"regionName"]];
//        [arr addObject:str];
//    }
//    [_wpcAreaView changeDatasource:arr];
}

- (void)wholeContryClick {
    self.cityId = @"";
    [self creatLeftView:@"全国"];
    [self loadDefaultData:0];
}

- (void)collectionClickAtCode:(NSString *)code andName:(NSString *)name andInfo:(NSDictionary *)dic{
    self.cityId = code;
    [self creatLeftView:name];
    [self loadDefaultData:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
