//
//  PersonSignController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/3/21.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "PersonSignController.h"
#import "ZHTeamDetaillCell.h"
#import "StateController.h"
#import "GetMatchListModel.h"
@interface PersonSignController ()<UITableViewDataSource,UITableViewDelegate>{
    UIButton *selectBtn;
    UITextField *partmentTf;//学院
    UITextField *hospatolTf;//系
    UIButton *btn;
}
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation PersonSignController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    [self.view addSubview:self.mTableView];
    btn =[[UIButton alloc] initWithFrame:CGRectMake(0, self.mTableView.bottom, BOUNDS.size.width, 44.0)];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    btn.enabled = NO;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(bomingOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)bomingOnClick{
    
}
#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0-44.0) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 80)];
        UIButton *protocolBtn = [[UIButton alloc] initWithFrame:CGRectMake((BOUNDS.size.width-200)/2.0, 20, 200, 40)];
        [protocolBtn setTitle:@"《校动平台赛事免责确认书》" forState:UIControlStateNormal];
        protocolBtn.titleLabel.font = Btn_font;
        [protocolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [protocolBtn addTarget:self action:@selector(protocolClick) forControlEvents:UIControlEventTouchUpInside];
        
        [bottomView addSubview:protocolBtn];
        selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(protocolBtn.left-20, 30, 20, 20)];
        selectBtn.backgroundColor = [UIColor redColor];
        [selectBtn setImage:[UIImage imageNamed:@"selecCheck"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"selecedCheck"] forState:UIControlStateSelected];
        [selectBtn addTarget:self action:@selector(selectonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:selectBtn];
        _mTableView.tableFooterView = bottomView;
    }
    return _mTableView;
}
- (void)selectonClick:(UIButton*)sender{
    sender.selected = !sender.selected;
    
}
- (void)protocolClick{
    StateController *vc =[[StateController alloc] init];
    vc.chuanBlock = ^(NSArray *arr){
        selectBtn.selected = YES;
        if ([self canSign]) {
            btn.selected = YES;
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (BOOL)canSign{
    return YES;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==4) {
        return 4;
    }
    else{
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHTeamDetaillCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCell"];
    if (cell == nil) {
        cell = [[ZHTeamDetaillCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"personCell"];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"运动类型:";
        NSString *sportType  =[LVTools mToString: self.matchInfo.type];
        if ([sportType isEqualToString:@"1"]) {
            cell.detailTextLabel.text = @"篮球";
        }
        else if([sportType isEqualToString:@"2"]){
            cell.detailTextLabel.text = @"足球";
        }
        else{
            cell.detailTextLabel.text = @"其它";
        }
        
    }
    else if (indexPath.section == 1){
        cell.textLabel.text = @"昵称:";
        cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:kUserName]];
    }
    else if (indexPath.section == 2){
        cell.textLabel.text = @"真实姓名:";
        cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserRealName]];
    }
    else if (indexPath.section == 3){
        cell.textLabel.text = @"手机号:";
        cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserMobile]];
    }
    else{
        if (indexPath.row==0) {
            cell.textLabel.text = @"学校:";
            cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserSchoolName]];
        }
        else if(indexPath.row==1){
            cell.textLabel.text = @"入学年份:";
            cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserYear]];
        }
        else if (indexPath.row==2){
            cell.textLabel.text = @"院:";
            cell.detailTextLabel.text = @"";
        }
        else{
            cell.textLabel.text = @"系:";
            cell.detailTextLabel.text = @"";
        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0f;
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
