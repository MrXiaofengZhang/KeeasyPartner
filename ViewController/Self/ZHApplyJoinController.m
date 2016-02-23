//
//  ZHApplyJoinController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHApplyJoinController.h"
#import "ZHApplyJoinCell.h"
#import "FriendListModel.h"
#import "EmpatyView.h"
@interface ZHApplyJoinController ()<UITableViewDataSource,UITableViewDelegate>{
    NSInteger pageNum;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation ZHApplyJoinController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"新添加的战友";
    [self navgationBarLeftReturn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearOnclick:)];
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.view addSubview:self.mTableView];
    [self MJRefresh];
}
- (void)clearOnclick:(id)sender{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setObject:[LVTools mToString:[kUserDefault objectForKey:kUserId]] forKey:@"recipient"];
    [dic setObject:@"6" forKey:@"type"];
    [DataService requestWeixinAPI:delAllMessage parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [_dataArray removeAllObjects];
            [_mTableView reloadData];
           
            self.mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyMessage" AndText:@"最近没有新的战友添加您"];
           
        }
    }];

}
#pragma  mark --刷新
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.mTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum=1;
        [weakSelf loadMessages];
    }];
    
    self.mTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        pageNum=pageNum+1;
        [weakSelf loadMessages];
    }];
    [self.mTableView.mj_header beginRefreshing];
}
//获取消息
- (void)loadMessages{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"recipient"];
    [dic setObject:@"10" forKey:@"rows"];
    [dic setObject:[NSString stringWithFormat:@"%d",(int)pageNum] forKey:@"page"];
    [dic setObject:@"6" forKey:@"type"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:selfmessagecenter parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        [self.mTableView.mj_header endRefreshing];
        [self.mTableView.mj_footer endRefreshing];
        if (pageNum==1) {
            [_dataArray removeAllObjects];
        }
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            [_dataArray addObjectsFromArray:result[@"message"]];
            [self.mTableView reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
        if (_dataArray.count==0) {
            self.mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyMessage" AndText:@"最近没有新的战友添加您"];
        }
        else{
            self.mTableView.backgroundView = nil;
        }
        
    }];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mTableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   static NSString *applyCell = @"applyCell";
    ZHApplyJoinCell *cell =[tableView dequeueReusableCellWithIdentifier:applyCell];
    if (cell == nil) {
        cell = [[ZHApplyJoinCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:applyCell];
    }
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic[@"icon"]]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];;
    cell.textLabel.text = [LVTools mToString:dic[@"userName"]];
    cell.detailTextLabel.text = @"已添加您为好友";
    if([[LVTools mToString:dic[@"isreaded"]] isEqualToString:@"1"]){
    cell.timeLb.text = @"已读";
        cell.backgroundColor = [UIColor whiteColor];
                        }
    else{
        cell.timeLb.text = @"未读";
        cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    }
                        
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setObject:_dataArray[indexPath.row][@"id"] forKey:@"id"];
    [DataService requestWeixinAPI:delMsgCenter parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [_dataArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (_dataArray.count==0) {
                self.mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyMessage" AndText:@"最近没有新的战友添加您"];
            }
            else{
                self.mTableView.backgroundView = nil;
            }

        }
    }];
    
    

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
