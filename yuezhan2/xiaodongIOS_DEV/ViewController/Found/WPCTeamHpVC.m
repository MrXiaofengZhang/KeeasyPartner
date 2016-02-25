//
//  WPCTeamHpVC.m
//  yuezhan123
//
//  Created by admin on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCTeamHpVC.h"
#import "WPCTeamCell.h"
#import "ZHNearXuanController.h"
#import "ZHTeamDetailController.h"
#import "WPCTeamBuildVC.h"
#import "TeamModel.h"
#import "LoginLoginZhViewController.h"
#import "EmpatyView.h"
#import "SingleImageController.h"
@interface WPCTeamHpVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIActionSheetDelegate>{
    NSInteger page;
    NSString *sportType;
    NSString *university;
    NSString *longitude;
    NSString *latitude;
    NSString *sort;
    NSString *keywordSearch;
    UIButton *bottomBtn;
    NSMutableArray *selectArray;
}

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UISegmentedControl *segCrol;
@property (nonatomic, strong) UISearchBar *searchCrol;
@end

@implementation WPCTeamHpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sportType = nil;
    university = @"";
    sort = @"0";
    page = 1;
    keywordSearch = @"";
    self.array = [[NSMutableArray alloc] initWithCapacity:0];
    if([self.title isEqualToString:@"附近球队"]){
    _searchCrol = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 44.0)];
    _searchCrol.placeholder = @"搜索";
    _searchCrol.showsCancelButton = YES;
    _searchCrol.delegate = self;
    [self.view addSubview:_searchCrol];
    }
    _segCrol = [[UISegmentedControl alloc] initWithItems:@[@"我的球队",@"关注的球队"]];
    _segCrol.frame = CGRectMake(124*propotion, 5, 500*propotion, 33);
    _segCrol.selectedSegmentIndex = 0;
    [_segCrol addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    _segCrol.tintColor = SystemBlue;

    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-49-64) style:UITableViewStylePlain];
    if ([self.title isEqualToString:@"附近球队"]) {
        _table.frame = CGRectMake(0, 44.0, UISCREENWIDTH, UISCREENHEIGHT-64.0-44.0);
        _table.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    _table.dataSource = self;
    _table.showsVerticalScrollIndicator = NO;
    _table.delegate = self;
    
    UIView *view = [[UIView alloc] init];
    _table.tableFooterView = view;
    [self.view addSubview:_table];
    if ([self.title isEqualToString:@"选择球队"]) {
        _table.editing = YES;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, _table.bottom, BOUNDS.size.width, 50.0)];
        [btn setBackgroundColor:SystemBlue];
        [btn setTitle:@"确认" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(applyOnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        selectArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.table addGestureRecognizer:tap];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"MarkerTeam"] forState:UIControlStateNormal];
    if ([self.title isEqualToString:@"附近球队"]) {
        _table.height = UISCREENHEIGHT-64;
        [_segCrol removeFromSuperview];
        [self navgationBarLeftReturn];
        [btn setImage:[UIImage imageNamed:@"nrightBtn"] forState:UIControlStateNormal];
    }
    
    [btn addTarget:self action:@selector(chooseAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if ([self.title isEqualToString:@"选择球队"]) {
        [self navgationBarLeftReturn];
        self.navigationItem.rightBarButtonItem = nil;
    }
    if (!self.title) {
        self.table.tableFooterView =[self createbottomBtn];
    }
    else{
        self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
       [self MJRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSateChange:) name:LOGINSTATECHANGE_NOTIFICATION object:nil];
}
- (UIButton*)createbottomBtn{
    if (bottomBtn == nil) {
      
        bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomBtn.frame = CGRectMake(0, 0, UISCREENWIDTH, 49);
        [bottomBtn addTarget:self action:@selector(foundAteam) forControlEvents:UIControlEventTouchUpInside];
        [bottomBtn setTitle:@"组建球队" forState:UIControlStateNormal];
        [bottomBtn setImage:[UIImage imageNamed:@"buildBtn"] forState:UIControlStateNormal];
        [bottomBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
        [bottomBtn setBackgroundColor:[UIColor whiteColor]];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [bottomBtn addSubview:line];
    }
    return bottomBtn;
}
- (void)applyOnClick{
    if (selectArray.count ==0) {
        [self showHint:@"请选择申请的球队"];
    }
    else{
        NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSIndexPath *index in selectArray) {
            TeamModel *model = self.array[index.row];
            [ids addObject:model.teamId];
        }
        NSMutableDictionary * dic = [LVTools getTokenApp];
        [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
        [dic setValue:ids forKey:@"teamIds"];
        [self showHudInView:self.view hint:LoadingWord];
        [DataService requestWeixinAPI:starTeamApply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                [WCAlertView showAlertWithTitle:nil message:@"您的申请已提交,\n请注意查收审核结果通知!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    //
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } cancelButtonTitle:@"确定" otherButtonTitles: nil];
            }
            else{
                if ([LVTools mToString: result[@"info"]].length>0) {
                    [self showHint:result[@"info"]];
                }
                else{
                    [self showHint:ErrorWord];
                }
            }
        }];
    }
}
- (void)loginSateChange:(NSNotification*)noti{
    if ([noti.object boolValue]) {
        [self loadTeamListData];
    }
    else{
        [self.array removeAllObjects];
        [self.table reloadData];
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)hideKeyboard{
    [_searchCrol resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.title) {
    [self.navigationController.navigationBar addSubview:_segCrol];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![self.title isEqualToString:@"附近球队"]) {
    [_segCrol removeFromSuperview];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
#pragma  mark --刷新
- (void)segmentAction:(UISegmentedControl *)seg {
    
    [self hideHud];
    
    page = 1;
    if (seg.selectedSegmentIndex ==0) {
        
        self.table.tableFooterView = [self createbottomBtn];
    }
    else{
        self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }

    [self loadTeamListData];
}
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.table.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page=1;
        [weakSelf loadTeamListData];
    }];
//    if ([self.title isEqualToString:@"附近球队"]) {
    self.table.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page=page+1;
        [weakSelf loadTeamListData];
    }];
//    }
    if (![[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
        return;
    }
    [self.table.mj_header beginRefreshing];
    
}

- (void)loadTeamListData{
    if (![[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
        return;
    }
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:sportType forKey:@"sportsType"];
    //[dic setValue:university forKey:@"university"];
    //[dic setValue:sort forKey:@"sort"];
    [dic setValue:[kUserDefault objectForKey:kLocationlng] forKey:@"longitude"];
    [dic setValue:[kUserDefault objectForKey:kLocationLat] forKey:@"latitude"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    [dic setValue:@"8" forKey:@"rows"];
    if ([self.title isEqualToString:@"选择球队"]) {
        [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    }
    else{
        [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    }
    if (keywordSearch&&keywordSearch.length>0) {
        [dic setValue:keywordSearch forKey:@"keyword"];
    }
   
    NSString *optionStr = nil;
    if ([self.title isEqualToString:@"附近球队"]) {
        optionStr = nearTeamList;
    }
    else if ([self.title isEqualToString:@"选择球队"]){
        optionStr = myTeams;
    }
    else{
        if (_segCrol.selectedSegmentIndex==0) {
            optionStr = getMyTeamList;
        }
        else{
            optionStr = followTeamList;
        }
    }
     NSLog(@"%@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    request = [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        [self.table.mj_header endRefreshing];
        [self.table.mj_footer endRefreshing];
        NSLog(@"result === %@",result);
        if (page==1) {
        //不需要重置筛选条件
//        sportType = @"";
//        university = @"";
//        sort = @"0";
        [self.array removeAllObjects];
        }
        if ([result[@"status"] boolValue]) {
            NSArray *resultArr =result[@"data"];
            if ([self.title isEqualToString:@"选择球队"]) {
                resultArr = result[@"data"][@"myTeams"];
            }
            for (NSDictionary *dic in resultArr) {
                TeamModel *teamModel = [[TeamModel alloc] init];
                [teamModel setValuesForKeysWithDictionary:dic];
                if ([self.title isEqualToString:@"选择球队"]) {
                if ([teamModel.teamLevel integerValue]<1000) {
                    [self.array addObject:teamModel];
                }
                }
                else{
                [self.array addObject:teamModel];
                }
            }
            [self.table reloadData];
            if ([result[@"moreData"] boolValue]) {
                __unsafe_unretained __typeof(self) weakSelf = self;
                self.table.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                    page=page+1;
                    [weakSelf loadTeamListData];
                }];

            }
            else{
                self.table.mj_footer = nil;
            }

        }
        else{
            [self showHint:ErrorWord];
            [self.table reloadData];
        }
        if (_array.count==0) {
            self.table.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyMessage" AndText:@"还没有相关信息"];
        }
        else{
            self.table.backgroundView = nil;
        }

    }];
}
- (void)foundAteam {
    if([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]){
    WPCTeamBuildVC *vc = [[WPCTeamBuildVC alloc] init];
    vc.title = @"组建球队";
        vc.chuanBlock = ^(NSArray *arr) {
            [self loadTeamListData];
        };
        vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        LoginLoginZhViewController *loginVC =[[LoginLoginZhViewController alloc] init];
        UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nac animated:YES completion:^{
            //
        }];
    }
}

- (void)chooseAction {
    /*
    ZHNearXuanController *shaixuanVC= [[ZHNearXuanController alloc] init];
    shaixuanVC.shaixuanType = ShaixuanTypeTeam;
    shaixuanVC.chuanBlock = ^(NSArray *arr){
//        self.chuanBlock(@[[LVTools mToString:self.searSchool.text],schoolName,distance,sportType]);
        sportType = [arr objectAtIndex:3];
        university = [arr objectAtIndex:1];
        sort = [arr objectAtIndex:2];
        keywordSearch = [arr objectAtIndex:0];
        [self loadTeamListData];
    };
    [self.navigationController pushViewController:shaixuanVC animated:YES];
     */
    if ([self.title isEqualToString:@"附近球队"]) {
        [self.view endEditing:YES];
        UIActionSheet *sheet  =[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"全部",@"篮球",@"足球", nil];
        [sheet showInView:self.view];
    }
    else{
    WPCTeamHpVC *vc = [[WPCTeamHpVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.title = @"附近球队";
    [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"cell";
    WPCTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[WPCTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        if([self.title isEqualToString:@"附近球队"]){
            cell.addBtn.hidden = NO;
        }
                }
    TeamModel *model = [self.array objectAtIndex:indexPath.row];
    [cell configTeamModel:model];
    cell.rankImg.tag = 100 + indexPath.row;
    [cell.rankImg addTarget:self action:@selector(levelOnclick:) forControlEvents:UIControlEventTouchUpInside];
   
    if (![[LVTools mToString: model.creatorId] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
        cell.ownerImg.hidden = YES;
    }
    else{
        cell.ownerImg.hidden = NO;
        cell.ownerImg.tag = 200 + indexPath.row;
        [cell.ownerImg addTarget:self action:@selector(ownerOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([self.title isEqualToString:@"选择球队"]) {
        cell.decleartionLab.text = [LVTools mToString: model.slogan];
    }
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title isEqualToString:@"选择球队"]) {
        return YES;
    }
    else{
        return NO;
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
}
- (void)ownerOnClick:(UIButton*)btn{
    SingleImageController *vc= [[SingleImageController alloc] init];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(772.0/750.0))];
    vc.title = @"球队经理人说明";
    img.image = [UIImage imageNamed:@"球队经理人说明"];
    img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(772.0/750.0));
    vc.imageView = img;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)levelOnclick:(UIButton*)btn{
    TeamModel *model = [self.array objectAtIndex:btn.tag-100];
    SingleImageController *vc= [[SingleImageController alloc] init];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(415.0/750.0))];
     vc.title = @"球队标示说明";
    NSInteger teamLevel = [model.teamLevel integerValue];
    if (teamLevel>=1000) {
        img.image = [UIImage imageNamed:@"明星校队说明"];
        img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(921.0/750.0));
        vc.canApply = YES;
    }
    else if(teamLevel==0){
        img.image = [UIImage imageNamed:@"普通球队说明"];
        img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(954.0/750.0));
    }
    else{
        img.image = [UIImage imageNamed:@"校园热队伍说明"];
        img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(901.0/750.0));
    }
    vc.imageView = img;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title isEqualToString:@"选择球队"]) {
        [selectArray removeObject:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //todo
    
    if ([self.title isEqualToString:@"选择球队"]) {
        [selectArray addObject:indexPath];
    }
    else{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZHTeamDetailController *teamDetailVC=[[ZHTeamDetailController alloc] init];
    teamDetailVC.chuanBlock = ^(NSArray *arr) {
        [self loadTeamListData];
    };
    teamDetailVC.teamModel = (TeamModel*)[self.array objectAtIndex:indexPath.row];
    teamDetailVC.teamId = [LVTools mToString:teamDetailVC.teamModel.teamId];
    teamDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:teamDetailVC animated:YES];
    }
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"search");
    keywordSearch = searchBar.text;
    page = 1;
    [searchBar resignFirstResponder];
    [self loadTeamListData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 176*UISCREENWIDTH/750;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            sportType = nil;
            break;
        case 1:
            sportType = @"1";
            break;
        case 2:
            sportType = @"2";
            break;
        default:
            break;
    }
    [self loadTeamListData];
}
@end
