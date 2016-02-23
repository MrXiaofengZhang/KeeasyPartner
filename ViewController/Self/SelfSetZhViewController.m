//
//  SelfSetZhViewController.m
//  NetWorking
//
//  Created by zhoujin on 15/3/20.
//  Copyright (c) 2015年 zhoujin. All rights reserved.
//

#import "SelfSetZhViewController.h"
#import "SelfRespectZhViewController.h"
#import "ZHAgreementViewController.h"
#import "SDImageCache.h"
#import "LVShareManager.h"
#import "AppDelegate.h"
#import "UMSocial.h"
#import "ApplyViewController.h"
#import "XGPush.h"
#define CELLHIGHT 50
@interface SelfSetZhViewController ()
{
    NSArray *_dataArray;
    UITableView *_tableView;
    
}

@property (nonatomic, strong)UISwitch *msgSwitch;

@end

@implementation SelfSetZhViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.navigationBar.hidden=NO;
    _dataArray = @[@"系统设置",@"清空缓存",@"邀请好友使用校动",@"其他",/*@"客服电话：400—6643255",*/@"用户协议",@"关于校动",@"去App Store评分"];
  
  
   _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64.0) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [self createfooterview];
    
}

- (UISwitch *)msgSwitch {
    if (!_msgSwitch) {
        _msgSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(UISCREENWIDTH-70, 10, 0, 0)];
        [_msgSwitch addTarget:self action:@selector(msgPushOn) forControlEvents:UIControlEventValueChanged];
        _msgSwitch.on = YES;
        _msgSwitch.onTintColor = NavgationColor;
    }
    return _msgSwitch;
}

- (UIView *)createfooterview {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 80)];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 22, UISCREENWIDTH-30, 45)];
    lab.text = @"退出登录";
    lab.backgroundColor = RGBACOLOR(244.0, 67.0, 54.0, 1);
    lab.layer.cornerRadius = 3;
    lab.layer.masksToBounds = YES;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor whiteColor];
    lab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginoutAction:)];
    [lab addGestureRecognizer:tap];
    if([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]){
        lab.hidden = NO;
    }
    else{
        lab.hidden = YES;
    }
    [view addSubview:lab];
    return view;
}

- (void)loginoutAction:(UITapGestureRecognizer *)tap {
    //todo
     [WCAlertView showAlertWithTitle:nil message:@"退出登录" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
            [self showHudInView:self.view hint:@"正在退出..."];
            [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
                [self hideHud];
                if (!error) {
                    NSLog(@"退出环信服务器成功");
                    [XGPush setAccount:@"*"];
                    [XGPush registerDeviceStr:[kUserDefault objectForKey:KxgToken]];
                    [[ApplyViewController shareController] clear];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
                    [kUserDefault setValue:@"0" forKey:kUserLogin];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
                    [kUserDefault setObject:nil forKey:kUserId];
                    [kUserDefault setValue:nil forKey:kUserPassword];
                    [kUserDefault setValue:nil forKey:kUserName];
                    [kUserDefault setValue:nil forKey:KUserMobile];
                    //个人信息移除本地
                    [kUserDefault setValue:nil forKey:[NSString stringWithFormat:@"xd%@",[kUserDefault objectForKey:kUserId]]];
//                    [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:dic[@"data"]] Key:[NSString stringWithFormat:@"xd%@", [LVTools mToString: dic[@"data"][@"user"][@"userId"]]]];
                    [kUserDefault synchronize];
                    [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
                        NSLog(@"response is %@",response);
                    }];
                    [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
                        NSLog(@"response is %@",response);
                    }];
                    [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToSina  completion:^(UMSocialResponseEntity *response){
                        NSLog(@"response is %@",response);
                    }];
                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
                    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
                    //退出成功，返回到之前节面

                    //发通知刷新个人中新页面 
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSTATECHANGE_NOTIFICATION object:@NO userInfo:nil];

                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else{
                    [self showHint:[NSString stringWithFormat:@"退出失败原因:%d,%@",(int)(error.errorCode),error.description]];
                }
            } onQueue:nil];
        }
    } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
}

- (void)msgPushOn {
    if (_msgSwitch.on) {
        //打开消息推送
    } else {
        //关闭消息推送
    }
}

#pragma mark-UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CELL=@"cell";
    UITableViewCell *table=[tableView dequeueReusableCellWithIdentifier:CELL];
    if (table==nil) {
        table=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
    }
    table.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    table.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    for (UIView *view in table.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(LEFTX, CELLHIGHT/3, BOUNDS.size.width-2*LEFTX, CELLHIGHT/3)];
    label.backgroundColor = [UIColor clearColor];
    label.text = _dataArray[indexPath.row];
    label.textColor=[UIColor darkGrayColor];
    if([label.text isEqualToString:@"清空缓存"]) {
      CGFloat tmpSize = [[SDImageCache sharedImageCache] getSize];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(200, CELLHIGHT/3, UISCREENWIDTH-LEFTX-200-LEFTX, CELLHIGHT/3)];
        label.tag=100;
        label.text=[NSString stringWithFormat:@"%0.2lfMB",(tmpSize/1024.0/1024.0)];
        label.textAlignment=NSTextAlignmentRight;
        [table.contentView addSubview:label];
       
    } else if ([label.text isEqualToString:@"客服电话：400—6643255"]) {
         table.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    } else if ([label.text isEqualToString:@"消息推送"]) {
        [table.contentView addSubview:self.msgSwitch];
        table.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.row == 0 || indexPath.row == 3) {
        label.font = [UIFont boldSystemFontOfSize:17];
        table.accessoryType = UITableViewCellAccessoryNone;
    }
    UILabel *linelabel=[[UILabel alloc]initWithFrame:CGRectMake(LEFTX, CELLHIGHT-0.3, UISCREENWIDTH-LEFTX, 0.3)];
    linelabel.backgroundColor=lightColor;
    [table.contentView addSubview:linelabel];
    
    table.selectionStyle=UITableViewCellSelectionStyleNone;
    [table.contentView addSubview:label];
    return table;
}
#pragma mark-UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)burItemClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"确定清理缓存的数据吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 101;
        [alertView show];
    }
    if (indexPath.row == 2) {
        [LVShareManager shareText:[NSString stringWithFormat:@"点击下载校动官方App-交球友，一起愉快的play吧%@",kDownLoadUrl] Targert:self];
    }
    if (indexPath.row == 1000) {
//        SelfRespectZhViewController *respect=[[SelfRespectZhViewController alloc]init];
//        respect.title=@"关于校动";
//        [self.navigationController pushViewController:respect animated:YES];

        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"4006643255"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    if (indexPath.row == 4) {
        ZHAgreementViewController *agreement=[[ZHAgreementViewController alloc]init];
        agreement.title=@"用户协议";
        agreement.urlstring=[NSString stringWithFormat:@"%@%@",VHAKKWEIXIN_URL,kProtocolUrl];
        [self.navigationController pushViewController:agreement animated:YES];
        //[self goToAppStore];
    }
    if (indexPath.row == 5) {
        SelfRespectZhViewController *respect=[[SelfRespectZhViewController alloc]init];
        respect.title=@"关于校动";
        [self.navigationController pushViewController:respect animated:YES];
    }
    if (indexPath.row == 6){
        [self goToAppStore];
    }
}
-(void)goToAppStore
{
    NSString *str = [NSString stringWithFormat:
                     @"http://itunes.apple.com/app/id982404823?mt=8"]; //appID 解释如下
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}
#pragma mark-UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        if (alertView.tag == 101) {
            UILabel *label=(UILabel *)[_tableView viewWithTag:100];
            label.text=@"0.00MB";
            [[SDImageCache sharedImageCache] clearDisk];
            if(TARGET_IPHONE_SIMULATOR){
            //清除asi缓存
//            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            [appDelegate.myCache clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
