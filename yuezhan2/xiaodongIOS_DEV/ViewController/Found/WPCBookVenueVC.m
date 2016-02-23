//
//  WPCBookVenueVC.m
//  VenueTest
//
//  Created by admin on 15/6/24.
//  Copyright (c) 2015年 zhoujin. All rights reserved.
//

#import "WPCBookVenueVC.h"
#import "WPCComfirmVenueVC.h"

#define bweekTag 3100
#define venueBorderColor RGBACOLOR(189, 212, 219, 1)


NSString *const cellIdentifier1 = @"cell1";
NSString *const cellIdentifier2 = @"cell2";
@interface WPCBookVenueVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

//ui
@property (nonatomic, strong)UICollectionView *btimeCollection;
@property (nonatomic, strong)UICollectionView *venueCollection;
@property (nonatomic, strong)UITableView *stimeTableview;
@property (nonatomic, strong)UIView *sliderView;
@property (nonatomic, strong)UILabel *costLabel;
@property (nonatomic, strong)UILabel *comfirmOrderLabel;
@property (nonatomic, strong)UIScrollView *contentScroll;

//datasource
@property (nonatomic, strong)NSMutableArray *weekArray;
@property (nonatomic, strong)NSMutableArray *dateArray;
@property (nonatomic, strong)NSArray *venueArray;
@property (nonatomic, strong)NSMutableArray *timeArray;
@property (nonatomic, strong)NSDictionary *infosDictionary;
@property (nonatomic, strong)NSMutableArray *detailArrays;//every object in the venues seperated by time and field
@property (nonatomic, strong)NSMutableArray *selectObject;

//week num－>string
@property (nonatomic, strong)NSDictionary *numStringDic;

//Auxiliary parameters
@property (nonatomic, strong)NSDateComponents *comps;
@property (nonatomic, assign)NSInteger selectedWeekday;
@property (nonatomic, assign)CGFloat costNum;


@end
@implementation WPCBookVenueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    self.title = @"场馆预定";
    self.costNum = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initialInterface];
    [self initialDatasource];
    
}

- (void)loadDataInfomation {
    [self showHudInView:self.view hint:@""];
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.vennueModel.id forKey:@"vid"];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:dayInterval*_selectedWeekday];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSMutableString *str = [[NSMutableString alloc] initWithString:[format stringFromDate:date]];
    [str deleteCharactersInRange:NSMakeRange(4, 1)];
    [str deleteCharactersInRange:NSMakeRange(6, 1)];
    [dic setValue:str forKey:@"date"];
    [DataService requestWeixinAPI:getVenuesPrices parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [_detailArrays removeAllObjects];
            [_timeArray removeAllObjects];
            
            self.infosDictionary = result[@"data"];
            self.venueArray = [self.infosDictionary allKeys];
            if(self.venueArray.count==0){
                return ;
            }
            if (_selectedWeekday == 0) {
                NSDate *now = [NSDate date];
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"HH:mm"];
                NSString *nowString = [formater stringFromDate:now];
                for (int i = 0; i < [[self.infosDictionary valueForKey:[LVTools mToString:self.venueArray[0]]] count]; i ++) {
                    NSString *timeString = [self.infosDictionary valueForKey:self.venueArray[0]][i][@"time"];
                    if ([nowString compare:timeString options:NSLiteralSearch] == NSOrderedAscending) {
                        [_timeArray addObject:[self.infosDictionary valueForKey:self.venueArray[0]][i][@"time"]];
                    }
                }
                for (int i = 0; i < self.venueArray.count; i ++) {
                    for (int j = 0; j < [[self.infosDictionary valueForKey:[LVTools mToString:self.venueArray[i]]] count]; j ++) {
                        NSString *timeString = [self.infosDictionary valueForKey:self.venueArray[i]][j][@"time"];
                        if ([nowString compare:timeString options:NSLiteralSearch] == NSOrderedAscending) {
                            [_detailArrays addObject:[self.infosDictionary valueForKey:self.venueArray[i]][j]];
                        }
                    }
                }
            } else {
                for (int i = 0; i < self.venueArray.count; i ++) {
                    [_detailArrays addObjectsFromArray:[self.infosDictionary valueForKey:self.venueArray[i]]];
                }
                for (int i = 0; i < [[self.infosDictionary valueForKey:self.venueArray[0]] count]; i ++) {
                    [_timeArray addObject:[self.infosDictionary valueForKey:self.venueArray[0]][i][@"time"]];
                }
            }
        }
        [_stimeTableview reloadData];
        [_venueCollection reloadData];
        [self setcontentForContentScroll];
    }];
}

- (void)initialDatasource {
    _detailArrays = [NSMutableArray array];
    _timeArray = [NSMutableArray array];
    _selectObject = [NSMutableArray array];
    [self loadDataInfomation];
    //initialize weekday
    _numStringDic = @{@"1":@"星期一",@"2":@"星期二",@"3":@"星期三",@"4":@"星期四",@"5":@"星期五",@"6":@"星期六",@"7":@"星期日"};
    NSInteger num = [self weekDayStr];
    num --;
    if (num == 0) {
        num = 7;
    }
    _weekArray = [NSMutableArray array];
    for (NSInteger i = num; i < 8; i ++) {
        NSString *numKey = [NSString stringWithFormat:@"%ld",(long)i];
        [_weekArray addObject:_numStringDic[numKey]];
    }
    if (num > 1) {
        for (NSInteger i = 1; i < num; i ++) {
            NSString *numKey = [NSString stringWithFormat:@"%ld",(long)i];
            [_weekArray addObject:_numStringDic[numKey]];
        }
    }
    
    //initialize date
    _dateArray = [NSMutableArray array];
    for (int i = 0; i < 7; i ++) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:dayInterval*i];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM-dd"];
        NSString *str = [format stringFromDate:date];
        str = [str stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"月"];
        str = [str stringByAppendingString:@"号"];
        if ([str hasPrefix:@"0"]) {
            str = [str substringFromIndex:1];
        }
        [_dateArray addObject:str];
    }
    [_btimeCollection reloadData];
}

- (void)initialInterface {
    [self createHeadInfomation];
    [self createWeekCollection];
    [self createVenueCollection];
    [self createstimeTableview];
    [self createSeperateLine];
    [self createContentScroll];
    [self createBottomView];
}

- (void)createHeadInfomation {
    NSArray *typeArray = @[@"可预定",@"我的预定",@"已预定"];
    NSArray *colorArray = @[RGBACOLOR(255, 255, 255, 1),RGBACOLOR(76, 162, 219, 1),RGBACOLOR(241, 69, 62, 1)];
    for (int i = 0; i < 3; i ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH/6, 15)];
        label.center = CGPointMake(UISCREENWIDTH/3*i+UISCREENWIDTH/6, 19);
        label.text = typeArray[i];
        label.textColor = RGBACOLOR(120, 120, 120, 1);
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH/5.5, 15)];
        view.center = CGPointMake(UISCREENWIDTH/3*i+UISCREENWIDTH/6, CGRectGetMaxY(label.frame)+10);
        view.backgroundColor = colorArray[i];
        view.layer.cornerRadius = 2.5;
        view.layer.masksToBounds = YES;
        if (i == 0) {
            view.layer.borderWidth = 1;
            view.layer.borderColor = [venueBorderColor CGColor];
        }
        [self.view addSubview:view];
    }
}

- (void)createWeekCollection {
    _sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH/4, UISCREENWIDTH/8)];
    _sliderView.backgroundColor = RGBACOLOR(77, 161, 219, 1);
    _selectedWeekday = 0;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.itemSize = CGSizeMake(UISCREENWIDTH/4, UISCREENWIDTH/8);
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _btimeCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 115-64, UISCREENWIDTH, UISCREENWIDTH/8) collectionViewLayout:flow];
    [_btimeCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier1];
    _btimeCollection.dataSource = self;
    _btimeCollection.backgroundColor = [UIColor whiteColor];
    _btimeCollection.delegate = self;
    _btimeCollection.showsHorizontalScrollIndicator = NO;
    _btimeCollection.showsVerticalScrollIndicator = NO;
    _btimeCollection.contentSize = CGSizeMake(UISCREENWIDTH/4*9, UISCREENWIDTH/8);
    [self.view addSubview:_btimeCollection];
}

- (void)createVenueCollection {
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.itemSize = CGSizeMake(UISCREENWIDTH/6, UISCREENWIDTH/14);
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _venueCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btimeCollection.frame), UISCREENWIDTH, UISCREENWIDTH/14) collectionViewLayout:flow];
    [_venueCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier2];
    _venueCollection.backgroundColor = [UIColor whiteColor];
    _venueCollection.dataSource = self;
    _venueCollection.delegate = self;
    _venueCollection.userInteractionEnabled = NO;
    _venueCollection.showsHorizontalScrollIndicator = NO;
    _venueCollection.showsVerticalScrollIndicator = NO;
    _venueCollection.contentSize = CGSizeMake(UISCREENWIDTH/6*(_venueArray.count+1), UISCREENWIDTH/14);
    [self.view addSubview:_venueCollection];
}

- (void)createstimeTableview {
    _stimeTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_venueCollection.frame)+10, UISCREENWIDTH/7, UISCREENHEIGHT-CGRectGetMaxY(_venueCollection.frame)-80-64) style:UITableViewStylePlain];
    _stimeTableview.dataSource = self;
    _stimeTableview.delegate = self;
    _stimeTableview.userInteractionEnabled = NO;
    _stimeTableview.backgroundColor = [UIColor whiteColor];
    _stimeTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _stimeTableview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_stimeTableview];
}

- (void)createBottomView {
    _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, UISCREENHEIGHT-45-64, UISCREENWIDTH/2, 45)];
    _costLabel.backgroundColor = [UIColor whiteColor];
    _costLabel.textAlignment = NSTextAlignmentCenter;
    NSString *costString = @"总计：0.0元";
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:costString];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, costString.length-3)];
    _costLabel.attributedText = attributeStr;
    _costLabel.font = [UIFont systemFontOfSize:15];
    _costLabel.layer.borderWidth = 0.5;
    _costLabel.layer.borderColor = [lightColor CGColor];
    
    _comfirmOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2, UISCREENHEIGHT-45-64, UISCREENWIDTH/2, 45)];
    _comfirmOrderLabel.backgroundColor = RGBACOLOR(77, 161, 219, 1);
    _comfirmOrderLabel.text = @"提交订单";
    _comfirmOrderLabel.textColor = [UIColor whiteColor];
    _comfirmOrderLabel.textAlignment = NSTextAlignmentCenter;
    _comfirmOrderLabel.font = [UIFont systemFontOfSize:15];
    _comfirmOrderLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitOrder)];
    [_comfirmOrderLabel addGestureRecognizer:tap];
    
    [self.view addSubview:_costLabel];
    [self.view addSubview:_comfirmOrderLabel];
}

- (void)createSeperateLine {
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_venueCollection.frame), UISCREENWIDTH, 0.5)];
    horizontalLine.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [self.view addSubview:horizontalLine];
    
    UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(UISCREENWIDTH/7.4, CGRectGetMaxY(horizontalLine.frame)+10, 0.5, UISCREENHEIGHT-CGRectGetMaxY(_venueCollection.frame)-80-64)];
    verticalLine.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [self.view addSubview:verticalLine];
}

- (void)createContentScroll {
    _contentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(UISCREENWIDTH/7, CGRectGetMaxY(_venueCollection.frame)+10, UISCREENWIDTH/7*6, UISCREENHEIGHT-CGRectGetMaxY(_venueCollection.frame)-80-64)];
    _contentScroll.delegate = self;
    _contentScroll.showsHorizontalScrollIndicator = NO;
    _contentScroll.showsVerticalScrollIndicator = NO;
    _contentScroll.userInteractionEnabled = YES;
    [self.view addSubview:_contentScroll];
    
}

#pragma mark -- collectionview delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _btimeCollection) {
        _costNum = 0;
        _selectedWeekday = indexPath.row;
        [self setsliderviewPosition:indexPath detailcell:nil];
        [self loadDataInfomation];
        NSString *str = [NSString stringWithFormat:@"总计：%.2f元",self.costNum];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, str.length-3)];
        _costLabel.attributedText = attributeStr;
        [_selectObject removeAllObjects];
    }
}

- (void)setsliderviewPosition:(NSIndexPath *)indexpath detailcell:(UICollectionViewCell *)cell{
    if (indexpath.row == _selectedWeekday) {
        NSArray *arr = [_btimeCollection visibleCells];
        for (int i = 0; i < arr.count; i ++) {
            UICollectionViewCell *cell = (UICollectionViewCell *)arr[i];
            UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:cell.tag+7];
            UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:cell.tag+14];
            label1.textColor = RGBACOLOR(110, 110, 110, 1);
            label2.textColor = lightColor;
        }
        if (!cell) {
            cell = [_btimeCollection cellForItemAtIndexPath:indexpath];
        }
        [_sliderView removeFromSuperview];
        [cell.contentView addSubview:_sliderView];
        [cell.contentView sendSubviewToBack:_sliderView];
        UILabel *lab1 = (UILabel *)[cell.contentView viewWithTag:indexpath.row+bweekTag+7];
        UILabel *lab2 = (UILabel *)[cell.contentView viewWithTag:indexpath.row+bweekTag+14];
        lab1.textColor = [UIColor whiteColor];
        lab2.textColor = [UIColor whiteColor];
    }
}

#pragma mark -- collectionview datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _btimeCollection) {
        return 7;
    }
    return _venueArray.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _btimeCollection) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier1 forIndexPath:indexPath];
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        cell.tag = bweekTag+indexPath.row;
        UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH/4, UISCREENWIDTH/16)];
        lab1.tag = cell.tag+7;
        lab1.text = _weekArray[indexPath.row];
        lab1.textColor = RGBACOLOR(110, 110, 110, 1);
        lab1.textAlignment = NSTextAlignmentCenter;
        lab1.font = [UIFont systemFontOfSize:15];
        
        UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, UISCREENWIDTH/16, UISCREENWIDTH/4, UISCREENWIDTH/16)];
        lab2.text = _dateArray[indexPath.row];
        lab2.textColor = lightColor;
        lab2.textAlignment = NSTextAlignmentCenter;
        lab2.font = [UIFont systemFontOfSize:13];
        
        [cell.contentView addSubview:lab1];
        [cell.contentView addSubview:lab2];
        lab2.tag = cell.tag+14;
        cell.layer.borderColor = [RGBACOLOR(220, 220, 220, 1) CGColor];
        cell.layer.borderWidth = 0.5;
        
        [self setsliderviewPosition:indexPath detailcell:cell];
        
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier2 forIndexPath:indexPath];
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        if (indexPath.row != 0) {
            UILabel *lab = [[UILabel alloc] initWithFrame:cell.bounds];
            lab.text = _venueArray[indexPath.row-1];
            lab.font = [UIFont systemFontOfSize:13];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = lightColor;
            [cell.contentView addSubview:lab];
        }
        return cell;
    }
}

#pragma mark -- tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}


#pragma mark -- tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier3 = @"cell3";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 30)];
    lab.font = [UIFont systemFontOfSize:11];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.text = _timeArray[indexPath.row];
    lab.textColor = lightColor;
    [cell.contentView addSubview:lab];
    return cell;
}

#pragma mark -- scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _contentScroll) {
        _venueCollection.contentOffset = CGPointMake(_contentScroll.contentOffset.x, 0);
        _stimeTableview.contentOffset = CGPointMake(0, _contentScroll.contentOffset.y);
    }
}

#pragma mark -- method (get detail weekday)
- (NSInteger)weekDayStr
{
    _comps = [[NSDateComponents alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [format stringFromDate:[NSDate date]];
    if (str.length >= 10) {
        NSString *nowString = [str substringToIndex:10];
        NSArray *array = [nowString componentsSeparatedByString:@"-"];
        if (array.count == 0) {
            array = [nowString componentsSeparatedByString:@"/"];
        }
        if (array.count >= 3) {
            NSInteger year = [[array objectAtIndex:0] integerValue];
            NSInteger month = [[array objectAtIndex:1] integerValue];
            NSInteger day = [[array objectAtIndex:2] integerValue];
            [_comps setYear:year];
            [_comps setMonth:month];
            [_comps setDay:day];
        }
    }
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *_date = [gregorian dateFromComponents:_comps];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:_date];
    NSInteger week = [weekdayComponents weekday];
    return week;
}

- (void)submitOrder {

    if ([_selectObject count] == 0) {
        [self showHint:@"请选择具体场地"];
        return;
    }
    WPCComfirmVenueVC *vc = [[WPCComfirmVenueVC alloc] init];
    vc.infoDic = [NSMutableDictionary dictionary];
    [vc.infoDic setValue:_vennueModel.venuesName forKey:@"venue"];
    [vc.infoDic setValue:[NSString stringWithFormat:@"%.2f",_costNum] forKey:@"costNum"];
    [vc.infoDic setValue:_selectObject forKey:@"infos"];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:dayInterval*_selectedWeekday];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSMutableString *str = [[NSMutableString alloc] initWithString:[format stringFromDate:date]];
    [vc.infoDic setValue:str forKey:@"date"];
    vc.ordertype = @"1";
    vc.costNum = _costNum;
    vc.selectedWeekday = _selectedWeekday;
    vc.taocanModel = self.taocanModel;
    vc.selectObject = _selectObject;
    vc.vennueModel = self.vennueModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setcontentForContentScroll {
    for (UIView *view in _contentScroll.subviews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i < [_venueArray count]; i ++) {
        for (int j = 0; j < [_timeArray count]; j ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(UISCREENWIDTH/42+UISCREENWIDTH/6*i, 5+30*j, UISCREENWIDTH/6.5, 25);
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [venueBorderColor CGColor];
            btn.layer.cornerRadius = 2;
            btn.tag = _selectedWeekday*10000+i*100+j;
            [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
            btn.layer.masksToBounds = YES;
            NSString *priceStr = [LVTools mToString:_detailArrays[i*_timeArray.count+j][@"price"]];
            NSString *stateStr = [LVTools mToString:_detailArrays[i*_timeArray.count+j][@"status"]];
            [btn setTitle:priceStr forState:UIControlStateNormal];
            [btn setTitleColor:lightColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
            [btn setBackgroundImage:[LVTools buttonImageFromColor:[UIColor whiteColor] withFrame:btn.bounds] forState:UIControlStateNormal];
            [btn setBackgroundImage:[LVTools buttonImageFromColor:NavgationColor withFrame:btn.bounds] forState:UIControlStateSelected];
            [btn setBackgroundImage:[LVTools buttonImageFromColor:RGBACOLOR(240, 68, 62, 1) withFrame:btn.bounds] forState:UIControlStateDisabled];
            if ([stateStr isEqualToString:@"1"]) {
                btn.enabled = NO;
            }
            [btn addTarget:self action:@selector(selectDetailVenue:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
        }
    }
    _contentScroll.contentSize = CGSizeMake(UISCREENWIDTH/6*(_venueArray.count+0.2), 30*(_timeArray.count));
}

- (void)selectDetailVenue:(UIButton *)btn {
    btn.selected = !btn.selected;
    NSString *tagString = [NSString stringWithFormat:@"%ld",(long)btn.tag];
    int i = 0,j = 0;
    int k = [tagString intValue];
    if (tagString.length < 3) {
        i = 0;
        j = k;
    } else if (tagString.length < 5) {
        i = k/100;
        j = k%100;
    } else {
        i = k%10000/100;
        j = k%10000%100;
    }
    if (btn.selected) {
        NSString *pricestring = btn.titleLabel.text;
        self.costNum += [pricestring floatValue];
        [_selectObject addObject:_detailArrays[i*_timeArray.count+j]];
    } else {
        NSString *pricestring = btn.titleLabel.text;
        self.costNum -= [pricestring floatValue];
        [_selectObject removeObject:_detailArrays[i*_timeArray.count+j]];
    }
    NSString *str = [NSString stringWithFormat:@"总计：%.2f元",self.costNum];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, str.length-3)];
    _costLabel.attributedText = attributeStr;
    NSLog(@"i = %d",i);
    NSLog(@"j = %d",j);
    NSLog(@"selectObject ==== %@",_selectObject);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

