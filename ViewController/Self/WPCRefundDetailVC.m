//
//  WPCRefundDetailVC.m
//  yuezhan123
//
//  Created by admin on 15/7/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCRefundDetailVC.h"
#import "WPCRefundView.h"

@interface WPCRefundDetailVC ()

@end

@implementation WPCRefundDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"退款流程";
    [self navgationBarLeftReturn];
    self.view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    [self initialInterface];
}

- (void)initialInterface {
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 220*propotion)];
    view1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view1];
    NSArray *arr1 = @[@"申请成功",@"处理申请",@"退款成功"];
    NSArray *arr2 = @[@"1",@"2",@"3"];
    for (int i = 0; i < 3; i ++) {
        WPCRefundView *view = [[WPCRefundView alloc] initWithFrame:CGRectMake(60*propotion+250*propotion*i, 76*propotion, 142*propotion, 90*propotion) contentTitle:arr1[i] index:arr2[i]];
        [view1 addSubview:view];
        if (i != 2) {
            [view changeColorWithState:YES];
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(236*propotion+250*propotion*i, 94*propotion, 38*propotion, 30*propotion)];
            img.image = [UIImage imageNamed:@"lightgray_arrow_wpc"];
            [view1 addSubview:img];
        } else {
            [view changeColorWithState:NO];
        }
    }
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, view1.bottom+10, UISCREENWIDTH, 128*propotion)];
    view2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view2];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(70*propotion, 20*propotion, UISCREENWIDTH-140*propotion, 90*propotion)];
    lab.numberOfLines = 2;
    lab.text =@"如果买家在7个工作日内未处理，系统将自动退款给您";
    lab.font = Btn_font;
    [view2 addSubview:lab];
    
//    UIButton *orderBnt = [UIButton buttonWithType:UIButtonTypeCustom];
//    orderBnt.frame = CGRectMake(15, view2.bottom+20, UISCREENWIDTH-30, 70*propotion);
//    orderBnt.backgroundColor = NavgationColor;
//    [orderBnt setTitle:@"查看订单" forState:UIControlStateNormal];
//    [orderBnt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [orderBnt addTarget:self action:@selector(orderclick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:orderBnt];
}

- (void)orderclick:(UIButton *)sender {
    
}

@end
