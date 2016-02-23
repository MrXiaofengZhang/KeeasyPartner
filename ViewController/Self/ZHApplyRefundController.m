//
//  ZHApplyRefundController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHApplyRefundController.h"
#import "WPCRefundDetailVC.h"
@interface ZHApplyRefundController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>{
    NSArray *resonArr;
}
@property (nonatomic,strong) UITableView *mtableView;
@property (nonatomic,strong) UITextView *introduceTex;
@property (nonatomic,strong) UILabel *plohLb;

@end

@implementation ZHApplyRefundController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"申请退款";
    resonArr = @[@"订错了",@"后悔了,不想要了",@"计划有变,没时间去",@"其他"];
    [self navgationBarLeftReturn];
    [self.view addSubview:self.mtableView];
}
#pragma mark UITableViewDatasourse
- (UITableView*)mtableView{
    if (_mtableView == nil) {
        _mtableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStyleGrouped];
        _mtableView.delegate = self;
        _mtableView.dataSource = self;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(mygap*2, 20, BOUNDS.size.width-4*mygap, 44.0)];
        [btn setTitle:@"提交申请" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:NavgationColor];
        btn.layer.cornerRadius = 5.0;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 80)];
        [footView addSubview:btn];
        _mtableView.tableFooterView = footView;
    }
    return _mtableView;
}

- (void)submitAction:(UIButton *)sender {
    
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.orderId forKey:@"id"];
    [DataService requestWeixinAPI:orderRefund parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"%@",result);
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            NSArray *arr = [NSArray array];
            self.chuanBlock(arr);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (UITextView*)introduceTex{
    if (_introduceTex == nil) {
        _introduceTex = [[UITextView alloc] initWithFrame:CGRectMake(mygap*2, 30, BOUNDS.size.width-4*mygap, 100)];
        _introduceTex.delegate = self;
    }
    return _introduceTex;
}

- (UILabel*)plohLb{
    if (_plohLb == nil) {
        _plohLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-100, 80, 100, 20)];
        _plohLb.textColor = BackGray_dan;
        _plohLb.text = @"200字以内";
    }
    return _plohLb;
}
#pragma utbdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 4;
    }
    else{
        return 1;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.section == 0) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 200, 20)];
        lab.text = [resonArr objectAtIndex:indexPath.row];
        [cell.contentView addSubview:lab];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-40, 12, 20, 20)];
        img.image = [UIImage imageNamed:@"selecedCheck"];
        img.hidden = YES;
        img.tag = 100+indexPath.row;
        [cell.contentView addSubview:img];
    }
    else if(indexPath.section==1){
        UILabel *textlb =[[UILabel alloc] initWithFrame:CGRectMake(mygap*2, 0, 150, 30)];
        textlb.text = @"描述(选填):";
        [cell.contentView addSubview:textlb];
        [cell.contentView addSubview:self.introduceTex];
    }
    else if (indexPath.section==2){
        cell.textLabel.text = [NSString stringWithFormat:@"退款金额:%@元(实际消费金额)",self.cost];
    }
    else{
       cell.textLabel.text = @"退款方式:原路退回到原支付方";
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 140.0;
    }
    else{
        return 44.0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 30.0;
    }
    else{
        return 10.0;
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 300)];
    lab.backgroundColor = BackGray_dan;
    if (section == 0) {
        lab.text = @"  退款原因";
    }
    return lab;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        for (int i = 0; i < 4; i ++) {
            UIImageView *img = (UIImageView *)[tableView viewWithTag:100+i];
            img.hidden = YES;
        }
        UIImageView *img = (UIImageView *)[tableView viewWithTag:100+indexPath.row];
        img.hidden = NO;
    }
}
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
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
