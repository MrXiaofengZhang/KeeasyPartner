//
//  WPCOrderPayVC.m
//  VenueTest
//
//  Created by admin on 15/6/25.
//  Copyright (c) 2015年 zhoujin. All rights reserved.
//

#import "WPCOrderPayVC.h"
#import "ZHPayResultController.h"
#import "payRequsestHandler.h"
#import "WXApi.h"
@interface WPCOrderPayVC () <UITableViewDataSource,UITableViewDelegate,UPPayPluginDelegate>
{
    double endTime;
    int leftTime;
    NSInteger selectIndex;
}
@property (nonatomic, strong)UITableView *tableview;
@property (nonatomic, strong)UILabel *timerLab;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)NSTimer *runloopTimer;

@end

@implementation WPCOrderPayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    selectIndex = 0;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PopView)];
    self.title = @"订单支付";
    self.view.backgroundColor = RGBACOLOR(245, 245, 245, 1);
    [self initialInterface];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayResultAction:) name:WXPAY_BACK_NOTIFICATION object:nil];
}

- (void)PopView {
    if (self.navigationController.viewControllers.count > 3) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)wxPayResultAction:(NSNotification *)noti {
    [self timeRunLoopRequest:@"ZFFS_0005"];
}

- (void)initialInterface {
    _tableview = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.backgroundColor = RGBACOLOR(245, 245, 245, 1);
    [self.view addSubview:_tableview];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 80)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"确认支付" forState:UIControlStateNormal];
    btn.frame = CGRectMake(12, 20, UISCREENWIDTH-24, 50);
    btn.backgroundColor = RGBACOLOR(77, 161, 219, 1);
    btn.tintColor = [UIColor whiteColor];
    btn.layer.cornerRadius = 3;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(confirmPayAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    _tableview.tableFooterView = view;
    
    NSLog(@"time === %@",self.time);
    NSString *str=@"";
    if (self.time.length == 0) {
        str = @"";
    } else {
     str = [self.time substringToIndex:self.time.length-3];
    }
    NSLog(@"str === %@",str);
    endTime = [str intValue]+1800;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSLog(@"now ===== %f",now);
    NSLog(@"endtime === %f",endTime);
    leftTime = (int)(endTime-now);
    NSLog(@"leftTime === %d",leftTime);
    //处理定时器数据
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeDescend) userInfo:nil repeats:YES];
}

- (void)timeDescend {
    leftTime --;
    if (leftTime > 0) {
        int second = leftTime%60;
        int minite = leftTime/60;
        _timerLab.text = [NSString stringWithFormat:@"%d:%.2d",minite,second];
    } else {
        _timerLab.text = @"已过期";
        _timerLab.font = Content_lbfont;
        [_timer invalidate];
    }
}

- (void)dealloc {
    [_timer invalidate];
    [_runloopTimer invalidate];
    _runloopTimer = nil;
}

#pragma mark -- tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = 350+indexPath.row+3*indexPath.section;
    if (indexPath.section == 0) {
        UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 70, 20)];
        lab1.textColor = [UIColor blackColor];
        lab1.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:lab1];
        if (indexPath.row == 0) {
            lab1.text = @"订单名称:";
        } else if (indexPath.row == 1) {
            lab1.text = @"订单金额:";
        } else {
            lab1.text = @"订单编号:";
        }
        if (indexPath.row != 2) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(90, 49.5, UISCREENWIDTH-90, 0.5)];
            if ([self.ordertype isEqualToString:@"2"] || ([self.ordertype isEqualToString:@"3"] && [[LVTools mToString:self.dic[@"orderType"]] isEqualToString:@"DDLX_0001"])) {
                if (indexPath.row == 0) {
                    line.frame = CGRectMake(90, 69.5, UISCREENWIDTH-90, 0.5);
                }
            }
            line.backgroundColor = lightColor;
            [cell addSubview:line];
        }
        
        if (indexPath.row != 0) {
            UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lab1.frame), 15, UISCREENWIDTH-110, 20)];
            lab2.font = [UIFont systemFontOfSize:15];
            lab2.textColor = [UIColor blackColor];
            if (indexPath.row == 1) {
                lab2.textColor = RGBACOLOR(110, 174, 203, 1);
            }
            [cell.contentView addSubview:lab2];
            if (indexPath.row == 1) {
                if ([self.ordertype isEqualToString:@"1"]) {
                    lab2.text = [NSString stringWithFormat:@"%@元",self.dic[@"costNum"]];
                } else {
                    NSLog(@"%@",self.totalCost);
                    lab2.text = [NSString stringWithFormat:@"%@元",self.totalCost];
                }
            } else {
                lab2.text = self.orderNum;
            }
        } else {
            if ([self.ordertype isEqualToString:@"1"]) {
                UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lab1.frame), 15, UISCREENWIDTH-110, 20)];
                lab2.font = [UIFont systemFontOfSize:15];
                lab2.textColor = [UIColor blackColor];
                [cell.contentView addSubview:lab2];
                lab2.text = self.dic[@"venue"];
            } else if ([self.ordertype isEqualToString:@"2"]) {
                UILabel *titlelab1 = [[UILabel alloc] initWithFrame:CGRectMake(lab1.right, 13, UISCREENWIDTH-110, 18)];
              
                titlelab1.text = _vennueModel.venuesName;
                titlelab1.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:titlelab1];
                
                UILabel *titlelab2 = [[UILabel alloc] initWithFrame:CGRectMake(lab1.right, titlelab1.bottom+8, UISCREENWIDTH-110, 15)];
                titlelab2.text = _taocanModel.packageName;
                titlelab2.font = [UIFont systemFontOfSize:14];
                [cell.contentView addSubview:titlelab2];
            } else {
                if ([[LVTools mToString:self.dic[@"orderType"]] isEqualToString:@"DDLX_0001"]) {
                    UILabel *titlelab1 = [[UILabel alloc] initWithFrame:CGRectMake(lab1.right, 13, UISCREENWIDTH-110, 18)];
                    
                    titlelab1.text = [LVTools mToString:self.dic[@"venuesName"]];
                    titlelab1.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:titlelab1];
                    
                    UILabel *titlelab2 = [[UILabel alloc] initWithFrame:CGRectMake(lab1.right, titlelab1.bottom+8, UISCREENWIDTH-110, 15)];
                    titlelab2.text = [LVTools mToString:self.dic[@"packageName"]];
                    titlelab2.font = [UIFont systemFontOfSize:14];
                    [cell.contentView addSubview:titlelab2];
                } else {
                    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lab1.frame), 15, UISCREENWIDTH-110, 20)];
                    lab2.font = [UIFont systemFontOfSize:15];
                    lab2.textColor = [UIColor blackColor];
                    [cell.contentView addSubview:lab2];
                    lab2.text = [LVTools mToString:self.dic[@"venuesName"]];
                }
            }
        }
    } else {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
        [cell.contentView addSubview:img];
        
        UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+10, 10, 180, 17)];
        lab1.font = [UIFont systemFontOfSize:15];
        lab1.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lab1];
        
        UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+10, CGRectGetMaxY(lab1.frame), 200, 13)];
        lab2.font = [UIFont systemFontOfSize:12];
        lab2.textColor = lightColor;
        [cell.contentView addSubview:lab2];
        if (indexPath.row == 1) {
            img.image = [UIImage imageNamed:@"zhifubao_wpc"];
            lab1.text = @"支付宝支付";
            lab2.text = @"推荐有支付宝账号的用户使用";
        } else if (indexPath.row == 0) {
            img.image = [UIImage imageNamed:@"yinlian_wpc"];
            lab1.text = @"银行卡支付";
            lab2.text = @"支持储蓄卡信用卡，无需卡通网银";
        } else {
            img.image = [UIImage imageNamed:@"weixin_wpc"];
            lab1.text = @"微信支付";
            lab2.text = @"推荐安装微信5.0及以上版本使用";
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(UISCREENWIDTH-40, 15, 20, 20);
        [btn setBackgroundImage:[UIImage imageNamed:@"selected_wpc"] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"disSelected_wpc"] forState:UIControlStateNormal];
        btn.tag = cell.tag+50;
        btn.selected = NO;
        if (indexPath.row == 0) {
            btn.selected = YES;
        }
        [cell.contentView addSubview:btn];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, UISCREENWIDTH, 0.5)];
        line.backgroundColor = lightColor;
        [cell addSubview:line];
    }
    return cell;
}

#pragma mark -- tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.ordertype isEqualToString:@"2"] || ([self.ordertype isEqualToString:@"3"] && [[LVTools mToString:self.dic[@"orderType"]] isEqualToString:@"DDLX_0001"])) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return 70;
        }
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 30)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 150, 18)];
        NSString *str = @"请在30分钟内支付,支付剩余时间";
        CGFloat width = [LVTools sizeWithStr:str With:16 With2:18];
        label.frame = CGRectMake(20, 6, width, 18);
        label.text = str;
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:16];
        [view addSubview:label];
        
        _timerLab = [[UILabel alloc] initWithFrame:CGRectMake(label.right+5, 6, 50, 18)];
        _timerLab.backgroundColor = [UIColor lightGrayColor];
        _timerLab.textAlignment = NSTextAlignmentCenter;
        
        [view addSubview:_timerLab];
        
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        selectIndex = indexPath.row;
        for (int i = 353; i < 356; i++) {
            UITableViewCell *cell = (UITableViewCell *)[tableView viewWithTag:i];
            UIButton *btn = (UIButton *)[cell.contentView viewWithTag:i+50];
            if (i-353 == indexPath.row) {
                btn.selected = YES;
            } else {
                btn.selected = NO;
            }
        }
    }
}

- (void)confirmPayAction {
    if (leftTime > 0) {
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.orderId forKey:@"id"];
        if (selectIndex == 0) {
            [DataService requestWeixinAPI:toPay parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                NSLog(@"pay result == =%@",result);
                if ([[LVTools mToString:result[@"tn"]] length] > 0) {
                    [LVTools mstartPay:[LVTools mToString:result[@"tn"]] mode:UPayMode viewController:self delegate:self];
                }
                else{
                    [self showHint:@"tn获取失败"];
                }
            }];
        } else if (selectIndex == 1) {
            [DataService requestWeixinAPI:toAliPay parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                NSLog(@"ali result == %@",result);
                if ([[LVTools mToString:result[@"sign"]] length] > 0) {
                    [LVTools mPay:self.orderNum ProductName:self.orderName ProductPrice:self.orderCost serviceSign:[LVTools mToString:result[@"sign"]] callback:^(id result) {
                        NSLog(@"result   ------------------------------------------   %@",result);
                        NSLog(@"memo === %@",result[@"memo"]);
                        switch ([[LVTools mToString:result[@"resultStatus"]] intValue]) {
                            case 9000:
                            {
                                [self timeRunLoopRequest:@"ZFFS_0002"];
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
        } else if (selectIndex == 2) {
            [DataService requestWeixinAPI:toWXPay parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                NSLog(@"wei xin result == = = == %@",result);
                if ([[LVTools mToString:result[@"prepayid"]] length] > 0) {
                    [LVTools sendPayWithDic:result];
                } else {
                    [self showHint:ErrorWord];
                }
            }];
        }
    } else {
        [self showHint:@"支付时间已过"];
    }
}

- (NSString *)md5StringForString:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
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
            if ([result[@"payWords"] count] > 0) {
                [self hideHud];
                [WCAlertView showAlertWithTitle:@"提示" message:@"支付成功!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    if (buttonIndex == 0) {
                        ZHPayResultController *payResultVC=[[ZHPayResultController alloc] init];
                        payResultVC.idString = self.orderId;
                        if ([self.ordertype isEqualToString:@"3"]) {
                            payResultVC.venueName = [LVTools mToString:self.dic[@"venuesName"]];
                        } else {
                            payResultVC.venueName = self.vennueModel.venuesName;
                        }
                        if ([self.ordertype isEqualToString:@"1"]) {
                            payResultVC.cost = [NSString stringWithFormat:@"%@元",self.dic[@"costNum"]];
                        } else {
                            payResultVC.cost = [NSString stringWithFormat:@"%@元",self.totalCost];
                        }
                        [self.navigationController pushViewController:payResultVC animated:YES];
                    }
                } cancelButtonTitle:@"确定" otherButtonTitles: nil];
            } else {
                [self showHint:@"服务器故障，请联系客服"];
            }
        }
    }];
}

-(void)UPPayPluginResult:(NSString*)result {
    NSLog(@"kkkkk ===== %@",result);
    if ([result isEqualToString:@"success"]) {
        //刷新页面，隐藏按钮
        [self timeRunLoopRequest:@"ZFFS_0001"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
