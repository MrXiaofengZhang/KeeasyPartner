//
//  TeamResultController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/20.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "TeamResultController.h"
#import "TeamModel.h"
#import "TeamResultCell.h"
#import "ZHTeamDetailController.h"
@interface TeamResultController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *teamArray;//战队列表
    
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UIImageView *imgBtn;
@end

@implementation TeamResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"球队战绩";
    [self navgationBarLeftReturn];
    [self loadSignInfo];
    [self.view addSubview:self.mTableView];
}
- (void)loadSignInfo{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.matchId forKey:@"matchId"];
    //[dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getTeamMatchRecord parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            if (teamArray == nil) {
                teamArray = [[NSMutableArray alloc] initWithCapacity:0];
            }
            [teamArray addObjectsFromArray:result[@"data"][@"matchTeams"]];
            [self.mTableView reloadData];
            [self.imgBtn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,result[@"data"][@"path"]]] placeholderImage:[UIImage imageNamed:@"match_plo"]];
        } else {
            [self showHint:ErrorWord];
        }
    }];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(280.0/750.0)+30*2)];
        headView.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.00];
        
        self.imgBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(280.0/750.0))];
        self.imgBtn.backgroundColor = [UIColor redColor];
        [self.imgBtn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,self.record[@"path"]]] placeholderImage:[UIImage imageNamed:@"match_plo"]];
        //NSLog(@"%@",[NSString stringWithFormat:@"%@%@",preUrl,self.matchInfo.matchShow]);
        [headView addSubview:self.imgBtn];
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.imgBtn.bottom, BOUNDS.size.width, BOUNDS.size.width*(65.0/750.0))];
        [imageV setImage:[UIImage imageNamed:[NSString stringWithFormat:@"球队信息%@",self.type]]];
        [headView addSubview:imageV];
        
        UIImageView *imageV1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, imageV.bottom, BOUNDS.size.width, BOUNDS.size.width*(58.0/750.0))];
        [imageV1 setImage:[UIImage imageNamed:@"球队详情页-比赛战绩"]];
        [headView addSubview:imageV1];
//        UILabel *lb1 =[[UILabel alloc] initWithFrame:CGRectMake(0, self.imgBtn.bottom, BOUNDS.size.width, BOUNDS.size.width*(70.0/750.0))];
//        lb1.backgroundColor = [UIColor clearColor];
//        lb1.text = @" 我的球队";
//        lb1.font = Btn_font;
//        [headView addSubview:lb1];
//        
//        
//        UILabel *lb2 =[[UILabel alloc] initWithFrame:CGRectMake(0, _teamCollectView.bottom, BOUNDS.size.width, BOUNDS.size.width*(70.0/750.0))];
//        lb2.backgroundColor = [UIColor clearColor];
//        lb2.text = @" 已选队友";
//        lb2.font = Btn_font;
//        [headView addSubview:lb2];
        _mTableView.tableHeaderView = headView;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mTableView;
}
#pragma mark UITableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [teamArray count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idece =@"idecell";
    TeamResultCell *cell =[tableView dequeueReusableCellWithIdentifier:idece];
    if (cell == nil) {
        cell = [[TeamResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idece];
    }
    [cell configWithTeamInfoDic:[teamArray objectAtIndex:indexPath.row]];
    if ([self.record[@"info"] isEqualToString:@"正在比赛"]||[LVTools mToString:self.record[@"info"]].length==0) {
          cell.rankLb.hidden = YES;
            }
    else{
        cell.rankLb.text = [NSString stringWithFormat:@"%d",(int)(indexPath.row+1)];
        if (indexPath.row<4) {
            cell.rankLb.backgroundColor = color_red_dan;
        }
        else{
            cell.rankLb.backgroundColor = [UIColor lightGrayColor];
        }
    }
        return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZHTeamDetailController *msgVc =[[ZHTeamDetailController alloc] init];
    NSDictionary *tmodel =teamArray[indexPath.row-1];
    msgVc.teamId = tmodel[@"teamId"];
    [self.navigationController pushViewController:msgVc animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
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
