//
//  ZHInviteFriendController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHInviteFriendController.h"
#import "FriendListModel.h"
#import "ZHInviteCell.h"
#import "AppDelegate.h"
#import "UMSocial.h"
#import "ChatSendHelper.h"
#import "ZHCollectionCell.h"
#import "StateController.h"
#import "LoginLoginZhViewController.h"
#import "WPCTeamBuildVC.h"
#define shareHeight 70.0
@interface ZHInviteFriendController ()<UITableViewDataSource,UITableViewDelegate,UMSocialUIDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableArray *teamArray;//战队列表
    NSInteger page;
    NSMutableArray *selectedArray;
    TeamModel *selectModel;
    UIButton *btn2;//协议按钮
    UIButton *btn1;//报名按钮
    UIButton *buildBtn;//创建战队
    UILabel *tipLb;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UICollectionView *teamCollectView;
@property (nonatomic,strong) NSMutableArray *dataArray;//成员列表
@end

@implementation ZHInviteFriendController
- (instancetype)initWithBlockSelectedUsernames:(NSArray*)userNames{
    if (self = [super init]) {
        selectedArray = [[NSMutableArray alloc] initWithArray:userNames];//保存群成员
        NSLog(@"%@",userNames);
    }
    return self;
}
- (BOOL)isBlockUsername:(NSString *)username
{
    if (username && [username length] > 0) {
        if ([selectedArray count] > 0) {
            for (NSString *tmpName in selectedArray) {
                if ([username isEqualToString:tmpName]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}
- (BOOL)canSign{
    if (btn2.selected == YES) {
        NSInteger selectCount = 0;
        for(NSInteger i=0;i<_dataArray.count;i++){
            NearByModel *model =(NearByModel*)_dataArray[i];
            if (model.selected) {
                selectCount++;
            }
        }
        if (selectCount>=self.floorCount) {
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return teamArray.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ZHCollectionCell";
    ZHCollectionCell * cell = (ZHCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell configTeamDict:teamArray[indexPath.row]];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    for (TeamModel *model in teamArray) {
        model.isSelected = NO;
    }
    ((TeamModel*)(teamArray[indexPath.row])).isSelected = YES;
    [self loadPlayersListWith:[LVTools mToString:((TeamModel*)(teamArray[indexPath.row])).teamId]];
    selectModel = teamArray[indexPath.row];
    [collectionView reloadData];
    btn1.selected = [self canSign];
}
- (void)stateClick:(UIButton*)btn{
    if (btn.selected) {
        
    }
    else{
        StateController *vc =[[StateController alloc] init];
        vc.chuanBlock = ^(NSArray *arr){
            btn2.selected = YES;
            if ([self canSign]) {
                btn1.selected = YES;
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)baoming:(UIButton*)btn{
    if (btn.selected) {
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:_idStr forKey:@"matchId"];
        [dic setValue:selectModel.teamId forKey:@"teamId"];
        [self showHudInView:self.view hint:LoadingWord];
        [DataService requestWeixinAPI:MatchSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            [self hideHud];
            NSDictionary * resultDic = (NSDictionary *)result;
            if ([resultDic[@"status"] boolValue])
            {
                [WCAlertView showAlertWithTitle:@"✅报名成功" message:@"队友同意数量满足报名条件时系统自动报名，同时会在消息中心通知您" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    //
                    //通知球队成员
                    [self finishOnClick:nil];
                    self.chuanBlock(nil);
                } cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
               
            }
            else{
                if ([LVTools mToString:result[@"info"]].length!=0) {
                    [self showHint:result[@"info"]];
                }
                else{
                [self showHint:ErrorWord];
                }
            }
        }];
    }
    else{
        if(btn2.selected){
            [self inviteNewFriend];
                   }
        else{
            [self showHint:@"您还没有同意赛事免责确认书"];
            return;

        }
    }
}
- (void)inviteNewFriend{
    [WCAlertView showAlertWithTitle:nil message:@"您所选的参赛人员不足,是否前往邀请?" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex==1) {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
            for (NearByModel *model in _dataArray) {
                [arr addObject:[LVTools mToString:model.userId]];
            }
            ZHInviteFriendController *inviteVC= [[ZHInviteFriendController alloc] initWithBlockSelectedUsernames:arr];
            inviteVC.idStr = selectModel.teamId;//战队id
            inviteVC.nameStr =self.nameStr;
            inviteVC.title = @"邀请好友";
            inviteVC.type = @"1";
            inviteVC.chuanBlock = ^(NSArray *arr){
                
                
                //                        if (friendstr == nil) {
                //                            friendstr = [[NSMutableString alloc] init];
                //                        }
                //                        [friendstr setString:@""];
                //                        for (NearByModel *model in arr) {
                //                            [friendstr appendFormat:@"%@,",model.uid];
                //                        }
            };
            [self.navigationController pushViewController:inviteVC animated:YES];
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"去邀请", nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self navgationBarLeftReturn];
    self.view.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
    if ([self.title isEqualToString:@"邀请好友"]) {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(finishOnClick:)];
    }
    _dataArray =[[NSMutableArray alloc] initWithCapacity:0];
    teamArray = [[NSMutableArray alloc] initWithCapacity:0];
   
    [self initOther];
    [self.view addSubview:self.mTableView];
    
    if ([self.title isEqualToString:@"赛事报名"]) {
        UIView *image = [[UIButton alloc] initWithFrame:CGRectMake(0,self.mTableView.bottom, BOUNDS.size.width, BOUNDS.size.width*(150.0/750.0))];
        image.backgroundColor = [UIColor whiteColor];
        UILabel *lb1 = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, mygap, 60.0, BOUNDS.size.width*(50.0/750.0))];
        lb1.text = @"已选择";
        lb1.font = Btn_font;
        [image addSubview:lb1];
        self.teamNameLb.frame = CGRectMake(lb1.right, lb1.top, BOUNDS.size.width*0.4, lb1.height);
        [image addSubview:self.teamNameLb];
        btn1 = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-120.0, 0, 100.0, 30.0)];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"sign"] forState:UIControlStateNormal];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"signed"] forState:UIControlStateSelected];
        [btn1 addTarget:self action:@selector(baoming:) forControlEvents:UIControlEventTouchUpInside];
        [image addSubview:btn1];
        
        UILabel *lb2 = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, lb1.bottom+mygap*3, 60.0, BOUNDS.size.width*(50.0/750.0))];
        lb2.text = @"已选择";
        lb2.font = Btn_font;
        [image addSubview:lb2];
        self.countLb.frame = CGRectMake(lb2.right, lb2.top, BOUNDS.size.width*0.4, lb2.height);
        [image addSubview:self.countLb];

        btn2 = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-150.0, lb2.top, 140.0, 20.0)];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"notify"] forState:UIControlStateNormal];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"notifyed"] forState:UIControlStateSelected];
        [btn2 addTarget:self action:@selector(stateClick:) forControlEvents:UIControlEventTouchUpInside];
        [image addSubview:btn2];
        //[image setBackgroundImage:[UIImage imageNamed:@"校内-赛事报名-选择战队-3-_04"] forState:UIControlStateNormal];
        //[image addTarget:self action:@selector(okOnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:image];
        [self loadTeamData];
    }
    else{
        if ([self.type isEqualToString:@"3"]) {
            [self loadPlayersListWith:self.idStr];
        }
        else{
        [self loadData];
        }
    }
}
- (UILabel*)teamNameLb{
    if (_teamNameLb == nil) {
        _teamNameLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _teamNameLb.textColor = SystemBlue;
        _teamNameLb.font = Btn_font;
        _teamNameLb.text = self.nameStr;
    }
    return _teamNameLb;
}
- (UILabel*)countLb{
    if (_countLb == nil) {
        _countLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLb.textColor = SystemBlue;
        _countLb.font = Btn_font;
        _countLb.text = [NSString stringWithFormat:@"1/%d人",(int)(self.topCount)];
    }
    return _countLb;
}
- (void)okOnClick{
    [WCAlertView showAlertWithTitle:@"✅" message:@"待队友同意后系统会自动报名成功,并且在消息中心通知您" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        //
        [self.navigationController popViewControllerAnimated:YES];
    } cancelButtonTitle:@"确定" otherButtonTitles: nil];
}
//其他平台好友
- (void)initOther{
    if([self.title isEqualToString:@"赛事报名"]){
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(337.0/750.0))];
    //[headImg setImage:[UIImage imageNamed:@"校内-赛事报名-选择战队-3-_02"]];
        headImg.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.00];
        UILabel *lb1 =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(70.0/750.0))];
        lb1.backgroundColor = [UIColor clearColor];
        lb1.text = @" 选择球队";
        lb1.font = Btn_font;
        [headImg addSubview:lb1];
        headImg.userInteractionEnabled = YES;
        [self.view addSubview:headImg];
        
        [headImg addSubview:self.teamCollectView];
        
        buildBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        buildBtn.center = headImg.center;
        [buildBtn setBackgroundColor:[UIColor clearColor]];
        [buildBtn setTitle:@"点击组建球队>>>" forState:UIControlStateNormal];
        [buildBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
        buildBtn.titleLabel.font = Btn_font;
        [buildBtn addTarget:self action:@selector(buildClick) forControlEvents:UIControlEventTouchUpInside];
        [headImg addSubview:buildBtn];
        tipLb = [[UILabel alloc] initWithFrame:CGRectMake(0, buildBtn.bottom, BOUNDS.size.width, 20)];
        tipLb.text = @"提示:只有队长才能报名,且球队类型必须符合赛事类型";
        tipLb.textColor = [UIColor lightGrayColor];
        tipLb.textAlignment = NSTextAlignmentCenter;
        tipLb.font = Content_lbfont;
        [headImg addSubview:tipLb];
        
        UILabel *lb2 =[[UILabel alloc] initWithFrame:CGRectMake(0, _teamCollectView.bottom, BOUNDS.size.width, BOUNDS.size.width*(70.0/750.0))];
        lb2.backgroundColor = [UIColor clearColor];
        lb2.text = @" 选择队友";
        lb2.font = Btn_font;
        [headImg addSubview:lb2];
    }
    else{
    NSArray *arry = @[@"手机通讯录",@"微信好友",@"朋友圈",@"新浪微博",@"人人网",@"QQ好友"];
    for (NSInteger row=0; row<2; row++) {
        for (NSInteger col=0; col<3; col++) {
            UIButton *myview = [[UIButton alloc] initWithFrame:CGRectMake(col*(BOUNDS.size.width/3.0), row*shareHeight, BOUNDS.size.width/3.0, shareHeight)];
            myview.backgroundColor = [UIColor whiteColor];
            myview.tag = row*3+col+100;
            myview.layer.borderWidth = 0.5;
            myview.layer.borderColor = BackGray_dan.CGColor;
            [myview addTarget:self action:@selector(otherFriend:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:myview];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake((myview.width-55)/2.0, 5, 55, 41)];
            image.image =[UIImage imageNamed:[NSString stringWithFormat:@"from_%d",(int)(row*3+col+1)]];
            [myview addSubview:image];
            
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, image.bottom,myview.width, 20)];
            lb.text = [arry objectAtIndex:(row*3+col)];
            lb.font = Content_lbfont;
            lb.textAlignment = NSTextAlignmentCenter;
            lb.textColor = [UIColor lightGrayColor];
            [myview addSubview:lb];
        }
    }
    }
}
- (void)buildClick{
    if([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]){
        WPCTeamBuildVC *vc = [[WPCTeamBuildVC alloc] init];
        vc.title = @"组建球队";
        vc.chuanBlock = ^(NSArray *arr) {
            [self loadTeamData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        LoginLoginZhViewController *loginVC =[[LoginLoginZhViewController alloc] init];
        UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nac animated:YES completion:^{
            //
        }];
    }

}
- (UICollectionView*)teamCollectView{
    if (_teamCollectView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(60, 80);
        flowLayout.sectionInset = UIEdgeInsetsMake(mygap, mygap, mygap, mygap);
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = mygap*2;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _teamCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.width*(70.0/750.0), BOUNDS.size.width, BOUNDS.size.width*(200.0/750.0)) collectionViewLayout:flowLayout];
        _teamCollectView.pagingEnabled = YES;
        _teamCollectView.scrollEnabled = NO;
        _teamCollectView.dataSource = self;
        _teamCollectView.delegate = self;
        _teamCollectView.backgroundColor = [UIColor whiteColor];
        [_teamCollectView registerClass:[ZHCollectionCell class] forCellWithReuseIdentifier:@"ZHCollectionCell"];
    }
    return _teamCollectView;
}
- (void)otherFriend:(UIButton*)btn{
    NSArray *nameArray=@[@"手机通讯录",@"微信好友",@"QQ好友",@"新浪微博",@"人人网",@"扫一扫"];
    NSLog(@"%@",[nameArray objectAtIndex:btn.tag-100]);
    
    //设置分享内容
    NSString *shareText=@"";
    UIImage *shareImage = [UIImage imageNamed:@"appImg"];
    shareText = [NSString stringWithFormat:@"快来参加比赛－%@",[LVTools mToString:self.nameStr]];
    if ([self.type isEqualToString:@"0"]) {
        shareText = [NSString stringWithFormat:@"快来参加约战－%@",[LVTools mToString:self.nameStr]];
    }
    if([self.type isEqualToString:@"1"]){
        shareText = [NSString stringWithFormat:@"点击下载校动官方APP—加入到%@的队伍%@中来吧!",[kUserDefault objectForKey:kUserName],[LVTools mToString:self.nameStr]];
    }
    if([self.type isEqualToString:@"2"]){
        shareText = [NSString stringWithFormat:@"点击下载校动官方APP—加入到%@的队伍%@中来吧!",[kUserDefault objectForKey:kUserName],[LVTools mToString:self.nameStr]];;
    }

    if (_type == nil) {
        shareText = [NSString stringWithFormat:@"我在玩这个app,一起来吧,点击查看详情%@",kDownLoadUrl];
    }
    else{
        shareText = [NSString stringWithFormat:@"%@,点击查看详情%@",shareText,kDownLoadUrl];
    }
    if (btn.tag-100==0) {
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSms];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);

    }
    else if (btn.tag-100==1){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    }
    else if (btn.tag-100==2){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatTimeline];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    }
    else if (btn.tag-100==3){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    }
    else if (btn.tag-100==4){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToRenren];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);

    }
    else if (btn.tag-100==5){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);

    }
    
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma  mark --加载数据
- (void)loadTeamData{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    NSString * userLogin = [kUserDefault objectForKey:kUserLogin];
    if (userLogin) {
        NSString * userId = [kUserDefault objectForKey:kUserId];
        [dic setValue:userId forKey:@"uid"];
    }
    [DataService requestWeixinAPI:myTeams parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        if ([resultDic[@"status"] boolValue])
        {
             NSLog(@"%@",result);
            NSArray *resultArr =result[@"data"][@"myTeams"];
            for (NSDictionary *dic in resultArr) {
                TeamModel *teamModel = [[TeamModel alloc] init];
                [teamModel setValuesForKeysWithDictionary:dic];
                if ([[LVTools mToString:teamModel.sportsType] isEqualToString:[LVTools mToString: self.matchType]]) {
                    [teamArray addObject:teamModel];
                }
                
            }
            if (teamArray.count >0) {
           ((TeamModel*)(teamArray[0])).isSelected = YES;
            selectModel = teamArray[0];
            [self loadPlayersListWith:[LVTools mToString:((TeamModel*)(teamArray[0])).teamId]];
                buildBtn.hidden = YES;
                tipLb.hidden = YES;
            }
            else{
                _countLb.text = [NSString stringWithFormat:@"0/%d人",(int)(self.topCount)];
            }
            [_teamCollectView reloadData];
        }else{
            [self showHint:ErrorWord];
        }
    }];
}
//加载战队成员
- (void)loadPlayersListWith:(NSString*)teamId{
    //    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:teamId  forKey:@"id"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"creatorId"];
    [dic setValue:[kUserDefault objectForKey:kLocationlng] forKey:@"longitude"];
    [dic setValue:[kUserDefault objectForKey:kLocationLat] forKey:@"latitude"];
    [dic setValue:[NSNumber numberWithInteger: [self.idStr integerValue]] forKey:@"matchId"];
    NSLog(@"%@",dic);
    request = [DataService requestWeixinAPI:getPlayerList parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        //        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            [_dataArray removeAllObjects];
            
            for (NSDictionary *dic in result[@"data"]) {
                FriendListModel *model = [[FriendListModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [_dataArray addObject:model];
            }
            ((FriendListModel*)(_dataArray[0])).selected = YES;
            [_mTableView reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
- (void)loadData{
    //通过环信获取好友ID
    [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
            for (EMBuddy *buddy in buddyList) {
                if (buddy.followState != eEMBuddyFollowState_NotFollowed) {
                    [ids addObject:buddy.username];
                }
            }
            if (ids.count!=0) {
                [self loadDataByids:ids];
            }
            else{
                [self showHint:@"你还没有好友"];
            }
            
        }
        else{
            [self showHint:error.description];
        }
    } onQueue:nil];
    
}

- (void)loadDataByids:(NSArray*)ids{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    NSString * lat =[LVTools mToString: [kUserDefault valueForKey:kLocationLat]];
    NSString * lng =[LVTools mToString: [kUserDefault valueForKey:kLocationlng]];
    [dic setObject:ids forKey:@"ids"];
    [dic setObject:lng forKey:@"longitude"];
    [dic setObject:lat forKey:@"latitude"];
    [DataService requestWeixinAPI:getUsersByIds parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",result);
        if ([resultDic[@"status"] boolValue])
        {
            AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            ap.arr = [NSMutableArray array];
            for (NSDictionary *dic in resultDic[@"data"][@"users"])
            {
                NearByModel * model = [[NearByModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                //如果用户已在群组就不在添加
                if (![self isBlockUsername:[LVTools mToString: model.userId]]) {
                    [_dataArray addObject:model];
                }
                [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:model] Key:[NSString stringWithFormat:@"xd%@",[LVTools mToString: model.userId]]];
            }
            [self.mTableView reloadData];
            [self.mTableView.mj_footer endRefreshing];
        }else{
            [self showHint:ErrorWord];
        }
    }];
}

- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.width*(337.0/750.0), BOUNDS.size.width, BOUNDS.size.height-64-BOUNDS.size.width*(150.0/750.0)-BOUNDS.size.width*(337.0/750.0)) style:UITableViewStylePlain];
        if ([self.title isEqualToString:@"邀请好友"]) {
            _mTableView.frame = CGRectMake(0, shareHeight*2+10, BOUNDS.size.width, BOUNDS.size.height-64-shareHeight*2-10);
        }
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mTableView;
}
#pragma mark UITableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idece =@"idecell";
    ZHInviteCell *cell =[tableView dequeueReusableCellWithIdentifier:idece];
    if (cell == nil) {
        cell = [[ZHInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idece menbertype:MenberInviteFriendType];
    }
    NearByModel *model = [_dataArray objectAtIndex:indexPath.row];
    [cell configModel:model];
    cell.selectedBtn.tag = 200+indexPath.row;
    if ([self.title isEqualToString:@"赛事报名"]) {
        if (indexPath.row == 0) {
            cell.statusLab.hidden = NO;
        }
        else{
             if ([LVTools mToString:model.status].length>0&&[model.status integerValue]>0) {
                 cell.selectedBtn.hidden = YES;
            }
             else{
                 cell.selectedBtn.hidden = NO;
             }
        }
    }
    [cell.selectedBtn addTarget:self action:@selector(selectedOnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kFriendCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击");
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (void)selectedOnClick:(UIButton*)btn{
    if([self.title isEqualToString:@"赛事报名"]){
    NSInteger index = btn.tag-200;
    if (index == 0) {
        [self showHint:@"球队代理人必须参加"];
        return;
    }
    NSInteger count = 0;
    for(NSInteger i=0;i<_dataArray.count;i++){
        NearByModel *model =(NearByModel*)_dataArray[i];
        if (model.selected) {
            count++;
        }
    }
    if (count>=self.topCount&&btn.selected == NO) {
        //人数不能超过上限
        [self showHint:@"人数不能超过上限"];
        return;
    }
    btn.selected = !btn.selected;
    NearByModel *model =(NearByModel*)[_dataArray objectAtIndex:btn.tag-200];
    model.selected = btn.selected;
    if (model.selected == YES) {
        count++;
    }
    else{
        count--;
    }
    btn1.selected = [self canSign];
    _countLb.text = [NSString stringWithFormat:@"%d/%d人",(int)count,(int)(self.topCount)];
    }
    else{
        if ([self.type isEqualToString:@"3"]) {
            NSInteger count = 0;
            for(NSInteger i=0;i<_dataArray.count;i++){
                NearByModel *model =(NearByModel*)_dataArray[i];
                if (model.selected) {
                    count++;
                }
            }
            if (count>=self.limit&&btn.selected == NO) {
                //人数不能超过上限
                [self showHint:@"人数不能超过上限"];
                return;
            }
            btn.selected = !btn.selected;
            NearByModel *model =(NearByModel*)[_dataArray objectAtIndex:btn.tag-200];
            model.selected = btn.selected;
            if (model.selected == YES) {
                count++;
            }
            else{
                count--;
            }
            

//            btn.selected = !btn.selected;
//            NearByModel *model =(NearByModel*)[_dataArray objectAtIndex:btn.tag-200];
//            model.selected = btn.selected;
        }
        else{
        btn.selected = !btn.selected;
        NearByModel *model =(NearByModel*)[_dataArray objectAtIndex:btn.tag-200];
        model.selected = btn.selected;
        }
    }
}
- (void)finishOnClick:(id)sender{
//    NSMutableString *friendStr = [[NSMutableString alloc] init];
//    NSMutableArray *friendModelArr = [[NSMutableArray alloc] initWithCapacity:0];
//    NSString *textMessage = [NSString stringWithFormat:@"快来参加比赛－%@",[LVTools mToString:self.nameStr]];
//    if ([self.type isEqualToString:@"0"]) {
//        textMessage = [NSString stringWithFormat:@"快来参加约战－%@",[LVTools mToString:self.nameStr]];
//    }
//    if([self.type isEqualToString:@"1"]){
//        textMessage = [NSString stringWithFormat:@"快来加入战队－%@",[LVTools mToString:self.nameStr]];
//    }
//    if([self.type isEqualToString:@"2"]){
//        textMessage = [NSString stringWithFormat:@"快来参加比赛－%@",[LVTools mToString:self.nameStr]];
//    }
//    for (NearByModel *model in _dataArray) {
//        if (model.selected == YES) {
//            if (self.type) {
//                NSLog(@"%@",[NSString stringWithFormat:@"%@",model.uid]);
//                [ChatSendHelper sendTextMessageWithString:textMessage
//                                               toUsername:[NSString stringWithFormat:@"%@",model.uid]
//                                              isChatGroup:NO
//                                        requireEncryption:NO
//                                                      ext:nil];
//            }
//            [friendStr appendString:[NSString stringWithFormat:@"%@,",model.userId]];
//            [friendModelArr addObject:model];
//        }
//    }
//    self.chuanBlock(friendModelArr);
//    NSLog(@"邀请好友的Id%@",friendStr);
//    [self.navigationController popViewControllerAnimated:YES];
    NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i=0;i<_dataArray.count;i++) {
        if ([self.title isEqualToString:@"赛事报名"]) {
        if (i==0) {
            continue;
        }
        }
        NearByModel *model = [self.dataArray objectAtIndex:i];
        if (model.selected == YES) {
            [ids addObject:model.userId];
        }
    }
    [self inviteJoinTeamWithIds:ids];
}
- (void)inviteJoinTeamWithIds:(NSArray*)ids{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:ids  forKey:@"receiveIds"];
    
    if([self.type isEqualToString:@"1"]){
        //球队
        [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"sendId"];
        [dic setValue:@"3" forKey:@"msgType"];
        [dic setValue:[NSString stringWithFormat:@"邀请您加入他的球队－%@",self.nameStr] forKey:@"content"];
      
    }
    else if([self.type isEqualToString:@"2"]||[self.type isEqualToString:@"3"]){
        //比赛
        [dic setValue:@"5" forKey:@"msgType"];
        [dic setValue:[NSString stringWithFormat:@"邀请参加赛事－%@",self.nameStr] forKey:@"content"];
        [dic setValue:selectModel.teamId forKey:@"sendId"];
    }
    [dic setValue:self.idStr forKey:@"extend"];
    NSLog(@"%@",dic);
    request = [DataService requestWeixinAPI:xdsendMessage parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if(result[@"status"]){
            if ([result[@"status"] boolValue]) {
                if([self.type isEqualToString:@"1"]){
                    [self showHint:@"邀请成功,等待对方同意"];
                    [NSThread sleepForTimeInterval:2.0f];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    if ([self.type isEqualToString:@"2"]) {
                        
                    
                    [WCAlertView showAlertWithTitle:nil message:@"已经发送邀请，等待好友回复，建议将此赛事加入我的收藏" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 1) {
                            //
                            NSMutableDictionary *dic = [LVTools getTokenApp];
                            [dic setValue:self.idStr forKey:@"matchId"];
                            [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
                            [DataService requestWeixinAPI:addMatchCollect parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                                NSLog(@"final result === %@",result);
                                [self hideHud];
                                if ([result[@"status"] boolValue]) {
                                    [self showHint:@"已收藏"];
                                    [self.navigationController popViewControllerAnimated:YES];
                                                                    }
                                else{
                                    [self showHint:@"请重试"];
                                }
                            }];
                        

                        }
                        else{
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"收藏", nil];
                    }
                    else if([self.type isEqualToString:@"3"]){
                        //type3
                        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] animated:YES];
                    }
                }
                
                //返回并收藏
            }
            else{
                [self showHint:result[@"info"]];
            }
        }
        else{
            [self showHint:ErrorWord];
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
