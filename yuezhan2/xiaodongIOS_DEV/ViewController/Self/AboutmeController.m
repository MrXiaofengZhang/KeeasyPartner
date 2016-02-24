//
//  AboutmeController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/2/23.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "AboutmeController.h"
#import "WPCCommentCell.h"
@interface AboutmeController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *commentArray;
    NSMutableArray *replyArray;
    NSInteger page;
    NSInteger rows;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UISegmentedControl *segContrl;
@end

@implementation AboutmeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
}
#pragma mark getter
- (UISegmentedControl*)segContrl{
    if (_segContrl == nil) {
        _segContrl = [[UISegmentedControl alloc] initWithItems:@[@"回复我的",@"我的评论"]];
        _segContrl.frame = CGRectMake(124*propotion, 5, 500*propotion, 33);
        _segContrl.selectedSegmentIndex = 0;
        _segContrl.backgroundColor = [UIColor whiteColor];
        [_segContrl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        _segContrl.tintColor = SystemBlue;

    }
    return _segContrl;
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
    }
    return _mTableView;
}
#pragma mark private
- (void)segmentAction:(UISegmentedControl *)seg {
    [self loadData];
}
- (void)loadData{
    NSString *optionStr = nil;
    if (_segContrl.selectedSegmentIndex==0) {
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
            if (commentArray==nil) {
                commentArray = [[NSMutableArray alloc] initWithCapacity:0];
            }
            [commentArray removeAllObjects];
            if (_segContrl.selectedSegmentIndex==0) {
//                for (NSDictionary *dic in result[@"data"]) {
//                    FriendListModel *model = [[FriendListModel alloc] init];
//                    if(![dic isKindOfClass:[NSNull class]]){
//                        [model setValuesForKeysWithDictionary:dic];
//                        [dataArray addObject:model];
//                    }
//                }
            }
            else{
//                for (NSDictionary *dic in result[@"data"]) {
//                    TeamModel *teamModel = [[TeamModel alloc] init];
//                    [teamModel setValuesForKeysWithDictionary:dic];
//                    [dataArray addObject:teamModel];
//                }
            }
            [self.mTableView reloadData];
            if ([result[@"moreData"] boolValue]) {
                
            }
            else{
                self.mTableView.mj_footer = nil;
            }
            
        }
        else{
            [self showHint:@"请重试"];
        }
    }];

}
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WPCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WPCCommentCell"];
    if (cell == nil) {
        cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WPCCommentCell" commentType:WPCAppointCommentType];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
