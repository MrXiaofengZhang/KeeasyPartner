//
//  WPCMyTeamVC.m
//  yuezhan123
//
//  Created by admin on 15/8/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCMyTeamVC.h"
#import "MyTeamCell.h"
#import "ZHTeamDetailController.h"
#import "TeamModel.h"

@interface WPCMyTeamVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableview;
@property (nonatomic, strong)UISegmentedControl *segmentControl;
@property (nonatomic, strong)NSMutableArray *myArray;
@property (nonatomic, strong)NSMutableArray *applyArray;

@end

@implementation WPCMyTeamVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    [self.navigationController.navigationBar addSubview:self.segmentControl];
    self.myArray = [NSMutableArray array];
    self.applyArray = [NSMutableArray array];
    [self.view addSubview:self.tableview];
    [self loadData];
    
}

- (void)loadData {
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
    [DataService requestWeixinAPI:getMyTeamList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"%@",result);
        NSLog(@"1");
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [_myArray removeAllObjects];
            [_applyArray removeAllObjects];
            [_myArray addObjectsFromArray:result[@"teamList"]];
            [_applyArray addObjectsFromArray:result[@"applyTeamsList"]];
            [_tableview reloadData];
        } else {
            [self showHint:@"页面加载失败，请重试"];
        }
    }];
}

- (UISegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"我的战队",@"已申请战队"]];
        _segmentControl.frame = CGRectMake(124*propotion, 5, 500*propotion, 33);
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        _segmentControl.tintColor = SystemBlue;
    }
    return _segmentControl;
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableview.backgroundColor = [UIColor whiteColor];
        _tableview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [[UIView alloc] init];
//        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableview;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"cellid";
    MyTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[MyTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    if (_segmentControl.selectedSegmentIndex == 0) {
        [cell configMyTeamWithDicinfo:_myArray[indexPath.row]];
    } else {
        [cell configMyApplyWithDicInfo:_applyArray[indexPath.row]];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_segmentControl.selectedSegmentIndex == 0) {
        return _myArray.count;
    } else {
        return _applyArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZHTeamDetailController *teamDetailVC=[[ZHTeamDetailController alloc] init];
    TeamModel *model = [[TeamModel alloc] init];
    if (_segmentControl.selectedSegmentIndex == 0) {
        [model setValuesForKeysWithDictionary:_myArray[indexPath.row]];
    } else {
        NSDictionary *dic = _applyArray[indexPath.row];
        [model setValuesForKeysWithDictionary:_applyArray[indexPath.row][@"teamDto"]];
        model.id = dic[@"teamId"];
    }
    teamDetailVC.chuanBlock = ^(NSArray *arr) {
        [self loadData];
    };
    teamDetailVC.teamModel = model;
    [self.navigationController pushViewController:teamDetailVC animated:YES];
}

- (void)segmentAction:(UISegmentedControl *)seg {
    [_tableview reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_segmentControl];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_segmentControl removeFromSuperview];
}

@end
