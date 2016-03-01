//
//  ZHSportDetailController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/16.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "ZHSportDetailController.h"
#import "ZHCommentController.h"
#import "ZHInviteFriendController.h"
#import "SportListController.h"
#import "LVShareManager.h"
#import "ZHTeamDetailController.h"
#import "TeamModel.h"
#import "WPCFriednMsgVC.h"
#import "ZHJubaoController.h"
#import "TeamCell.h"
#import "BigImgCell.h"
#import "WebCell.h"
#import "WPCCommentCell.h"
#import "ReplyCell.h"
#import "GetMatchListModel.h"
#import "ZHSportInfoController.h"
#import "LoginLoginZhViewController.h"
#import "CommentDetailController.h"
#import "WPCImageView.h"
#import "ImgShowViewController.h"
#import "SportResultController.h"
#import "UMSocial.h"
#import "WPCMyOwnVC.h"
#define TileInitialTag 100000
@interface ZHSportDetailController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIWebViewDelegate,UMSocialUIDelegate>{
    NSMutableArray *agreeArray;
    NSMutableArray *praiseList;
    NSMutableArray *commentsArray;
    NSMutableArray *teamArray;
    NSMutableArray *usersArray;
    UIImageView *headImg;
    UIButton *zan;
    UIButton *rightBtn;
    UIButton *b;
    UIView *secv;//
    UILabel *zanUserLb;
    UIView *footView;
    NSInteger selectSection;
    CGFloat webViewHeight;
    NSDictionary *matchShowInfo;
    BOOL webLoaded;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) NSMutableDictionary *wholeInfoDic;
@end

@implementation ZHSportDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"赛事详情";
    webViewHeight = 44.0f;
    agreeArray = [[NSMutableArray alloc] initWithCapacity:0];
    praiseList = [[NSMutableArray alloc] initWithCapacity:0];
    commentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    teamArray = [[NSMutableArray alloc] initWithCapacity:0];
    usersArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self navgationBarLeftReturn];
    
    [self loadMatchData];
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 83.0/3.5, 65.0/3.5)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"sc"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"sc1"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(showSeleted:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}
- (void)createBottomViews{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100.0, _mTableView.bottom+10, BOUNDS.size.width-100.0-2*mygap,30.0)];
    [btn setBackgroundColor:[UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1.00]];
    btn.layer.cornerRadius = mygap;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.layer.borderWidth = 0.5;
    [btn addTarget:self action:@selector(addcomment) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(mygap*2, _mTableView.bottom+10, 30.0, 30.0)];
    [share setBackgroundImage:[UIImage imageNamed:@"shareBtn"] forState:UIControlStateNormal];
    [share addTarget:self action:@selector(shareOnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share];
    
    zan = [[UIButton alloc] initWithFrame:CGRectMake(share.right+mygap*2, _mTableView.bottom+10, 30.0, 30.0)];
    [zan setBackgroundImage:[UIImage imageNamed:@"mylike"] forState:UIControlStateNormal];
    [zan setBackgroundImage:[UIImage imageNamed:@"myliked"] forState:UIControlStateSelected];
    [zan addTarget:self action:@selector(zanOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zan];

}
- (void)loadMatchData{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setObject:_matchInfo.id forKey:@"id"];
    NSString * lat =[LVTools mToString: [kUserDefault valueForKey:kLocationLat]];
    NSString * lng =[LVTools mToString: [kUserDefault valueForKey:kLocationlng]];
    [dic setObject:lng forKey:@"longitude"];
    [dic setObject:lat forKey:@"latitude"];
    if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    }
    request = [DataService requestWeixinAPI:getMatchDetail parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"%@",result);
        //加载完网页再隐藏
        if (webLoaded) {
            [self hideHud];
        }
        
        if (result[@"error"]) {
            [self hideHud];
            [self showHint:ErrorWord];
        }
        else{
            if ([result[@"status"] boolValue]) {
                if (self.isMyMatch) {
                    [self readMatchById];
                }
                [self.matchInfo setValuesForKeysWithDictionary:result[@"data"][@"match"]];
                self.matchInfo.matchShow = result[@"data"][@"matchShow"][@"path"];
                self.wholeInfoDic = [NSMutableDictionary dictionaryWithDictionary:result[@"data"]];
                [agreeArray addObjectsFromArray:result[@"data"][@"agree"]];
                [praiseList addObjectsFromArray:result[@"data"][@"praiseList"]];
                [commentsArray addObjectsFromArray:result[@"data"][@"comments"]];
                [teamArray addObjectsFromArray:result[@"data"][@"matchTeams"]];
                [usersArray addObjectsFromArray:result[@"data"][@"matchUsers"]];
                matchShowInfo = result[@"data"][@"matchShow"];
                if (self.mTableView.superview == nil) {
                    [self.view addSubview:self.mTableView];
                    [self createBottomViews];
                }
                else{
                [self.mTableView reloadData];
                }
                if (agreeArray.count>0) {
                    [self setZanUserStr];
                }
                if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
                    if ([[LVTools mToString: result[@"data"][@"isAgree"]] isEqualToString:@"0"]) {
                        zan.selected = NO;
                    }
                    else{
                        zan.selected = YES;
                    }

//                zan.selected = [result[@"data"][@"isAgree"] boolValue];
                }
                if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
                    if ([[LVTools mToString: result[@"data"][@"isCollect"]] isEqualToString:@"0"]) {
                        rightBtn.selected = NO;
                    }
                    else{
                        rightBtn.selected = YES;
                    }

//                rightBtn.selected = [result[@"data"][@"isCollect"] boolValue];
                }
                if (b==nil) {
                    b = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-120, 7.0f, BOUNDS.size.width*(66.0/750.0)*3.5, BOUNDS.size.width*(66.0/750.0))];
                    [b setBackgroundImage:[UIImage imageNamed:@"赛事新-11_05"] forState:UIControlStateNormal];
                    [b setBackgroundImage:[UIImage imageNamed:@"已报名"] forState:UIControlStateSelected];
                    [b addTarget:self action:@selector(baomingOnClick:) forControlEvents:UIControlEventTouchUpInside];

                }
                if ([[LVTools mToString:self.matchInfo.signUpStatus] isEqualToString:@"1"])
                {
                    if ([[LVTools mToString: result[@"data"][@"isSignUp"]] isEqualToString:@"0"]) {
                        b.selected = NO;
                        [b setBackgroundImage:[UIImage imageNamed:@"截止报名"] forState:UIControlStateNormal];
                    }
                    else{
                        b.selected = YES;
                        [b setBackgroundImage:[UIImage imageNamed:@"截止报名"] forState:UIControlStateSelected];
                    }
                    
                }
                else{
                    if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
                        if ([[LVTools mToString: result[@"data"][@"isSignUp"]] isEqualToString:@"0"]) {
                            b.selected = NO;
                        }
                        else{
                            b.selected = YES;
                        }
                    }
                }
                
                
                NSArray *contentArr = @[[LVTools mToString: _matchInfo.sponsor],@"",[NSString getCreateTime:[NSString stringWithFormat:@"%lld", [_matchInfo.starttime longLongValue]/1000]],[LVTools mToString:_matchInfo.userlimit],[LVTools mToString:_matchInfo.phone],[LVTools mToString:_matchInfo.linkman],[LVTools mToString:_matchInfo.site],[LVTools mToString:_matchInfo.entryfee]];
                NSInteger k=0;
                for (NSInteger i=0; i<4; i++) {
                    for (NSInteger j=0; j<2; j++) {
                        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(90.0/750.0*BOUNDS.size.width+j*BOUNDS.size.width*0.54, 100.0/750.0*BOUNDS.size.width+64.0/750.0*BOUNDS.size.width*i, BOUNDS.size.width*0.5, 64.0/750.0*BOUNDS.size.width)];
                        lb.text = contentArr[k];
                        k++;
                        lb.font = Content_lbfont;
                        [headImg addSubview:lb];
                    }
                }

            }
            else{
                [self hideHud];
                [self showHint:ErrorWord];
            }
        }
    }];
}
- (void)setZanUserStr{
    NSMutableString *resultStr = [[NSMutableString alloc] initWithString:@"    "];
    NSMutableString *usersStr = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger i=0;i<(agreeArray.count>3?3:agreeArray.count);i++) {
        NSDictionary *dic = agreeArray[i];
        [resultStr appendString:dic[@"userName"]];
        [usersStr appendString:dic[@"userName"]];
        if (i==(agreeArray.count>3?2:agreeArray.count-1)) {
            [resultStr appendString:[NSString stringWithFormat:@"等%d人觉得很赞",(int)(agreeArray.count)]];
            break;
        }
        else{
            [resultStr appendString:@","];
            [usersStr appendString:@","];
        }
    }
    if (zanUserLb == nil) {
        zanUserLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, BOUNDS.size.width-2*mygap, 35.0)];
        zanUserLb.backgroundColor = [UIColor whiteColor];
        zanUserLb.font = Content_lbfont;
        zanUserLb.userInteractionEnabled = YES;
        zanUserLb.layer.borderWidth = 0.5;
        zanUserLb.layer.borderColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.00].CGColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zanListClick)];
        [zanUserLb addGestureRecognizer:tap];
    }
    NSRange rang = [resultStr rangeOfString:usersStr];
    NSAttributedString *str = [LVTools attributedStringFromText:resultStr range:rang andColor:NavgationColor];
    zanUserLb.attributedText = str;
}
- (void)zanListClick{
    SportListController *vc= [[SportListController alloc] init];
    vc.title = [NSString stringWithFormat:@"%d人赞过",(int)(agreeArray.count)];
    vc.dataArray = praiseList;
    vc.type = self.matchInfo.type;
    vc.sportName = self.matchInfo.name;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)readMatchById{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setObject:_matchInfo.id forKey:@"id"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    request = [DataService requestWeixinAPI:readMatch parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if (result[@"error"]) {
            [self showHint:ErrorWord];
        }
        else{
            if ([result[@"status"] boolValue]) {
                
            }
            else{
                
            }
        }
    }];
}
- (void)shareOnclick{
    [LVShareManager shareText:[NSString stringWithFormat:@"点击下载校动官方App－加入到%@",self.matchInfo.name] Targert:self];
    
}
#pragma mark UMengShare
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    if (response.error) {

    }
    else{
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.matchInfo.id forKey:@"id"];
        [DataService requestWeixinAPI:countShare parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            [self hideHud];
        }];

    }
}
- (void)zanOnclick:(UIButton*)btn{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else{
    if (btn.selected == YES) {
        //取消点赞
        [self showHudInView:self.view hint:LoadingWord];
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.matchInfo.id forKey:@"matchId"];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
        [DataService requestWeixinAPI:deleteZan parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                btn.selected = !btn.selected;
                for (NSInteger i=0; i<agreeArray.count; i++) {
                    NSDictionary *dic = [agreeArray objectAtIndex:i];
                    if ([[LVTools mToString: dic[@"userId"]] isEqualToString:[LVTools mToString: [kUserDefault objectForKey:kUserId]]]) {
                        [agreeArray removeObjectAtIndex:i];
                        break;
                    }
                }
                
                [self setZanUserStr];
            }
            else{
                [self showHint:@"请重试"];
            }
        }];
    }
    else{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.matchInfo.id forKey:@"matchId"];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@[] forKey:@"ids"];
    [DataService requestWeixinAPI:addMatchInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"final result === %@",result);
        [self hideHud];
        if ([result[@"status"] boolValue]) {
            btn.selected = !btn.selected;
            [agreeArray addObject:@{@"userName":[kUserDefault objectForKey:kUserName],@"face":[kUserDefault objectForKey:KUserIcon],@"createuser":[kUserDefault objectForKey:kUserId],@"userId":[kUserDefault objectForKey:kUserId],@"createtime":[NSNumber numberWithFloat:[[NSString stringTimeIntervalSince1970] floatValue]]}];
            [self setZanUserStr];
        }
        else{
            [self showHint:@"请重试"];
        }
    }];
    }
    }
}
- (void)showSeleted:(UIButton*)btn{
    //收藏赛事
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else{
        //个人信息加载失败重新加载数据
        [self showHudInView:self.view hint:LoadingWord];
        NSString *optionStr = nil;
        
        if (!btn.selected) {
            optionStr = addMatchCollect;
                   }
        else{
            optionStr = deleteMatchCollect;
           }
        NSMutableDictionary *dic = [LVTools getTokenApp];
        [dic setValue:self.matchInfo.id forKey:@"matchId"];
        [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
        [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"final result === %@",result);
            [self hideHud];
            if ([result[@"status"] boolValue]) {
                btn.selected = !btn.selected;
                if(btn.selected == YES){
                [self showHint:@"已收藏"];
                }
                else{
                [self showHint:@"已取消收藏"];
                }
            }
            else{
                [self showHint:@"请重试"];
            }
        }];
    }
}
- (void)addcomment{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else{
    ZHCommentController *comentVC =[[ZHCommentController alloc] init];
    comentVC.fromStyle = StyleResultMatch;
    comentVC.idstring = self.matchInfo.id;
    comentVC.title = @"写评论";
    comentVC.count = 3;
    comentVC.chuanComment = ^(NSDictionary *dic){
        [self loadMatchData];
    };
    [self.navigationController pushViewController:comentVC animated:YES];
    }
}
- (void)notiOnClick{
    ZHSportInfoController *Vc =[[ZHSportInfoController alloc] init];
    Vc.title = @"报名须知";
    Vc.idString = self.matchInfo.id;
    Vc.matchInfo = self.matchInfo;
    [self.navigationController pushViewController:Vc animated:YES];
}
- (void)ruleOnClick{
    ZHSportInfoController *Vc =[[ZHSportInfoController alloc] init];
    Vc.title = @"赛事规则";
    Vc.idString = self.matchInfo.id;
    Vc.matchInfo = self.matchInfo;
    [self.navigationController pushViewController:Vc animated:YES];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0-BOUNDS.size.width*(118.0/750.0)) style:UITableViewStylePlain];
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 358.0/750.0*BOUNDS.size.width)];
        headImg.userInteractionEnabled = YES;
        UIImageView *typeImg = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, 25.0, 25.0)];
        typeImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"type%@",_matchInfo.type]];
        [headImg addSubview:typeImg];
        UILabel *sportNameLb = [[UILabel alloc] initWithFrame:CGRectMake(typeImg.right+mygap, mygap, BOUNDS.size.width-130.0, 40)];
        sportNameLb.font = Btn_font;
        sportNameLb.textColor = SystemBlue;
        sportNameLb.numberOfLines = 2;
        sportNameLb.text = self.matchInfo.name;
        [headImg addSubview:sportNameLb];
        
        UIButton *notifyBt =[[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-90.0, mygap*2, 70.0, 19.0)];
        [notifyBt setBackgroundImage:[UIImage imageNamed:@"报名须知"] forState:UIControlStateNormal];
        [notifyBt addTarget:self action:@selector(notiOnClick) forControlEvents:UIControlEventTouchUpInside];
        [headImg addSubview:notifyBt];
        
        UIButton *ruleBt =[[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-90.0,notifyBt.bottom + mygap, 70.0, 19.0)];
        [ruleBt setBackgroundImage:[UIImage imageNamed:@"比赛规则"] forState:UIControlStateNormal];
        [ruleBt addTarget:self action:@selector(ruleOnClick) forControlEvents:UIControlEventTouchUpInside];
        [headImg addSubview:ruleBt];
        
        [headImg setImage:[UIImage imageNamed:@"赛事新-11_02"]];
        _mTableView.tableHeaderView = headImg;
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mTableView;
}
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4+commentsArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }
    else if(section == 1){
        if (teamArray.count==0) {
            return 0;
        }
        else if(teamArray.count>0&&teamArray.count<4){
            return teamArray.count+1;
        }
        else{
           return  3+2;//最多显示三个
        }
        //return 5;
    }
    else if(section == 2){
        if (usersArray.count==0) {
            return 0;
        }
        else if(usersArray.count>0&&usersArray.count<4){
            return usersArray.count+1;
        }
        else{
            return 3+2;//最多显示三个
        }
//        return 5;
    }
    else if(section == 3){
        return 1;
    }
    else{
        if (commentsArray.count==0) {
            return 0;
        }
        else{
            if([[commentsArray objectAtIndex:section-4][@"replys"] count]>2){
                return  3+1;
            }
            else{
                return  [[commentsArray objectAtIndex:section-4][@"replys"] count]+1;
            }
        }
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if (indexPath.section == 0) {
        BigImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bigimgcell"];
        if (cell == nil) {
            cell = [[BigImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bigimgcell"];
        }
        cell.line.hidden = YES;
        [cell.sportImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,_matchInfo.matchShow]] placeholderImage:[UIImage imageNamed:@""]];
        CGFloat width = [matchShowInfo[@"width"] floatValue];
        CGFloat height = [matchShowInfo[@"height"] floatValue];
        cell.sportImg.height = height/width*(BOUNDS.size.width-2*mygap);
        return cell;
    }
    else if(indexPath.section == 3){
            WebCell *cell = [tableView dequeueReusableCellWithIdentifier:@"webcell"];
            if (cell == nil) {
                cell = [[WebCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"webcell"];
                cell.webView.delegate = self;
                cell.webView.userInteractionEnabled = NO;
                [cell.webView loadHTMLString:self.matchInfo.schedule baseURL:nil];
            }
        
            return cell;
    }
    //球队信息
    else if(indexPath.section == 1){
        if (indexPath.row>0&&indexPath.row<4) {
            TeamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teamcell"];
            if (cell == nil) {
                cell = [[TeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"teamcell"];
            }
            [cell configWithTeamInfoDic:teamArray[indexPath.row-1]];
//            cell.teamImg.tag = indexPath.row-1+indexPath.section*100;
//            [cell.teamImg addTarget:self action:@selector(teamImgOnClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.zanBtn.tag = indexPath.row+indexPath.section*1000;
            [cell.zanBtn addTarget:self action:@selector(admireOnClick:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else{
            BigImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bigimgcell"];
            if (cell == nil) {
                cell = [[BigImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bigimgcell"];
            }
            
            if (indexPath.row == 0) {
              cell.line.hidden = NO;
                cell.sportImg.frame =CGRectMake(0, 2, BOUNDS.size.width, BOUNDS.size.width*(58.0/750.0));
                cell.sportImg.image = [UIImage imageNamed:@"赛事新-11_12"];
            }
            else if(indexPath.row == 4){
//                cell.sportImg.height = BOUNDS.size.width*(77.0/750.0);
                cell.line.hidden = YES;
                cell.sportImg.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(77.0/750.0));
                cell.sportImg.image = [UIImage imageNamed:@"赛事新-11-_02"];
            }
            return cell;
        }
    }
    else if(indexPath.section == 2){
        if (indexPath.row>0&&indexPath.row<4) {
            TeamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teamcell"];
            if (cell == nil) {
                cell = [[TeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"teamcell"];
            }
            [cell configWithUserInfoDic:usersArray[indexPath.row-1]];
            cell.zanBtn.tag = indexPath.row+indexPath.section*1000;
            [cell.zanBtn addTarget:self action:@selector(admireOnClick:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else{
            BigImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bigimgcell"];
            if (cell == nil) {
                cell = [[BigImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bigimgcell"];
            }
            if (indexPath.row == 0) {
                cell.line.hidden = NO;
                //cell.sportImg.height = BOUNDS.size.width*(58.0/750.0);
                cell.sportImg.frame = CGRectMake(0, 2, BOUNDS.size.width, BOUNDS.size.width*(58.0/750.0));
                cell.sportImg.image = [UIImage imageNamed:@"赛事新-11_18"];
            }
            else if(indexPath.row == 4){
                cell.line.hidden = YES;
                //cell.sportImg.height = BOUNDS.size.width*(77.0/750.0);
                cell.sportImg.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(77.0/750.0));
                cell.sportImg.image = [UIImage imageNamed:@"赛事新-11-_04"];
            }
            return cell;
        }
    }
    else {
        if (indexPath.row==0) {
            WPCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comentcell"];
            if (cell == nil) {
                cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"comentcell" commentType:WPCSportCommentType];
            }
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:[WPCImageView class]]) {
                    [view removeFromSuperview];
                }
            }
            cell.index = indexPath;
            [cell configTheCellContent:[commentsArray objectAtIndex:indexPath.section-4]];
            
            cell.morActionBtn.tag = TileInitialTag+indexPath.section;
            cell.replyActionBtn.tag = 2*TileInitialTag+indexPath.section;
            cell.headImgView.tag = 3*TileInitialTag+indexPath.section;
            [cell.morActionBtn addTarget:self action:@selector(moreOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.replyActionBtn addTarget:self action:@selector(replyOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.headImgView addTarget:self action:@selector(headOnClick:) forControlEvents:UIControlEventTouchUpInside];
            //评论里的图片tag为90+i
            if ([[commentsArray objectAtIndex:indexPath.section-4][@"commentImages"] count] > 0) {
                for (int i = 0; i < [[commentsArray objectAtIndex:indexPath.section-4][@"commentImages"] count]; i++) {
                    WPCImageView *image = (WPCImageView *)[cell.contentView viewWithTag:90+i];
                    image.row = indexPath.section-4;
                    image.userInteractionEnabled = YES;
                    UITapGestureRecognizer *commentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImagesFromComment:)];
                    [image addGestureRecognizer:commentImgTap];
                }
                cell.line.top = [LVTools sizeContent:[commentsArray objectAtIndex:indexPath.section-4][@"message"] With:14 With2:(UISCREENWIDTH-60-60)]+130.0+10.0;
            }
            else{
                cell.line.top = [LVTools sizeContent:[commentsArray objectAtIndex:indexPath.section-4][@"message"] With:14 With2:(UISCREENWIDTH-60-60)]+40.0+10.0;
            }
            if ([[commentsArray objectAtIndex:indexPath.section-4][@"replys"] count]==0) {
                cell.line.hidden = YES;
            }
            else{
                cell.line.hidden = NO;
            }
            return cell;
        }
        else{
            if([[commentsArray objectAtIndex:indexPath.section-4][@"replys"] count]>2){
                ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replycell"];
                if (cell == nil) {
                    cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replycell"];
                }
                if (indexPath.row == 3) {
                    cell.contentLb.textAlignment = NSTextAlignmentRight;
                    cell.contentLb.text = [NSString stringWithFormat:@"更多%d条回复...",(int)[[commentsArray objectAtIndex:indexPath.section-4][@"replys"] count]-2];
                    cell.contentLb.textColor = SystemBlue;
                    cell.separatorInset = UIEdgeInsetsMake(0, BOUNDS.size.width, 0, 0);
                }
                else{
                [cell configDic:[commentsArray objectAtIndex:indexPath.section-4][@"replys"][indexPath.row-1]];
                    cell.separatorInset =  UIEdgeInsetsMake(0, 50.0, 0, 0);
                }
                return cell;

            }
            else{
                ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replycell"];
                if (cell == nil) {
                    cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replycell"];
                }
                [cell configDic:[commentsArray objectAtIndex:indexPath.section-4][@"replys"][indexPath.row-1]];
                return cell;

            }
                       }
}
}
- (void)teamImgOnClick:(UIButton*)btn{
    
}
- (void)admireOnClick:(UIButton*)btn{
      if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
    if (btn.selected) {
        [self showHint:@"已打赏"];
        return;
    }
    NSMutableDictionary *dic = [LVTools getTokenApp];
    NSDictionary *infoDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (btn.tag/1000 == 1) {
        [infoDic setValuesForKeysWithDictionary: [teamArray objectAtIndex:btn.tag-1000-1]];
        [dic setValue:[NSNumber numberWithInt:1] forKey:@"type"];
        [dic setValue:infoDic[@"id"] forKey:@"accusativeId"];
    }
    else{
        [infoDic setValuesForKeysWithDictionary:[usersArray objectAtIndex:btn.tag-2000-1]];
        [dic setValue:[NSNumber numberWithInt:2] forKey:@"type"];
        [dic setValue:infoDic[@"id"] forKey:@"accusativeId"];
    }
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:MatchAdmire parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"---------------------%@",result);
        [self hideHud];
        if ([result[@"status"] boolValue]) {
            btn.selected = YES;
            [infoDic setValue:[NSNumber numberWithInt:1] forKey:@"isAdmire"];
            [infoDic setValue:[NSNumber numberWithInt:[infoDic[@"admireNum"] intValue]+1] forKey:@"admireNum"];
            if (btn.tag/1000 == 1) {
                [teamArray replaceObjectAtIndex:btn.tag-1000-1 withObject:infoDic];
                [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag-1000 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                [usersArray replaceObjectAtIndex:btn.tag-2000-1 withObject:infoDic];
                [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag-2000 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
      }
      else{
          LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
          UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
          [self.navigationController presentViewController:loginNav animated:YES completion:nil];
      }
}
#pragma mark private
- (void)moreOnClick:(UIButton*)btn{
   
    if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
    selectSection = btn.tag-TileInitialTag;
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
    [action showInView:self.view];
    }
    else{
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
}
- (void)replyOnClick:(UIButton*)btn{
    CommentDetailController *vc= [[CommentDetailController alloc] init];
    vc.title = @"赛事评论";
    vc.commentDic =[[NSMutableDictionary alloc] initWithDictionary:[commentsArray objectAtIndex:btn.tag-2*TileInitialTag-4]];
    vc.chuanBlock = ^(NSArray* arr){
        if (arr.count>0) {
            [commentsArray replaceObjectAtIndex:btn.tag-2*TileInitialTag-4 withObject:[arr lastObject]];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)headOnClick:(UIButton*)btn{
    if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
        
         NSDictionary *dic = commentsArray[btn.tag-3*TileInitialTag-4];
        if ([[LVTools mToString:dic[@"createuser"]] isEqualToString:[LVTools mToString:[kUserDefault valueForKey:kUserId]]]) {
            WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
            vc.basicVC = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
        WPCFriednMsgVC *msgVc =[[WPCFriednMsgVC alloc] init];
        NSDictionary *dic = commentsArray[btn.tag-3*TileInitialTag-4];
        msgVc.uid = dic[@"createuser"];
        [self.navigationController pushViewController:msgVc animated:YES];
        }
    }
    else{
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }

}
- (void)scanImagesFromComment:(UITapGestureRecognizer *)sender {
    //ImgShowViewController
    WPCImageView *view = (WPCImageView *)sender.view;
    NSMutableArray *imagearr = [NSMutableArray array];
    for (int i = 0; i < [[commentsArray objectAtIndex:view.row][@"commentImages"] count]; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,[[commentsArray objectAtIndex:view.row][@"commentImages"][i] valueForKey:@"path"]];
        [imagearr addObject:str];
    }
    
    ImgShowViewController *vc = [[ImgShowViewController alloc] initWithSourceData:imagearr withIndex:sender.view.tag-90 hasUseUrl:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        CGFloat width = [matchShowInfo[@"width"] floatValue];
        CGFloat height = [matchShowInfo[@"height"] floatValue];
        return  height/width*(BOUNDS.size.width-2*mygap)+2*mygap;
    }
    else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            return BOUNDS.size.width*(58.0/750.0)+2.5;
        }
        else if(indexPath.row==teamArray.count+1){
           return BOUNDS.size.width*(77.0/750.0);
        }
        else{
            return 35.0;
        }
    }
    else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            return BOUNDS.size.width*(58.0/750.0)+2.5;
        }
        else if(indexPath.row==usersArray.count+1){
            return BOUNDS.size.width*(78.0/750.0);
        }
        else{
            return 35.0;
        }
    }
    else if(indexPath.section==3){
        if (indexPath.row==0) {
            return webViewHeight;
        }
        else{
            return BOUNDS.size.width*(77.0/750.0);
        }
    }
    else{
        if (indexPath.row == 0) {
            //return BOUNDS.size.width*(193.0/750.0);
            if ([[commentsArray objectAtIndex:indexPath.section-4][@"commentImages"] count] > 0) {
                return [LVTools sizeContent:[commentsArray objectAtIndex:indexPath.section-4][@"message"] With:14 With2:(UISCREENWIDTH-60-60)]+130.0+10.0;
            }
            else{
                return [LVTools sizeContent:[commentsArray objectAtIndex:indexPath.section-4][@"message"] With:14 With2:(UISCREENWIDTH-60-60)]+40.0+10.0;
            }
        }
        else{
            if([[commentsArray objectAtIndex:indexPath.section-4][@"replys"] count]>2&&indexPath.row==3){
                return 30.0;
            }
            else{
            NSDictionary *dic = [commentsArray objectAtIndex:indexPath.section-4][@"replys"][indexPath.row-1];
            NSString *time = [NSString getCreateTime:[NSString stringWithFormat:@"%lld", [dic[@"createtime"] longLongValue]/1000]];
            NSString *contentstr = [NSString stringWithFormat:@"%@:%@ %@",dic[@"userName"],dic[@"message"],time];
                if ([LVTools mToString:dic[@"parentId"]].length>0) {
                    contentstr = [NSString stringWithFormat:@"%@:回复%@ %@ %@",dic[@"userName"],dic[@"lastName"],dic[@"message"],time];
                }
                NSLog(@"%@",contentstr);
            return [LVTools sizeContent:contentstr With:11.0 With2:BOUNDS.size.width-55.0-mygap*2]+mygap;
            }
        }
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        if (secv == nil) {
       secv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(66.0/750.0)+15.0)];
        secv.backgroundColor = [UIColor whiteColor];
            if (b==nil) {
    b = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-120, 7.0f, BOUNDS.size.width*(66.0/750.0)*3.5, BOUNDS.size.width*(66.0/750.0))];
    [b setBackgroundImage:[UIImage imageNamed:@"赛事新-11_05"] forState:UIControlStateNormal];
    [b setBackgroundImage:[UIImage imageNamed:@"已报名"] forState:UIControlStateSelected];
    [b setBackgroundImage:[UIImage imageNamed:@"截止报名"] forState:UIControlStateDisabled];
         
    [b addTarget:self action:@selector(baomingOnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
    [secv addSubview:b];
        }
    return secv;
    }
    else if(section == 4){
        return nil;
    }
    else{
       UIImageView *secimageView= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(66.0/750.0))];
        [secimageView setBackgroundColor:[UIColor whiteColor]];
        secimageView.layer.borderColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.00].CGColor;
        secimageView.layer.borderWidth = 0.7;
        NSString *imageName = nil;
        if (section==1) {
            imageName = [NSString stringWithFormat:@"球队信息%@",_matchInfo.type];
        }
        else if(section == 2){
            imageName = [NSString stringWithFormat:@"参赛人员%@",_matchInfo.type];
        }
        else if(section == 3){
            imageName = [NSString stringWithFormat:@"赛事赛程%@",_matchInfo.type];
        }
        [secimageView setImage:[UIImage imageNamed:imageName]];
        return secimageView;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return BOUNDS.size.width*(66.0/750.0)+15.0;
    }
    else if (section==1) {
            if(teamArray.count==0){
            return 0;
            }
            else{
                return BOUNDS.size.width*(66.0/750.0);
            }
    }
    else if(section==2){
            if(usersArray.count == 0){
            return 0;
            }
            else{
                return BOUNDS.size.width*(66.0/750.0);
            }
        }
    else if (section==3){
        return BOUNDS.size.width*(66.0/750.0);
    }
    else{
        return 0.0f;
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section==3) {
        if (agreeArray.count>0) {
    if (zanUserLb == nil) {
        zanUserLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, BOUNDS.size.width-2*mygap, 35.0)];
        zanUserLb.font = Content_lbfont;
        zanUserLb.backgroundColor = [UIColor whiteColor];
        zanUserLb.layer.borderWidth = 0.5;
        zanUserLb.layer.borderColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.00].CGColor;
    }
            if (footView==nil) {
                footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 50.0)];
                footView.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.00];
                [footView addSubview:zanUserLb];
            }
    return footView;
        }
        else{
            return nil;
        }
    }
    else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 5.0f;
    }
    else if(section == 1){
        if (teamArray.count==0) {
            return 0;
        }
        return 10.0f;
    }
    else if(section == 2){
        if (usersArray.count==0) {
            return 0;
        }
        return 10.0f;
    }
    else if(section == 3){
        if (agreeArray.count>0) {
            return 30.0+20.0;
        }
        else{
        return 20.0f;
        }
    }
    else{
        return 10.0;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section==0) {
        
    }
    else if (indexPath.section == 1) {
        if (indexPath.row==4) {
        SportListController *vc= [[SportListController alloc] init];
        vc.title = @"球队信息";
        vc.dataArray = teamArray;
        vc.type = self.matchInfo.type;
        [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row==0){
            
        }
        else{
            //球队信息
            ZHTeamDetailController *msgVc =[[ZHTeamDetailController alloc] init];
            NSDictionary *tmodel =teamArray[indexPath.row-1];
            TeamModel *model = [[TeamModel alloc] init];
            [model setValuesForKeysWithDictionary:tmodel];
            msgVc.teamId = tmodel[@"teamId"];
            msgVc.teamModel = model;
            [self.navigationController pushViewController:msgVc animated:YES];
        }
    }
    else if(indexPath.section == 2){
        if(indexPath.row==4){
        SportListController *vc= [[SportListController alloc] init];
        vc.title = @"参赛人员";
        vc.type = self.matchInfo.type;
        vc.dataArray = usersArray;
        [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row==0){
            
        }
        else{
            //球员信息
            
             if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
                WPCFriednMsgVC *msgVc =[[WPCFriednMsgVC alloc] init];
                NSDictionary *dic = usersArray[indexPath.row-1];
                msgVc.uid = dic[@"userId"];
                [self.navigationController pushViewController:msgVc animated:YES];
            }
            else{
                LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
                UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [self.navigationController presentViewController:loginNav animated:YES completion:nil];
            }
        }

    }
    else if(indexPath.section == 3){
        if (indexPath.row==0) {
            ZHSportInfoController *Vc =[[ZHSportInfoController alloc] init];
            Vc.title = @"赛事赛程";
            Vc.idString = self.matchInfo.id;
            Vc.matchInfo = self.matchInfo;
            [self.navigationController pushViewController:Vc animated:YES];
        }
    }
    else if(indexPath.section == 3&&indexPath.row == 1){
//        SingleImageController *vc= [[SingleImageController alloc] init];
//        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(1082.0/750.0))];
//        vc.title = @"赞过的人";
//        img.image = [UIImage imageNamed:@"赞过的人_02"];
//        vc.imageView = img;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        if(indexPath.row==0){
//        CommentDetailController *vc= [[CommentDetailController alloc] init];
//        vc.title = @"赛事评论";
//        vc.commentDic = [commentsArray objectAtIndex:indexPath.section-4];
//        [self.navigationController pushViewController:vc animated:YES];
        }
        else{
        CommentDetailController *vc= [[CommentDetailController alloc] init];
        vc.title = @"赛事评论";
        vc.commentDic = [commentsArray objectAtIndex:indexPath.section-4];
            vc.chuanBlock = ^(NSArray* arr){
                [self loadMatchData];
            };
        [self.navigationController pushViewController:vc animated:YES];

        }
    }
}
#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        ZHJubaoController *jubaoVc= [[ZHJubaoController alloc] init];
        jubaoVc.reportId = [LVTools mToString:[commentsArray objectAtIndex:selectSection-4][@"createuser"]];
        jubaoVc.commenentId = [commentsArray objectAtIndex:selectSection-4][@"id"];
        [self.navigationController pushViewController:jubaoVc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)baomingOnClick:(UIButton*)btn{
    NSLog(@"我要报名");
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else{
    if(btn.selected){
        //已报名
        SportResultController *sportDVC =[[SportResultController alloc] init];
        sportDVC.title = @"我的报名详情";
        sportDVC.matchInfo = self.matchInfo;
        sportDVC.matchShow =matchShowInfo;
        [self.navigationController pushViewController:sportDVC animated:YES];
    }
    else{
        if ([[LVTools mToString:self.matchInfo.signUpStatus] isEqualToString:@"1"]){
            //报名已截止且未参赛
        }
    else{
    ZHInviteFriendController *inviteVC =[[ZHInviteFriendController alloc] init];
    inviteVC.type = @"2";
        inviteVC.matchType = [LVTools mToString:self.matchInfo.matchType];
        inviteVC.chuanBlock = ^(NSArray *arr){
            //刷新页面
            [self loadMatchData];
        };
    inviteVC.idStr = self.matchInfo.id;
    inviteVC.title = @"赛事报名";
    inviteVC.nameStr = self.matchInfo.name;
        inviteVC.matchType = self.matchInfo.type;
    inviteVC.floorCount = [[[self.matchInfo.userlimit componentsSeparatedByString:@"-"] objectAtIndex:0] integerValue];
    inviteVC.topCount = [[[self.matchInfo.userlimit componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue];
    [self.navigationController pushViewController:inviteVC animated:YES];
    }
    }
    }
}
#pragma mark WebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '600%'";
//    [webView stringByEvaluatingJavaScriptFromString:str];
    //垂直水平居中
    NSString *bodyStyleVertical = @"document.getElementsByTagName('body')[0].style.verticalAlign = 'middle';";
    NSString *bodyStyleHorizontal = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
    NSString *mapStyle = @"document.getElementById('mapid').style.margin = 'auto';";
    //字体大小
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '150%'";
    [webView stringByEvaluatingJavaScriptFromString:str];

    [webView stringByEvaluatingJavaScriptFromString:bodyStyleVertical];
    [webView stringByEvaluatingJavaScriptFromString:bodyStyleHorizontal];
    [webView stringByEvaluatingJavaScriptFromString:mapStyle];
    [self hideHud];
    webLoaded = YES;
    //宽度适应屏幕
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
    [webView stringByEvaluatingJavaScriptFromString:meta];
//    NSLog(@"%f",webView.scrollView.contentSize.height);
    webViewHeight = webView.scrollView.contentSize.height;
    webView.height = webView.scrollView.contentSize.height;
    [self.mTableView reloadData];
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
