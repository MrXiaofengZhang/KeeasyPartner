//
//  CitySchoolsController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/24.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "CitySchoolsController.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
@interface CitySchoolsController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    NSDictionary *_dataDict;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *_allSchoolsArray;
    NSMutableArray *_searchResults;
    NSLock *lock;
    UIView *headView;
}
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation CitySchoolsController
- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _allSchoolsArray = [[NSMutableArray alloc] initWithCapacity:0];
    _searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    lock = [[NSLock alloc] init];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:@"输入大学名或拼音"];
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    [self.view addSubview:self.mTableView];
    [self loadCitySchoolsData];
}
- (void)loadCitySchoolsData{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    if (![[LVTools mToString: _cityInfo[@"id"]] isEqualToString:@"0"]) {
        [dic setObject:_cityInfo[@"id"] forKey:@"cityId"];
    }
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getCityUniversities parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        //NSLog(@"====%@",result);
        [self hideHud];
        if (!result[@"error"]) {
            if ([result[@"status"] boolValue]) {
                _dataDict = result[@"data"][@"citySchool"];
                [self getAllschools];
                self.mTableView.hidden = NO;
                [self.mTableView reloadData];
            }
            else{
                [self showHint:result[@"info"]];
            }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
- (void)getAllschools{
    //将所有学校放在一个数组中搜索
    for(NSString *key in _dataDict.allKeys){
        [_allSchoolsArray addObjectsFromArray:[_dataDict objectForKey:key]];
    }
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height) style:UITableViewStylePlain];
        _mTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        _mTableView.backgroundColor = [UIColor clearColor];
        _mTableView.tableHeaderView = mySearchBar;
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.tableFooterView = [[UIView alloc] init];
        _mTableView.hidden = YES;
    }
    return _mTableView;
}
- (void)resetPrama{
    self.chuanBlock(@[@{@"id":@0,@"cityid":@0,@"name":@"全国"}]);
    [self dismiss];
}
#pragma mark UITableViewDatasouse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    else {
    return   [[_dataDict allKeys] count]+1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }
    else {
        if (section==0) {
            return 0;
        }
        else{
    return [[_dataDict objectForKey: [[_dataDict allKeys] objectAtIndex:section-1]] count];
        }
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolcell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"schoolcell"];
    }
    NSDictionary *infoDic = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        infoDic = [_searchResults objectAtIndex:indexPath.row];
    }
    else {
    infoDic = [[_dataDict objectForKey: [[_dataDict allKeys] objectAtIndex:indexPath.section-1]] objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = infoDic[@"name"];
    if ([infoDic[@"matchNum"] integerValue] ==0) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    }
    else{
    return [[_dataDict allKeys] objectAtIndex:section-1];
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        if (headView==nil) {
            headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 50.0)];
            headView.backgroundColor = [UIColor whiteColor];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(mygap*4, mygap*2, 80.0, 30.0)];
            [btn setTitle:@"全国" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.layer.cornerRadius = 2.0;
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [btn setBackgroundColor:BackGray_dan];
            [btn addTarget:self action:@selector(resetPrama) forControlEvents:UIControlEventTouchUpInside];
            [headView addSubview:btn];
        }
        return  headView;
    }
    else{
        return nil;
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0.0;
    }
    else{
        if (section==0) {
            return 50.0;
        }
        else{
        return 20.0;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if([_searchResults[indexPath.row][@"matchNum"] integerValue]==0){
            [self showHint:@"该学校暂无赛事"];
        }
        else{
        self.chuanBlock(@[_searchResults[indexPath.row]]);
            [self dismiss];
        }
    }
    else{
        NSDictionary *infoDic = nil;
        infoDic = [[_dataDict objectForKey: [[_dataDict allKeys] objectAtIndex:indexPath.section-1]] objectAtIndex:indexPath.row];
        if ([infoDic[@"matchNum"] integerValue] ==0) {
            //不可点击
            [self showHint:@"该学校暂无赛事"];
        }
        else{
    self.chuanBlock(@[[[_dataDict objectForKey: [[_dataDict allKeys] objectAtIndex:indexPath.section-1]] objectAtIndex:indexPath.row]]);
            [self dismiss];
        }
    }
    
}
#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView endUpdates];
    __async_opt__,^{
        
        if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
            [lock lock];
            for (int i=0; i<_allSchoolsArray.count; i++) {
                if ([ChineseInclude isIncludeChineseInString:_allSchoolsArray[i][@"name"]]) {
                    NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:_allSchoolsArray[i][@"name"]];
                    NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        if (![_searchResults containsObject:_allSchoolsArray[i]]) {
                            [_searchResults addObject:_allSchoolsArray[i]];
                        }
                    } else {
                        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:_allSchoolsArray[i][@"name"]];
                        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                        if (titleHeadResult.length>0) {
                            if (![_searchResults containsObject:_allSchoolsArray[i]]) {
                                [_searchResults addObject:_allSchoolsArray[i]];
                            }
                        }
                    }
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:_allSchoolsArray[i][@"name"]];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
                        if (![_searchResults containsObject:_allSchoolsArray[i]]) {
                            [_searchResults addObject:_allSchoolsArray[i]];
                        }
                        }
                } else {
                    NSRange titleResult=[_allSchoolsArray[i][@"name"] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        if (![_searchResults containsObject:_allSchoolsArray[i]]) {
                            [_searchResults addObject:_allSchoolsArray[i]];
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
            for (NSDictionary *tempStr in _allSchoolsArray) {
                NSRange titleResult=[tempStr[@"name"] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    if (![_searchResults containsObject:tempStr]) {
                        [_searchResults addObject:tempStr];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
