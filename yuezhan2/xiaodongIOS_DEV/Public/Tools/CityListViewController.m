//
//  CityListViewController.m
//  CityList
//
//  Created by Chen Yaoqiang on 14-3-6.
//
//

#import "CityListViewController.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "WPCAreaSelectCell.h"

static NSString *cityCollectionID = @"cityCollectionID";

@interface CityListViewController ()
{
    NSArray *hotCityCode;
    NSLock *lock;
    NSOperationQueue *myQune;
    NSBlockOperation *blockOp;
}


@end

@implementation CityListViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.arrayHotCity = [[NSMutableArray alloc] initWithArray:@[@"北京市",@"上海市",@"广州市",@"深圳市",@"杭州市"]];
        hotCityCode = @[@"291",@"365",@"490",@"492",@"380"];
        self.keys = [NSMutableArray array];
    }
    return self;
}

- (void)getAllCitiesInfo {
    self.citiesDictionary = [[NSDictionary alloc] initWithContentsOfFile:LISTFILEPATH];
    NSLog(@" a ==== %@",self.citiesDictionary);
    //只存一次，没必要每次检测新的，存了之后从plist文件拿取
    if (!self.citiesDictionary) {//为空则网络请求，并将数据保存到沙盒
        NSDictionary *dic = [LVTools getTokenApp];
        [DataService requestWeixinAPI:getCity parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@" a ==== %@",result);
            if ([result[@"statusCode"] isEqualToString:@"success"]) {
                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:result[@"cityResult"]];
                self.cities = [NSMutableDictionary dictionaryWithDictionary:result[@"cityResult"]];
                [self getCityData];
                [_tableView reloadData];
                if ([dic writeToFile:LISTFILEPATH atomically:YES]) {
                    NSLog(@"success");
                }
            }
        }];
    } else {
        self.cities = [NSMutableDictionary dictionaryWithContentsOfFile:LISTFILEPATH];
        [self getCityData];
    }
}
- (void)getAllUniversitiesInfo{
    NSString *urlStr =[[NSBundle mainBundle] pathForResource:@"university" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:urlStr];
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                 options:NSJSONReadingAllowFragments
                                                   error:nil];
    
    self.cities = [NSMutableDictionary dictionaryWithObjectsAndKeys:jsonObj,@"universityList", nil];
    [self getCityData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isUniversityList) {
        [self getAllUniversitiesInfo];
    }
    else{
        [self getAllCitiesInfo];
    }
    lock = [[NSLock alloc] init];
    _searchResults = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(PopView)];
    
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 40)];
    mySearchBar.delegate = self;
    if (self.isUniversityList) {
        [mySearchBar setPlaceholder:@"输入大学名或拼音"];
    }
    else{
        [mySearchBar setPlaceholder:@"输入城市名或拼音"];
    }
    
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    [self createHeaderView];
    
    // Do any additional setup after loading the view.
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT) style:UITableViewStylePlain];
    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    _tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = mySearchBar;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)createHeaderView {
    CGFloat cellWidth = UISCREENWIDTH/3.6;
    //searchbar
    _headerview = [[UIView alloc] init];
    _headerview.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    if (_hasAllCountry) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((UISCREENWIDTH-3*cellWidth)/4, 10, cellWidth, cellWidth/3);
        [btn setTitle:@"全国" forState:UIControlStateNormal];
        [btn setTitleColor:lightColor forState:UIControlStateNormal];
        [btn setTitleColor:lightColor forState:UIControlStateSelected];
        btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        btn.layer.borderWidth = 1;
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(chooseWholeCountry) forControlEvents:UIControlEventTouchUpInside];
        [_headerview addSubview:btn];
    }
    
    //热门城市
    UIView *whiteView = [[UIView alloc] init];
    if (!_hasAllCountry) {
        whiteView.frame = CGRectMake(0, 0, UISCREENWIDTH, 30);
    } else {
        whiteView.frame = CGRectMake(0, 54, UISCREENWIDTH, 30);
    }
    whiteView.backgroundColor = [UIColor whiteColor];
    [_headerview addSubview:whiteView];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake((UISCREENWIDTH-3*cellWidth)/4, 5, 100, 20)];
    lab.text = @"热门城市";
    [whiteView addSubview:lab];
    //collectionview
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
    flowLayout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
    
    _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, whiteView.bottom, UISCREENWIDTH, (self.arrayHotCity.count/3+1)*(cellWidth/3+5)+30) collectionViewLayout:flowLayout];
    if(self.isUniversityList){
        _collectView.height = 0;
    }
    [_collectView registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:cityCollectionID];
    _collectView.backgroundColor = [UIColor clearColor];
    _collectView.delegate = self;
    _collectView.dataSource = self;
    [_headerview addSubview:_collectView];
    _headerview.frame = CGRectMake(0, 0, UISCREENWIDTH, _collectView.bottom+5);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayHotCity.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WPCAreaSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cityCollectionID forIndexPath:indexPath];
    cell.titleLab.text = self.arrayHotCity[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLab.textColor = RGBACOLOR(135, 135, 135, 1);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    for (int i = 0; i < self.tempArray.count; i ++) {
        if ([[LVTools mToString:self.tempArray[i][@"regionId"]] isEqualToString:hotCityCode[indexPath.row]]) {
            dic = self.tempArray[i];
        }
    }
    [self.citydelegate collectionClickAtCode:hotCityCode[indexPath.row] andName:self.arrayHotCity[indexPath.row] andInfo:dic];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)chooseWholeCountry {
    [self.citydelegate wholeContryClick];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PopView{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - tableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0.0;
    }
    else{
        if (section == 0) {
            if (_isUniversityList) {
                return 20.0;
            } else {
                if (_hasAllCountry) {
                    return 220;
                }
                return 166;
            }
        } else {
            return 20.0;
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (_isUniversityList) {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 20)];
            bgView.backgroundColor = RGBACOLOR(248, 248, 248, 1);
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 250, 20)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.font = [UIFont systemFontOfSize:12];
            
            NSString *key = [_keys objectAtIndex:section];
            titleLabel.text = key;
            
            [bgView addSubview:titleLabel];
            
            return bgView;
        } else {
            UIView *view = [[UIView alloc] init];
            [view addSubview:_headerview];
            
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, _headerview.bottom, UISCREENWIDTH, 20)];
            view1.backgroundColor = RGBACOLOR(248, 248, 248, 1);
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 250, 20)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.font = [UIFont systemFontOfSize:12];
            
            NSString *key = [_keys objectAtIndex:section];
            titleLabel.text = key;
            [view1 addSubview:titleLabel];
            [view addSubview:view1];
            view.frame = CGRectMake(0, 0, UISCREENHEIGHT, titleLabel.bottom);
            return view;
        }
    } else {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 20)];
        bgView.backgroundColor = RGBACOLOR(248, 248, 248, 1);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 250, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        
        NSString *key = [_keys objectAtIndex:section];
        titleLabel.text = key;
        
        [bgView addSubview:titleLabel];
        
        return bgView;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _tableView) {
        return _keys;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    else {
        return [_keys count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchResults.count;
    }
    else {
        // Return the number of rows in the section.
        if (self.isUniversityList) {
            return [[_cities objectForKey:@"universityList"][section][@"school"] count];
        }
        else{
            NSString *key = [_keys objectAtIndex:section];
            NSArray *citySection = [_cities objectForKey:key];
            return [citySection count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSString *key = [_keys objectAtIndex:indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.textLabel setTextColor:[UIColor blackColor]];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = _searchResults[indexPath.row];
    }
    else {
        if (self.isUniversityList) {
            cell.textLabel.text = [_cities objectForKey:@"universityList"][indexPath.section][@"school"][indexPath.row][@"name"];
        }
        else{
            cell.textLabel.text = [_cities objectForKey:key][indexPath.row][@"regionName"];
        }
    }
    return cell;
}

#pragma mark - 获取城市数据
-(void)getCityData
{
    self.tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.searchInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    if (self.isUniversityList) {
        for (NSDictionary *dic in self.cities[@"universityList"]) {
            [self.keys addObject:dic[@"name"]];
        }
        
        for (int j = 0; j < [self.cities[@"universityList"] count]; j ++) {
            for (int i = 0; i < [self.cities[@"universityList"][j][@"school"] count]; i ++) {
                [dataArray addObject:self.cities[@"universityList"][j][@"school"][i][@"name"]];
            }
        }
    }
    else{
        [self.keys addObjectsFromArray:[[self.cities allKeys] sortedArrayUsingSelector:@selector(compare:)]];
        for (NSString *key in self.keys) {
            NSMutableArray *arr = [NSMutableArray array];
            NSMutableArray *arr1 = [NSMutableArray array];
            for (int i = 0; i < [self.cities[key] count]; i ++) {
                [arr addObject:self.cities[key][i][@"regionName"]];
                [arr1 addObject:self.cities[key][i]];
            }
            [dataArray addObjectsFromArray:arr];
            [self.tempArray addObjectsFromArray:arr1];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_isUniversityList) {
        if (tableView == _tableView) {
            NSString *key = [_keys objectAtIndex:indexPath.section];
            self.areaDictionary = [NSDictionary dictionaryWithDictionary:_cities[key][indexPath.row]];
        } else {
            self.areaDictionary = [NSDictionary dictionaryWithDictionary:_searchInfoArray[indexPath.row]];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.citydelegate sendMsg:cell.textLabel.text];
        [self.citydelegate sendCityAreas:self.areaDictionary];
    } else {
        //回传大学字段
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *str = cell.textLabel.text;
        NSArray *arr = @[str];
        self.chuanBlock(arr);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchResults removeAllObjects];
    [_searchInfoArray removeAllObjects];
    [self.searchDisplayController.searchResultsTableView endUpdates];
    //operation
    //    if (myQune) {
    //        [blockOp cancel];
    //        [myQune cancelAllOperations];
    //    }
    //    else{
    //        myQune = [[NSOperationQueue alloc] init];
    //    }
    //    blockOp = [NSBlockOperation blockOperationWithBlock:^{
    //        if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
    //            [lock lock];
    //            for (int i=0; i<dataArray.count; i++) {
    //                if ([ChineseInclude isIncludeChineseInString:dataArray[i]]) {
    //                    NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:dataArray[i]];
    //                    NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                    if (titleResult.length>0) {
    //                        if (![_searchResults containsObject:dataArray[i]]) {
    //                            [_searchResults addObject:dataArray[i]];
    //
    //                        }
    //                        if (!_isUniversityList) {
    //                            if (![_searchInfoArray containsObject:_tempArray[i]]) {
    //                                [_searchInfoArray addObject:_tempArray[i]];
    //                            }
    //                        }
    //                    } else {
    //                        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:dataArray[i]];
    //                        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                        if (titleHeadResult.length>0) {
    //                            if (![_searchResults containsObject:dataArray[i]]) {
    //                                [_searchResults addObject:dataArray[i]];
    //                            }
    //                            if (!_isUniversityList) {
    //                                if (![_searchInfoArray containsObject:_tempArray[i]]) {
    //                                    [_searchInfoArray addObject:_tempArray[i]];
    //                                }
    //                            }
    //                        }
    //                    }
    //                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:dataArray[i]];
    //                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                    if (titleHeadResult.length>0) {
    //                        if (![_searchResults containsObject:dataArray[i]]) {
    //                            [_searchResults addObject:dataArray[i]];
    //                        }
    //                        if (!_isUniversityList) {
    //                            if (![_searchInfoArray containsObject:_tempArray[i]]) {
    //                                [_searchInfoArray addObject:_tempArray[i]];
    //                            }
    //                        }
    //                    }
    //                } else {
    //                    NSRange titleResult=[dataArray[i] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                    if (titleResult.length>0) {
    //                        if (![_searchResults containsObject:dataArray[i]]) {
    //                            [_searchResults addObject:dataArray[i]];
    //                        }
    //                        if (!_isUniversityList) {
    //                            if (![_searchInfoArray containsObject:_tempArray[i]]) {
    //                                [_searchInfoArray addObject:_tempArray[i]];
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //            [lock unlock];
    //            __async_main__,^{
    //                [self.searchDisplayController.searchResultsTableView reloadData];
    //            });
    //        }
    //        else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
    //            [lock lock];
    //            for (NSString *tempStr in dataArray) {
    //                NSRange titleResult=[tempStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                if (titleResult.length>0) {
    //                    if (![_searchResults containsObject:tempStr]) {
    //                        [_searchResults addObject:tempStr];
    //                    }
    //                    for (int i = 0; i < dataArray.count; i ++) {
    //                        if ([dataArray[i] isEqualToString:tempStr]) {
    //                            if (!_isUniversityList) {
    //                                if (![_searchInfoArray containsObject:_tempArray[i]]) {
    //                                    [_searchInfoArray addObject:_tempArray[i]];
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //            [lock unlock];
    //            __async_main__,^{
    //                [self.searchDisplayController.searchResultsTableView reloadData];
    //            });
    //        }
    //
    //    }];
    //    [myQune addOperation:blockOp];
    
    __async_opt__,^{
        
        if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
            [lock lock];
            for (int i=0; i<dataArray.count; i++) {
                if ([ChineseInclude isIncludeChineseInString:dataArray[i]]) {
                    NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:dataArray[i]];
                    NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        if (![_searchResults containsObject:dataArray[i]]) {
                            [_searchResults addObject:dataArray[i]];
                            
                        }
                        if (!_isUniversityList) {
                            if (![_searchInfoArray containsObject:_tempArray[i]]) {
                                [_searchInfoArray addObject:_tempArray[i]];
                            }
                        }
                    } else {
                        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:dataArray[i]];
                        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                        if (titleHeadResult.length>0) {
                            if (![_searchResults containsObject:dataArray[i]]) {
                                [_searchResults addObject:dataArray[i]];
                            }
                            if (!_isUniversityList) {
                                if (![_searchInfoArray containsObject:_tempArray[i]]) {
                                    [_searchInfoArray addObject:_tempArray[i]];
                                }
                            }
                        }
                    }
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:dataArray[i]];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
                        if (![_searchResults containsObject:dataArray[i]]) {
                            [_searchResults addObject:dataArray[i]];
                        }
                        if (!_isUniversityList) {
                            if (![_searchInfoArray containsObject:_tempArray[i]]) {
                                [_searchInfoArray addObject:_tempArray[i]];
                            }
                        }
                    }
                } else {
                    NSRange titleResult=[dataArray[i] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        if (![_searchResults containsObject:dataArray[i]]) {
                            [_searchResults addObject:dataArray[i]];
                        }
                        if (!_isUniversityList) {
                            if (![_searchInfoArray containsObject:_tempArray[i]]) {
                                [_searchInfoArray addObject:_tempArray[i]];
                            }
                        }
                    }
                }
            }
            [lock unlock];
            __async_main__,^{
                [self.searchDisplayController.searchResultsTableView reloadData];
            });
        }
        else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
            [lock lock];
            for (NSString *tempStr in dataArray) {
                NSRange titleResult=[tempStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    if (![_searchResults containsObject:tempStr]) {
                        [_searchResults addObject:tempStr];
                    }
                    for (int i = 0; i < dataArray.count; i ++) {
                        if ([dataArray[i] isEqualToString:tempStr]) {
                            if (!_isUniversityList) {
                                if (![_searchInfoArray containsObject:_tempArray[i]]) {
                                    [_searchInfoArray addObject:_tempArray[i]];
                                }
                            }
                        }
                    }
                }
            }
            [lock unlock];
            __async_main__,^{
                [self.searchDisplayController.searchResultsTableView reloadData];
            });
        }
    });
    
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [mySearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
