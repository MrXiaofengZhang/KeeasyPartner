//
//  ZHNewMesController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHNewMesController.h"
#import "ZHNewmesCell.h"
#import "WPCTimeDetailVC.h"
#import "ZHShuoModel.h"
@interface ZHNewMesController ()<UITableViewDataSource,UITableViewDelegate>{
    NSInteger pageNum;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) NSMutableArray *messages;
@end

@implementation ZHNewMesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消息";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PopView)];
    pageNum = 1;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleBordered target:self action:@selector(clearONclick)];
    self.messages = [[NSMutableArray alloc] initWithCapacity:0];
    [self.view addSubview:self.mTableView];
    [self MJRefresh];
}
- (void)PopView{
    NSArray *arr = [NSArray array];
    self.chuanBlock(arr);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark --刷新
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.mTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum=1;
        [weakSelf getUnreadMessageWithType:@"0"];
    }];
    
    self.mTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        pageNum=pageNum+1;
        [weakSelf getUnreadMessageWithType:@"1"];
    }];
    [self.mTableView.mj_header beginRefreshing];
}
#pragma mark private
- (void)getUnreadMessageWithType:(NSString*)type{
    NSDictionary *dic  =[LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setValue:type forKey:@"type"];
    [dic setValue:[NSString stringWithFormat:@"%d",(int)pageNum] forKey:@"page"];
    [dic setValue:@"10" forKey:@"rows"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getMessageAbout parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST"  completion:^(id result) {
        //
        NSLog(@"%@",result);
        [self hideHud];
        if ([type isEqualToString:@"0"]){
            [self.mTableView.mj_header endRefreshing];
        }
        else{
            [self.mTableView.mj_footer endRefreshing];
        }
        if ( [result[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            //
            if (pageNum == 1) {
                [self.messages removeAllObjects];
            }
            [self.messages addObjectsFromArray:result[@"aboutMeComments"]];
            [_mTableView reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
- (void)clearONclick{
    [self.messages removeAllObjects];
    [_mTableView reloadData];
}
- (void)moreOnClick{
    NSLog(@"更多。。。");
}
#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        
//        UIButton *moreBtn= [UIButton buttonWithType:UIButtonTypeCustom];
//        moreBtn.frame =CGRectMake(0, 0, BOUNDS.size.width, 60.0f);
//        moreBtn.titleLabel.font = Content_lbfont;
//        [moreBtn setTitle:@"查看更早信息" forState:UIControlStateNormal];
//        [moreBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [moreBtn setBackgroundColor:[UIColor whiteColor]];
//        moreBtn.layer.borderColor = BackGray_dan.CGColor;
//        moreBtn.layer.borderWidth = 1;
//        [moreBtn addTarget:self action:@selector(moreOnClick) forControlEvents:UIControlEventTouchUpInside];
//        _mTableView.tableFooterView = moreBtn;

    }
    return _mTableView;
}
#pragma mark UITableViewDataSourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idecell =@"ideCell";
    ZHNewmesCell *cell = (ZHNewmesCell*)[tableView dequeueReusableCellWithIdentifier:idecell];
    if (cell == nil) {
        cell = [[ZHNewmesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idecell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = [self.messages objectAtIndex:indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"iconPath"]]]] placeholderImage: [UIImage imageNamed:@"plhor_2"]];

    if([[LVTools mToString:[dic objectForKey:@"type"]] isEqualToString:@"0"]){
        //赞
        cell.textLabel.text = [LVTools mToString:[dic objectForKey:@"userName"]];
        cell.detailTextLabel.text = @"觉得很赞";
        cell.timeLb.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"time"] longLongValue]/1000]];
        cell.contentImg.hidden = YES;
        cell.contentLb.text = [LVTools mToString:[dic objectForKey:@"mContent"]];
    }
    else if([[LVTools mToString:[dic objectForKey:@"type"]] isEqualToString:@"1"]){
        //评论
        cell.textLabel.text = [LVTools mToString:[dic objectForKey:@"userName"]];
        cell.detailTextLabel.text = [LVTools mToString:[dic objectForKey:@"info"]];
        cell.timeLb.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"time"] longLongValue]/1000]];
        cell.contentImg.hidden = YES;
        cell.contentLb.text = [LVTools mToString:[dic objectForKey:@"mContent"]];
    }
    else{
        //回复
        cell.textLabel.text = [LVTools mToString:[dic objectForKey:@"userName"]];
        cell.detailTextLabel.text = [LVTools mToString:[dic objectForKey:@"info"]];
        cell.timeLb.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"time"] longLongValue]/1000]];
        cell.contentImg.hidden = YES;
        cell.contentLb.text = [LVTools mToString:[dic objectForKey:@"mContent"]];
    }
    
//    }
//    else{
//    cell.textLabel.text = @"上者";
//    cell.detailTextLabel.text = @"👍";
//    cell.timeLb.text = @"16:24";
//        cell.contentLb.hidden = YES;
//    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [self.messages objectAtIndex:indexPath.row];
    ZHShuoModel *model = [[ZHShuoModel alloc]init];
    model.id = [LVTools mToString:dic[@"mid"]];
    model.info = [LVTools mToString:dic[@"mContent"]];
    model.timeMachineList = dic[@"mpics"];
    model.time = [LVTools mToString:dic[@"time"]];
    WPCTimeDetailVC *wpcDetailVC =[[WPCTimeDetailVC alloc] init];
    wpcDetailVC.shouModel = model;
    [self.navigationController pushViewController:wpcDetailVC animated:YES];
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
