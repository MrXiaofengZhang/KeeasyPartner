//
//  SchoolsController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/24.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "SchoolsController.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
@interface SchoolsController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    NSArray *_dataArray;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *_searchResults;
    NSLock *lock;
}
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation SchoolsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadSchoolsData];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    _searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    lock = [[NSLock alloc] init];
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:@"输入大学名或拼音"];
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    [self.view addSubview:self.mTableView];
}
- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)loadSchoolsData{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:SchoolCacheTime] forKey:@"time"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getUniversities parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        //NSLog(@"====%@",result);
        [self hideHud];
        if (![result[@"status"] isKindOfClass:[NSNull class]]) {
            if ([result[@"status"] boolValue]) {
                //数据有更新
                [kUserDefault setObject:result[@"data"][@"time"] forKey:SchoolCacheTime];
                [kUserDefault synchronize];
                _dataArray = result[@"data"][@"schools"];
                
                [self.mTableView reloadData];
                if ([_dataArray writeToFile:SCHOOLSLISTFILEPATH atomically:YES]) {
                    NSLog(@"success");
                }
            }
            else{
                //无更新
                _dataArray = [[NSArray alloc] initWithContentsOfFile:SCHOOLSLISTFILEPATH];
                
                if (_dataArray) {
                    self.mTableView.hidden = NO;
                    [self.mTableView reloadData];
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
//- (void)loadSchoolsData{
//    NSString *urlStr =[[NSBundle mainBundle] pathForResource:@"Schools" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:urlStr];
//    NSError *error = nil;
//    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                 options:NSJSONReadingAllowFragments
//                                                   error:&error];
//    if (error) {
//        NSDictionary *dic = [LVTools getTokenApp];
//        [DataService requestWeixinAPI:getCity parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
//            NSLog(@" a ==== %@",result);
//            if ([result[@"statusCode"] isEqualToString:@"success"]) {
//                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:result[@"data"]];
//                if (_dataArray==nil) {
//                    _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
//                }
//                [_dataArray addObjectsFromArray:result[@"data"][@"schools"]];
//                
//                [self.mTableView reloadData];
//                if ([dic writeToFile:LISTFILEPATH atomically:YES]) {
//                    NSLog(@"success");
//                }
//            }
//        }];
//    }
//    else{
//        NSLog(@"%@",jsonObj);
//        if (_dataArray==nil) {
//            _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
//        }
//        [_dataArray addObjectsFromArray:jsonObj[@"schools"]];
//
//    }
//}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height) style:UITableViewStylePlain];
        _mTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        _mTableView.backgroundColor = [UIColor clearColor];
        _mTableView.tableHeaderView = mySearchBar;
        _mTableView.hidden = YES;
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
    }
    return _mTableView;
}
#pragma mark UITableViewDatasouse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }
    else{
    return [_dataArray count];
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolcell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"schoolcell"];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row][@"name"];
    }
    else{
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row][@"name"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.chuanBlock(@[[_searchResults objectAtIndex:indexPath.row]]);
    }
    else{
    self.chuanBlock(@[[_dataArray objectAtIndex:indexPath.row]]);
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
            for (int i=0; i<_dataArray.count; i++) {
                if ([ChineseInclude isIncludeChineseInString:_dataArray[i][@"name"]]) {
                    NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:_dataArray[i][@"name"]];
                    NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        if (![_searchResults containsObject:_dataArray[i]]) {
                            [_searchResults addObject:_dataArray[i]];
                        }
                    } else {
                        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:_dataArray[i][@"name"]];
                        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                        if (titleHeadResult.length>0) {
                            if (![_searchResults containsObject:_dataArray[i]]) {
                                [_searchResults addObject:_dataArray[i]];
                            }
                        }
                    }
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:_dataArray[i][@"name"]];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
                        if (![_searchResults containsObject:_dataArray[i]]) {
                            [_searchResults addObject:_dataArray[i]];
                        }
                    }
                } else {
                    NSRange titleResult=[_dataArray[i][@"name"] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        if (![_searchResults containsObject:_dataArray[i]]) {
                            [_searchResults addObject:_dataArray[i]];
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
            for (NSDictionary *tempStr in _dataArray) {
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
