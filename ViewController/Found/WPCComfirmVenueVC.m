//
//  WPCComfirmVenueVC.m
//  VenueTest
//
//  Created by admin on 15/6/25.
//  Copyright (c) 2015年 zhoujin. All rights reserved.
//

#import "WPCComfirmVenueVC.h"
#import "WPCOrderPayVC.h"

@interface WPCComfirmVenueVC () <UITableViewDataSource,UITableViewDelegate>
{
    UILabel *moneyLabel;
    UILabel *costlab;
}
@property (nonatomic, strong)UITableView *infoTableview;
@property (nonatomic, strong)NSArray *prefixArray;

@property (nonatomic, strong)UILabel *costLabel;
@property (nonatomic, strong)UILabel *comfirmOrderLabel;
@property (nonatomic, strong)UILabel *countLab;

@end

@implementation WPCComfirmVenueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    self.title = @"场馆订单";
    self.view.backgroundColor = RGBACOLOR(245, 245, 245, 1);
    [self initialInterface];
    [self initialDatasource];
}

- (void)initialDatasource {
    _prefixArray = @[@"场馆名称:",@"预订时间:",@"预订信息:",@"小       计:"];
    [_infoTableview reloadData];
    if ([self.ordertype isEqualToString:@"1"]) {
        NSString *str = [NSString stringWithFormat:@"总计：%@元",[LVTools mToString:_infoDic[@"costNum"]]];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, str.length-3)];
        [_infoTableview reloadData];
        _costLabel.attributedText = attributeStr;
    } else {
        NSString *str = [NSString stringWithFormat:@"总计：%@元",_taocanModel.discountPrice];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, str.length-3)];
        [_infoTableview reloadData];
        _costLabel.attributedText = attributeStr;
    }
}

- (void)initialInterface {
    [self createBottomView];
    [self createInfotableview];
}

- (void)createInfotableview {
    _infoTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-45-64) style:UITableViewStylePlain];
    _infoTableview.dataSource = self;
    _infoTableview.backgroundColor = RGBACOLOR(245, 240, 245, 1);
    _infoTableview.delegate = self;
    _infoTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_infoTableview];
}

- (void)createBottomView {
    _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, UISCREENHEIGHT-45-64, UISCREENWIDTH/2, 45)];
    _costLabel.backgroundColor = [UIColor whiteColor];
    _costLabel.textAlignment = NSTextAlignmentCenter;
    NSString *costString = @"总计：0元";
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:costString];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, costString.length-3)];
    _costLabel.attributedText = attributeStr;
    _costLabel.font = [UIFont systemFontOfSize:15];
    _costLabel.layer.borderWidth = 0.5;
    _costLabel.layer.borderColor = [lightColor CGColor];
    
    _comfirmOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2, UISCREENHEIGHT-45-64, UISCREENWIDTH/2, 45)];
    _comfirmOrderLabel.backgroundColor = RGBACOLOR(77, 161, 219, 1);
    _comfirmOrderLabel.text = @"确认订单";
    _comfirmOrderLabel.textColor = [UIColor whiteColor];
    _comfirmOrderLabel.textAlignment = NSTextAlignmentCenter;
    _comfirmOrderLabel.font = [UIFont systemFontOfSize:15];
    _comfirmOrderLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitOrder)];
    [_comfirmOrderLabel addGestureRecognizer:tap];
    
    [self.view addSubview:_costLabel];
    [self.view addSubview:_comfirmOrderLabel];
}

- (void)submitOrder {
    if ([self.ordertype isEqualToString:@"1"]) {
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < _selectObject.count; i ++) {
            NSMutableDictionary *tempdic = [NSMutableDictionary dictionary];
            NSString *idstring =[LVTools mToString: _selectObject[i][@"id"]];
            [tempdic setValue:idstring forKey:@"typeid"];
            [tempdic setValue:@"DDLX_0004" forKey:@"type"];
            [temp addObject:tempdic];
        }
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:[LVTools mToString:[kUserDefault valueForKey:kUserId]] forKey:@"uid"];
        [dic setValue:[LVTools mToString: [kUserDefault valueForKey:kUserName]] forKey:@"username"];
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)_selectObject.count] forKey:@"quantity"];
        [dic setValue:@"DDLX_0004" forKey:@"orderType"];
        [dic setValue:[NSString stringWithFormat:@"%.2f",_costNum] forKey:@"amount"];
        [dic setValue:temp forKey:@"placeOrders"];
        [dic setValue:_vennueModel.id forKey:@"goodsId"];
        NSLog(@"%@",dic);
        [DataService requestWeixinAPI:addPlaceOrders parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            if ([result[@"statusCode"] isEqualToString:@"success"]) {
                NSLog(@"%@",result);
                WPCOrderPayVC *vc = [[WPCOrderPayVC alloc] init];
                vc.dic = self.infoDic;
                vc.ordertype = self.ordertype;
                vc.taocanModel = self.taocanModel;
                vc.vennueModel = self.vennueModel;
                vc.orderName = [LVTools mToString:result[@"orderName"]];
                vc.orderCost = [LVTools mToString:result[@"amount"]];
                vc.orderNum = [LVTools mToString:result[@"orderNum"]];
                vc.orderId = [LVTools mToString:result[@"oId"]];
                vc.time = [LVTools mToString:result[@"createtime"]];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self showHint:@"订单提交失败"];
            }
        }];
    } else {
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:[LVTools mToString: [kUserDefault valueForKey:kUserName]] forKey:@"username"];
        [dic setValue:[LVTools mToString: [kUserDefault valueForKey:kUserId]] forKey:@"uid"];
        [dic setValue:_countLab.text forKey:@"quantity"];
        [dic setValue:@"DDLX_0001" forKey:@"orderType"];
        [dic setValue:_taocanModel.packageName forKey:@"orderName"];
        [dic setValue:_taocanModel.id forKey:@"goodsId"];
        [dic setValue:_taocanModel.discountPrice forKey:@"unitPrice"];
        NSMutableDictionary *tempdic = [NSMutableDictionary dictionary];
        [tempdic setValue:[LVTools mToString: _taocanModel.id] forKey:@"packageId"];
        [dic setValue:tempdic forKey:@"packageParam"];
        
        
        NSLog(@"dic ===============%@",dic);
        [DataService requestWeixinAPI:payVenuesPackage parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"result ============================== %@",result);
            if ([result[@"statusCode"] isEqualToString:@"success"]) {
                WPCOrderPayVC *vc = [[WPCOrderPayVC alloc] init];
                vc.dic = self.infoDic;
                vc.totalCost = [NSString stringWithFormat:@"%.2f",[[LVTools mToString:_taocanModel.discountPrice] floatValue]*[_countLab.text intValue]];
                vc.ordertype = self.ordertype;
                vc.taocanModel = self.taocanModel;
                vc.vennueModel = self.vennueModel;
                vc.orderNum = [LVTools mToString:result[@"orderNum"]];
                vc.orderId = [LVTools mToString:result[@"oId"]];
                vc.orderName = [LVTools mToString:result[@"orderName"]];
                vc.orderCost = [LVTools mToString:result[@"amount"]];
                vc.time = [LVTools mToString:result[@"createtime"]];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self showHint:@"订单提交失败"];
            }
        }];
    }
}

#pragma mark -- tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        UILabel *prefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 65, 16)];
        prefixLabel.text = _prefixArray[indexPath.row];
        prefixLabel.textColor = [UIColor grayColor];
        prefixLabel.font = [UIFont systemFontOfSize:14];
        prefixLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:prefixLabel];
        UIView *grayline = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height-1, UISCREENWIDTH, 1)];
        grayline.backgroundColor = RGBACOLOR(240, 240, 240, 1);
        [cell.contentView addSubview:grayline];
        
        if (indexPath.row == 0) {
            UILabel *venueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(prefixLabel.frame)+20, 14, UISCREENWIDTH-CGRectGetMaxX(prefixLabel.frame)-40, 16)];
            venueLabel.text = self.vennueModel.venuesName;
            venueLabel.font = [UIFont systemFontOfSize:14];
            venueLabel.textColor = [UIColor blackColor];
            venueLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:venueLabel];
        } else if (indexPath.row == 1) {
            if ([self.ordertype isEqualToString:@"1"]) {
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(prefixLabel.frame)+20, 14, UISCREENWIDTH-CGRectGetMaxX(prefixLabel.frame)-40, 16)];
                timeLabel.text =[LVTools mToString: self.infoDic[@"date"]];
                timeLabel.font = [UIFont systemFontOfSize:14];
                timeLabel.textAlignment = NSTextAlignmentRight;
                timeLabel.textColor = [UIColor blackColor];
                [cell.contentView addSubview:timeLabel];
            } else {
                prefixLabel.text = @"团购券名:";
                UILabel *teamBuyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 35, UISCREENWIDTH-80-100, 15)];
                teamBuyLabel.textAlignment = NSTextAlignmentRight;
                teamBuyLabel.textColor = [UIColor blackColor];
                teamBuyLabel.font = [UIFont systemFontOfSize:15];
                teamBuyLabel.text =[LVTools mToString: self.taocanModel.packageName];
                [cell.contentView addSubview:teamBuyLabel];
                
                moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(teamBuyLabel.right+10, 35, 50, 15)];
                moneyLabel.text = [NSString stringWithFormat:@"%@元",_taocanModel.discountPrice];
                moneyLabel.textAlignment = NSTextAlignmentRight;
                moneyLabel.font = [UIFont systemFontOfSize:15];
                moneyLabel.textColor = [UIColor blackColor];
                [cell.contentView addSubview:moneyLabel];
                
                grayline.frame = CGRectMake(0, 59, UISCREENWIDTH, 1);
            }
        } else if (indexPath.row == 2) {
            if ([self.ordertype isEqualToString:@"1"]) {
                NSMutableArray *bookArr = [NSMutableArray array];
                NSArray *arr = self.infoDic[@"infos"];
                for (int i = 0; i < arr.count; i ++) {
                    NSString *str1 = arr[i][@"time"];
                    NSString *str2 = arr[i][@"place"];
                    NSString *str3 = [NSString stringWithFormat:@"%@元",arr[i][@"price"]];
                    NSArray *tempArray = @[str1,str2,str3];
                    [bookArr addObject:tempArray];
                }
                grayline.frame= CGRectMake(0, 44+22*bookArr.count, UISCREENWIDTH, 1);
                for (int i = 0; i < bookArr.count; i ++) {
                    for (int j = 0; j < 3; j ++) {
                        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/5*2+UISCREENWIDTH/5*j, 40+22*i, UISCREENWIDTH/5, 22)];
                        lab.font = [UIFont systemFontOfSize:15];
                        lab.textAlignment = NSTextAlignmentCenter;
                        lab.text = bookArr[i][j];
                        lab.backgroundColor = [UIColor clearColor];
                        lab.textColor = [UIColor blackColor];
                        [cell.contentView addSubview:lab];
                    }
                }
            } else {
                prefixLabel.text = @"数       量:";
                UIButton *minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                minusBtn.backgroundColor = RGBACOLOR(200, 200, 200, 1);
                [minusBtn setTitle:@"-" forState:UIControlStateNormal];
                [minusBtn addTarget:self action:@selector(minusAction) forControlEvents:UIControlEventTouchUpInside];
                minusBtn.frame = CGRectMake(UISCREENWIDTH-108, 9, 26, 26);
                minusBtn.titleLabel.textColor = [UIColor whiteColor];
                [cell.contentView addSubview:minusBtn];
                
                UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                addBtn.backgroundColor = RGBACOLOR(242, 69, 65, 1);
                addBtn.titleLabel.textColor = [UIColor whiteColor];
                [addBtn setTitle:@"+" forState:UIControlStateNormal];
                [addBtn addTarget:self action:@selector(plusAction) forControlEvents:UIControlEventTouchUpInside];
                addBtn.frame = CGRectMake(UISCREENWIDTH-46, 9, 26, 26);
                [cell.contentView addSubview:addBtn];
                
                _countLab = [[UILabel alloc] initWithFrame:CGRectMake(minusBtn.right+3, 12, 30, 20)];
                _countLab.font = [UIFont systemFontOfSize:15];
                _countLab.textAlignment = NSTextAlignmentCenter;
                _countLab.text = @"1";
                [cell.contentView addSubview:_countLab];
            }
        } else if (indexPath.row == 3) {
            costlab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(prefixLabel.frame)+20, 10, UISCREENWIDTH-CGRectGetMaxX(prefixLabel.frame)-40, 30)];
            if (moneyLabel != nil) {
                costlab.text = moneyLabel.text;
            } else {
                costlab.text = [NSString stringWithFormat:@"%.2f元",[[self.infoDic valueForKey:@"costNum"] floatValue]];
            }
            costlab.font = [UIFont systemFontOfSize:15];
            costlab.textColor = [UIColor blackColor];
            costlab.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:costlab];
        }
    } else {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 28, 28)];
        [img setImage:[UIImage imageNamed:@"change_binding"]];
        [cell.contentView addSubview:img];
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+10, 14, 140, 16)];
        lab.textColor = [UIColor blackColor];
        lab.text = @"已绑定手机号";
        lab.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:lab];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *phoneNumLab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2, 14, UISCREENWIDTH/2-25, 16)];
        phoneNumLab.textAlignment = NSTextAlignmentRight;
        if ([[LVTools mToString:[kUserDefault valueForKey:KUserMobile]] length] == 11) {
            NSMutableString *phoneStr = [NSMutableString stringWithString:[LVTools mToString:[kUserDefault valueForKey:KUserMobile]]];
            [phoneStr replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            phoneNumLab.text = phoneStr;
        }
        phoneNumLab.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:phoneNumLab];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark -- tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.ordertype isEqualToString:@"1"]) {
        if (indexPath.row == 2 && indexPath.section == 0) {
            return 44+22*[self.infoDic[@"infos"] count];
        }
    } else {
        if (indexPath.row == 1 && indexPath.section == 0) {
            return 60;
        }
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSLog(@"wahaha");
    }
}

#pragma mark -- method
- (void)minusAction {
    int i = [_countLab.text intValue];
    if (i > 1) {
        i --;
        _countLab.text =[NSString stringWithFormat:@"%d",i];
    } else {
        [self showHint:@"最低数量不得小于1"];
    }
    CGFloat cost = [[moneyLabel.text substringToIndex:(moneyLabel.text.length-1)] floatValue];
    costlab.text = [NSString stringWithFormat:@"%.2f元",cost*i];
    
    NSString *str = [NSString stringWithFormat:@"总计：%.2f元",cost*i];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, str.length-3)];
    _costLabel.attributedText = attributeStr;
}

- (void)plusAction {
    int i = [_countLab.text intValue];
    i ++;
    _countLab.text = [NSString stringWithFormat:@"%d",i];
    CGFloat cost = [[moneyLabel.text substringToIndex:(moneyLabel.text.length-1)] floatValue];
    costlab.text = [NSString stringWithFormat:@"%.2f元",cost*i];
    NSString *str = [NSString stringWithFormat:@"总计：%.2f元",cost*i];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(165, 168, 171, 1) range:NSMakeRange(0, 3)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(110, 174, 203, 1) range:NSMakeRange(3, str.length-3)];
    _costLabel.attributedText = attributeStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
