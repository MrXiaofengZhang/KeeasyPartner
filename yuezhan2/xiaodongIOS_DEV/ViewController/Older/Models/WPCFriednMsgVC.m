//
//  WPCFriednMsgVC.m
//  yuezhan123
//
//  Created by admin on 15/5/14.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCFriednMsgVC.h"
#import "WPCFriendMsgTableViewCell.h"
#import "ChatViewController.h"
//#import "WPCTimeMachineVC.h"
#import "LoginLoginZhViewController.h"
#import "ZHJubaoController.h"
#import "ZHTeamDetailController.h"
#import "TeamModel.h"
#import "ScoreCell.h"
#import "SingleImageController.h"
#import "SportResultController.h"
#import "PopoverView.h"
@interface WPCFriednMsgVC () <UITableViewDataSource,UITableViewDelegate>
{
    BOOL newDynamic;
}
@property (nonatomic, strong)UITableView *msgTableView;
@property (nonatomic, strong)NSMutableArray *resultArr;//个人参赛积分
@property (nonatomic, strong)NSArray *preInfoArr;
@property (nonatomic, strong)NSArray *iconArr;
@property (nonatomic, strong)NSDictionary *dic;
@property (nonatomic, strong)NSString *fuid;
@property (nonatomic, assign)BOOL logined;
@property (nonatomic, strong)NSMutableArray *myTeamArray;

@end

@implementation WPCFriednMsgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hasLogin];
    newDynamic = YES;
    self.isfriend = YES;
    _preInfoArr = @[@[@"基本资料"],@[@"Ta的时光机",@"Ta的战队",@"Ta的群组"]];
    _iconArr = @[@[@"personal_info"],@[@"time_machine",@"my_team",@"his_group"]];
    [self navgationBarLeftReturn];
    [self initialInterface];
    [self loadData];
    [self getMyTeamArray];
}

- (void)initialInterface
{
    self.msgTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, UISCREENWIDTH, UISCREENHEIGHT+20-45.0) style:UITableViewStylePlain];
    self.msgTableView.dataSource = self;
    self.msgTableView.delegate = self;
    self.msgTableView.backgroundColor = [UIColor clearColor];
//    self.msgTableView.backgroundColor = UIColorFromRGB(234, 234, 234);
    self.msgTableView.showsVerticalScrollIndicator = NO;
    
    self.msgTableView.tableHeaderView = [self createTheTableHeaderView];
    
    self.msgTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 25.0)];
    [self.view addSubview:self.msgTableView];
}
#pragma mark --加载战队信息
- (void)getMyTeamArray {
//    NSDictionary *dic = [LVTools getTokenApp];
//    [dic setValue:_uid forKey:@"uid"];
//    [DataService requestWeixinAPI:getMyTeamList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
//        NSLog(@"%@",result);
//        if ([result[@"statusCode"] isEqualToString:@"success"]) {
//            if (self.myTeamArray == nil) {
//                self.myTeamArray = [[NSMutableArray alloc] initWithCapacity:0];
//            }for (NSDictionary *dic in result[@"teamList"]) {
//                TeamModel *model = [[TeamModel alloc]init];
//                [model setValuesForKeysWithDictionary:dic];
//                [_myTeamArray addObject:model];
//            }
//            [_msgTableView reloadData];
//            
//        } else {
//            [self showHint:ErrorWord];
//        }
//    }];
}

- (void)createTheTableFooterView
{
    //进行判断，是否是战友
    
        UIButton *msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [msgBtn addTarget:self action:@selector(sendMsg:) forControlEvents:UIControlEventTouchUpInside];
        msgBtn.frame = CGRectMake(0, UISCREENHEIGHT-45, UISCREENWIDTH, 45);
        msgBtn.backgroundColor = SystemBlue;
        msgBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        msgBtn.layer.cornerRadius = mygap;
        [msgBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [msgBtn setTitle:@"发消息" forState:UIControlStateNormal];
        [msgBtn setTitle:@"添加为好友" forState:UIControlStateSelected];
        if (self.isfriend) {
            msgBtn.selected = NO;
        }
        else{
            msgBtn.selected = YES;
        }
        [self.view addSubview:msgBtn];
       
//    } else {
//        NSArray *arr = @[@"添加为好友"];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, UISCREENHEIGHT-45, BOUNDS.size.width, 45)];
//        view.backgroundColor = [UIColor whiteColor];
//        view.layer.borderWidth = 0.5;
//        view.layer.borderColor = [RGBACOLOR(210, 210, 210, 1) CGColor];
//        [self.view addSubview:view];
//        for (int i = 0; i < 1; i ++) {
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.frame = CGRectMake(0, 0, BOUNDS.size.width, 45);
//            btn.backgroundColor = SystemBlue;
//            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [btn setTitle:arr[i] forState:UIControlStateNormal];
//            btn.tag = 820+i;
//            [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
//            [view addSubview:btn];
//            
//        }
//    }
}

- (void)clickAction:(UIButton *)sender
{
    if (_logined) {
        
        if (sender.tag == 820) {
            //添加
            if (![[LVTools mToString:_uid] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
            [self insertAddFriendRequest];
            }
            else{
                [self showHint:@"不能添加自己为战友"];
            }
        }
            } else {
        //跳转登陆
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
    }
}

- (void)sendMsg:(UIButton*)btn
{
    if (btn.selected) {
        //非好友
        if (![[LVTools mToString:_uid] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
            [self insertAddFriendRequest];
        }
        else{
            [self showHint:@"不能添加自己为战友"];
        }

    }
    else{
        //好友
    if ([[LVTools mToString:_uid] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
        [self showHint:@"不能和自己聊天"];
    }
    else{
    ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:[LVTools mToString:self.dic[@"userId"]] isGroup:NO WithIcon:self.dic[@"path"]];
    chatVC.title =[LVTools mToString: self.dic[@"nickName"]];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
    }
    }
}

- (UIView *)createTheTableHeaderView
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 220.0+44.0)];
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    UIImage *img1 = [UIImage imageNamed:@"backGround"];
    UIImage *img2 = [UIImage imageNamed:@"back"];
    UIImage *img3 = [UIImage imageNamed:@"more2"];
    UIView *headerView = [LVTools headerViewWithbackgroudcolor:img1 backBtn:img2 settingBtn:img3 beginTag:2500 islogin:islogin isHide:NO];
    
    headerView.tag = 2500;
    UIButton *btn1 = (UIButton *)[headerView viewWithTag:2501];
    [btn1 addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = (UIButton *)[headerView viewWithTag:2502];
    [btn2 addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *img = (UIButton *)[headerView viewWithTag:2503];
    [img addTarget:self action:@selector(headerImageClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:headerView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.bottom, BOUNDS.size.width, 44.0)];
    bottomView.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 12.0, 70.0, 20.0)];
    btn.layer.cornerRadius = 5.0;
    btn.layer.masksToBounds = YES;
    btn.tag = 2601;
    [btn setTitle:@"关注" forState:UIControlStateNormal];
    [btn setTitle:@"取消关注" forState:UIControlStateSelected];
    [btn setBackgroundImage:[LVTools buttonImageFromColor:SystemBlue withFrame:btn.bounds] forState:UIControlStateNormal];
    [btn setBackgroundImage:[LVTools buttonImageFromColor:[UIColor lightGrayColor] withFrame:btn.bounds] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(addclick:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = Content_lbfont;
    [bottomView addSubview:btn];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-130.0, 7.0, 160.0, 24.0)];
    lab.text = @"距离:2.5km  1小时前";
    lab.tag = 2602;
    lab.textAlignment = NSTextAlignmentLeft;
    [bottomView addSubview:lab];
    lab.font = Content_lbfont;
    [view addSubview:bottomView];
    return view;
}
- (void)addclick:(UIButton*)btn{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[LVTools mToString:self.uid] forKey:@"followId"];
    [dic setObject:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setValue:@"1" forKey:@"followType"];
    NSLog(@"%@",dic);
    NSString *optionStr = nil;
    if (!btn.selected) {
        optionStr = addFollow;
    }
    else{
        optionStr = cancleFollow;
    }
    request = [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            btn.selected = !btn.selected;
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
#pragma mark --- cornerBtnClickDelegate
- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    NSLog(@"1");
}

- (void)settingBtnClick
{
    //举报删除好友
    NSLog(@"2");
    if (self.isfriend) {
        CGPoint point = CGPointMake(UISCREENWIDTH-25, 69);
        PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:@[@"举报",@"删除好友"] images:@[@"jubao",@"deleteF"] andStyle:PopoverStyleTrancent];
        pop.borderColor = [UIColor clearColor];
        pop.selectRowAtIndex = ^ (NSInteger index) {
            switch (index) {
                case 1:
                {
                    //删除战友
//                    WPCAddPartnerVC *vc = [[WPCAddPartnerVC alloc] init];
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        EMError *error;
                        [[EaseMob sharedInstance].chatManager removeBuddy:[LVTools mToString: self.uid] removeFromRemote:YES error:&error];
                        if (!error) {
                            [[EaseMob sharedInstance].chatManager removeConversationByChatter:[LVTools mToString: self.uid] deleteMessages:YES append2Chat:YES];
                            //刷新消息个数
                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
                            self.isfriend = NO;
                        }
                        else{
                            [self showHint:@"删除好友失败,请重试"];
                        }
                    });            

                }
                    break;
                case 0:
                {
                    //举报
                    //举报
                    if (![[LVTools mToString:_uid] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
                        ZHJubaoController *jubaoVC = [[ZHJubaoController alloc] init];
                        jubaoVC.reportId = self.uid;
                        [self.navigationController pushViewController:jubaoVC animated:YES];
                    }
                    else{
                        [self showHint:@"不能举报自己"];
                    }
//                    WPCGroupChatVC *vc = [[WPCGroupChatVC alloc] init];
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
        };
        __block PopoverView *tempPop = pop;
        pop.dismissBlock = ^() {
            tempPop = nil;
        };
        [pop show];
    }
    else{
        CGPoint point = CGPointMake(UISCREENWIDTH-25, 69);
        PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:@[@"举报"] images:@[@"jubao"] andStyle:PopoverStyleTrancent];
        pop.borderColor = [UIColor clearColor];
        pop.selectRowAtIndex = ^ (NSInteger index) {
            switch (index) {
                case 0:
                {
                    //举报
                    if (![[LVTools mToString:_uid] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
                        ZHJubaoController *jubaoVC = [[ZHJubaoController alloc] init];
                        jubaoVC.reportId = self.uid;
                        [self.navigationController pushViewController:jubaoVC animated:YES];
                    }
                    else{
                        [self showHint:@"不能举报自己"];
                    }
                }
                    break;
                case 1:
                {
                    //举报
                                       //                    WPCGroupChatVC *vc = [[WPCGroupChatVC alloc] init];
                    //                    vc.hidesBottomBarWhenPushed = YES;
                    //                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
        };
        __block PopoverView *tempPop = pop;
        pop.dismissBlock = ^() {
            tempPop = nil;
        };
        [pop show];

    }
}

- (void)headerImageClick
{
    NSLog(@"3");
}

//判断自己是否登陆，登陆了得出自己的fuid
- (void)hasLogin
{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if ([islogin isEqualToString:@"1"]) {
        //得到fuid
        _fuid = [kUserDefault objectForKey:kUserId];
        _logined = YES;
    } else {
        _logined = NO;
        _fuid = nil;
    }
}
//判断是否已经发送了申请加好友请求
- (BOOL)hasSendBuddyRequest:(NSString *)buddyName
{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState == eEMBuddyFollowState_NotFollowed &&
            buddy.isPendingApproval) {
            return YES;
        }
    }
    return NO;
}
//判断是否在好友列表中
- (BOOL)didBuddyExist:(NSString *)buddyName
{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
   
    for (EMBuddy *buddy in buddyList) {
         NSLog(@"%@",buddy.username);
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState != eEMBuddyFollowState_NotFollowed) {
            return YES;
        }
    }
    return NO;
}

- (void)loadData
{
    NSDictionary * dictionary = [LVTools getTokenApp];
    [dictionary setValue:_uid forKey:@"uid"];
    [dictionary setValue:[kUserDefault objectForKey:kLocationLat] forKey:@"latitude"];
    [dictionary setValue:[kUserDefault objectForKey:kLocationlng] forKey:@"longitude"];
    if (_logined) {
        [dictionary setValue:_fuid forKey:@"myId"];
    }
    [self showHudInView:self.view hint:@"加载好友信息..."];
    [DataService requestWeixinAPI:selfcenterhome parsms:@{@"param":[LVTools configDicToDES:dictionary]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            if (self.myTeamArray == nil) {
                self.myTeamArray = [[NSMutableArray alloc] initWithCapacity:0];
            }
            for (NSDictionary *dic in result[@"data"][@"teams"]) {
                TeamModel *model = [[TeamModel alloc]init];
                [model setValuesForKeysWithDictionary:dic];
                [_myTeamArray addObject:model];
            }
            if (self.resultArr == nil) {
                self.resultArr = [[NSMutableArray alloc] initWithCapacity:0];
            }
            [self.resultArr addObjectsFromArray:result[@"data"][@"records"]];
            if (self.resultArr.count == 0) {
                UIImageView *footView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 40.0)];
                footView.image =[UIImage imageNamed:@"nomore"];
                footView.contentMode = UIViewContentModeCenter;
                self.msgTableView.tableFooterView = footView;
            }
            [_msgTableView reloadData];
            
            self.dic = result[@"data"][@"userInfo"];
            UIView *view = (UIView *)[self.view viewWithTag:2500];
            [LVTools createTheSortsLab:self.dic inView:view];
            UIButton *image = (UIButton *)[self.view viewWithTag:2503];
            [image sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:self.dic[@"path"]]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
            UIButton *namelab = (UIButton *)[self.view viewWithTag:2504];
            if ([[LVTools mToString:self.dic[@"nickName"]] length] != 0) {
                NSLog(@"----------------%@",self.dic[@"nickName"]);
                [namelab setTitle:[LVTools mToString:self.dic[@"nickName"]] forState:UIControlStateNormal];
            } else {
                //todo
                [namelab setTitle:@"无名" forState:UIControlStateDisabled];
            }
            //个性签名
            UILabel *idLab = (UILabel *)[self.view viewWithTag:2505];
            if ([[LVTools mToString:self.dic[@"signature"]] length] != 0) {
                idLab.text = [LVTools mToString:self.dic[@"signature"]];
            } else {
                idLab.text = @"这个家伙很懒,什么也没写";
            }
            //关注数 粉丝数
            UILabel *shuLab = (UILabel *)[self.view viewWithTag:2506];
            if ([[LVTools mToString:self.dic[@"followNum"]] length] != 0) {
                shuLab.text =[NSString stringWithFormat:@"关注  %@   ｜   粉丝  %@",[LVTools mToString:self.dic[@"followNum"]],[LVTools mToString:self.dic[@"fansNum"]]];
            } else {
                shuLab.text = @"关注  0   ｜   粉丝  0";
            }
            UIButton *fllowbtn = (UIButton*)[self.view viewWithTag:2601];
            if ([self.dic[@"isFollow"] boolValue]) {
                fllowbtn.selected = YES;
            }
            else{
                fllowbtn.selected = NO;
            }
            //距离键暂用addr
            UILabel *disLab = (UILabel *)[self.view viewWithTag:2602];
            NSString *distanceStr = nil;
            if ([[LVTools mToString:self.dic[@"distance"]] length] != 0) {
                distanceStr = [NSString stringWithFormat:@"距离:%@km",[NSString stringWithFormat:@"%.1f",[self.dic[@"distance"]floatValue]]];
            } else {
                distanceStr = @"距离:暂无";
            }
            NSString *lastlogin = nil;
            if ([LVTools mToString:self.dic[@"lastlogin"]].length==0) {
                lastlogin = @"未知";
            }
            else{
                lastlogin = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[self.dic[@"lastlogin"] longLongValue]/1000]];
            }
            disLab.text = [NSString stringWithFormat:@"%@  %@",distanceStr,lastlogin];
            [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
                if (!error) {
                    self.isfriend = [self didBuddyExist:[LVTools mToString: self.uid]];
                    [self createTheTableFooterView];
                }
            } onQueue:nil];
            
            [self.msgTableView reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
#pragma mark [加好友]
- (void)insertAddFriendRequest{
    //环信申请添加好友
    [self showHudInView:self.view hint:NSLocalizedString(@"friend.sendApply", @"sending application...")];
    EMError *error;
    [[EaseMob sharedInstance].chatManager addBuddy:[LVTools mToString: self.uid] message:@"申请添加你为好友" error:&error];
    [self hideHud];
    if (error) {
        [self showHint:NSLocalizedString(@"friend.sendApplyFail", @"send application fails, please operate again")];
    }
    else{
        [self showHint:NSLocalizedString(@"friend.sendApplySuccess", @"send successfully")];
    }

//    NSMutableDictionary * dic = [LVTools getTokenApp];
//    [dic setValue:self.uid forKey:@"fuid"];
//    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
//    [dic setValue:@"1" forKey:@"status"];
//    [dic setValue:self.dic[@"userName"] forKey:@"fusername"];
//    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"username"];
//    
//    [self showHudInView:self.view hint:LoadingWord];
//    [DataService requestWeixinAPI:addFrirend parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
//        NSDictionary * resultDic = (NSDictionary *)result;
//        NSLog(@"%@",resultDic);
//        [self hideHud];
//        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
//        {
//            [self showHint:@"加好友成功!"];
//            //底部按钮改变
//            self.isfriend = YES;
//            [self createTheTableFooterView];
//            //好友列表刷新
//          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshOldList object:nil];
//        }
//        else{
//            NSLog(@"请求失败");
//            [self showHint:ErrorWord];
//        }
//    }];
    
}

#pragma mark -- tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.resultArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0&&indexPath.section == 0){
        WPCFriendMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WPCFriendMsgTableViewCell"];
        if (cell == nil) {
            cell = [[WPCFriendMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WPCFriendMsgTableViewCell" andType:11];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.userId = self.uid;
        }
    //cell的内容设置
    //CGFloat cellHeight = cell.bounds.size.height;
    
    //cell.iconImage.image = [UIImage imageNamed:_iconArr[indexPath.section][indexPath.row]];
    //cell.nameLab.text = _preInfoArr[indexPath.section][indexPath.row];
    if(indexPath.section == 1&&indexPath.row == 0){
    }
    else {
       // cell.infoDic = self.dic;
    }
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-35, 12, 20, 20)];
//        image.image = [UIImage imageNamed:@"arrow"];
//        [cell.contentView addSubview:image];
//        if (newDynamic) {
//            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-cellHeight*1.4, cellHeight/6, cellHeight*2/3, cellHeight*2/3)];
//            [cell.contentView addSubview:img];
//        }
//    }
    if (indexPath.section == 0&&indexPath.row == 0) {
        NSInteger a=0,b=0;
        if (UISCREENWIDTH == 320) {
            a = self.myTeamArray.count/4;
            b = self.myTeamArray.count%4;
            
        } else if (UISCREENWIDTH == 375) {
            a = self.myTeamArray.count/5;
            b = self.myTeamArray.count%5;
        } else {
            a = self.myTeamArray.count/6;
            b = self.myTeamArray.count%6;
        }
        cell.teamCollection.height = 90*(b==0?a:(a+1));
        cell.dataArray = self.myTeamArray;
        cell.isSelect = YES;//是否
        cell.selectBlock = ^(UICollectionView *view,NSIndexPath *index){
            ZHTeamDetailController *teamDetail = [[ZHTeamDetailController alloc] init];
            teamDetail.teamModel = _myTeamArray[index.row];
            [self.navigationController pushViewController:teamDetail animated:YES];
        };
        cell.leaderBlock = ^(TeamModel *model){
            SingleImageController *vc= [[SingleImageController alloc] init];
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(772.0/750.0))];
            vc.title = @"球队经理人说明";
            img.image = [UIImage imageNamed:@"球队经理人说明"];
            img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(772.0/750.0));
            vc.imageView = img;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
        cell.levelBlock = ^(TeamModel *model){
            SingleImageController *vc= [[SingleImageController alloc] init];
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(415.0/750.0))];
            vc.title = @"球队标示说明";
            NSInteger teamLevel = [model.teamLevel integerValue];
            if (teamLevel>=1000) {
                img.image = [UIImage imageNamed:@"明星校队说明"];
                img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(921.0/750.0));
                vc.canApply = YES;
            }
            else if(teamLevel==0){
                img.image = [UIImage imageNamed:@"普通球队说明"];
                img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(954.0/750.0));
            }
            else{
                img.image = [UIImage imageNamed:@"校园热队伍说明"];
                img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(901.0/750.0));
            }
            vc.imageView = img;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];

        };
    }
    return cell;
    }
    else{
        ScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mycell"];
        if (cell == nil) {
            cell = [[ScoreCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"mycell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, BOUNDS.size.width, 0, 0);
        }
        [cell configInfo:self.resultArr[indexPath.row]];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
 return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return BOUNDS.size.width*(99.0/750.0)+20;
    } else {
        if (indexPath.row == 0) {
            NSInteger a=0,b=0;
            if (UISCREENWIDTH == 320) {
                a = self.myTeamArray.count/4;
                b = self.myTeamArray.count%4;
                
            } else if (UISCREENWIDTH == 375) {
                a = self.myTeamArray.count/5;
                b = self.myTeamArray.count%5;
            } else {
                a = self.myTeamArray.count/6;
                b = self.myTeamArray.count%6;
            }
            return 90*(b==0?a:(a+1))+20;
        }
    }
    return 44.0;
}
#pragma mark -- tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        SportResultController *sportDVC =[[SportResultController alloc] init];
        sportDVC.title = @"赛事积分";
        NSDictionary *dic = self.resultArr[indexPath.row];
        sportDVC.matchId = dic[@"matchId"];
        sportDVC.uid = self.uid;
        sportDVC.record = dic;
        [self.navigationController pushViewController:sportDVC animated:YES];
    }
//    if (indexPath.section == 0) {
//   
//    } else if (indexPath.section == 1) {
//        if (indexPath.row == 1) {
//            //时光机
//            if ([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
//                
//            
//            if(_isfriend){
//            WPCTimeMachineVC *timeVC = [[WPCTimeMachineVC alloc] init];
//            self.navigationController.navigationBar.hidden = YES;
//            timeVC.userId = [LVTools mToString:self.dic[@"uid"]];
//            timeVC.userName = [LVTools mToString:self.dic[@"userName"]];
//            timeVC.iconPath = [LVTools mToString:self.dic[@"iconPath"]];
//            //[self.navigationController pushViewController:timeVC animated:YES];
//            }
//            else{
//                //添加好友
//                [WCAlertView showAlertWithTitle:nil message:@"添加好友即可查看Ta的时光机" customizationBlock:^(WCAlertView *alertView) {
//                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
//                    if (buttonIndex == 0) {
//                        //添加好友接口
//                        [self insertAddFriendRequest];
//                    }
//                } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//                
//            }
//            }
//            else{
//                //跳转登陆
//                LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
//                [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
//            }
//        } else if (indexPath.row == 0) {
//           //战队
//        } else {
//            //他的群组
//        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"TA的球队";
    }
    else{
        return @"TA的战绩/积分";
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
