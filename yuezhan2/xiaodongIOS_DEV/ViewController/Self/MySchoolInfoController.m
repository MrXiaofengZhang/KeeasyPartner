//
//  MySchoolInfoController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/16.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "MySchoolInfoController.h"
#import "ZHTeamDetaillCell.h"
#import "EditViewController.h"
#import "SchoolsController.h"
@interface MySchoolInfoController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    NSArray *titleArr;
    NSMutableArray *contentArr;
    UIView *btnV;
}
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic,strong) UIPickerView *yearPicker;
@end

@implementation MySchoolInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"报名信息";
    titleArr = @[@"真实姓名",@"手机号码",@"学校",@"入学年份"];
    NSLog(@"%@",self.infoDic);
    contentArr =[[NSMutableArray alloc] initWithArray:  @[self.infoDic[@"user"][@"realName"],self.infoDic[@"user"][@"mobile"],self.infoDic[@"schoolName"],self.infoDic[@"user"][@"enrollment"]]];
    [self navgationBarLeftReturn];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveOnClick)];
    [self.view addSubview:self.mTableView];
    [self.view addSubview:self.yearPicker];
}
- (void)saveOnClick{
    
}
- (void)cancelOnClick{
    [UIView animateWithDuration:0.3f animations:^{
        self.yearPicker.frame = CGRectMake(0, BOUNDS.size.height+30.0, BOUNDS.size.width, 216.0);
        btnV.frame = CGRectMake(0, BOUNDS.size.height, BOUNDS.size.width, 30.0);
    }];
}
- (void)okOnClick{
    [contentArr replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",(int)(2016-(int)[_yearPicker selectedRowInComponent:0])]];
    [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self cancelOnClick];
}

- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStyleGrouped];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.tableFooterView = [[UIView alloc] init];
    }
    return _mTableView;
}
- (UIPickerView*)yearPicker{
    if (_yearPicker == nil) {
        _yearPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height+30, BOUNDS.size.width, 216.0)];
        _yearPicker.delegate = self;
        _yearPicker.backgroundColor = [UIColor colorWithRed:0.824f green:0.835f blue:0.859f alpha:1.00f];
        btnV = [[UIView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height, BOUNDS.size.width, 30)];
        btnV.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:btnV];
        
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-40, 0, 40, 30)];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        [okBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okOnClick) forControlEvents:UIControlEventTouchUpInside];
        [btnV addSubview:okBtn];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelOnClick) forControlEvents:UIControlEventTouchUpInside];
        [btnV addSubview:cancelBtn];
    }
    return _yearPicker;
}
#pragma mark UIPickViewDelegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 10;
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",(int)(2016-row)];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHTeamDetaillCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infocell"];
    if (cell == nil) {
        cell = [[ZHTeamDetaillCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"infocell"];
    }
    cell.textLabel.text = [titleArr objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [contentArr objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
    if (indexPath.row == 2) {
    //选择院校
        SchoolsController *schoolVC =[[SchoolsController alloc] init];
        schoolVC.title = @"选择所在院校";
        schoolVC.chuanBlock = ^(NSArray *arr){
            [contentArr replaceObjectAtIndex:indexPath.row withObject:[arr objectAtIndex:0][@"name"]];
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
//            [schoolBtn setTitle:[arr objectAtIndex:0][@"name"] forState:UIControlStateNormal];
//            schoolInfo = [arr objectAtIndex:0];
        };
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:schoolVC];
        [self presentViewController:navi animated:YES completion:nil];
    }
    else if(indexPath.row == 3){
        [UIView animateWithDuration:0.3f animations:^{
            self.yearPicker.frame = CGRectMake(0, BOUNDS.size.height-216.0f, BOUNDS.size.width, 216.0);
            btnV.top = BOUNDS.size.height-246.0;
        }];
    }
    else{
        EditViewController *editVc =[[EditViewController alloc] init];
        editVc.infoDic =[[NSMutableDictionary alloc] initWithDictionary: self.infoDic];
        editVc.title = [titleArr objectAtIndex:indexPath.row];
        editVc.contentStr = [contentArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:editVc animated:YES];
    }
     */
}
#pragma mark 修改信息
- (void)updateUserInfoWithKey:(NSString*)key AndValue:(NSString*)value{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:KUserMobile] forKey:@"mobile"];
    [dic setValue:value forKey:key];
    [DataService requestWeixinAPI:resetPassword parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"重置密码返回的信息：%@",result);
        NSDictionary * dic = (NSDictionary *)result;
        if ([dic[@"status"] boolValue]) {
            
        }
        else{
            
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
