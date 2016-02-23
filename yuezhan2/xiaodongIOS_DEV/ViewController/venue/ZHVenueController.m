//
//  ZHVenueController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/24.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHVenueController.h"
#import "ZHVenueCell.h"
#import "ZHVenueDetailController.h"
#import "ZHVenueTaocanController.h"
#import "ZHVenueModel.h"
#import "ZHNavgationSearchBar.h"
#import "WPCTopView.h"
#import "WPCAreaSelectCell.h"
#import "WPCAreaView.h"
#import "CityListViewController.h"


#define selectedColor [UIColor colorWithRed:0.867f green:0.871f blue:0.875f alpha:1.00f]
#define rowCount @"8"
#define ItemWidth ((CGRectGetWidth(BOUNDS)-20)/4)
#define SiftWidth (CGRectGetWidth(BOUNDS)/4)


static NSString *collectionIdentier = @"cell10";
static NSInteger defaultIndex;

@interface ZHVenueController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,WPCTopViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WpcAreaDelegate,SearchClickDelegate,CityDelegate,ZHRefreshDelegate>
{
    UIView * bgView;
    UITableView * _sportTableView;
    NSArray *areasInfo;
    
    //上传参数
    NSString *sortType;//排序方式，0=离我最近，1=综合排序
    NSString *sportType;//运动类型
    NSString *keyWord;//搜索用的关键字
    NSInteger pageNumber;//上拉刷新时传的page参数
    NSString *latitude;
    NSString *longitude;
    NSString *cityId;
    NSString *areaId;
    NSString *lowestPrice;//最低价格
    NSString *highestPrice;//最高价格
    NSString *status;//拓展参数，先暂时传空
    
    NSInteger selectPriceRow;
    BOOL isScrolling;
    WPCTopView *topView;
    UIView *screenView;//筛选视图
    BOOL isOpen;//是否展开
    UIScrollView *screenScroview;//底部滚动
    WPCAreaView *areaView;
}
@property (nonatomic,strong) NSArray *itemResource;//运动类型
@property (nonatomic,strong) NSMutableArray *ListDataArray;
@property (nonatomic,strong) ZHNavgationSearchBar *search;
@property (nonatomic,strong) UILabel *priceLb;//价格区间
@property (nonatomic,strong) UICollectionView *sportCollection;
@property (nonatomic,strong) UICollectionView *areaCollection;
@property (nonatomic,strong) UILabel *cityLb;
@property (nonatomic,strong) UIPickerView *pricePicker;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@end

@implementation ZHVenueController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"场馆";
    selectPriceRow = 0;
    defaultIndex = 0;
    
    //初始化参数信息
    sortType = @"0";//默认是综合排序
    sportType= @"";
    keyWord = @"";
    pageNumber = 1;
    cityId = @"";
    areaId = @"";
    lowestPrice = @"";
    highestPrice = @"";
    status = @"";
    [kUserDefault setValue:[NSString stringWithFormat:@"%d",0] forKey:kAreaIndex];
    
    isOpen=NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.ListDataArray = [NSMutableArray arrayWithCapacity:0];
    //默认北京，做缓存判断
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:LISTFILEPATH];
    areasInfo = dic[@"B"][0][@"area"];
    NSLog(@"%@",areasInfo);
    [self navgationBarLeftReturn];
    [self readPlist];
    [self makeUI];
    [self navgationbarRrightImg:@"searchbar" WithAction:@selector(searchBarShow) WithTarget:self];
    [self createTableView];
    [self setupRefresh];
    [self loadDefaultData];
}
#pragma mark getter
- (UILabel*)priceLb{
    if (_priceLb == nil) {
        UILabel *textLb = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, 100, 30)];
        textLb.text = @"价格区间(元)";
        textLb.textAlignment = NSTextAlignmentLeft;
        textLb.font = Btn_font;
        [screenScroview addSubview:textLb];
        _priceLb = [[UILabel alloc] initWithFrame:CGRectMake(textLb.right, textLb.top, BOUNDS.size.width-textLb.right-mygap*2, textLb.height)];
        _priceLb.backgroundColor = selectedColor;
        _priceLb.textAlignment = NSTextAlignmentCenter;
        _priceLb.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPrice:)];
        [_priceLb addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _priceLb.bottom+2*mygap, BOUNDS.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [screenScroview addSubview:line];
    }
    return _priceLb;
}
- (void)selectPrice:(id)sender{
    _pricePicker.hidden = !_pricePicker.hidden;
}
- (UIPickerView*)pricePicker{
    if (_pricePicker == nil) {
        _pricePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(_priceLb.left, _priceLb.bottom, _priceLb.width, 162.0)];
        _pricePicker.backgroundColor = selectedColor;
        _pricePicker.dataSource= self;
        _pricePicker.delegate = self;
        _pricePicker.hidden = YES;
    }
    return _pricePicker;
}
- (UICollectionViewFlowLayout*)layout{
    if (_layout == nil) {
          CGFloat cellWidth = UISCREENWIDTH/3.6;
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layout.minimumInteritemSpacing = 10;
        _layout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        _layout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
    }
    return _layout;
}
- (UILabel*)cityLb{
    if (_cityLb == nil) {
        UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(2*mygap, _sportCollection.bottom+2*mygap, 40, 20)];
        lab.text = @"城市:";
        lab.font= Btn_font;
        [screenScroview addSubview:lab];
        _cityLb = [[UILabel alloc] initWithFrame:CGRectMake(lab.right,lab.top, 120, 20)];
        _cityLb .backgroundColor = [UIColor clearColor];
        _cityLb.text = @"北京";
        _cityLb.textColor = NavgationColor;
        _cityLb.font = Btn_font;
    }
    return _cityLb;
}
- (UICollectionView*)sportCollection{
    if (_sportCollection == nil) {
        UILabel *textLb = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, _priceLb.bottom+mygap*2, 120, 30)];
        textLb.text = @"运动类型";
        textLb.textAlignment = NSTextAlignmentLeft;
        textLb.font = Btn_font;
        [screenScroview addSubview:textLb];

        _sportCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, textLb.bottom, UISCREENWIDTH, 150) collectionViewLayout:self.layout];
        _sportCollection.dataSource = self;
        _sportCollection.delegate = self;
        _sportCollection.backgroundColor = BackGray_dan;
        [_sportCollection registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:collectionIdentier];
    }
    return _sportCollection;
}
- (UICollectionView*)areaCollection{
    if (_areaCollection == nil) {
        _areaCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _cityLb.bottom, UISCREENWIDTH, 476-_cityLb.bottom) collectionViewLayout:self.layout];
        _areaCollection.dataSource = self;
        _areaCollection.delegate = self;
        _areaCollection.backgroundColor = BackGray_dan;
        [_areaCollection registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:collectionIdentier];
    }
    return _sportCollection;
}
#pragma mark UIPickerDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
        return 12;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 30)] ;
    
    myView.textAlignment = NSTextAlignmentCenter;
    
    
    if (row == 11) {
        myView.text = @"1000以上";
    }
    if (row == 0) {
        myView.text = @"不限";
    }
    if (row > 0 && row < 11) {
        myView.text = [NSString stringWithFormat:@"%d元 - %d元",(int)(row-1)*100,(int)(row)*100];
    }
    myView.font = [UIFont systemFontOfSize:14];         //用label来设置字体大小
    myView.userInteractionEnabled = YES;
    myView.backgroundColor = [UIColor clearColor];
    return myView;
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"点击");
    selectPriceRow = row;
    _priceLb.text = [NSString stringWithFormat:@"%d元 - %d元",(int)(row-1)*100,(int)(row)*100];
    _pricePicker.hidden = YES;
    if (row == 0) {
        lowestPrice = @"";
        highestPrice = @"";
        _priceLb.text = @"不限";
    }
    if (row == 11) {
        lowestPrice = @"1000";
        highestPrice = @"";
        _priceLb.text = @"1000元以上";
    }
    if (row > 0 && row < 11) {
        lowestPrice = [NSString stringWithFormat:@"%ld",(long)(selectPriceRow-1)*100];
        highestPrice = [NSString stringWithFormat:@"%ld",(long)(selectPriceRow)*100];
    }
    NSLog(@"low == %@",lowestPrice);
    NSLog(@" high == %@",highestPrice);
    NSLog(@"1");
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *anyOne = [touches anyObject];
    if ([anyOne.view isEqual:screenScroview]) {
        _pricePicker.hidden = YES;
    }
}
#pragma mark -- uicollection delegate    datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return self.itemResource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPCAreaSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentier forIndexPath:indexPath];
    if ([collectionView isEqual:_sportCollection]) {
        NSDictionary *dict = [self.itemResource objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [RGBACOLOR(215, 215, 215, 1) CGColor];
        cell.titleLab.textColor = RGBACOLOR(135, 136, 136, 1);
        cell.titleLab.text =[LVTools mToString: dict[@"name"]];
        if (indexPath.row == 0) {
            cell.titleLab.text = @"不限";
        }
        if (indexPath.row == defaultIndex) {
            cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        }
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
        lab.text = @"筛选";
    }
    //同时要记住用户选择这个
    defaultIndex = indexPath.row;
    [collectionView reloadData];
    sportType = [LVTools mToString:self.itemResource[indexPath.row][@"sport2"]];
}

#pragma mark 集成刷新
/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    _sportTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
//    [_sportTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    //warning 自动刷新(一进入程序就下拉刷新)
    //[self.tabelview headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
//    [_sportTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
    _sportTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    pageNumber =1;
    [self loadPageData];
}
- (void)footerRereshing
{
    pageNumber = pageNumber+1;
    [self loadPageData];
}

-(void)searchBarShow
{
    if (isOpen) {
        screenView.frame = CGRectMake(0,topView.bottom , BOUNDS.size.width, 0);
        screenScroview.frame = CGRectMake(0, 0, BOUNDS.size.width, 0);
        UIView *view =[screenView viewWithTag:999];
        view.hidden = YES;
        isOpen = !isOpen;
    }
    
    topView.flagForCollection = NO;
    //发送运动类型箭头向上的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SPORT_TYPE_CHANGE_NOTIFICATION object:nil];
    
    if (_search == nil) {
        _search=[[ZHNavgationSearchBar alloc]init];
        _search.searchTextField.delegate=self;
        _search.delegate = self;
        _search.searchTextField.placeholder = @"请输入场馆名称进行搜索";
        _search.searchTextField.returnKeyType = UIReturnKeySearch;
        [self.navigationController.navigationBar addSubview:_search];
        [self.view addSubview:_search.searchView];
        [self.navigationController.navigationBar addSubview:_search.clearBtn];
        [_search.searchTextField becomeFirstResponder];
    }
}

- (void)searchClickEvent
{
    //网络请求
    keyWord = _search.searchTextField.text;
    NSLog(@"%@",keyWord);
    [self loadDefaultData];
    [_search.searchTextField resignFirstResponder];
    _search.delegate = nil;
    [_search.searchView removeFromSuperview];
    [_search removeFromSuperview];
    [_search.clearBtn removeFromSuperview];
    _search = nil;
}

- (void)assignSelfToBeNil {
    _search.delegate = nil;
    _search = nil;
}

#pragma mark UItextFielddelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    pageNumber = 1;
    keyWord = textField.text;
    [self loadPageData];
    [textField resignFirstResponder];
    [_search.searchView removeFromSuperview];
    [_search removeFromSuperview];
    _search.delegate = nil;
    [_search.clearBtn removeFromSuperview];
    _search = nil;
    return YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)loadDefaultData{
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setObject:sportType forKey:@"sportsType"];
    [dic setObject:sortType forKey:@"sort"];
    [dic setObject:[LVTools mToString:[kUserDefault objectForKey:kLocationlng]] forKeyedSubscript:@"longitude"];
    [dic setObject:[LVTools mToString: [kUserDefault objectForKey:kLocationLat]] forKeyedSubscript:@"latitude"];
    [dic setObject:rowCount forKey:@"rows"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)pageNumber] forKey:@"page"];
    [dic setValue:lowestPrice forKey:@"min_price"];
    [dic setValue:highestPrice forKey:@"max_price"];
    [dic setValue:status forKey:@"status"];
    [dic setValue:cityId forKey:@"city"];
    [dic setValue:areaId forKey:@"area"];
    [dic setObject:keyWord forKey:@"venuesName"];
    
    
    NSLog(@"dic === %@",dic);
    
    [self showHudInView:self.view hint:@"请稍后..."];
     request = [DataService requestWeixinAPI:getVenues parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
           
        if ([resultDic[@"statusCode"] isEqualToString:@"success"]) {
            [self.ListDataArray removeAllObjects];
            for (NSDictionary * dic in resultDic[@"venuesList"]) {
                ZHVenueModel * model = [[ZHVenueModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [self.ListDataArray addObject:model];
            }
            [_sportTableView reloadData];
            [self hideHud];
        }
        else{
            [self hideHud];
            [self showHint:@"数据加载失败!"];
        }
    }];
}
- (void)loadPageData{
    longitude =[LVTools mToString: [kUserDefault objectForKey:kLocationlng]];
    latitude =[LVTools mToString: [kUserDefault objectForKey:kLocationLat]];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setObject:sportType forKey:@"sportsType"];
    [dic setObject:sortType forKey:@"sort"];
    [dic setObject:longitude forKey:@"longitude"];
    [dic setObject:latitude forKey:@"latitude"];
    [dic setObject:keyWord forKey:@"venuesName"];
    [dic setObject:rowCount forKey:@"rows"];
    [dic setValue:lowestPrice forKey:@"min_price"];
    [dic setValue:highestPrice forKey:@"max_price"];
    [dic setValue:status forKey:@"status"];
    [dic setValue:cityId forKey:@"city"];
    [dic setValue:areaId forKey:@"area"];
    
    [dic setObject:[NSString stringWithFormat:@"%ld",(unsigned long)pageNumber] forKey:@"page"];
    [self showHudInView:self.view hint:LoadingWord];
     request =  [DataService requestWeixinAPI:getVenues parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
            [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"]) {
            if (pageNumber==1) {
                [self.ListDataArray removeAllObjects];
            }
            NSArray *array = resultDic[@"venuesList"];
            if (resultDic[@"venuesList"] ==nil ||[array count]==0) {
                [self showHint:EmptyList];
                [_sportTableView.mj_footer endRefreshing];
                
            } else{
                for (NSDictionary * dic in resultDic[@"venuesList"]) {
                    ZHVenueModel * model = [[ZHVenueModel alloc] init];
                    [model setValuesForKeysWithDictionary:dic];
                    [self.ListDataArray addObject:model];
                }
            }
            [_sportTableView reloadData];
            if (pageNumber==1) {
                [_sportTableView.mj_header endRefreshing];
            }
            else{
                [_sportTableView.mj_footer endRefreshing];
            }
            
        } else {
            if (pageNumber==1) {
                [_sportTableView.mj_header endRefreshing];
            } else {
                [_sportTableView.mj_footer endRefreshing];
            }
            [self showHint:@"数据加载失败"];
        }
    }];
}

- (void)collectionCellClickAtIndex:(NSInteger)index {
    NSLog(@"hahah");
    if (index == 0) {
        areaId = @"";
    } else {
        areaId = areasInfo[index-1][@"regionId"];
    }
    NSLog(@"---------%@\n%@",areaId,areasInfo);
    
    [areaView.areaCollection reloadData];
}
#pragma mark --createTableView
- (void)createTableView{
    if (_sportTableView == nil) {
        _sportTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topView.bottom, CGRectGetWidth(BOUNDS),CGRectGetHeight(BOUNDS)-CGRectGetMaxY(bgView.frame)-64-44) style:UITableViewStylePlain];
        [self.view addSubview:_sportTableView];
    }
    _sportTableView.delegate = self;
    _sportTableView.dataSource = self;
    _sportTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(BOUNDS), 5)];
    view.backgroundColor = [UIColor whiteColor];
    _sportTableView.tableFooterView = view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * sportIdenfier = @"venueIdenfier";
    ZHVenueCell * cell = [tableView dequeueReusableCellWithIdentifier:sportIdenfier];
    if (!cell) {
        cell = [[ZHVenueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sportIdenfier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ZHVenueModel * model = self.ListDataArray[indexPath.row];
    [cell configVenueModel:model];
    cell.locationLb.text =[LVTools caculateDistanceFromLat:model.latitude andLng:model.longitude];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.ListDataArray count];
}
//ZXF adder
#pragma mark UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHVenueCell *cell =(ZHVenueCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    ZHVenueModel *model =[self.ListDataArray objectAtIndex:indexPath.row];
    ZHVenueDetailController *zhsportDetailVC = [[ZHVenueDetailController alloc] init];
    zhsportDetailVC.vennueModel = model;
    zhsportDetailVC.venueImg = cell.mImageView.image;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:zhsportDetailVC animated:YES];
    
}
- (void)okOnClick{
    //动画
    [UIView animateWithDuration:0.3 animations:^{
        if (isOpen) {
            screenView.frame = CGRectMake(0,topView.bottom , BOUNDS.size.width, 0);
            screenScroview.frame = CGRectMake(0, 0, BOUNDS.size.width, 0);
            UIView *view =[screenView viewWithTag:999];
            view.hidden = YES;
        }
        else{
            screenView.frame = CGRectMake(0,topView.bottom , BOUNDS.size.width, BOUNDS.size.height-64-44);
            screenScroview.frame =CGRectMake(0, 0, screenView.width, BOUNDS.size.height-64-44-80);
            
        }
        
    } completion:^(BOOL finished) {
        UIView *view =[screenView viewWithTag:999];
        if (!isOpen) {
            
        }
        else{
            view.hidden = NO;
        }
    }];
    isOpen = !isOpen;
    //筛选参数刷新处理
    [self loadDefaultData];
}
- (void)makeUI{
    // 添加下拉菜单
    topView = [[WPCTopView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 44) andArray:@[@"综合排序",@"离我最近",@"筛选"]];
    topView.delegate = self;
    [self.view addSubview:topView];
    screenView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.bottom, BOUNDS.size.width, 0)];
    screenView.backgroundColor = BackGray_dan;
    [self.view addSubview:screenView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(mygap*2, BOUNDS.size.height-64-44-50, BOUNDS.size.width-4*mygap, 44)];
    [btn setTitle:@"确 定" forState:UIControlStateNormal];
    [btn setBackgroundColor:NavgationColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 5;
    btn.hidden = YES;
    btn.tag = 999;
    [btn addTarget:self action:@selector(okOnClick) forControlEvents:UIControlEventTouchUpInside];
    [screenView addSubview:btn];
    screenScroview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenView.width, 0)];
    screenScroview.backgroundColor = BackGray_dan;
    screenScroview.contentSize =  CGSizeMake(screenView.width, 467);
    
    [screenView addSubview:screenScroview];
    //价格区间
    [screenScroview addSubview:self.priceLb];
    //运动类型
    [screenScroview addSubview:self.sportCollection];
    //这里必须在之后添加这个picker
    [screenScroview addSubview:self.pricePicker];
    //城市
    [screenScroview addSubview:self.cityLb];
    //区域
   //6plus
    if (BOUNDS.size.width == 414.0) {
        
         areaView = [[WPCAreaView alloc] initWithFrame:CGRectMake(0,self.cityLb.bottom, BOUNDS.size.width, 292.0) dataSource:@[] city:@"北京"];
        NSMutableArray *arr = [NSMutableArray array];
        NSString *str = @"全城";
        [arr addObject:str];
        for (int i = 0; i < [areasInfo count]; i ++) {
            NSString *string = [NSString stringWithFormat:@"%@",areasInfo[i][@"regionName"]];
            [arr addObject:string];
        }
        [areaView changeDatasource:arr];
        NSLog(@"%f",areaView.height);
    }
    else{
         areaView = [[WPCAreaView alloc] initWithFrame:CGRectMake(0,self.cityLb.bottom, BOUNDS.size.width, 200) dataSource:@[] city:@"北京"];
        NSMutableArray *arr = [NSMutableArray array];
        NSString *str = @"全城";
        [arr addObject:str];
        for (int i = 0; i < [areasInfo count]; i ++) {
            NSString *string = [NSString stringWithFormat:@"%@",areasInfo[i][@"regionName"]];
            [arr addObject:string];
        }
        [areaView changeDatasource:arr];
    }
    areaView.delegate = self;
    areaView.tag = 9527;
    areaView.areaType = TypeVenue;
    [screenScroview addSubview:areaView];
}

- (void)changeBtnClick {
    CityListViewController *cityVC = [[CityListViewController alloc] init];
    cityVC.title = @"当前城市";
    cityVC.delegate = self;
    cityVC.citydelegate = self;
    UINavigationController *navi  =[[UINavigationController alloc] initWithRootViewController:cityVC];
    [self presentViewController:navi animated:YES completion:^{
        //
    }];
}

- (void)sendMsg:(NSString *)msg {
    _cityLb.text = msg;
    WPCAreaView *areaView1 = (WPCAreaView *)[self.view viewWithTag:9527];
    areaView1.currentCityLab.text = [NSString stringWithFormat:@"当前城市：%@",msg];
}

- (void)sendCityAreas:(NSDictionary *)dic {
    NSLog(@"dic === %@",dic);

    
    cityId =[LVTools mToString: dic[@"regionId"]];
    areaId = @"";
    NSMutableArray *arr = [NSMutableArray array];
    NSString *str = @"全城";
    [arr addObject:str];
    for (int i = 0; i < [dic[@"area"] count]; i ++) {
        NSString *string = [NSString stringWithFormat:@"%@",dic[@"area"][i][@"regionName"]];
        [arr addObject:string];
    }
    WPCAreaView *areaView1 = (WPCAreaView *)[self.view viewWithTag:9527];
    [areaView1 changeDatasource:arr];
}

- (void)collectionClickAtCode:(NSString *)code andName:(NSString *)name andInfo:(NSDictionary *)dic{
    _cityLb.text = name;
    WPCAreaView *areaView1 = (WPCAreaView *)[self.view viewWithTag:9527];
    areaView1.currentCityLab.text = [NSString stringWithFormat:@"当前城市：%@",name];
    cityId = code;
    areaId = @"";
    areasInfo = [NSArray arrayWithArray:dic[@"area"]];
    NSMutableArray *arr = [NSMutableArray array];
    NSString *str = @"全城";
    [arr addObject:str];
    for (int i = 0; i < [dic[@"area"] count]; i ++) {
        NSString *string = [NSString stringWithFormat:@"%@",dic[@"area"][i][@"regionName"]];
        [arr addObject:string];
    }
    [areaView1 changeDatasource:arr];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y==0) {
        isScrolling = NO;
    }
    else{
        isScrolling = YES;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        
    }
    else{
        isScrolling = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    isScrolling = NO;
}
#pragma  mark --［运动类型筛选］
- (void)itemClick:(UIButton *)button{
    if (isScrolling) {
        return;
    }
    NSLog(@"%@",[NSString stringWithFormat:@"%@",self.itemResource[button.tag-Sport_Select_Item_Tag][@"sport2"]]);
    pageNumber =1;
    for (NSInteger i = 0; i<self.itemResource.count; i++) {
        LVButton * button = (LVButton *)[self.view viewWithTag:Sport_Select_Item_Tag+i];
        button.selected = NO;
        [button selectedOrNo:button.selected WithNum:1];
    }
    button.selected = YES;
    [(LVButton*)button selectedOrNo:button.selected WithNum:1];
    sportType = [NSString stringWithFormat:@"%@",self.itemResource[button.tag-Sport_Select_Item_Tag][@"sport2"]];
    [self moveToTop];
    [self loadPageData];
}
#pragma mark WPCTopViewDelegate
- (void)menuClickWithIndex:(NSInteger)index{
    if (index == 0) {
        if (isOpen) {
            [UIView animateWithDuration:0.3 animations:^{
                screenView.frame = CGRectMake(0,topView.bottom , BOUNDS.size.width, 0);
                screenScroview.frame = CGRectMake(0, 0, BOUNDS.size.width, 0);
                UIView *view =[screenView viewWithTag:999];
                view.hidden = YES;
            }];
            isOpen = !isOpen;
        }
        sortType = @"0";
        keyWord = @"";
        areaId = @"";
        highestPrice = @"";
        lowestPrice = @"";
        sportType = @"";
        UILabel *lab = (UILabel *)[topView viewWithTag:5557];
        lab.text = @"筛选";
        pageNumber = 1;
        [self loadDefaultData];
    }
    else if (index==1){
        if (isOpen) {
            [UIView animateWithDuration:0.3 animations:^{
                screenView.frame = CGRectMake(0,topView.bottom , BOUNDS.size.width, 0);
                screenScroview.frame = CGRectMake(0, 0, BOUNDS.size.width, 0);
                UIView *view =[screenView viewWithTag:999];
                view.hidden = YES;
            }];
            isOpen = !isOpen;
        }
        sortType = @"1";
        keyWord = @"";
        [self loadDefaultData];
    }
    else{
        //筛选 
        [self.view bringSubviewToFront:screenView];
        [UIView animateWithDuration:0.3 animations:^{
            if (isOpen) {
                screenView.frame = CGRectMake(0,topView.bottom , BOUNDS.size.width, 0);
                screenScroview.frame = CGRectMake(0, 0, BOUNDS.size.width, 0);
                UIView *view =[screenView viewWithTag:999];
                view.hidden = YES;
            }
            else{
                screenView.frame = CGRectMake(0,topView.bottom , BOUNDS.size.width, BOUNDS.size.height-64-44);
                screenScroview.frame =CGRectMake(0, 0, screenView.width, BOUNDS.size.height-64-44-80);
                
            }

        } completion:^(BOOL finished) {
            UIView *view =[screenView viewWithTag:999];
            if (!isOpen) {
                
            }
            else{
                view.hidden = NO;
            }
        }];
        
        isOpen = !isOpen;
    }
}
//#pragma  mark -- ［综合筛选］
//- (void)siftClick:(UIButton *)button{
//    if (isScrolling) {
//        return;
//    }
//    NSLog(@"赛事一级界面综合筛选 ：%ld",(long)button.tag);
//    pageNumber =1;
//    for (NSInteger i = 0; i<4; i++) {
//        LVButton * button = (LVButton *)[self.view viewWithTag:1450+i];
//        button.selected = NO;
//        [button selectedOrNo:button.selected WithNum:2];
//    }
//    button.selected = YES;
//    [(LVButton*)button selectedOrNo:button.selected WithNum:2];
//    if (button.tag == 1451) {
//        //离我最近
//        sortType = @"1";
//    }
//    else if(button.tag == 1450){
//        //综合排序
//        sortType = @"0";
//    }
//    else{
//        //默认排序
//        sortType = @"";
//    }
//    [self moveToTop];
//    [self loadPageData];
//}
- (void)moveToTop{
    if(_sportTableView.contentOffset.y!=0){
    [UIView animateWithDuration:0.3 animations:^{
        _sportTableView.contentOffset = CGPointMake(0, 0);
    }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)readPlist{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    self.itemResource = [NSArray arrayWithContentsOfFile:path];
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
