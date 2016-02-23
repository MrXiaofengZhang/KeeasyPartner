//
//  ZHTeamDetailController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHTeamDetailController.h"
#import "PopoverView.h"
#import "ZHAppointBuildController.h"
#import "ZHTeamDetaillCell.h"
#import "TeamModel.h"
#import "ZHInviteFriendController.h"
#import "WPCMenberListVC.h"
#import "WPCFriednMsgVC.h"
#import "FriendListModel.h"
#import "WPCTeamBuildVC.h"
#import "ZHCommentController.h"
#import "ImgShowViewController.h"
#import "LoginLoginZhViewController.h"
#import "WPCMyOwnVC.h"
#import "ListViewController.h"
#import "ScoreCell.h"
#import "SingleImageController.h"
#import "TeamResultController.h"
@interface ZHTeamDetailController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *titleArr;
    NSArray *dataArr;
    NSMutableArray *playerArr;
    NSMutableArray *imgArray;//战绩
    BOOL isInTeam;
    UIButton *addbtn;
    UIButton *rankImg;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UIImageView *teamImg;
@property (nonatomic,strong) UILabel *teamNameLb;
@property (nonatomic,strong) UILabel *schoolNameLb;
@property (nonatomic,strong) UILabel *distanceLb;
@property (nonatomic,strong) UIScrollView *teamPhotos;
@property (nonatomic,strong) UIScrollView *teamMenbers;
@property (nonatomic,strong) UIView *headView;
@property (nonatomic,strong) UILabel *menberCount;
@property (nonatomic,strong) UIImageView *teamLeaderImg;
@property (nonatomic,strong) UIImageView *img;
@property (nonatomic,strong) NSString *hasApply;

@end

@implementation ZHTeamDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    self.title = @"球队信息";
    
    titleArr = @[@"球队成员",@"运动类型",@"口号",@"球队经理人",@"身份",@"常出没地",@"所属俱乐部",@"粉丝"];
    playerArr = [[NSMutableArray alloc] initWithCapacity:0];
    imgArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.view addSubview:self.mTableView];
    if ([[LVTools mToString: self.teamModel.creatorId] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]&&[LVTools mToString:[kUserDefault objectForKey:kUserId]].length>0) {
        //队长
        [self navgationbarRrightImg:@"edit" WithAction:@selector(editOnClick) WithTarget:self];
        addbtn.hidden = YES;
    }
    else{
        //非队长
        addbtn.hidden = NO;
    }
    [self loadTeamInfo];
}
- (void)editOnClick{
    WPCTeamBuildVC *teamBuild = [[WPCTeamBuildVC alloc] init];
    teamBuild.title = @"修改球队信息";
    teamBuild.model = self.teamModel;
    teamBuild.idstring = self.teamModel.teamId;
    teamBuild.chuanBlock = ^(NSArray *arr) {
        [self loadTeamInfo];
    };
    [self.navigationController pushViewController:teamBuild animated:YES];
}
- (NSString*)convertStrWith:(NSString*)sportCode{
    NSDictionary *resultDic = nil;
    for (NSDictionary *dic in [LVTools readPlist]) {
        if ([[dic objectForKey:@"sport2"] isEqualToString:sportCode]) {
            resultDic = dic;
            return resultDic[@"name"];
            break;
        }
    }
    return @"";
}
//加载战队详情
- (void)loadTeamInfo{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    if (self.teamModel) {
        [dic setValue:[LVTools mToString:self.teamModel.teamId] forKey:@"teamId"];
    } else {
        [dic setValue:self.teamId forKey:@"teamId"];
        self.teamModel = [[TeamModel alloc] init];
    }
    if ([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
    [dic setObject:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setValue:[kUserDefault objectForKey:kLocationlng] forKey:@"longitude"];
    [dic setValue:[kUserDefault objectForKey:kLocationLat] forKey:@"latitude"];
    }
    else{
        [dic setObject:@"-1" forKey:@"userId"];
    }
    NSLog(@"%@",dic);
    request = [DataService requestWeixinAPI:getTeamDetail parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            if (![result[@"data"] isKindOfClass:[NSNull class]]) {
                if (![result[@"data"] isKindOfClass:[NSNull class]]) {
                    [self.teamModel setValuesForKeysWithDictionary: result[@"data"]];
                }
                addbtn.selected = [result[@"data"][@"follow"] boolValue];
                [imgArray removeAllObjects];
                [playerArr removeAllObjects];
                [imgArray addObjectsFromArray:result[@"data"][@"records"]];
                if (imgArray.count==0) {
                    UIImageView *footView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 40.0)];
                    footView.image =[UIImage imageNamed:@"nomore"];
                    footView.contentMode = UIViewContentModeCenter;
                    self.mTableView.tableFooterView = footView;
                }
                [playerArr  addObjectsFromArray:result[@"data"][@"userPath"]];
                _menberCount.text = [NSString stringWithFormat:@"%d",(int)(playerArr.count)];
                [self setmenberImg:playerArr];
                _schoolNameLb.text = [LVTools mToString:self.teamModel.schoolName];
                NSString *statusString = nil;
               
                    if([[LVTools mToString:self.teamModel.academic] length]==0){
                        self.teamModel.hospital = @"保密";
                    }
                    if ([[LVTools mToString:self.teamModel.department] length] == 0) {
                        self.teamModel.department = @"保密";
                    }
                    statusString = [NSString stringWithFormat:@"%@-%@-%@",self.teamModel.schoolName,[LVTools mToString:self.teamModel.academic],[LVTools mToString:self.teamModel.department]];
                dataArr = @[@"",[self convertStrWith:[LVTools mToString:self.teamModel.sportsType]],[LVTools mToString:self.teamModel.slogan],[NSString stringWithFormat:@"        %@",[LVTools mToString: self.teamModel.creatorName]],statusString,[LVTools mToString:self.teamModel.often],[LVTools mToString:self.teamModel.club],[LVTools mToString:self.teamModel.fansCount]];
                
                _hasApply = [LVTools mToString:result[@"status"]];
                isInTeam = [result[@"data"][@"inTeam"] boolValue];
                [self.mTableView reloadData];
                [self refreshHeadInfo];
            }
            [self setBottomBtn];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}

- (void)refreshHeadInfo {
    
    CGFloat nameWidth = [LVTools sizeWithStr:[LVTools mToString:self.teamModel.teamName] With:17 With2:30];
    _teamNameLb.frame = CGRectMake(_teamImg.right+mygap*2, _teamImg.top, nameWidth, 30);
    _img.frame = CGRectMake(_teamNameLb.right+mygap, _teamNameLb.top+mygap, 15, 15);
    [_teamImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:self.teamModel.path]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    _teamNameLb.text = [LVTools mToString:self.teamModel.teamName];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    for (int i = 0; i < arr.count; i ++) {
        if ([arr[i][@"sport2"] isEqualToString:self.teamModel.sportsType]) {
            _img.image = [UIImage imageNamed:arr[i][@"name"]];
        }
    }
    _schoolNameLb.text = self.teamModel.schoolName;
    //这里与首页一致
    if ([LVTools mToString:self.teamModel.distance].length==0) {
        self.distanceLb.text = @"未知";
    }
    else{
    CGFloat distance = [[LVTools mToString:_teamModel.distance] doubleValue];
    self.distanceLb.text = [NSString stringWithFormat:@"%.2fkm",distance];
    }
}
//上传战队晒图
- (void)updateTeamPics{
    
}
//申请加入
- (void)applyJoin{
    if (![_hasApply isEqualToString:@"1"]) {
        [self showHint:@"您已申请加入，正等队长审核"];
        return;
    }
        [WCAlertView showAlertWithTitle:nil message:@"确定要加入该球队吗" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
           
        }
        else{
            [self showHudInView:self.view hint:LoadingWord];
            NSMutableDictionary * dic = [LVTools getTokenApp];
            [dic setValue:@[self.teamModel.creatorId]  forKey:@"receiveIds"];
            [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"sendId"];
            [dic setValue:@"4" forKey:@"msgType"];
            [dic setValue:[NSString stringWithFormat:@"申请加入您的球队－%@",self.teamModel.teamName] forKey:@"content"];
            [dic setValue:self.teamModel.teamId forKey:@"extend"];
            NSLog(@"%@",dic);
            request = [DataService requestWeixinAPI:xdsendMessage parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                [self hideHud];
                NSLog(@"%@",result);
                if(result[@"status"]){
                    if ([result[@"status"] boolValue]) {
                        [self showHint:@"申请成功,等待队长同意"];
                        //刷新
                        _hasApply =@"2";
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
        }
        cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
//退出战队
- (void)quitTeam{
    
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[LVTools mToString:self.teamModel.teamId]  forKey:@"teamId"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    request = [DataService requestWeixinAPI:delPlayer parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
         if(result[@"status"]){
        if ([result[@"status"] boolValue]) {
            [self showHint:@"退出成功"];
            //刷新
            for (UIView *v in _teamMenbers.subviews) {
                [v removeFromSuperview];
            }
            [self loadTeamInfo];
            //[self loadPlayersList];
            self.chuanBlock(nil);
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
- (void)updateTeamPhotos{
    
}
//解散战队
- (void)breakTeam{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[LVTools mToString:self.teamModel.id] forKey:@"id"];
    request = [DataService requestWeixinAPI:delTeam parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if(result[@"statusCodeInfo"]){
            if ([result[@"statusCodeInfo"] isEqualToString:@"解散战队成功"]) {
                [self showHint:@"解散战队成功"];
                self.chuanBlock(nil);
               [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                [self showHint:result[@"statusCodeInfo"]];
            }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
- (void)setBottomBtn{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.mTableView.bottom, BOUNDS.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
   
    if([[LVTools mToString: self.teamModel.creatorId] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]){
    //队长情况
    NSArray *arr= @[@"invite_wpc",/*@"manager_wpc"*/];
    for (NSInteger i=0; i<[arr count]; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(BOUNDS.size.width/[arr count]*i,self.mTableView.bottom, BOUNDS.size.width/[arr count], kBottombtn_height);
        btn.tag = 100+i;
        [btn setBackgroundColor:SystemBlue];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"邀好友" forState:UIControlStateNormal];
        //[btn setImage:[UIImage imageNamed:[arr objectAtIndex:i]] forState:UIControlStateNormal];
        btn.contentMode = UIViewContentModeScaleAspectFill;
        [btn addTarget:self action:@selector(bottomOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        if (i==[arr count]) {
            UIView *lineh =[[UIView alloc] initWithFrame:CGRectMake(BOUNDS.size.width/2.0, 7, 0.5, 30)];
            lineh.backgroundColor = [UIColor lightGrayColor];
            [btn addSubview:lineh];
        }
    }
    }
    else{
        //非队长情况
        NSArray *arr= @[@[@"Btn_ApplyTeam",@"Btn_quitTeam"]];
        for (NSInteger i=0; i<[arr count]; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(BOUNDS.size.width/[arr count]*i,self.mTableView.bottom, BOUNDS.size.width/[arr count], kBottombtn_height);
            btn.tag = 200+i;
            //[btn setImage:[UIImage imageNamed:[[arr objectAtIndex:i] objectAtIndex:0]] forState:UIControlStateNormal];
//            [btn setImage:[UIImage imageNamed:[[arr objectAtIndex:i] objectAtIndex:0]] forState:UIControlStateNormal];
//            [btn setImage:[UIImage imageNamed:[[arr objectAtIndex:i] objectAtIndex:1]] forState:UIControlStateSelected];
            [btn setBackgroundColor:SystemBlue];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            if (isInTeam) {
                btn.selected = YES;
            }
            else{
                btn.selected = NO;
            }
            [btn setTitle:@"退出球队" forState:UIControlStateSelected];
            [btn setTitle:@"申请加入" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(bottomOnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.contentMode = UIViewContentModeScaleAspectFill;
            [self.view addSubview:btn];
            if (i!=[arr count]-1) {
                UIView *lineh =[[UIView alloc] initWithFrame:CGRectMake(BOUNDS.size.width/2.0, 7, 0.5, 30)];
                lineh.backgroundColor = [UIColor lightGrayColor];
                [btn addSubview:lineh];
            }
        }

    }
}
//是否是队员
- (BOOL)isMemberWithPlayer:(NSArray*)players{
    BOOL flag = NO;
    if([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"0"]){
        return NO;
    }
    for (FriendListModel *model in players) {
        NSString *playerId =[LVTools mToString: model.uid];
        if ([playerId isEqualToString:[kUserDefault objectForKey:kUserId]]) {
            flag = YES;
            break;
        }
    }
    return flag;
}
//队长信息
- (FriendListModel*)getTeamLeaderInfo:(NSArray*)players{
    FriendListModel *resultDic = nil;
    for ( FriendListModel *model in players) {
        NSString *playerId =[LVTools mToString: model.uid];
        if ([playerId isEqualToString:[LVTools mToString: self.teamModel.captainId]]) {
            resultDic = model;
            NSLog(@"%@",model.uid);
            break;
        }
    }
    return resultDic;
}
- (void)bottomOnClick:(UIButton*)btn{
    NSString *islogin = [LVTools mToString:[kUserDefault objectForKey:kUserLogin]];
    if ([islogin isEqualToString:@"1"]) {
        if (btn.tag == 100) {
            //邀战友
            NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *dic in playerArr) {
                [ids addObject:[LVTools mToString:dic[@"userId"]]];
            }
            ZHInviteFriendController *inviteVC= [[ZHInviteFriendController alloc] initWithBlockSelectedUsernames:ids];
            inviteVC.nameStr =_teamModel.teamName;
            inviteVC.title = @"邀请好友";
            inviteVC.type = @"1";
            inviteVC.idStr = _teamModel.teamId;
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
        else if (btn.tag == 101){
            //管理
            //弹出
            
            CGPoint point = CGPointMake(UISCREENWIDTH*3/4, UISCREENHEIGHT-45);
            NSArray *arr = @[@"修改",@"解散战队"];
            PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:arr images:nil andStyle:PopoverStyleDefault];
            pop.popStyle = PopoverStyleDefault;
            pop.selectRowAtIndex = ^(NSInteger index){
                if (index == 0) {
                    //修改
                    WPCTeamBuildVC *teamBuild = [[WPCTeamBuildVC alloc] init];
                    teamBuild.title = @"修改球队信息";
                    NSLog(@"teammodel ==== %@",self.teamModel.university);
                    teamBuild.model = self.teamModel;
                    teamBuild.idstring = self.teamModel.id;
                    teamBuild.chuanBlock = ^(NSArray *arr) {
                        [self loadTeamInfo];
                    };
                    [self.navigationController pushViewController:teamBuild animated:YES];
                }
                else
                {
                    //解散战队
                    [WCAlertView showAlertWithTitle:nil message:@"确定解散战队吗?" customizationBlock:^(WCAlertView *alertView) {
                        NSLog(@"1");
                    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 1) {
                            //向服务器提交删除约战的数据。同时返回首页
                            [self breakTeam];
                            
                        }
                    } cancelButtonTitle:@"放弃" otherButtonTitles:@"确定", nil];
                }
            };
            __block PopoverView *tempPop = pop;
            pop.dismissBlock = ^() {
                tempPop = nil;
            };
            [pop show];
        }
        else{
            //申请与退出
            if (btn.tag==200) {
                if (btn.selected) {
                    //退出
                    if ([[LVTools mToString:self.teamModel.matchStatus] isEqualToString:@"1"]){
                        [self showHint:@"球队正在赛事中,不允许退出球队"];
                        return;
                    }
                    [WCAlertView showAlertWithTitle:nil message:@"确定退出该球队吗？" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == [alertView cancelButtonIndex]) {
                            
                        }
                        else{
                            [self quitTeam];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    
                }
                else{
                    //申请
                            [self applyJoin];
                }
            }
        }
    }
    else{
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setImgWithArray:(NSMutableArray*)array{
    NSLog(@"arra =arr === == %@",array);
    for (NSInteger i=0; i<4; i++) {
        UIButton *btn = (UIButton*)[self.teamPhotos viewWithTag:400+i];
        btn.enabled = NO;
        [btn setImage:nil forState:UIControlStateNormal];
    }
    if ([[LVTools mToString: self.teamModel.captainId] isEqualToString:[kUserDefault objectForKey:kUserId]]) {
        //队长可编辑
        for (NSInteger i=0; i<array.count+1; i++) {
            UIButton *btn = (UIButton*)[self.teamPhotos viewWithTag:400+i];
            btn.enabled = YES;
            if (i== array.count) {
                [btn setImage:[UIImage imageNamed:@"addImg"] forState:UIControlStateNormal];
            }
            else{
                [btn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[array objectAtIndex:i][@"path"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
                btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                btn.imageView.clipsToBounds = YES;
            }
        }
    }
    else{
        for (NSInteger i=0; i<array.count; i++) {
            
            UIButton *btn = (UIButton*)[self.teamPhotos viewWithTag:400+i];
            btn.enabled = YES;
            [btn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[array objectAtIndex:i][@"path"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            btn.imageView.clipsToBounds = YES;
        }
    }
}
//选中某张图片
- (void)imageOnClick:(UIButton*)btn{
    if ([[LVTools mToString: self.teamModel.captainId] isEqualToString:[kUserDefault objectForKey:kUserId]]) {
        //队长可编辑
        //选择图片
        if ((btn.tag-400)== imgArray.count) {
        ZHCommentController *commentVC = [[ZHCommentController alloc] init];
        commentVC.title = @"上传战队晒图";
        commentVC.fromStyle = StyleResultTeam;
        commentVC.idstring = [LVTools mToString:self.teamModel.id];
        commentVC.count = 4-imgArray.count;
        commentVC.chuanBlock = ^(NSArray *arr){
            [imgArray addObjectsFromArray:arr];
            
            [self setImgWithArray:imgArray];
        };
        [self.navigationController pushViewController:commentVC animated:YES];
        }
        else{
            NSMutableArray *urlArr = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *dic in imgArray) {
                [urlArr addObject:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"path"]]];
            }
            ImgShowViewController *imgshowVC =[[ImgShowViewController alloc] initWithSourceData:urlArr withIndex:btn.tag-400 hasUseUrl:YES];
            imgshowVC.isSelf = YES;
            
//            imgShow.data = testArray;
            imgshowVC.detailArray = imgArray;
            imgshowVC.chuanImg = ^(NSInteger index) {
                [imgArray removeObjectAtIndex:index];
                [self setImgWithArray:imgArray];
            };
            [self.navigationController pushViewController:imgshowVC animated:YES];
        }
    }
    else{
        NSMutableArray *urlArr = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSDictionary *dic in imgArray) {
            [urlArr addObject:[NSString stringWithFormat:@"%@%@",preUrl,dic[@"path"]]];
        }
        ImgShowViewController *imgshowVC =[[ImgShowViewController alloc] initWithSourceData:urlArr withIndex:btn.tag-400 hasUseUrl:YES];
        [self.navigationController pushViewController:imgshowVC animated:YES];
    }
}
- (void)deleteAction:(UIButton*)btn
{
    [WCAlertView showAlertWithTitle:nil message:@"确定删除此图片么？" customizationBlock:^(WCAlertView *alertView) {
        //todo wpc
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
            //向服务器提交删除图片的数据，删除成功对详情页也进行处理，然后返回
            NSDictionary *dic = [LVTools getTokenApp];
            [dic setValue:[imgArray objectAtIndex:btn.tag-400][@"id"] forKey:@"id"];
            [DataService requestWeixinAPI:deletePlayShow parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                NSLog(@"===========%@",result);
                if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                    [imgArray removeObjectAtIndex:btn.tag-400];
                    [self setImgWithArray:imgArray];
                }
            }];
        }
    } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
}

- (void)setmenberImg:(NSArray*)array{
    for (UIImageView *img in self.teamMenbers.subviews) {
        [img removeFromSuperview];
    }
    for (NSInteger i=0; i<[array count]; i++) {
        CGFloat left = _teamMenbers.width-(i+1)*(mygap+40);
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(left, 0, 40, 40)];
        NSDictionary *model =[array objectAtIndex:i];
        [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model[@"userPath"]]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
        if ([[LVTools mToString: model[@"userId"]] isEqualToString:[LVTools mToString: self.teamModel.creatorId]]) {
            [self.teamLeaderImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model[@"userPath"]]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
        }
        img.layer.masksToBounds = YES;
        img.layer.cornerRadius = 20.0;
        img.userInteractionEnabled = YES;
        [self.teamMenbers addSubview:img];
        if (left<img.width/2.0) {
            break;
        }
    }
}
- (void)guangzhu:(UIButton*)btn{
    if (![[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:^{
            
        }];
        return;
    }
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[LVTools mToString:self.teamModel.teamId] forKey:@"followId"];
    [dic setObject:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setValue:@"0" forKey:@"followType"];
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
#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64-kBottombtn_height) style:UITableViewStylePlain];
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 100)];
        self.headView.backgroundColor = BackGray_dan;
        addbtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-80, self.teamImg.top, 60.0, 20.0)];
        [addbtn setBackgroundImage:[LVTools buttonImageFromColor:SystemBlue withFrame:CGRectMake(0, 0, 80.0, 30.0)] forState:UIControlStateNormal];
        addbtn.layer.cornerRadius = 5.0;
        addbtn.layer.masksToBounds = YES;
        addbtn.titleLabel.font = Content_lbfont;
        [addbtn setBackgroundImage:[LVTools buttonImageFromColor:[UIColor lightGrayColor] withFrame:CGRectMake(0, 0, 80.0, 30.0)] forState:UIControlStateSelected];
        [addbtn setTitle:@"+关注" forState:UIControlStateNormal];
        [addbtn setTitle:@"取消关注" forState:UIControlStateSelected];
        [addbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [addbtn addTarget:self action:@selector(guangzhu:) forControlEvents:UIControlEventTouchUpInside];
        [self.headView addSubview:addbtn];
    
        [self.headView addSubview:self.teamImg];
        [self.headView addSubview:rankImg];
        [self.headView addSubview:self.teamNameLb];
        [self.headView addSubview:self.schoolNameLb];
        [self.headView addSubview:self.distanceLb];
        
        NSMutableArray *stringArr = [NSMutableArray array];
        if ([[LVTools mToString:self.teamModel.matchStatus] isEqualToString:@"1"]) {
            [stringArr addObject:@"赛事ing"];
        }
        if (stringArr.count > 0) {
            for (NSInteger i=0; i<stringArr.count; i++) {
                UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(self.distanceLb.right+2*mygap, self.distanceLb.top, 50, 20)];
                lab.layer.cornerRadius = 10;
                lab.layer.masksToBounds = YES;
                lab.layer.borderWidth = 0.5;
                lab.layer.borderColor = SystemBlue.CGColor;
                lab.font = [UIFont systemFontOfSize:12.0];
                lab.textAlignment = NSTextAlignmentCenter;
                lab.text = [stringArr objectAtIndex:i];
                if ([stringArr[i] isEqualToString:@"赛事ing"]) {
                    lab.backgroundColor = [UIColor clearColor];
                } else {
                    lab.backgroundColor = NavgationColor;
                }
                lab.textColor = SystemBlue;
                [self.headView addSubview:lab];
            }
        }
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 100, BOUNDS.size.width, 0.5)];
        line.backgroundColor = BackGray_dan;
        [self.headView addSubview:line];
        _mTableView.tableHeaderView = self.headView;
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
    }
    return _mTableView;
}

- (UIImageView*)teamImg{
    if (_teamImg == nil) {
        _teamImg = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, 80, 80)];
        _teamImg.contentMode = UIViewContentModeScaleAspectFill;
        _teamImg.clipsToBounds = YES;
        _teamImg.layer.cornerRadius = 3.0;
        _teamImg.layer.masksToBounds = YES;
        [_teamImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,self.teamModel.path]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
        if ([[LVTools mToString: self.teamModel.creatorId] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]&&[LVTools mToString:[kUserDefault objectForKey:kUserId]].length>0) {
            //队长
        UIButton *leaderBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
            [leaderBtn setBackgroundImage:[UIImage imageNamed:@"owner"] forState:UIControlStateNormal];
            _teamImg.userInteractionEnabled = YES;
            [_teamImg addSubview:leaderBtn];
            [leaderBtn addTarget:self action:@selector(ownerOnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        NSInteger teamLevel = [self.teamModel.teamLevel integerValue];
        rankImg = [[UIButton alloc] initWithFrame:CGRectMake(_teamImg.right-15.0f, _teamImg.bottom-15.0f, 20.0f, 20.0f)];
        rankImg.contentMode = UIViewContentModeScaleAspectFit;
        rankImg.titleLabel.textColor = [UIColor whiteColor];
        rankImg.titleLabel.font = [UIFont systemFontOfSize:9];
        
        [rankImg addTarget:self action:@selector(levelOnclick:) forControlEvents:UIControlEventTouchUpInside];
        if (teamLevel == 0) {
            [rankImg setBackgroundImage:[UIImage imageNamed:@"lv_3"]forState:UIControlStateNormal];
            [rankImg setTitle:@"1" forState:UIControlStateNormal];
        }
        else{
            
            if (teamLevel>0&&teamLevel<100) {
                [rankImg setBackgroundImage:[UIImage imageNamed:@"lv_2"]forState:UIControlStateNormal];
                [rankImg setTitle:[NSString stringWithFormat:@"%d",(int)teamLevel] forState:UIControlStateNormal];
            }
            else if(teamLevel>99&&teamLevel<1000){
                [rankImg setBackgroundImage:[UIImage imageNamed:@"lv_2"]forState:UIControlStateNormal];
                [rankImg setTitle:@"99+" forState:UIControlStateNormal];
            }
            else{
                [rankImg setBackgroundImage:[UIImage imageNamed:@"lv_1"]forState:UIControlStateNormal];
            }
        }
        }
    return _teamImg;
}
- (void)ownerOnClick:(UIButton*)btn{
    SingleImageController *vc= [[SingleImageController alloc] init];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(772.0/750.0))];
    vc.title = @"球队经理人说明";
    img.image = [UIImage imageNamed:@"球队经理人说明"];
    img.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(772.0/750.0));
    vc.imageView = img;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)levelOnclick:(UIButton*)btn{
    SingleImageController *vc= [[SingleImageController alloc] init];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(415.0/750.0))];
    vc.title = @"球队标示说明";
    NSInteger teamLevel = [self.teamModel.teamLevel integerValue];
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
}

- (UILabel*)teamNameLb{
    if (_teamNameLb == nil) {
        _teamNameLb = [[UILabel alloc] initWithFrame:CGRectMake(_teamImg.right+mygap*2, _teamImg.top, 100, 30)];
        _teamNameLb.backgroundColor = [UIColor clearColor];
        _teamNameLb.text = [LVTools mToString:self.teamModel.teamName];
        _teamNameLb.font = [UIFont systemFontOfSize:17];
        [_teamNameLb sizeToFit];
        
        
        
        _img = [[UIImageView alloc] init];
        _img.frame = CGRectMake(_teamNameLb.right+mygap, _teamNameLb.top+mygap, 15, 15) ;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
        NSArray *arr = [NSArray arrayWithContentsOfFile:path];
        for (int i = 0; i < arr.count; i ++) {
            if ([arr[i][@"sport2"] isEqualToString:self.teamModel.sportsType]) {
                _img.image = [UIImage imageNamed:arr[i][@"name"]];
            }
        }
        [self.headView addSubview:_img];
    }
    return _teamNameLb;
}
- (UILabel*)schoolNameLb{
    if (_schoolNameLb==nil) {
        _schoolNameLb = [[UILabel alloc] initWithFrame:CGRectMake(_teamNameLb.left, _teamNameLb.bottom+mygap*2, BOUNDS.size.width-_teamNameLb.left-20.0f, _teamNameLb.height)];
        _schoolNameLb.textAlignment = NSTextAlignmentLeft;
        _schoolNameLb.text = @"上海交通大学篮球校队";
        _schoolNameLb.textColor = [UIColor lightGrayColor];
        _schoolNameLb.font = Content_lbfont;
    }
    return _schoolNameLb;
}
- (UILabel*)distanceLb{
    if (_distanceLb == nil) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(_teamNameLb.left, _schoolNameLb.bottom+mygap*2, 15, 15)];
        img.image = [UIImage imageNamed:@"Marker"];
        [self.headView addSubview:img];
        _distanceLb = [[UILabel alloc] initWithFrame:CGRectMake(img.right,img.top, 120, 15)];
        _distanceLb.font = Content_lbfont;
        _distanceLb.textColor = [UIColor lightGrayColor];
        CGFloat distance = [[LVTools mToString:_teamModel.distance] doubleValue];
        self.distanceLb.text = [NSString stringWithFormat:@"%.2fkm",distance/1000.0];
    }
    return _distanceLb;
}
- (UIScrollView*)teamPhotos{
    if (_teamPhotos == nil) {
        _teamPhotos = [[UIScrollView alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, BOUNDS.size.width-4*mygap, 65)];
        _teamPhotos.showsHorizontalScrollIndicator = NO;
        for (NSInteger i=0; i<4; i++) {
            UIButton *img = [[UIButton alloc] initWithFrame:CGRectMake(mygap+i*(mygap*2+65), 0, 65, 65)];
            [img addTarget:self action:@selector(imageOnClick:) forControlEvents:UIControlEventTouchUpInside];
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.clipsToBounds = YES;
            //[img addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchDragExit];
            img.tag = 400+i;
            img.enabled = NO;
            [self.teamPhotos addSubview:img];
        }
    }
    return _teamPhotos;
}

- (UILabel*)menberCount{
    if (_menberCount == nil) {
        _menberCount = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width*0.12, mygap*2+20, 60, 30)];
        _menberCount.textAlignment = NSTextAlignmentCenter;
        _menberCount.text = [LVTools mToString:@"1"];
        _menberCount.font = [UIFont systemFontOfSize:22.0];
        _menberCount.textColor = [UIColor lightGrayColor];
    }
    return _menberCount;
}
- (UIImageView*)teamLeaderImg{
    if (_teamLeaderImg == nil) {
        _teamLeaderImg =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _teamLeaderImg.layer.masksToBounds = YES;
        _teamLeaderImg.layer.cornerRadius =_teamLeaderImg.height/2.0;
        
    }
    return _teamLeaderImg;
}
- (UIScrollView*)teamMenbers{
    if (_teamMenbers == nil) {
        _teamMenbers = [[UIScrollView alloc] initWithFrame:CGRectMake(BOUNDS.size.width*0.3, 10, BOUNDS.size.width*0.6, 40)];
    }
    return _teamMenbers;
}
#pragma mark UItableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return titleArr.count;
    }
    else{
        return imgArray.count;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        ScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mycell"];
        if (cell == nil) {
            cell = [[ScoreCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"mycell"];
//            UIImageView *ima = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, BOUNDS.size.width,BOUNDS.size.width*(99.0/750.0))];
//            ima.image = [UIImage imageNamed:@"球队经理人—球队详情页_02"];
//            [cell.contentView addSubview:ima];
            cell.separatorInset = UIEdgeInsetsMake(0, BOUNDS.size.width, 0, 0);
        }
        [cell configInfo:imgArray[indexPath.row]];
        return cell;
    }
    else{
    ZHTeamDetaillCell *cell= [[ZHTeamDetaillCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.detailTextLabel.text =[dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text =[titleArr objectAtIndex:indexPath.row];
    if (indexPath.row==0) {
        //战友
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.contentView addSubview:self.menberCount];
        [cell.contentView addSubview:self.teamMenbers];
    }
    else if (indexPath.row==3){
        //队长
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.detailTextLabel addSubview:self.teamLeaderImg];
    }
    else if(indexPath.row == 7){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    return cell;
    }
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return @"球队战绩";
    }
    else{
        return @"";
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
    
    if (indexPath.row==0) {
        return 70.0;
    }
    else{
        return 44.0;
    }
    }
    else{
        return BOUNDS.size.width*(99.0/750.0)+20;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section==0) {
    if (indexPath.row==0) {
        //战友
        WPCMenberListVC *teamPlayerList = [[WPCMenberListVC alloc] init];
        teamPlayerList.detailType = MenberTeamType;
        teamPlayerList.title = @"球队成员";
        teamPlayerList.teamModel = self.teamModel;
        if ([[LVTools mToString:self.teamModel.creatorId] isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
            teamPlayerList.isTeamLeader = YES;
        }
        else{
            teamPlayerList.isTeamLeader = NO;
        }
        teamPlayerList.chuanBlock = ^(NSArray *arr) {
            //[self loadPlayersList];
            [self loadTeamInfo];
            NSArray *backarr = [NSArray array];
            self.chuanBlock(backarr);
        };
        [self.navigationController pushViewController:teamPlayerList animated:YES];
    }
    else if(indexPath.row==3){
        //队长信息
        NSLog(@"%@",[kUserDefault valueForKey:kUserId]);
        NSLog(@"%@",self.leaderModel.uid);
        if ([[LVTools mToString:[kUserDefault valueForKey:kUserId]] isEqualToString:[LVTools mToString:self.teamModel.creatorId]]) {
            WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
            vc.basicVC = NO;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
                WPCFriednMsgVC *leaderInfo = [[WPCFriednMsgVC alloc] init];
                leaderInfo.uid =[LVTools mToString: self.teamModel.creatorId];
                [self.navigationController pushViewController:leaderInfo animated:YES];
            }
            else{
                LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
            }
                    }
    }
        if (indexPath.row == 7) {
            ListViewController *vc= [[ListViewController alloc] init];
            vc.title = @"球队粉丝";
            vc.teamId = self.teamId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else{
        TeamResultController *teamResultVc= [[TeamResultController alloc] init];
        NSDictionary *record =[imgArray objectAtIndex:indexPath.row];
        teamResultVc.matchId = [LVTools mToString:record[@"matchId"]];
        teamResultVc.type = self.teamModel.sportsType;
        teamResultVc.record = record;
        [self.navigationController pushViewController:teamResultVc animated:YES];
    }
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
