//
//  ListViewController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/17.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "ListViewController.h"
#import "ZHSportDetailController.h"
#import "WPCFriednMsgVC.h"
#import "ZHTeamDetailController.h"
#import "TeamModel.h"
#import "GetMatchListModel.h"
#import "SWTableViewCell.h"
#import "ZHInviteCell.h"
#import "WPCTeamCell.h"
#import "ZHSportOrderCell.h"
@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SWTableViewCellDelegate>{
    NSMutableArray *dataArray;
    NSInteger rows;
    NSInteger page;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic, strong) UISegmentedControl *segCrol;


@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    page = 1;
    rows = 8;
    _segCrol = [[UISegmentedControl alloc] initWithItems:@[@"关注的人",@"关注的球队"]];
    _segCrol.frame = CGRectMake(124*propotion, 5, 500*propotion, 33);
    _segCrol.selectedSegmentIndex = 0;
    _segCrol.backgroundColor = [UIColor whiteColor];
    [_segCrol addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    _segCrol.tintColor = SystemBlue;

    [self navgationBarLeftReturn];
    [self.view addSubview:self.mTableView];
    [self MJRrefresh];
    
}
- (void)MJRrefresh{
    if ([self.title isEqualToString:@"我的粉丝"]||[self.title isEqualToString:@"我的关注"]||[self.title isEqualToString:@"球队粉丝"]) {
        
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.mTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [dataArray removeAllObjects];
        page = 1;
        [weakSelf.mTableView reloadData];
        [weakSelf loadData];
        
    }];
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _mTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (request != nil) {
            
        }
        else{
            page++;
            [weakSelf loadData];
        }
    }];
    [_mTableView.mj_header beginRefreshing];
    }
    else{
        [self loadData];
    }
}


- (void)loadData{
    NSString *optionStr = nil;
    if ([self.title isEqualToString:@"我的关注"]) {
        if (_segCrol.selectedSegmentIndex==0) {
            optionStr = followPersonList;
        }
        else{
            optionStr = followTeamList;
        }
        [self showHudInView:self.view hint:LoadingWord];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
        [dic setValue:[kUserDefault valueForKey:kLocationlng] forKey:@"longitude"];
        [dic setValue:[kUserDefault valueForKey:kLocationLat] forKey:@"latitude"];
        [dic setValue:[NSNumber numberWithInteger:page] forKey:@"page"];
        [dic setValue:[NSNumber numberWithInteger:rows] forKey:@"rows"];
        [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self.mTableView.mj_header endRefreshing];
            [self.mTableView.mj_footer endRefreshing];
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                if (dataArray==nil) {
                    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
                }
                [dataArray removeAllObjects];
                if (_segCrol.selectedSegmentIndex==0) {
                    for (NSDictionary *dic in result[@"data"]) {
                        FriendListModel *model = [[FriendListModel alloc] init];
                        if(![dic isKindOfClass:[NSNull class]]){
                        [model setValuesForKeysWithDictionary:dic];
                        [dataArray addObject:model];
                        }
                    }
                }
                else{
                for (NSDictionary *dic in result[@"data"]) {
                    TeamModel *teamModel = [[TeamModel alloc] init];
                    [teamModel setValuesForKeysWithDictionary:dic];
                    [dataArray addObject:teamModel];
                }
                }
                [self.mTableView reloadData];
                if ([result[@"moreData"] boolValue]) {
                    self.mTableView.mj_footer.hidden = NO;
                }
                else{
                    self.mTableView.mj_footer.hidden = YES;
                }

            }
            else{
                [self showHint:@"请重试"];
            }
        }];
    }
    else if([self.title isEqualToString:@"我的粉丝"]){
        optionStr = followMeList;
        [self showHudInView:self.view hint:LoadingWord];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
        [dic setValue:[kUserDefault valueForKey:kLocationlng] forKey:@"longitude"];
        [dic setValue:[kUserDefault valueForKey:kLocationLat] forKey:@"latitude"];
        [dic setValue:[NSNumber numberWithInteger:page] forKey:@"page"];
        [dic setValue:[NSNumber numberWithInteger:rows] forKey:@"rows"];
        [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self.mTableView.mj_header endRefreshing];
            [self.mTableView.mj_footer endRefreshing];
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                if (dataArray==nil) {
                    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
                }
                [dataArray removeAllObjects];
                for (NSDictionary *dic in result[@"data"]) {
                    FriendListModel *model = [[FriendListModel alloc] init];
                    [model setValuesForKeysWithDictionary:dic];
                    [dataArray addObject:model];
                }
                [self.mTableView reloadData];
                if ([result[@"moreData"] boolValue]) {
                    self.mTableView.mj_footer.hidden = NO;
                }
                else{
                    self.mTableView.mj_footer.hidden = YES;
                }

            }
            else{
                [self showHint:@"请重试"];
            }
        }];
    }
    else if([self.title isEqualToString:@"我的赛事"]){
        optionStr = myMatches;
        [self showHudInView:self.view hint:LoadingWord];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
//        [dic setValue:[kUserDefault valueForKey:kLocationlng] forKey:@"longitude"];
//        [dic setValue:[kUserDefault valueForKey:kLocationLat] forKey:@"latitude"];
//        [dic setValue:[NSNumber numberWithInteger:page] forKey:@"page"];
//        [dic setValue:[NSNumber numberWithInteger:rows] forKey:@"rows"];
        [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                if (dataArray==nil) {
                    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
                }
                [dataArray removeAllObjects];
                [dataArray addObjectsFromArray:result[@"data"][@"matches"]];
                [self.mTableView reloadData];
            }
            else{
                [self showHint:@"请重试"];
            }
        }];

    }
    else if([self.title isEqualToString:@"我的收藏"]){
        optionStr = myCollections;
        [self showHudInView:self.view hint:LoadingWord];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
        [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                if (dataArray==nil) {
                    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
                }
                [dataArray removeAllObjects];
                [dataArray addObjectsFromArray:result[@"data"][@"collections"]];
                [self.mTableView reloadData];
            }
            else{
                [self showHint:@"请重试"];
            }
        }];
    }
    else if ([self.title isEqualToString:@"球队粉丝"]){
        [self showHudInView:self.view hint:LoadingWord];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.teamId forKey:@"teamId"];
        [dic setValue:[kUserDefault valueForKey:kLocationlng] forKey:@"longitude"];
        [dic setValue:[kUserDefault valueForKey:kLocationLat] forKey:@"latitude"];
        [dic setValue:[NSNumber numberWithInteger:page] forKey:@"page"];
        [dic setValue:[NSNumber numberWithInteger:rows] forKey:@"rows"];
        [DataService requestWeixinAPI:TeamFansList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self.mTableView.mj_header endRefreshing];
            [self.mTableView.mj_footer endRefreshing];
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                if (dataArray==nil) {
                    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
                }
                [dataArray removeAllObjects];
                for (NSDictionary *dic in result[@"data"]) {
                    FriendListModel *model = [[FriendListModel alloc] init];
                    [model setValuesForKeysWithDictionary:dic];
                    [dataArray addObject:model];
                }
                [self.mTableView reloadData];
                if ([result[@"moreData"] boolValue]) {
                    self.mTableView.mj_footer.hidden = NO;
                }
                else{
                    self.mTableView.mj_footer.hidden = YES;
                }

            }
            else{
                [self showHint:@"请重试"];
            }
        }];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.title isEqualToString:@"我的关注"]) {
        [self.navigationController.navigationBar addSubview:_segCrol];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.title isEqualToString:@"我的关注"]) {
        [_segCrol removeFromSuperview];
    }
}
- (void)segmentAction:(UISegmentedControl *)seg {
    [self loadData];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        if ([self.title isEqualToString:@"我的关注"]) {
//        UISearchBar *search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 44.0)];
//        search.delegate = self;
//        search.placeholder = @"搜索";
//        [self.view addSubview:search];
            _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
        }
        else{
            _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
        }
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.tableFooterView = [[UIView alloc] init];
    }
    return _mTableView;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if ([self.title isEqualToString:@"我的关注"]) {
//        return BOUNDS.size.width*(80.0/750.0)+mygap;
//        
//    }
//    else{
//        return 0.0;
//    }
//}
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(80.0/750.0)) ];
//    if (section == 0) {
//        [imageView setImage:[UIImage imageNamed:@"关注wo_02"]];
//    }
//    else{
//    [imageView setImage:[UIImage imageNamed:@"关注wo_07"]];
//    }
//    return imageView;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    if ([self.title isEqualToString:@"我的关注"]) {
//        return BOUNDS.size.width*(45.0/750.0);
//    }
//    else{
//        return 0.0;
//    }
//
//}
//- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(45.0/750.0)) ];
//    [imageView setImage:[UIImage imageNamed:@"关注wo_06"]];
//    return imageView;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title isEqualToString:@"我的赛事"]||[self.title isEqualToString:@"我的收藏"]) {
        static NSString *idestr= @"ZHSportOrderCell";
        ZHSportOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:idestr];
        if (cell == nil) {
            cell = [[ZHSportOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idestr];
            //cell.delegate = self;
            if ([self.title isEqualToString:@"我的收藏"]) {
                cell.sportStatus.hidden = YES;
                cell.stateLb.hidden = YES;
            }
        }
        [cell configMatchDic:dataArray[indexPath.row]];
        //cell.rightUtilityButtons = [self rightButtons];
        return cell;
    }
//    else if([self.title isEqualToString:@"我的收藏"]){
//        static NSString *idestr= @"ZHSportOrderCell";
//        ZHSportOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:idestr];
//        if (cell == nil) {
//            cell = [[ZHSportOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idestr];
//            cell.delegate = self;
//        }
//        [cell configMatchDic:dataArray[indexPath.row]];
//        cell.rightUtilityButtons = [self rightButtons];
//        return cell;
//    }
    else if([self.title isEqualToString:@"我的粉丝"]){
        static NSString *idestr= @"ZHInviteCell";
        ZHInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:idestr];
        if (cell == nil) {
            cell = [[ZHInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idestr menbertype:MenberNearByType];
        }
        [cell configModel:[dataArray objectAtIndex:indexPath.row]];
        //cell.rightUtilityButtons = [self rightButtons];
        return cell;
    }
    else{
        if (_segCrol.selectedSegmentIndex==0) {
            static NSString *idestr= @"ZHInviteCell";
            ZHInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:idestr];
            if (cell == nil) {
                cell = [[ZHInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idestr menbertype:MenberNearByType];
            }
            [cell configModel:[dataArray objectAtIndex:indexPath.row]];
            //cell.rightUtilityButtons = [self rightButtons];
            return cell;
        }
        else{
            static NSString *idestr= @"WPCTeamCell";
            WPCTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:idestr];
            if (cell == nil) {
                cell = [[WPCTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idestr];
                //cell.delegate = self;
            }
            //cell.rightUtilityButtons = [self rightButtons];
            cell.ownerImg.hidden = YES;
            [cell configTeamModel:dataArray[indexPath.row]];
            return cell;
        }
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if([self.title isEqualToString:@"我的关注"]){
        if (_segCrol.selectedSegmentIndex == 0) {
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor lightGrayColor] title:@"取消关注"];
            [rightUtilityButtons sw_addUtilityButtonWithColor:color_red_dan title:@"添加好友"];
        }
        else{
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor lightGrayColor] title:@"取消关注"];
            //[rightUtilityButtons sw_addUtilityButtonWithColor:color_red_dan title:@"添加好友"];
        }
    }
    else if([self.title isEqualToString:@"我的粉丝"]){
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor orangeColor]
                                                    title:@"关注"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.99f green:0.01f blue:0.01f alpha:1.0]
                                                    title:@"添加好友"];
    }
    else{
        
    }
    
    return rightUtilityButtons;
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
     if([self.title isEqualToString:@"我的关注"]){
         if (_segCrol.selectedSegmentIndex == 0) {
             //
             if(index==0){
                 //取消关注球队
             }
             else{
                 //取消关注球队
             }
         }
         else{
             //取消关注球队
         }
     }
     else if([self.title isEqualToString:@"我的粉丝"]){
         if (index == 0) {
             //
         }
         else{
             //
         }
     }
     else{
         //
     }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title isEqualToString:@"我的赛事"]||[self.title isEqualToString:@"我的收藏"]) {
        
        return 100.0;
    }
    else if([self.title isEqualToString:@"我的粉丝"]){
       
        return 90.0f;;
    }
    else{
        if (_segCrol.selectedSegmentIndex==0) {
            return 90.0f;
        }
        else{
            return 176*UISCREENWIDTH/750;
        }
    }
}
- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title isEqualToString:@"我的关注"]) {
    return @"取消关注";
    }
    else if([self.title isEqualToString:@"我的粉丝"]){
        return @"关注";
    }
    else{
        return @"删除";
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title isEqualToString:@"我的关注"]||[self.title isEqualToString:@"我的粉丝"]||[self.title isEqualToString:@"我的粉丝"]||[self.title isEqualToString:@"球队粉丝"]) {
        return NO;
    }
    else{
    return YES;
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title isEqualToString:@"我的关注"]) {
        [self showHint:@"已取消关注"];
            }
    else if([self.title isEqualToString:@"我的粉丝"]){
        [self showHint:@"已关注"];
    }
    else if([self.title isEqualToString:@"我的收藏"]){
        NSDictionary *infodic = [dataArray objectAtIndex:indexPath.row];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:infodic[@"id"] forKey:@"matchId"];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
        [DataService requestWeixinAPI:deleteMatchCollect parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                [self showHint:@"已删除"];
                [dataArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            else{
                if ([LVTools mToString:result[@"info"]].length>0) {
                    [self showHint:[LVTools mToString:result[@"info"]]];
                }
                else{
                    [self showHint:ErrorWord];
                }
            }
        }];
    }
    else if([self.title isEqualToString:@"我的赛事"]){
        NSDictionary *infodic = [dataArray objectAtIndex:indexPath.row];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:infodic[@"id"] forKey:@"id"];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
        [DataService requestWeixinAPI:hideMatch parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                [self showHint:@"已删除"];
                [dataArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            else{
                if ([LVTools mToString:result[@"info"]].length>0) {
                    [self showHint:[LVTools mToString:result[@"info"]]];
                }
                else{
                    [self showHint:ErrorWord];
                }
            }
        }];
    }
    else{
    [self showHint:@"已删除"];
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.title isEqualToString:@"我的关注"]) {
        if (self.segCrol.selectedSegmentIndex==0) {
            FriendListModel *model = [dataArray objectAtIndex:indexPath.row];
            WPCFriednMsgVC *msgVc =[[WPCFriednMsgVC alloc] init];
            msgVc.uid = [LVTools mToString:model.userId];
            [self.navigationController pushViewController:msgVc animated:YES];
        }
        else{
            TeamModel *model = [dataArray objectAtIndex:indexPath.row];
            ZHTeamDetailController *msgVc =[[ZHTeamDetailController alloc] init];
            msgVc.teamModel = model;
            msgVc.teamId = model.teamId;
            [self.navigationController pushViewController:msgVc animated:YES];

        }
    }
    else if([self.title isEqualToString:@"我的粉丝"]){
        FriendListModel *model = [dataArray objectAtIndex:indexPath.row];
        WPCFriednMsgVC *msgVc =[[WPCFriednMsgVC alloc] init];
        msgVc.uid = model.userId;
        [self.navigationController pushViewController:msgVc animated:YES];
    }
    else{
        NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
        ZHSportDetailController *sportDVC =[[ZHSportDetailController alloc] init];
        GetMatchListModel *model = [[GetMatchListModel alloc] init];
        [model setValuesForKeysWithDictionary:dic];
        sportDVC.matchInfo = model;
        sportDVC.isMyMatch = YES;
        [self.navigationController pushViewController:sportDVC animated:YES];
    }
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
