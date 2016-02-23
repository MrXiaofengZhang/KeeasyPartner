//
//  ZHSelfOrderController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHSelfOrderController.h"
#import "ZHSportOrderCell.h"
#import "ZHVenueOrderCell.h"
#import "ZHOrderController.h"
#import "WPCApplyDetailVC.h"
#import "ZHCommentController.h"
#import "WPCOrderPayVC.h"
#import "ZHApplyRefundController.h"
#import "WPCRefundDetailVC.h"
#import "EmpatyView.h"
#import "PayView.h"
#define topViewHeight 55.0f
@interface ZHSelfOrderController ()<UITableViewDataSource,UITableViewDelegate,UPPayPluginDelegate,PayViewDelegate>{
    NSMutableArray *sportDataArray;
    NSMutableArray *venueDataArray;
    NSMutableArray *resultDataArray;
    NSInteger defaultIndex;
    NSInteger itemCount;
    NSInteger selectIndexOne;
    NSInteger selectIndexTwo;
    PayView *payView;
    NSInteger orderSelect;
    NSInteger matchSelect;
    NSMutableArray *countArr1;
    NSMutableArray *countArr2;
    UILabel *lab;
}
@property (nonatomic,strong) UISegmentedControl *segCon;
@property (nonatomic,strong) UIView *redLine;
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UIView *firstTopView;
@property (nonatomic,strong) UIView *secondTopView;
@property (nonatomic,strong) UIView *secondRedLine;
@property (nonatomic,strong) NSArray *arr1;
@property (nonatomic,strong) NSArray *arr2;
@property (nonatomic,strong) NSString *orderId;
@property (nonatomic,strong) NSString *orderName;
@property (nonatomic,strong) NSString *orderCost;
@property (nonatomic,strong) NSString *orderNum;

@end

@implementation ZHSelfOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectIndexOne = 1;
    selectIndexTwo = 1;
    [self navgationBarLeftReturn];
    sportDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    venueDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    resultDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    defaultIndex = 0;
    itemCount = 6;
    [self createUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayResult:) name:WXPAY_BACK_NOTIFICATION object:nil];

}

- (void)loadOrderList{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setObject:[kUserDefault valueForKey:kUserId]  forKey:@"uid"];

   [DataService requestWeixinAPI:getOrderList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"dic=%@",result);
       if ([result[@"statusCodeInfo"] isEqualToString:@"成功"]) {
           [sportDataArray removeAllObjects];
           [venueDataArray removeAllObjects];
           self.arr1 = [NSArray arrayWithArray:result[@"venuesOrdersList"]];
           self.arr2 = [NSArray arrayWithArray:result[@"matchOrderList"]];
           NSInteger a1 = 0, a2 = 0, a3 = 0, a4 = 0, a5 = 0, a6 = 0;
           for (int i = 0; i < self.arr1.count; i ++) {
               a1 = self.arr1.count;
               if ([self.arr1[i][@"status"] isEqualToString:DDZT_0001]) {
                   a2 += 1;
               }
               if ([self.arr1[i][@"status"] isEqualToString:DDZT_0002]) {
                   a3 += 1;
               }
               if ([self.arr1[i][@"status"] isEqualToString:DDZT_0005]) {
                   a4 += 1;
               }
               if ([self.arr1[i][@"status"] isEqualToString:DDZT_0003]) {
                   a5 += 1;
               }
               if ([self.arr1[i][@"status"] isEqualToString:DDZT_0004] || [self.arr1[i][@"status"] isEqualToString:DDZT_0007]) {
                   a6 += 1;
               }
           }
           countArr1 =[[NSMutableArray alloc] initWithArray: @[[NSString stringWithFormat:@"%ld",(long)a1],[NSString stringWithFormat:@"%ld",(long)a2],[NSString stringWithFormat:@"%ld",(long)a3],[NSString stringWithFormat:@"%ld",(long)a4],[NSString stringWithFormat:@"%ld",(long)a5],[NSString stringWithFormat:@"%ld",(long)a6]]];
           
           NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
           [formatter setDateFormat:@"yyyy-MM-dd"];
           NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
           NSTimeInterval now = [date timeIntervalSince1970];
           NSInteger b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0;
           for (int i = 0; i < self.arr2.count; i ++) {
               b1 = self.arr2.count;
               if ([self.arr2[i][@"status"] isEqualToString:DDZT_0001]) {
                   b2 += 1;
               }
               if ([self.arr2[i][@"status"] isEqualToString:DDZT_0002]) {
                   b3 += 1;
               }
               if ([self.arr2[i][@"status"] isEqualToString:DDZT_0003]) {
                   b4 += 1;
               }
               
               if ([self.arr2[i][@"status"] isEqualToString:DDZT_0001]) {
                   NSDate *beginVerify = [formatter dateFromString:[LVTools mToString:self.arr2[i][@"matchSighUptoTime"]]];
                   NSDate *endVerify = [formatter dateFromString:[LVTools mToString:self.arr2[i][@"matchVerifyUptoTime"]]];
                   NSTimeInterval begin = [beginVerify timeIntervalSince1970];
                   NSTimeInterval end = [endVerify timeIntervalSince1970];
                   NSTimeInterval begincha = now - begin;
                   NSTimeInterval endcha = now - end;
                   if (begincha > 0 && endcha < 0) {
                       b5 += 1;
                   }
               }
           }
           if (b2>0) {
               if (lab == nil) {
                   lab = [[UILabel alloc] initWithFrame:CGRectMake(_segCon.width-15, mygap, mygap, mygap)];
                   lab.layer.cornerRadius = mygap/2.0;
                   lab.layer.masksToBounds = YES;
                   lab.backgroundColor = color_red_dan;
                   [_segCon addSubview:lab];
               }
           }
           countArr2 =[[NSMutableArray alloc] initWithArray: @[[NSString stringWithFormat:@"%ld",(long)b1],[NSString stringWithFormat:@"%ld",(long)b2],[NSString stringWithFormat:@"%ld",(long)b3],[NSString stringWithFormat:@"%ld",(long)b4],[NSString stringWithFormat:@"%ld",(long)b5]]];
           
           if (defaultIndex == 0) {
               [self setVenueCatagoryCountWithNum:countArr1];
           } else {
               [self setMatchCatagoryCountWithNum:countArr2];
           }
           
           [venueDataArray addObjectsFromArray:result[@"venuesOrdersList"]];
           [sportDataArray addObjectsFromArray:result[@"matchOrderList"]];
           if (venueDataArray.count == 0) {
               _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
           }
           if (_segCon.selectedSegmentIndex == 0) {
               if (selectIndexOne == 1) {
                   [_mTableView reloadData];
               } else {
                   [self venueEvent:selectIndexOne+99];
               }
           } else if (_segCon.selectedSegmentIndex == 1) {
               if (selectIndexTwo == 1) {
                   [_mTableView reloadData];
               } else {
                   [self sportEvent:selectIndexTwo+199];
               }
           }
       }
       else{
           [self showHint:ErrorWord];
       }
   }];
}
- (void)createUI{
    [self.view addSubview:self.firstTopView];
    [self.view addSubview:self.redLine];
    [self.view addSubview:self.mTableView];
}

- (UIView *)firstTopView {
    if (!_firstTopView) {
        _firstTopView = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, BOUNDS.size.width+2, topViewHeight)];
        _firstTopView.backgroundColor = [UIColor colorWithRed:0.965f green:0.969f blue:0.973f alpha:1.00f];
        _firstTopView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _firstTopView.layer.borderWidth = 0.5;
        
        CGFloat itemwidth = _firstTopView.width/6;
        NSArray *titleArr = @[@"全部",@"未付款",@"未消费",@"待评价",@"已失效",@"退款单"];
        for (NSInteger i=0; i<6; i++) {
            UIButton *btn= [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100+i;
            [btn setFrame:CGRectMake(itemwidth*i, 0, itemwidth, _firstTopView.height)];
            [btn setTitle:[titleArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:0.341f green:0.345f blue:0.349f alpha:1.00f] forState:UIControlStateNormal];
            [btn setTitleColor:color_red_dan forState:UIControlStateSelected];
            [btn setBackgroundColor:[UIColor clearColor]];
            btn.titleLabel.font = Content_lbfont;
            [btn addTarget:self action:@selector(changeOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_firstTopView addSubview:btn];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(btn.right, mygap*3.5, 0.5, topViewHeight-7*mygap)];
            line.backgroundColor = [UIColor lightGrayColor];
            [_firstTopView addSubview:line];
        }
    }
    return _firstTopView;
}

- (UIView *)secondTopView {
    if (!_secondTopView) {
        _secondTopView = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, BOUNDS.size.width+2, topViewHeight)];
        _secondTopView.backgroundColor = [UIColor colorWithRed:0.965f green:0.969f blue:0.973f alpha:1.00f];
        _secondTopView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _secondTopView.layer.borderWidth = 0.5;
        
        CGFloat itemwidth = _secondTopView.width/5;
        NSArray *titleArr = @[@"全部",@"未付款",@"已成功",@"已失效",@"审核单"];
        for (NSInteger i=0; i<5; i++) {
            UIButton *btn= [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 200+i;
            [btn setFrame:CGRectMake(itemwidth*i, 0, itemwidth, _firstTopView.height)];
            [btn setTitle:[titleArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:0.341f green:0.345f blue:0.349f alpha:1.00f] forState:UIControlStateNormal];
            [btn setTitleColor:color_red_dan forState:UIControlStateSelected];
            [btn setBackgroundColor:[UIColor clearColor]];
            btn.titleLabel.font = Btn_font;
            [btn addTarget:self action:@selector(secondChangeOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_secondTopView addSubview:btn];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(btn.right, mygap*3.5, 0.5, topViewHeight-7*mygap)];
            line.backgroundColor = [UIColor lightGrayColor];
            [_secondTopView addSubview:line];
        }
    }
    return _secondTopView;
}

- (void)setVenueCatagoryCountWithNum:(NSArray *)arr {
    NSLog(@"arr ===========%@",arr);
    NSArray *arr1 = @[@"全部",@"未付款",@"未消费",@"待评价",@"已失效",@"退款单"];
    for (int i = 101; i < 106; i ++) {
        UIButton *btn = (UIButton *)[_firstTopView viewWithTag:i];
        NSString *str = [LVTools mToString:arr[i-100]];
        NSInteger count = [str integerValue];
        if (count > 0) {
            [btn setTitle:[arr1[i-100] stringByAppendingString:str] forState:UIControlStateNormal];
        }
    }
}

- (void)setMatchCatagoryCountWithNum:(NSArray *)arr {
    NSArray *arr1 = @[@"全部",@"未付款",@"已成功",@"已失效",@"审核单"];
    for (int i = 201; i < 202; i ++) {
        UIButton *btn = (UIButton *)[_secondTopView viewWithTag:i];
        NSString *str = [LVTools mToString:arr[i-200]];
        NSInteger count = [str integerValue];
        if (count > 0) {
            [btn setTitle:[arr1[i-200] stringByAppendingString:str] forState:UIControlStateNormal];
        }
    }
}

- (void)changeOnClick:(UIButton*)sender{
    selectIndexOne = sender.tag-99;
    for (UIView *view in _firstTopView.subviews) {
        if ([view isMemberOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
        }
    }
    sender.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        //
        self.redLine.left = (sender.tag-100)*(BOUNDS.size.width+2)/itemCount+mygap*2;
    }];
    
    
    [self venueEvent:sender.tag];
}

- (void)venueEvent:(NSInteger)index {
    _mTableView.backgroundView = nil;
    [venueDataArray removeAllObjects];
    switch (index) {
        case 100://全部
        {
            [venueDataArray addObjectsFromArray:self.arr1];
            if (venueDataArray.count == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 101://未付款
        {
            for (int i = 0; i < [self.arr1 count]; i++) {
                if ([self.arr1[i][@"status"] isEqualToString:DDZT_0001]) {
                    [venueDataArray addObject:self.arr1[i]];
                }
            }
            NSLog(@"venuedata ==== %@",venueDataArray);
            if (venueDataArray.count == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 102://未消费
        {
            for (int i = 0; i < [self.arr1 count]; i++) {
                if ([self.arr1[i][@"status"] isEqualToString:DDZT_0002]) {
                    [venueDataArray addObject:self.arr1[i]];
                }
            }
            if (venueDataArray.count == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 103://待评价
        {
            for (int i = 0; i < [self.arr1 count]; i++) {
                if ([self.arr1[i][@"status"] isEqualToString:DDZT_0005]) {
                    [venueDataArray addObject:self.arr1[i]];
                }
            }
            if (venueDataArray.count == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 104://已失效
        {
            for (int i = 0; i < [self.arr1 count]; i++) {
                if ([self.arr1[i][@"status"] isEqualToString:DDZT_0003]) {
                    [venueDataArray addObject:self.arr1[i]];
                }
            }
            if (venueDataArray.count == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 105://退款单
        {
            for (int i = 0; i < [self.arr1 count]; i++) {
                if ([self.arr1[i][@"status"] isEqualToString:DDZT_0004] || [self.arr1[i][@"status"] isEqualToString:DDZT_0007]) {
                    [venueDataArray addObject:self.arr1[i]];
                }
            }
            if (venueDataArray.count == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        default:
            break;
    }
}

- (void)secondChangeOnClick:(UIButton*)sender{
    selectIndexTwo = sender.tag-199;
    for (UIView *view in _secondTopView.subviews) {
        if ([view isMemberOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
        }
    }
    sender.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        //
        self.secondRedLine.left = (sender.tag-200)*(BOUNDS.size.width+2)/itemCount+mygap*2;
    }];
    
    
    [self sportEvent:sender.tag];
}

- (void)sportEvent:(NSInteger)index {
    _mTableView.backgroundView = nil;
    [sportDataArray removeAllObjects];
    switch (index) {
        case 200://全部
        {
            [sportDataArray addObjectsFromArray:self.arr2];
            if ([sportDataArray count] == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 201://未付款
        {
            for (int i = 0; i < [self.arr2 count]; i++) {
                if ([self.arr2[i][@"status"] isEqualToString:DDZT_0001]) {
                    [sportDataArray addObject:self.arr2[i]];
                }
            }
            if ([sportDataArray count] == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 202://已成功
        {
            for (int i = 0; i < [self.arr2 count]; i++) {
                if ([self.arr2[i][@"status"] isEqualToString:DDZT_0002]) {
                    [sportDataArray addObject:self.arr2[i]];
                }
            }
            if ([sportDataArray count] == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 203://已失效
        {
            for (int i = 0; i < [self.arr2 count]; i++) {
                if ([self.arr2[i][@"status"] isEqualToString:DDZT_0003]) {
                    [sportDataArray addObject:self.arr2[i]];
                }
            }
            if ([sportDataArray count] == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        case 204://审核单
        {
            //未付款情况下，根据审核期之类判断
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval now = [date timeIntervalSince1970];
            for (int i = 0; i < self.arr2.count; i ++) {
                if ([self.arr2[i][@"status"] isEqualToString:DDZT_0001]) {
                    NSDate *beginVerify = [formatter dateFromString:[LVTools mToString:self.arr2[i][@"matchSighUptoTime"]]];
                    NSDate *endVerify = [formatter dateFromString:[LVTools mToString:self.arr2[i][@"matchVerifyUptoTime"]]];
                    NSTimeInterval begin = [beginVerify timeIntervalSince1970];
                    NSTimeInterval end = [endVerify timeIntervalSince1970];
                    NSTimeInterval begincha = now - begin;
                    NSTimeInterval endcha = now - end;
                    if (begincha > 0 && endcha < 0) {
                        [sportDataArray addObject:self.arr2[i]];
                    }
                }
            }
            if ([sportDataArray count] == 0) {
                _mTableView.backgroundView = [[EmpatyView alloc] initWithImg:@"emptyOrder" AndText:@"暂无相关订单"];
            }
            [self.mTableView reloadData];
        }
            break;
        default:
            break;
    }
}

- (void)changeSegOnClick:(UISegmentedControl*)seg{
    [lab removeFromSuperview];
    lab = nil;
    if (seg.selectedSegmentIndex == 0) {
        if (defaultIndex == 0) {
            return;
        }
        [self.secondRedLine removeFromSuperview];
        [self.secondTopView removeFromSuperview];
        [self.view addSubview:self.firstTopView];
        [self.view addSubview:self.redLine];
        [self venueEvent:selectIndexOne+99];
        [self setVenueCatagoryCountWithNum:countArr1];
        itemCount = 6;
        defaultIndex = 0;
    } else {
        if (defaultIndex == 1) {
            return;
        }
        [self.redLine removeFromSuperview];
        [self.firstTopView removeFromSuperview];
        [self.view addSubview:self.secondTopView];
        [self.view addSubview:self.secondRedLine];
        [self sportEvent:selectIndexTwo+199];
        [self setMatchCatagoryCountWithNum:countArr2];
        itemCount = 5;
        defaultIndex = 1;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.segCon.superview==nil) {
        [self.navigationController.navigationBar addSubview:self.segCon];
    }
    [self loadOrderList];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.segCon.superview) {
        [self.segCon removeFromSuperview];
    }
}
#pragma mark Getter
- (UISegmentedControl*)segCon{
    if (_segCon == nil) {
        _segCon = [[UISegmentedControl alloc] initWithItems:@[@"场馆订单",@"赛事订单"]];
        _segCon.frame = CGRectMake((BOUNDS.size.width-200)/2.0, 7, BOUNDS.size.width*0.6, 30);
        _segCon.selectedSegmentIndex = 0;
        _segCon.tintColor = [UIColor colorWithRed:0.831f green:0.933f blue:0.996f alpha:1.00f];
        [_segCon addTarget:self action:@selector(changeSegOnClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _segCon;
}
- (UIView*)redLine{
    if (_redLine == nil) {
        _redLine = [[UIView alloc] initWithFrame:CGRectMake(mygap*2, topViewHeight-2.0, (BOUNDS.size.width+2)/itemCount-4*mygap, 1)];
        _redLine.backgroundColor = [UIColor colorWithRed:0.949f green:0.263f blue:0.243f alpha:1.00f];
    }
    return _redLine;
}

- (UIView *)secondRedLine {
    if (!_secondRedLine) {
        _secondRedLine = [[UIView alloc] initWithFrame:CGRectMake(mygap*2, topViewHeight-2.0, (BOUNDS.size.width+2)/itemCount-4*mygap, 1)];
        _secondRedLine.backgroundColor = [UIColor colorWithRed:0.949f green:0.263f blue:0.243f alpha:1.00f];
    }
    return _secondRedLine;
}


- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topViewHeight, BOUNDS.size.width, BOUNDS.size.height-64-topViewHeight)];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mTableView;
}
#pragma mark UITableviewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_segCon.selectedSegmentIndex==1) {
         return sportDataArray.count;
    }
    else{
        return venueDataArray.count;
    }
}


- (void)payAction:(NSInteger)index {
    WPCOrderPayVC *vc = [[WPCOrderPayVC alloc] init];
    NSDictionary *info = [venueDataArray objectAtIndex:index];
    NSLog(@"info ===== %@",info);
    vc.orderId = [LVTools mToString:info[@"id"]];
    vc.time = [LVTools mToString:info[@"orderTime"]];
    vc.orderNum = [LVTools mToString:info[@"orderNum"]];
    vc.totalCost = [LVTools mToString:info[@"amount"]];
    vc.orderCost = [LVTools mToString:info[@"amount"]];
    vc.orderName = [LVTools mToString:info[@"orderName"]];
    vc.ordertype = @"3";//
    vc.dic = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)applyRefound:(NSInteger)index {
    ZHApplyRefundController *vc = [[ZHApplyRefundController alloc] init];
    vc.chuanBlock = ^ (NSArray *arr) {
//        sender.hidden = YES;
    };
    NSDictionary *info = [venueDataArray objectAtIndex:index];
    vc.orderId = [LVTools mToString:info[@"id"]];
    vc.cost = [LVTools mToString:info[@"amount"]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scanProcess:(NSInteger)index {
    WPCRefundDetailVC *vc = [[WPCRefundDetailVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)makeComment:(NSInteger)index {
    ZHCommentController *vc = [[ZHCommentController alloc] init];
    vc.fromStyle = StyelResultVenueComment;
    vc.count = 3;
    vc.chuanComment = ^(NSDictionary *dic) {

    };
    NSDictionary *info = [venueDataArray objectAtIndex:index];
    NSLog(@"info ==== %@",info);
    vc.idstring = [LVTools mToString:info[@"id"]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)venueBtnClick:(UIButton *)sender {
    NSInteger index = sender.tag/selectIndexOne - 500;
    NSDictionary *dic = [venueDataArray objectAtIndex:index];
    
    if ([[LVTools mToString:dic[@"status"]] isEqualToString:DDZT_0001]) {
        //立即支付
        [self payAction:index];
    } else if ([[LVTools mToString:dic[@"status"]] isEqualToString:DDZT_0002]) {
        //申请退款
        [self applyRefound:index];
    } else if ([[LVTools mToString:dic[@"status"]] isEqualToString:DDZT_0005]) {
        //立即评价
        [self makeComment:index];
    } else if ([[LVTools mToString:dic[@"status"]] isEqualToString:DDZT_0004]) {
        //查看退款流程
        [self scanProcess:index];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.segCon.selectedSegmentIndex == 0) {
        NSString *venueorderCell = [NSString stringWithFormat:@"cellid%ld",(long)selectIndexOne];
        ZHVenueOrderCell *cell= [tableView dequeueReusableCellWithIdentifier:venueorderCell];
        if (cell == nil) {
            cell = [[ZHVenueOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:venueorderCell];
        }
        cell.btn.tag = (500+indexPath.row)*selectIndexOne;
        
        NSDictionary *dic = [venueDataArray objectAtIndex:indexPath.row];
        
        [cell.btn addTarget:self action:@selector(venueBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell configVenueModel:dic];
        return cell;
    }
    else{
        NSString *sportorderCell = [NSString stringWithFormat:@"cellidenty%ld",(long)selectIndexOne];
        ZHSportOrderCell *cell= [tableView dequeueReusableCellWithIdentifier:sportorderCell];
        if (cell == nil) {
            cell = [[ZHSportOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sportorderCell];
        }
        cell.payBtn.tag = (5000+indexPath.row)*selectIndexTwo;
        [cell.payBtn addTarget:self action:@selector(payForMatch:) forControlEvents:UIControlEventTouchUpInside];
        [cell configMatchDic:sportDataArray[indexPath.row]];
        return cell;
    }
}

- (void)payForMatch:(UIButton *)sender {
    NSInteger index = sender.tag/selectIndexTwo-5000;
    matchSelect = index;
    self.orderId = [LVTools mToString:sportDataArray[index][@"id"]];
    self.orderName = [LVTools mToString:sportDataArray[index][@"orderName"]];
    self.orderNum = [LVTools mToString:sportDataArray[index][@"orderNum"]];
    self.orderCost = [LVTools mToString:sportDataArray[index][@"amount"]];
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

- (void)wxpayResult:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    NSString *code = [dic valueForKey:@"code"];
    [self dismissPayView];
    if ([code isEqualToString:@"0"]) {
        //支付成功
        [self timeRunLoopRequest:@"ZFFS_0005"];
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
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.segCon.selectedSegmentIndex == 0) {
        NSString *stateString = venueDataArray[indexPath.row][@"status"];
        if ([stateString isEqualToString:DDZT_0002] || [stateString isEqualToString:DDZT_0004]) {
            return UITableViewCellEditingStyleNone;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    } else {
        NSDictionary *dic = sportDataArray[indexPath.row];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval now = [date timeIntervalSince1970];
        
        NSDate *matchEnd = [formatter dateFromString:dic[@"matchEndTime"]];
        NSTimeInterval matchend = [matchEnd timeIntervalSince1970];
        NSTimeInterval matchendCha = now - matchend;
        
        NSString *stateString = [LVTools mToString:sportDataArray[indexPath.row][@"status"]];
        NSString *verifyString = [LVTools mToString:sportDataArray[indexPath.row][@"verifyStatus"]];//bmsh_0004代表还没到审核期
        if ([stateString isEqualToString:DDZT_0003] || ([stateString isEqualToString:DDZT_0001] && [verifyString isEqualToString:@"BMSH_0004"]) || matchendCha > 0) {
            return UITableViewCellEditingStyleDelete;
        } else {
            return UITableViewCellEditingStyleNone;
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.segCon.selectedSegmentIndex == 0) {
        //todo
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:[LVTools mToString:venueDataArray[indexPath.row][@"id"]] forKey:@"id"];
        [DataService requestWeixinAPI:delOrder parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"%@",result);
            if ([result[@"statusCode"] isEqualToString:@"success"]) {
                [venueDataArray removeObjectAtIndex:indexPath.row];
                [tableView reloadData];
                
                [self setVenueCatagoryCountWithNum:countArr1];
            }
        }];
    } else {
        //删除（取消）赛事报名
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:sportDataArray[indexPath.row][@"goodsId"] forKey:@"id"];
        [DataService requestWeixinAPI:delMatchSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                [sportDataArray removeObjectAtIndex:indexPath.row];
                [tableView reloadData];
                [countArr2 replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%d",  (int)[[countArr2 objectAtIndex:1] integerValue]-1]];
                [self setMatchCatagoryCountWithNum:countArr2];
            } else {
                [self showHint:@"删除失败，请重试"];
            }
        }];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_segCon.selectedSegmentIndex == 0)
    {
        //场馆订单
        ZHOrderController *zhorderVC =[[ZHOrderController alloc] init];
        zhorderVC.idString = [LVTools mToString:venueDataArray[indexPath.row][@"id"]];
        [self.navigationController pushViewController:zhorderVC animated:YES];
    }
    else{
        //赛事订单
        WPCApplyDetailVC *zhorderVC =[[WPCApplyDetailVC alloc] init];
        zhorderVC.orderDic = sportDataArray[indexPath.row];
        [self.navigationController pushViewController:zhorderVC animated:YES];
    }
}

#pragma mark UPPayPluginDelegate
- (void)UPPayPluginResult:(NSString *)result{
    NSLog(@"%@",result);
    if ([result isEqualToString:@"success"]) {
        //刷新页面，隐藏按钮
        [self timeRunLoopRequest:@"ZFFS_0001"];
//        [WCAlertView showAlertWithTitle:@"提示" message:@"支付成功!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
//            WPCApplyDetailVC *zhorderVC =[[WPCApplyDetailVC alloc] init];
//            zhorderVC.orderDic = sportDataArray[matchSelect];
//            [self.navigationController pushViewController:zhorderVC animated:YES];
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
                [self loadOrderList];
            } cancelButtonTitle:@"确定" otherButtonTitles: nil];
        } else {
            [self showHint:@"服务器故障，请联系客服"];
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
