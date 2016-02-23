//
//  WPCMenberListVC.m
//  yuezhan123
//
//  Created by admin on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCMenberListVC.h"
#import "ZHInviteCell.h"
#import "TeamModel.h"
#import "FriendListModel.h"
#import "WPCFriednMsgVC.h"
#import "WPCMyOwnVC.h"
#import "LoginLoginZhViewController.h"
@interface WPCMenberListVC () <UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>

@property (nonatomic, strong)UITableView *table;


@end

@implementation WPCMenberListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datasource = [[NSMutableArray alloc] initWithCapacity:0];
    [self navgationBarLeftReturn];
    [self initialInterface];
    [self loadPlayersList];
}
//退出战队
- (void)quitTeamWithUid:(NSString*)uid With:(completionHandle)block{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[LVTools mToString:self.teamModel.teamId]  forKey:@"teamId"];
    [dic setValue:[LVTools mToString:uid] forKey:@"userId"];
    request = [DataService requestWeixinAPI:delPlayer parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:block];
}

- (void)initialInterface {
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    UIView *view = [[UIView alloc] init];
    _table.tableFooterView = view;
    
    [self.view addSubview:_table];
    
}
#pragma mark -- tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellid";
    ZHInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[ZHInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID menbertype:self.detailType];
    }
    cell.tag = indexPath.row;
    NearByModel *model =self.datasource[indexPath.row];
    [cell configModel:model];
    if (indexPath.row == 0) {
        cell.statusLab.hidden = NO;
    }
    if (self.detailType == MenberTeamType) {
        if (_isTeamLeader) {
            cell.delegate = self;
            if (![[LVTools mToString:model.userId] isEqualToString:[LVTools mToString:self.teamModel.creatorId]]) {
                cell.rightUtilityButtons = [self rightButtons];
            }
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%d",(int)(indexPath.row));
    FriendListModel *model = [_datasource objectAtIndex:indexPath.row];
    NSLog(@"uid ====== %@",model.userId);
    if ([[LVTools mToString:model.userId] isEqualToString:[LVTools mToString:[kUserDefault valueForKey:kUserId]]]) {
        WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
        vc.basicVC = NO;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
            WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
            
            vc.uid = model.userId;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
        }

       
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.99f green:0.01f blue:0.01f alpha:1.0]
                                                title:@"移出球队"];
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    
    if (_detailType == MenberTeamType) {
        if (index == 0) {
            //移除战队
            FriendListModel *model = [self.datasource objectAtIndex:cell.tag];
            [self quitTeamWithUid:model.userId With:^(id result) {
                [self hideHud];
                NSLog(@"%@",result);
                if ([result[@"status"] boolValue]) {
                    [self showHint:@"退出成功"];
                    [self.datasource removeObject:model];
                    [_table reloadData];
                    self.chuanBlock(self.datasource);
                }
                else{
                    if (result[@"info"]) {
                        [self showHint:result[@"info"]];
                    }
                    else{
                    [self showHint:ErrorWord];
                    }
                }
                
            }];
        }
    }
    
}
//加载战队成员
- (void)loadPlayersList{
    //    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[LVTools mToString:self.teamModel.teamId]  forKey:@"id"];
    [dic setValue:self.teamModel.creatorId forKey:@"creatorId"];
    [dic setValue:[kUserDefault objectForKey:kLocationlng] forKey:@"longitude"];
    [dic setValue:[kUserDefault objectForKey:kLocationLat] forKey:@"latitude"];
    NSLog(@"%@",dic);
    
    request = [DataService requestWeixinAPI:getPlayerList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        //        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            [_datasource removeAllObjects];
            for (NSDictionary *dic in result[@"data"]) {
                FriendListModel *model = [[FriendListModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [_datasource addObject:model];
            }
            [_table reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}

#pragma mark -- tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kFriendCellHeight;
}


@end
