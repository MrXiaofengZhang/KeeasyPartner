//
//  ZHPayResultController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/26.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHPayResultController.h"
//#import "ZHTaocanModel.h"
#import "ZHOrderController.h"
@interface ZHPayResultController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation ZHPayResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付成功";
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backbtn setImage:[UIImage imageNamed:@"black_back_arrow"] forState:UIControlStateNormal];
    backbtn.frame = CGRectMake(0, 0, 15, 30);
    [backbtn addTarget:self action:@selector(PopView) forControlEvents:UIControlEventTouchUpInside];
//    [self getKeywordInfo];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backbtn];
    [self.view addSubview:self.mTableView];
}

- (void)PopView {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)getKeywordInfo {
//    NSMutableDictionary *dic = [LVTools getTokenApp];
//    [dic setValue:self.idString forKey:@"id"];
//    [DataService requestWeixinAPI:getPaywordList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
//        NSLog(@"result ==== %@",result);
//    }];
//}

#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        [_mTableView setSeparatorInset:UIEdgeInsetsZero];
        UIImageView *img =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width/(750.0f/280.0f))];
        img.image = [UIImage imageNamed:@"pay_success"];
        _mTableView.tableHeaderView = img;
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.tableFooterView = [[UIView alloc] init];
    }
    return _mTableView;
}
#pragma mark UItableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row==0) {
        cell.textLabel.text = self.venueName;
    }
    else if(indexPath.row == 1){
        
        cell.textLabel.text = [NSString stringWithFormat:@"付款人：%@",[kUserDefault valueForKey:kUserName]];
        cell.textLabel.font = Btn_font;
    }
    else if(indexPath.row==2){
        cell.textLabel.text = [NSString stringWithFormat:@"实付款：¥%@",self.cost];
        cell.textLabel.font = Btn_font;
    }
    else if(indexPath.row == 3){
        cell.textLabel.text = @"订单密码：前往订单管理，查看密码";
        cell.textLabel.font = Btn_font;
        cell.detailTextLabel.text = @"消费时请出示密码";
        cell.detailTextLabel.textColor = NavgationColor;
    } else if (indexPath.row == 4) {
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(0, 0, 85, 30);
        btn1.center = CGPointMake(UISCREENWIDTH/4, 35);
        [btn1 setTitle:@"订单详情" forState:UIControlStateNormal];
        btn1.layer.borderWidth = 0.5;
        btn1.layer.cornerRadius = 3;
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn1.titleLabel.font = [UIFont systemFontOfSize:14];
        btn1.layer.borderColor = [[UIColor grayColor] CGColor];
        [btn1 addTarget:self action:@selector(detailClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"返回场馆" forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 85, 30);
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.center = CGPointMake(UISCREENWIDTH/4*3, 35);
        [btn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.layer.borderWidth = 0.5;
        btn.layer.cornerRadius = 3;
        btn.layer.borderColor = [[UIColor grayColor] CGColor];
        
        [cell.contentView addSubview:btn1];
        [cell.contentView addSubview:btn];
        
    }
    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],
                                                           NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setBarTintColor:NavgationColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==3 || indexPath.row == 4) {
        return 70.0;
    }
    return 50.0;
}
#pragma mark UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)detailClick:(id)sender{
    ZHOrderController *orderDetailVC= [[ZHOrderController alloc] init];
    orderDetailVC.idString = self.idString;
//    orderDetailVC.taocanModel = self.model;
//    orderDetailVC.vennueModel = self.venueModel;
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}
- (void)backClick:(id)sender{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setBarTintColor:NavgationColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
    
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
