//
//  ZHSelfSportController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHSelfSportController.h"
#import "ZHAppointItemCell.h"
#import "ZHSportOrderCell.h"
#import "GetAppliesModel.h"
#import "GetMatchListModel.h"
#import "ZHAppointDetailController.h"
#import "WPCSportDetailVC.h"
#import "ZHAppointBuildController.h"
#import "EmpatyView.h"

@interface ZHSelfSportController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>{
    NSMutableArray *selfplayDataArr;
    NSMutableArray *otherplayDataarr;
    NSMutableArray *matchDataArr;
    NSArray *selfplaydicArr;
    NSArray *otherplaydicArr;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UISegmentedControl *segCon;
@end

@implementation ZHSelfSportController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    if (_type==0) {
    selfplayDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    otherplayDataarr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    else{
        matchDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.view addSubview:self.mTableView];
//    [self loadData];
    
}



//取消应战
- (void)cancelPlayWithId:(NSString*)appID{
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:appID forKey:@"id"];
    [DataService requestWeixinAPI:delReply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            [self showHint:@"取消应战成功"];
        }
        else{
            [self showHint:@"取消应战失败"];
        }
    }];

}
//删除约战
- (void)dePlayWith:(NSString*)appID{
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:appID forKey:@"id"];
    [DataService requestWeixinAPI:delReply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            [self showHint:@"删除约战成功"];
        }
        else{
            [self showHint:@"取消应战失败"];
        }
    }];

}
- (void)loadData{
    if (_type == 0) {
    NSMutableDictionary *dic=[LVTools getTokenApp];
    [dic setObject:[kUserDefault valueForKey:kUserId]  forKey:@"uid"];
    request=  [DataService requestWeixinAPI:getPlayList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"result=%@",result);
        NSDictionary *dic=(NSDictionary *)result;
        NSLog(@"resulterror=%@",[result valueForKey:@"error"]);
        if ([[dic objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
        {
            [selfplayDataArr removeAllObjects];
            NSArray *applylist=[dic objectForKey:@"applyList"];
            if (applylist.count!=0&&![applylist isKindOfClass:[NSNull class]]) {
                for (NSDictionary *dictory in applylist) {
                    GetAppliesModel *model=[[GetAppliesModel alloc]init];
                    [model setValuesForKeysWithDictionary:dictory];
                    model.username = [LVTools mToString:[kUserDefault objectForKey:kUserName]];
                    model.userLogoPath = [LVTools mToString:[kUserDefault objectForKey:KUserIcon]];
                    [selfplayDataArr addObject:model];
                }
                selfplaydicArr = applylist;
            }
            [otherplayDataarr removeAllObjects];
            NSArray *replyList=[dic objectForKey:@"replyList"];
            if (replyList.count!=0&&![replyList isKindOfClass:[NSNull class]]) {
                for (NSDictionary *dic in replyList) {
                    GetAppliesModel *model=[[GetAppliesModel alloc]init];
                    NSDictionary *dicapply=[dic objectForKey:@"apply"];
                    [model setValuesForKeysWithDictionary:dicapply];
                    [otherplayDataarr addObject:model];
                }
                otherplaydicArr = replyList;
            }
        }
        
        [_mTableView reloadData];
        if (_segCon.selectedSegmentIndex==0) {
            if (selfplayDataArr.count==0) {
                self.mTableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptyAppoint" AndText:@"暂无相关约战信息,赶快去约战吧"];
            }
            else{
                self.mTableView.backgroundView = nil;
            }
        }
        else{
            if (otherplayDataarr.count==0) {
                self.mTableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptyAppoint" AndText:@"暂无相关约战信息,赶快去约战吧"];
            }
            else{
                self.mTableView.backgroundView = nil;
            }

        }
    }];
    }
    else{
        //赛事
        NSMutableDictionary *dic=[LVTools getTokenApp];
        [dic setObject:[kUserDefault valueForKey:kUserId]  forKey:@"uid"];
        request = [DataService requestWeixinAPI:getNotOrderSigup parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSDictionary *dic=(NSDictionary *)result;
            NSLog(@"dic=%@",dic);
            if ([result[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            NSNull *value=[dic objectForKey:@"myNotOrderSigupList"];
            if(value!=[NSNull null])
            {
                [matchDataArr removeAllObjects];
                for (NSDictionary *dict in [dic objectForKey:@"myNotOrderSigupList"] ) {
                    GetMatchListModel *model=[[GetMatchListModel alloc]init];
                    [model setValuesForKeysWithDictionary:dict];
                    [matchDataArr addObject:model];
                }
            }
            [_mTableView reloadData];
                if (matchDataArr.count==0) {
                    _mTableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptySport" AndText:@"暂无相关赛事信息"];
                }
                else{
                    _mTableView.backgroundView = nil;
                }
            }
            else{
                [self showHint:ErrorWord];
            }
        }];
    }
}
- (void)changeSegOnClick:(UISegmentedControl*)seg{
    [self.mTableView reloadData];
    if (_segCon.selectedSegmentIndex==0) {
        if (selfplayDataArr.count==0) {
            self.mTableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptyAppoint" AndText:@"暂无相关约战信息,赶快去约战吧"];
        }
        else{
            self.mTableView.backgroundView = nil;
        }
    }
    else{
        if (otherplayDataarr.count==0) {
            self.mTableView.backgroundView = [[EmpatyView alloc]initWithImg:@"emptyAppoint" AndText:@"暂无相关约战信息,赶快去约战吧"];
        }
        else{
            self.mTableView.backgroundView = nil;
        }
        
    }

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    if (_type == 0) {
    if (self.segCon.superview==nil) {
        [self.navigationController.navigationBar addSubview:self.segCon];
    }
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_type == 0) {
    if (self.segCon.superview) {
        [self.segCon removeFromSuperview];
    }
    }
}
#pragma mark Getter
- (UISegmentedControl*)segCon{
    if (_segCon == nil) {
        _segCon = [[UISegmentedControl alloc] initWithItems:@[@"约战",@"应战"]];
        _segCon.frame = CGRectMake((BOUNDS.size.width-200)/2.0, 7, BOUNDS.size.width*0.6, 30);
        _segCon.selectedSegmentIndex = 0;
        _segCon.tintColor = [UIColor colorWithRed:0.831f green:0.933f blue:0.996f alpha:1.00f];
        [_segCon addTarget:self action:@selector(changeSegOnClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _segCon;
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64)];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mTableView;
}

#pragma mark UITableviewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_type == 0) {
    if(_segCon.selectedSegmentIndex==0)
    return selfplayDataArr.count;
    else
        return otherplayDataarr.count;
    }
    else{
        return matchDataArr.count;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.type == 0) {//约战
        
        ZHAppointDetailController *zhappointDetailVC =[[ZHAppointDetailController alloc] init];
        if(_segCon.selectedSegmentIndex==0)
            zhappointDetailVC.model = [selfplayDataArr objectAtIndex:indexPath.row];
        else
            zhappointDetailVC.model = [otherplayDataarr objectAtIndex:indexPath.row];
    
        zhappointDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:zhappointDetailVC animated:YES];

    }
    else{
         //赛事
        WPCSportDetailVC *vc = [[WPCSportDetailVC alloc] init];
        vc.MatchModel = [matchDataArr objectAtIndex:indexPath.row];
        ZHSportOrderCell *cell =(ZHSportOrderCell*)[tableView cellForRowAtIndexPath:indexPath];
        vc.sportImg = cell.SportImg.image;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_type == 0) {
        static NSString *venueorderCell = @"ZHAppointItemCell";
        ZHAppointItemCell *cell= [tableView dequeueReusableCellWithIdentifier:venueorderCell];
        if (cell == nil) {
            cell = [[ZHAppointItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:venueorderCell];
        }
        cell.tag = 100+indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        GetAppliesModel *model = nil;
        if(_segCon.selectedSegmentIndex==0){
            model = [selfplayDataArr objectAtIndex:indexPath.row];
            model.username = [LVTools mToString:[kUserDefault objectForKey:kUserName]];
            model.userLogoPath = [LVTools mToString:[kUserDefault objectForKey:KUserIcon]];
        }
        else{
            model = [otherplayDataarr objectAtIndex:indexPath.row];
        }
        [cell configDefaultModel:model];
        [cell.headImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[kUserDefault objectForKey:KUserIcon]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
        return cell;
    }
    else{
        static NSString *sportorderCell = @"sportorderCell";
        ZHSportOrderCell *cell= [tableView dequeueReusableCellWithIdentifier:sportorderCell];
        if (cell == nil) {
            cell = [[ZHSportOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sportorderCell];
        }
        cell.tag = 100+indexPath.row;
        GetMatchListModel *model = [matchDataArr objectAtIndex:indexPath.row];
        [cell configMatchModel:model];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.rightUtilityButtons = [self sportBtns];
        cell.delegate = self;
        cell.payBtn.hidden = YES;
        return cell;
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_type==0){
        return NO;
    }
    else{
    return YES;
    }
}

- (NSArray *)sportBtns {
    NSMutableArray *rightButtons = [NSMutableArray new];
    [rightButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
    return rightButtons;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_type == 0) {
        return 5.0+44.0+90.0+15;
    }
    else{
        return 100.0;
    }
}
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if(self.segCon.selectedSegmentIndex ==  0){
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor lightGrayColor] title:@"修改"];
    }
    else{
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor lightGrayColor] title:@"取消应战"];
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.99f green:0.01f blue:0.01f alpha:1.0]
                                                title:@"删除"];
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    if (_type == 0) {
        if(_segCon.selectedSegmentIndex == 0){
            //我的约战
            if(index==0){
                //修改应战
                
                GetAppliesModel *_builddic = [selfplayDataArr objectAtIndex:cell.tag-100];
                NSLog(@"%d",(int)(cell.tag)-100);
                //修改,推到发起约占界面
                NSString *timeOut = [LVTools time:_builddic.playTime];
                //判断该约战是否过去，过期就提示
                if ([timeOut isEqualToString:@"1"]) {
                    [self showHint:@"该约战已过期，不能修改"];
                } else {
                    ZHAppointBuildController *vc = [[ZHAppointBuildController alloc] init];
                    vc.title = @"修改约战";
                    vc.chuanBlock = ^(NSArray *arr) {
                        [self loadData];
                    };
                    vc.idString = [LVTools mToString:_builddic.id];
                    vc.datasource = [NSMutableDictionary dictionaryWithDictionary:[selfplaydicArr objectAtIndex:cell.tag-100]];
                    [self.navigationController pushViewController:vc animated:YES];
                }

            }
            else{
                //删除约战
                [WCAlertView showAlertWithTitle:nil message:@"确定删除该约战吗？" customizationBlock:^(WCAlertView *alertView) {
                    NSLog(@"1");
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    if (buttonIndex == 1) {
                        //向服务器提交删除约战的数据。同时返回首页
                        GetAppliesModel *_builddic = [selfplayDataArr objectAtIndex:cell.tag-100];
                        NSMutableDictionary *dic = [LVTools getTokenApp];
                        [dic setObject:[LVTools mToString:_builddic.id] forKey:@"id"];
                        [self showHudInView:self.view hint:@"正在删除"];
                        [DataService requestWeixinAPI:deletePlayApply parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"post" completion:^(id result) {
                            [self hideHud];
                            if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                                [self showHint:@"删除成功"];
//                                [selfplayDataArr removeObjectAtIndex:cell.tag-100];
//                                [_mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cell.tag-100 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                [self loadData];
                            } else {
                                [self showHint:@"删除失败"];
                            }
                        }];
                    }
                } cancelButtonTitle:@"放弃" otherButtonTitles:@"确定", nil];
            }
        }
        else{
            //我的应战
            NSDictionary *model = [otherplaydicArr objectAtIndex:cell.tag-100];
            
            NSMutableDictionary *dic=[LVTools getTokenApp];
            [dic setValue:[LVTools mToString:model[@"id"]] forKey:@"id"];
            NSLog(@"%@",[LVTools mToString:model[@"id"]]);
            [DataService requestWeixinAPI:deletePlayReply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
                NSLog(@"删除应战%@",result);
                if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]){
                    [self showHint:@"操作完成"];
//                    [otherplayDataarr removeObjectAtIndex:cell.tag-100];
//                    [_mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cell.tag-100 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    [self loadData];
                }
                else{
                    [self showHint:@"操作失败"];
                }
            }];
        }
    } else {
        //赛事
        //取消报名
        GetMatchListModel *model = [matchDataArr objectAtIndex:cell.tag-100];
        [WCAlertView showAlertWithTitle:nil message:@"确定要取消该报名吗" customizationBlock:^(WCAlertView *alertView) {
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 1) {
                NSMutableDictionary *dic = [LVTools getTokenApp];
                [dic setValue:model.signUpId forKey:@"id"];
                NSLog(@"dic ==== %@",dic);
                [DataService requestWeixinAPI:delMatchSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                    if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                        UIButton *btn = (UIButton *)[self.view viewWithTag:311];
                        [btn setImage:[UIImage imageNamed:@"baoming_wpc"] forState:UIControlStateNormal];
                    } else {
                        [self showHint:@"取消报名失败，请重试"];
                    }
                }];
            }
        } cancelButtonTitle:@"放弃" otherButtonTitles:@"确定", nil];
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
