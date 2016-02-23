//
//  SportListController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/15.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "SportListController.h"
#import "TeamCell.h"
#import "SportZanCell.h"
#import "ZHTeamDetailController.h"
#import "WPCFriednMsgVC.h"
#import "LoginLoginZhViewController.h"
@interface SportListController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation SportListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    [self.view addSubview:self.mTableView];
    if([self.title hasSuffix:@"赞过"]){
    UIImageView *typeImag = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, 30.0, 30.0)];
    typeImag.image = [UIImage imageNamed:[NSString stringWithFormat:@"select%@_3",self.type]];
    NSLog(@"%@",[NSString stringWithFormat:@"select%@_3",self.type]);
    [self.view addSubview:typeImag];
    }
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if([self.title hasSuffix:@"赞过"]){
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 48.0)];
//            UIImageView *typeImag = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, 4, 40.0, 40.0)];
//            typeImag.image = [UIImage imageNamed:[NSString stringWithFormat:@"select%@_3",self.type]];
//            NSLog(@"%@",[NSString stringWithFormat:@"select%@_3",self.type]);
//            [lab addSubview:typeImag];
            lab.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1.00];
            lab.text = [NSString stringWithFormat:@"            %@",self.sportName];
            lab.textColor = [UIColor lightGrayColor];
            _mTableView.tableHeaderView =lab;
        }
        else{
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30.0)];
        [imageV setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@",self.title,self.type]]];
        _mTableView.tableHeaderView = imageV;
        }
        _mTableView.tableFooterView = [[UIView alloc] init];
    }
    return _mTableView;
}
#pragma mark UITableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title hasSuffix:@"赞过"]) {
        SportZanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamCell"];
        if (cell == nil) {
            cell = [[SportZanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeamCell"];
        }
        [cell configWithUserInfoDic:_dataArray[indexPath.row]];
        return cell;
    }
    else{
    TeamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamCell"];
    if (cell == nil) {
        cell = [[TeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeamCell"];
    }
    if ([self.title isEqualToString:@"球队信息"]) {
        [cell configWithTeamInfoDic:_dataArray[indexPath.row]];
    }
    else{
    [cell configWithUserInfoDic:_dataArray[indexPath.row]];
    }
    return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.title hasSuffix:@"赞过"]) {
        return 50.0;
    }
    else{
    return 35.0;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.title isEqualToString:@"球队信息"]) {
        //球队信息
        ZHTeamDetailController *msgVc =[[ZHTeamDetailController alloc] init];
        NSDictionary *tmodel =_dataArray[indexPath.row];
        msgVc.teamId = tmodel[@"teamId"];
        [self.navigationController pushViewController:msgVc animated:YES];
        
    }
    else{
        if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
        WPCFriednMsgVC *msgVc =[[WPCFriednMsgVC alloc] init];
        NSDictionary *dic = _dataArray[indexPath.row];
        msgVc.uid = dic[@"userId"];
        [self.navigationController pushViewController:msgVc animated:YES];
        }
        else{
            LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self.navigationController presentViewController:loginNav animated:YES completion:nil];
        }
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
