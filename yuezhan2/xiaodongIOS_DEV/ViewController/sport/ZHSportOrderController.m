//
//  ZHSportOrderController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/8.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHSportOrderController.h"
#import "PayView.h"

@interface ZHSportOrderController ()<UITableViewDataSource,UITableViewDelegate,UPPayPluginDelegate,PayViewDelegate>
{
    PayView *payView;
}
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation ZHSportOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    //self.title = @"订单信息";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayResult:) name:WXPAY_BACK_NOTIFICATION object:nil];
    [self.view addSubview:self.mTableView];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WXPAY_BACK_NOTIFICATION object:nil];
}
#pragma mark Getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStyleGrouped];
        if (iOS7) {
        _mTableView.separatorInset = UIEdgeInsetsMake(0, BOUNDS.size.width*0.3, 0, 0);
        }
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 44.0)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = @"恭喜您,您的赛事报名表已经成功提交!";
        lab.font = [UIFont fontWithName:@"AlNile-Bold" size:20.0];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, lab.height, self.view.width, 0.4)];
        line.backgroundColor = BackGray_dan;
        [lab addSubview:line];
        _mTableView.tableHeaderView = lab;
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 100)];
        footView.backgroundColor = [UIColor clearColor];
        UILabel *textlab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, BOUNDS.size.width-40, 40)];
        textlab.numberOfLines = 0;
        textlab.textAlignment = NSTextAlignmentLeft;
        textlab.font = Content_lbfont;
        NSString *textstr = @"您的报名信息提交成功,请到个人中心-我的赛事页面查看报名状态";
        NSRange range2 = [textstr rangeOfString:@"个人中心-我的赛事"];
        NSAttributedString *str=[LVTools attributedStringFromText:textstr range:range2 andColor:NavgationColor];
        textlab.attributedText = str;
        [footView addSubview:textlab];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, textlab.bottom+20, textlab.width, 40)];
        [btn setBackgroundColor:NavgationColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if ([self.isVerify isEqualToString:@"SF_0001"]) {
            [btn setTitle:@"报名已申请，返回" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(bonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [btn setTitle:@"我要支付" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(paynow:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 5.0;
        
        [footView addSubview:btn];
        _mTableView.tableFooterView = footView;
    }
    return _mTableView;
}

- (void)wxpayResult:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    NSString *code = [dic valueForKey:@"code"];
    [self dismissPayView];
    if ([code isEqualToString:@"0"]) {
        //支付成功
        [self timeRunLoopRequest:@"ZFFS_0005"];
//        [WCAlertView showAlertWithTitle:nil message:@"支付成功" customizationBlock:^(WCAlertView *alertView) {
//            
//        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
//            if (buttonIndex == 0) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:PAY_SUCCESS object:self];
//                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
//            }
//        } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    }
}

- (void)dismissPayView {
    [UIView animateWithDuration:0.3 animations:^{
        payView.frame = CGRectMake(0, UISCREENHEIGHT, UISCREENWIDTH, UISCREENHEIGHT);
    } completion:^(BOOL finished) {
        [payView.backGround removeFromSuperview];
        [payView removeFromSuperview];
        payView.backGround = nil;
        payView = nil;
    }];
}

- (void)paynow:(UIButton *)sender {
    
    payView = [[PayView alloc] initWithFrame:CGRectMake(0, UISCREENHEIGHT, UISCREENWIDTH, UISCREENHEIGHT)];
    payView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:payView.backGround];
    [[UIApplication sharedApplication].keyWindow addSubview:payView];
    [UIView animateWithDuration:0.3 animations:^{
        payView.frame = CGRectMake(0, -10, UISCREENWIDTH, UISCREENHEIGHT);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            payView.frame = CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)cancelAction {
    [UIView animateWithDuration:0.3 animations:^{
        payView.frame = CGRectMake(0, UISCREENHEIGHT, UISCREENWIDTH, UISCREENHEIGHT);
    } completion:^(BOOL finished) {
        [payView.backGround removeFromSuperview];
        [payView removeFromSuperview];
        payView.backGround = nil;
        payView = nil;
    }];
}

- (void)confirmAction:(NSInteger)index {
    [self dismissPayView];
    if (index == 0) {
        //银联
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.orderId forKey:@"id"];
        [DataService requestWeixinAPI:toPay parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"pay result == =%@",result);
            if ([[LVTools mToString:result[@"tn"]] length] > 0) {
                [LVTools mstartPay:[LVTools mToString:result[@"tn"]] mode:UPayMode viewController:self delegate:self];
            }
            else{
                [self showHint:@"tn获取失败"];
            }
        }];
    }
    if (index == 1) {
        //支付宝
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.orderId forKey:@"id"];
        [DataService requestWeixinAPI:toAliPay parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"ali result == %@",result);
            if ([[LVTools mToString:result[@"sign"]] length] > 0) {
                [LVTools mPay:self.orderNum ProductName:self.orderName ProductPrice:self.orderCost serviceSign:[LVTools mToString:result[@"sign"]] callback:^(id result) {
                    NSLog(@"result   ------------------------------------------   %@",result);
                    
                    switch ([[LVTools mToString:result[@"resultStatus"]] intValue]) {
                        case 9000:
                        {
                            [self timeRunLoopRequest:@"ZFFS_0002"];
//                            [WCAlertView showAlertWithTitle:nil message:@"支付成功" customizationBlock:^(WCAlertView *alertView) {
//                                
//                            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
//                                if (buttonIndex == 0) {
//                                    [[NSNotificationCenter defaultCenter] postNotificationName:PAY_SUCCESS object:self];
//                                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]  animated:YES];
//                                }
//                            } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        }
                            break;
                        case 8000:
                        {
                            [WCAlertView showAlertWithTitle:nil message:@"结果处理中" customizationBlock:^(WCAlertView *alertView) {
                                
                            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                
                            } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        }
                            break;
                        case 4000:
                        {
                            [WCAlertView showAlertWithTitle:nil message:@"支付失败" customizationBlock:^(WCAlertView *alertView) {
                                
                            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                
                            } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        }
                            break;
                        case 6001:
                        {
                            [WCAlertView showAlertWithTitle:nil message:@"支付取消" customizationBlock:^(WCAlertView *alertView) {
                                
                            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                
                            } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        }
                            break;
                        case 6002:
                        {
                            [WCAlertView showAlertWithTitle:nil message:@"网络连接错误" customizationBlock:^(WCAlertView *alertView) {
                                
                            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                
                            } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        }
                            break;
                        default:
                            break;
                    }
                }];
            } else {
                [self showHint:@"sign获取失败"];
            }
        }];
    }
    if (index == 2) {
        //微信
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.orderId forKey:@"id"];
        [DataService requestWeixinAPI:toWXPay parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"wei xin result == = = == %@",result);
            if ([[LVTools mToString:result[@"prepayid"]] length] > 0) {
                [LVTools sendPayWithDic:result];
            } else {
                [self showHint:ErrorWord];
            }
        }];
    }
    [self cancelAction];
}

#pragma mark UPPayPluginDelegate
- (void)UPPayPluginResult:(NSString *)result{
    NSLog(@"%@",result);
    if ([result isEqualToString:@"success"]) {
        //刷新页面，隐藏按钮
        [self timeRunLoopRequest:@"ZFFS_0001"];
//        [WCAlertView showAlertWithTitle:@"支付成功！" message:@"可前往订单管理查看详细信息" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:PAY_SUCCESS object:self];
//            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]  animated:YES];
//      
//        } cancelButtonTitle:@"确定" otherButtonTitles: nil];
    }
    else if([result isEqualToString:@"fail"]){
        [WCAlertView showAlertWithTitle:@"提示" message:@"支付失败!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
    }
    else if([result isEqualToString:@"cancel"]){
        [WCAlertView showAlertWithTitle:@"提示" message:@"您已经取消支付!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
    }
    else{
        
    }
}

- (void)timeRunLoopRequest:(NSString *)str {
    [self showHudInView:self.view hint:@"结果处理中"];
    [self getKeywordInfo:str];
}


- (void)getKeywordInfo:(NSString *)str {
    NSMutableDictionary *dic = [LVTools getTokenApp];
    NSLog(@"orderid =================%@",self.orderId);
    [dic setValue:self.orderId forKey:@"id"];
    [dic setValue:str forKey:@"type"];
    NSLog(@"dic ======= %@",dic);
    [DataService requestWeixinAPI:getPaywordList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"result ==== %@",result);
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [self hideHud];
            [WCAlertView showAlertWithTitle:@"提示" message:@"支付成功!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAY_SUCCESS object:self];
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]  animated:YES];
            } cancelButtonTitle:@"确定" otherButtonTitles: nil];
        } else {
            [self showHint:@"服务器故障，请联系客服"];
        }
    }];
}

- (void)bonOnClick:(UIButton*)btn{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]  animated:YES];
}
#pragma mark UITableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, BOUNDS.size.width*0.3, 20)];
    titleLab.textAlignment = NSTextAlignmentRight;
    titleLab.font = Btn_font;
    [cell.contentView addSubview:titleLab];
    UILabel *contentLb = [[UILabel alloc] initWithFrame:CGRectMake(titleLab.right+mygap, titleLab.top, BOUNDS.size.width*0.6, titleLab.height)];
    contentLb.textAlignment = NSTextAlignmentLeft;
    contentLb.font = Btn_font;
    [cell.contentView addSubview:contentLb];
    if (indexPath.row == 0) {
        titleLab.text = @"赛事名称:";
        contentLb.text = [LVTools mToString:_detalModel.matchName];
        
    }
    else if (indexPath.row == 1){
        titleLab.text = @"报名费:";
        NSString *str = [LVTools mToString:self.detalModel.registrationFee];
        contentLb.text = [NSString stringWithFormat:@"%@元/人",str];
    }
    else{
        titleLab.text = @"总计:";
        CGFloat a = [[LVTools mToString:self.detalModel.registrationFee] floatValue] * [self.number intValue];
        contentLb.text = [NSString stringWithFormat:@"%.2f元",a];
        contentLb.textColor = NavgationColor;
    }
    return cell;
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
