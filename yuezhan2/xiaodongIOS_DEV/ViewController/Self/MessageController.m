//
//  MessageController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/18.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "MessageController.h"
#import "ZHSportDetailController.h"
#import "ZHTeamDetailController.h"
#import "TeamModel.h"
#import "ZHApplyJoinCell.h"
#import "EmpatyView.h"
@interface MessageController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *dataArray;
}
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    [self.view addSubview:self.mTableView];
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self loadMessageData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleBordered target:self action:@selector(clear)];
}
- (void)loadMessageData{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:xdgetMyMessage parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"final result === %@",result);
        [self hideHud];
        if ([result[@"status"] boolValue]) {
            [dataArray removeAllObjects];
            [dataArray addObjectsFromArray:result[@"data"][@"messages"]];
            [self.mTableView reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
- (void)clear{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setObject:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [DataService requestWeixinAPI:delAllMessage parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if ([result[@"status"] boolValue]) {
            [dataArray removeAllObjects];
            [_mTableView reloadData];
            if (dataArray.count==0) {
                self.mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyMessage" AndText:@"还没有新消息"];
            }
            else{
                self.mTableView.backgroundView = nil;
            }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
    _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
    _mTableView.dataSource = self;
    _mTableView.delegate = self;
    _mTableView.tableFooterView = [[UIView alloc] init];
    _mTableView.allowsSelection = NO;
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
 }
    return _mTableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHApplyJoinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mesCell"];
    if (cell == nil) {
        cell = [[ZHApplyJoinCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"mesCell"];
    }
    [cell configDic:dataArray[indexPath.row]];
    [cell.agreeBtn addTarget:self action:@selector(okclick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.rejectBtn addTarget:self action:@selector(refu:) forControlEvents:UIControlEventTouchUpInside];
    cell.agreeBtn.tag = 100 + indexPath.row;
    cell.rejectBtn.tag = 200 + indexPath.row;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60.0;
}
- (void)okclick:(UIButton*)btn{
    [WCAlertView showAlertWithTitle:@"是否确定同意加入球队？" message:nil customizationBlock:^(WCAlertView *alertView) {
        //
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        //
        if(buttonIndex==1){
            [self doWitOption:YES Info:dataArray[btn.tag-100]];
        }
            } cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
}
- (void)refu:(UIButton*)btn{
    [WCAlertView showAlertWithTitle:@"是否确定拒绝加入球队？" message:nil customizationBlock:^(WCAlertView *alertView) {
        //
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        //
        if(buttonIndex==1){
            [self doWitOption:NO Info:dataArray[btn.tag-200]];
        }
        } cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
}
- (void)doWitOption:(BOOL)isagree Info:(NSDictionary*)infoDic{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:infoDic[@"receiveId"]  forKey:@"receiveId"];
    [dic setValue:infoDic[@"sendId"] forKey:@"sendId"];
    [dic setValue:infoDic[@"msgType"] forKey:@"msgType"];
    [dic setValue:infoDic[@"extend"] forKey:@"extend"];
    if(isagree){
    [dic setValue:[NSNumber numberWithInt:1] forKey:@"operation"];
    }
    else{
    [dic setValue:[NSNumber numberWithInt:0] forKey:@"operation"];
    }
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:xdMessageOperation parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"final result === %@",result);
        [self hideHud];
        if ([result[@"status"] boolValue]) {
            [self showHint:@"操作成功"];
            [self loadMessageData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row%3==0) {
//        ZHTeamDetailController *msgVc =[[ZHTeamDetailController alloc] init];
//        TeamModel *tmodel =[[TeamModel alloc] init];
//        tmodel.id = [LVTools mToString:@"120"];
//        tmodel.teamName = @"无所不在";
//        msgVc.teamModel = tmodel;
//        msgVc.teamId = tmodel.id;
//        [self.navigationController pushViewController:msgVc animated:YES];
//    }
//    else if(indexPath.row%3==1){
//        ZHTeamDetailController *msgVc =[[ZHTeamDetailController alloc] init];
//        TeamModel *tmodel =[[TeamModel alloc] init];
//        tmodel.id = [LVTools mToString:@"120"];
//        tmodel.teamName = @"无所不在";
//        msgVc.teamModel = tmodel;
//        msgVc.teamId = tmodel.id;
//        [self.navigationController pushViewController:msgVc animated:YES];
//    }
//    else{
//        ZHSportDetailController *sportDVC =[[ZHSportDetailController alloc] init];
//        [self.navigationController pushViewController:sportDVC animated:YES];
//    }
//}
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
