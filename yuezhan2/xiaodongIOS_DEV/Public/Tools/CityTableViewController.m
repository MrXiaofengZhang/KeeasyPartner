//
//  CityTableViewController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/24.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "CityTableViewController.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"

@interface CityTableViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSDictionary *_dataDict;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *_allSchoolsArray;
    NSMutableArray *_searchResults;
    NSLock *lock;
    UIView *headView;
    NSMutableArray *_keys;
}
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation CityTableViewController
- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    _searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    _allSchoolsArray = [[NSMutableArray alloc] initWithCapacity:0];
    lock = [[NSLock alloc] init];

    [self loadCityData];
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:@"输入城市名或拼音"];
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    [self.view addSubview:self.tableView];

}
- (UITableView*)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = mySearchBar;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}
- (void)resetPrama{
    self.chuanBlock(@[@{@"id":@0,@"city":@"全国"}]);
    [self dismiss];
}
- (void)loadCityData{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:CityCacheTime] forKey:@"time"];
    //NSLog(@"%@",[kUserDefault objectForKey:CityCacheTime]);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getCity parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"====%@",result);
        [self hideHud];
        if (![result[@"status"] isKindOfClass:[NSNull class]]) {
        if ([result[@"status"] boolValue]) {
            //数据有更新
            [kUserDefault setObject:result[@"data"][@"time"] forKey:CityCacheTime];
            //NSLog(@"%@",result[@"data"][@"time"]);
            [kUserDefault synchronize];
            if (_keys==nil) {
                _keys = [[NSMutableArray alloc] initWithCapacity:0];
            }
            NSDictionary *contentDic = result[@"data"][@"citys"];
            for(NSString *key in contentDic.allKeys){
                if ([contentDic[key] count]>0) {
                    [_keys addObject:key];
                }
            }
            _dataDict = result[@"data"][@"citys"];
            [self getCityData];
            [self.tableView reloadData];
            if ([_dataDict writeToFile:CITYLISTFILEPATH atomically:YES]) {
                NSLog(@"success");
            }
        }
        else{
            //无更新
            _dataDict = [[NSDictionary alloc] initWithContentsOfFile:CITYLISTFILEPATH];
            if (_dataDict) {
                [self getCityData];
                [self.tableView reloadData];
            }
            else{
                //这里有个容错处理
            }
        }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];

}
- (void)getCityData{
    //将所有城市放在一个数组中搜索
    for(NSString *key in _dataDict.allKeys){
        [_allSchoolsArray addObjectsFromArray:[_dataDict objectForKey:key]];
    }
    NSLog(@"qq%@",_allSchoolsArray);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    else{
       return _keys.count+1;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }
    else{
        if (section==0) {
            return 0;
        }
        else{
    return [[_dataDict objectForKey:[NSString stringWithFormat:@"%@",_keys[section-1]]] count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row][@"city"];
    }
    else{
    cell.textLabel.text = [[_dataDict objectForKey:[NSString stringWithFormat:@"%@",_keys[indexPath.section-1]]] objectAtIndex:indexPath.row][@"city"];
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    }
    else{
    return [NSString stringWithFormat:@"%@",_keys[section-1]];
    }
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _tableView) {
        return _keys;
    }
    return nil;
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
    self.chuanBlock(@[_searchResults[indexPath.row]]);
    }
    else{
    self.chuanBlock(@[[[_dataDict objectForKey:[NSString stringWithFormat:@"%@",_keys[indexPath.section-1]]] objectAtIndex:indexPath.row]]);
    }
    [self dismiss];
}
#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView endUpdates];
    __async_opt__,^{
        
        if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
            [lock lock];
            for (int i=0; i<_allSchoolsArray.count; i++) {
                if ([ChineseInclude isIncludeChineseInString:_allSchoolsArray[i][@"city"]]) {
                    NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:_allSchoolsArray[i][@"city"]];
                    NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        if (![_searchResults containsObject:_allSchoolsArray[i]]) {
                            [_searchResults addObject:_allSchoolsArray[i]];
                        }
                    } else {
                        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:_allSchoolsArray[i][@"city"]];
                        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                        if (titleHeadResult.length>0) {
                            if (![_searchResults containsObject:_allSchoolsArray[i]]) {
                                [_searchResults addObject:_allSchoolsArray[i]];
                            }
                        }
                    }
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:_allSchoolsArray[i][@"city"]];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
                        if (![_searchResults containsObject:_allSchoolsArray[i]]) {
                            [_searchResults addObject:_allSchoolsArray[i]];
                        }
                    }
                } else {
                    NSRange titleResult=[_allSchoolsArray[i][@"city"] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
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
                NSRange titleResult=[tempStr[@"city"] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
