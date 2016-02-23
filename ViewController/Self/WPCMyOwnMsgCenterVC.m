//
//  WPCMyOwnMsgCenterVC.m
//  yuezhan123
//
//  Created by admin on 15/5/20.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCMyOwnMsgCenterVC.h"
#import "ZHApplyJoinCell.h"
#import "EmpatyView.h"
@interface WPCMyOwnMsgCenterVC () <UITableViewDataSource,UITableViewDelegate>
{
    CGFloat cellheight;
    NSMutableArray *dataArray;
    NSInteger pageNum;
}
@property (nonatomic, strong) UITableView *tableview;

@end

@implementation WPCMyOwnMsgCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fakeTheNavigationBar];
    [self navgationBarLeftReturn];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleBordered target:self action:@selector(clear)];
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64) style:UITableViewStylePlain];
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    pageNum = 0;
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    _tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableview];
    [self MJRefresh];
}
- (void)clear{
    
}
#pragma  mark --刷新
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.tableview.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum=1;
        [weakSelf loadMessages];
    }];
    
    self.tableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        pageNum=pageNum+1;
        [weakSelf loadMessages];
    }];
    [self.tableview.mj_header beginRefreshing];
}
//获取消息
- (void)loadMessages{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setObject:@"10" forKey:@"rows"];
    [dic setObject:[NSString stringWithFormat:@"%d",(int)pageNum] forKey:@"page"];
    NSLog(@"%@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:selfmessagecenter parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        [self.tableview.mj_header endRefreshing];
        [self.tableview.mj_footer endRefreshing];
        if (pageNum==1) {
            [dataArray removeAllObjects];
        }
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            [dataArray addObjectsFromArray:result[@"message"]];
            [self.tableview reloadData];
                   }
        else{
            [self showHint:ErrorWord];
        }
        if (dataArray.count==0) {
            self.tableview.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyMessage" AndText:@"还没有新消息"];
        }
        else{
            self.tableview.backgroundView = nil;
        }

    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setObject:dataArray[indexPath.row][@"id"] forKey:@"id"];
    [DataService requestWeixinAPI:delMsgCenter parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [dataArray removeObjectAtIndex:indexPath.row];
            [_tableview reloadData];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    ZHApplyJoinCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ZHApplyJoinCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.timeLb.hidden = NO;
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
   cell.imageView.layer.masksToBounds = YES;
    if([[LVTools mToString:dic[@"source"]] isEqualToString:@"-1"]){
        cell.imageView.image = [UIImage imageNamed:@"systemIcon"];
    }
    else{
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic[@"icon"]]]] placeholderImage:[UIImage imageNamed:@"systemIcon"]];
    }
    if([[LVTools mToString:dic[@"isreaded"]] isEqualToString:@"0"]){
        cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
        cell.timeLb.text = @"未读";
    }
    else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.timeLb.text = @"已读";
    }
    cell.textLabel.text = [LVTools mToString:dic[@"userName"]];
    if (cell.textLabel.text.length == 0) {
        cell.textLabel.text = @"系统消息";
    }
    cell.detailTextLabel.textColor = UIColorFromRGB(150, 150, 150);
    cell.detailTextLabel.text = [LVTools mToString:dic[@"content"]];
    if ([[LVTools mToString:dataArray[indexPath.row][@"type"]] isEqualToString:@"4"]) {
        [cell.agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        cell.timeLb.hidden = YES;
        cell.agreeBtn.backgroundColor = NavgationColor;
        cell.agreeBtn.titleLabel.textColor = [UIColor whiteColor];
        cell.agreeBtn.layer.cornerRadius = 4;
        cell.agreeBtn.titleLabel.font = Btn_font;
        cell.agreeBtn.layer.masksToBounds = YES;
        cell.agreeBtn.hidden = NO;
        cell.agreeBtn.tag = indexPath.row+1000;
        [cell.agreeBtn addTarget:self action:@selector(agreeAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.agreeBtn.hidden = YES;
    }
    return cell;
}
- (void)agreeAction:(UIButton *)sender {
    NSInteger index = sender.tag - 1000;
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setObject:[LVTools mToString:dataArray[index][@"jump"]] forKey:@"id"];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
    [dic setValue:[LVTools mToString:dataArray[index][@"userName"]] forKey:@"userName"];
    NSLog(@"dic == %@",dic);
    [DataService requestWeixinAPI:agreeJoin parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"result === %@",result);
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [self showHint:@"您已同意成员的申请"];
            [dataArray removeObjectAtIndex:index];
            [_tableview reloadData];

//            [sender setTitle:@"已同意" forState:UIControlStateNormal];
//            sender.backgroundColor = [UIColor grayColor];
//            sender.enabled = NO;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)fakeTheNavigationBar
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"清空" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor clearColor]];
    [btn1 addTarget:self action:@selector(clearClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"消息中心";
    
//    UIView *naviViwe = [LVTools selfNavigationWithColor:[UIColor whiteColor] leftBtn:btn rightBtn:btn1 titleLabel:titleLab];
//    [self.view addSubview:naviViwe];
}
- (void)clearClick{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setObject:[LVTools mToString:[kUserDefault objectForKey:kUserId]] forKey:@"recipient"];
    [DataService requestWeixinAPI:delAllMessage parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [dataArray removeAllObjects];
            [_tableview reloadData];
            if (dataArray.count==0) {
                self.tableview.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyMessage" AndText:@"还没有新消息"];
            }
            else{
                self.tableview.backgroundView = nil;
            }

        }
    }];

}
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
