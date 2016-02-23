//
//  SportResultController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/20.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "SportResultController.h"
#import "ZHSportDetailController.h"
#import "ZHCollectionCell.h"
#import "ZHInviteCell.h"
#import "NearByModel.h"
#import "ZHInviteFriendController.h"
#import "GetMatchListModel.h"
@interface SportResultController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource>{
    NSMutableArray *teamArray;//战队列表
    UILabel *nameLb;
    UILabel *rankLb;
    UIButton *bottomBtn;
    NSInteger topCount;
    NSInteger lowCount;
    NSInteger curentCount;
    NSMutableArray *refuArr;//已确认人员列表
    UIButton *inviteBtn;
    TeamModel *selectModel;
    UIView *footView;
    UILabel *countLb;
}
@property (nonatomic,strong) NSMutableArray *dataArray;//成员列表
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UICollectionView *teamCollectView;
@property (nonatomic,strong) UIImageView *imgBtn;

@end

@implementation SportResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curentCount = 0;
    refuArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    topCount = [[[self.matchInfo.userlimit componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue];
    lowCount = [[[self.matchInfo.userlimit componentsSeparatedByString:@"-"] objectAtIndex:0] integerValue];
    [self navgationBarLeftReturn];
    [self.view addSubview:self.mTableView];
    if([self.title isEqualToString:@"赛事积分"]){
        //积分
        [self loadSignInfo1];
    }
    else{
        //赛事报名详情
        [self loadSignInfo];
    }
}
- (void)loadSignInfo1{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[NSNumber numberWithInteger:[self.matchId integerValue]]  forKey:@"matchId"];
    NSLog(@"%@",self.uid);
    [dic setValue:[NSNumber numberWithInteger:[self.uid integerValue]] forKey:@"uid"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getTeamMatchRecord parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            [self.imgBtn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,result[@"data"][@"path"]]] placeholderImage:[UIImage imageNamed:@"match_plo"]];
            if(self.dataArray == nil){
                self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
            }
            for (NSDictionary *dic in result[@"data"][@"matchUsers"]) {
                NearByModel *model = [[NearByModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [self.dataArray addObject:model];
            }
            if (teamArray == nil) {
                teamArray = [[NSMutableArray alloc] initWithCapacity:0];
            }
            for (NSDictionary *dic in result[@"data"][@"matchTeams"]) {
                TeamModel *model = [[TeamModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [teamArray addObject:model];
            }
//            NSString *isLogin = [LVTools mToString:[kUserDefault objectForKey:kUserLogin]];
//            TeamModel *model = nil;
//            if (teamArray.count>0) {
//                model = [teamArray objectAtIndex:0];
//            }
//            if ([isLogin isEqualToString:@"1"]&&[[LVTools mToString:[kUserDefault objectForKey:kUserId]] isEqualToString:[LVTools mToString:model.creatorId ]]) {
//                //判断是否可添加候补
//                if (curentCount<topCount) {
//                    self.mTableView.tableFooterView = [self createbottomBtn];
//                }
//            }
            [self.mTableView reloadData];
            [self.teamCollectView reloadData];
//            if (nameLb == nil) {
//                nameLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//                nameLb.font = Btn_font;
//                nameLb.backgroundColor = [UIColor redColor];
//                [self.teamCollectView addSubview:nameLb];
//                nameLb.center = self.teamCollectView.center;
//                NSDictionary *infodic = [result[@"data"][@"matchTeams"] objectAtIndex:0];
//                nameLb.text =[LVTools mToString: infodic[@"teamName"]];
//            }
            if ([self.record[@"info"] isEqualToString:@"正在比赛"]||[LVTools mToString:self.record[@"info"]].length==0) {
                
            }
            else{
                if (rankLb == nil) {
                    rankLb = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-80, 40, 60, 20)];
                    rankLb.backgroundColor = color_red_dan;
                    rankLb.font = Content_lbfont;
                    rankLb.textAlignment = NSTextAlignmentCenter;
                    rankLb.textColor = [UIColor whiteColor];
                    [self.teamCollectView addSubview:rankLb];
                    NSDictionary *infodic = nil;
                    if ([result[@"data"][@"matchTeams"] count]>0) {
                    infodic = [result[@"data"][@"matchTeams"] objectAtIndex:0];
                    }
                    
                    NSInteger rankNum = [infodic[@"scores"] integerValue];
                    if(rankNum == 1){
                        rankLb.text = @"冠军";
                    }
                    else if(rankNum == 2){
                        rankLb.text = @"亚军";
                    }
                    else if(rankNum == 3){
                        rankLb.text = @"季军";
                    }
                    else{
                        rankLb.text = [NSString stringWithFormat:@"第%d名",(int)rankNum];
                    }
                        }
                
            }
        } else {
            [self showHint:ErrorWord];
        }
    }];
}

- (void)loadSignInfo{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.matchInfo.id forKey:@"matchId"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setValue:[kUserDefault objectForKey:kLocationlng] forKey:@"longitude"];
    [dic setValue:[kUserDefault objectForKey:kLocationLat] forKey:@"latitude"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:MatchSignUpInfo parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            
            if (teamArray == nil) {
                teamArray = [[NSMutableArray alloc] initWithCapacity:0];
            }
            TeamModel *model = [[TeamModel alloc] init];
            [model setValuesForKeysWithDictionary:result[@"data"][@"team"]];
            [teamArray addObject:model];
            [self.teamCollectView reloadData];
            if(self.dataArray == nil){
                self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
            }
            for (NSInteger i=0;i<[result[@"data"][@"userList"] count];i++) {
                NSDictionary *dic = result[@"data"][@"userList"][i];
                NearByModel *model = [[NearByModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                if ([model.inviteStatus intValue]==1||i==0) {
                    [refuArr addObject:model];
                }
                [self.dataArray addObject:model];
            }
            NSString *isLogin = [LVTools mToString:[kUserDefault objectForKey:kUserLogin]];
            
            if (teamArray.count>0) {
                selectModel = [teamArray objectAtIndex:0];
            }
            //1，确认人数没达到最高报名人数2，是球队队长3，报名没截止
            if ([isLogin isEqualToString:@"1"]&&[[LVTools mToString:[kUserDefault objectForKey:kUserId]] isEqualToString:[LVTools mToString:selectModel.creatorId ]]&&[[LVTools mToString: self.matchInfo.matchStatus] isEqualToString:@"0"]) {
                //判断是否可添加候补   最大人数多于已确认
                if (topCount-refuArr.count>0) {
                   
                    topCount = [[[self.matchInfo.userlimit componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue]-refuArr.count;
                    lowCount = [[[self.matchInfo.userlimit componentsSeparatedByString:@"-"] objectAtIndex:0] integerValue]-refuArr.count;
                    NSLog(@"%d",(int)topCount);
                    NSLog(@"%d",(int)lowCount);
                    self.mTableView.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64-80);
                    [self.view addSubview:[self createFootView]];
                }
                else{
                    
                }
           }
            [self.mTableView reloadData];
            
        } else {
            [self showHint:ErrorWord];
        }
    }];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(337.0/750.0)+BOUNDS.size.width*(280.0/750.0))];
        headView.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.00];
        
        self.imgBtn = [[UIImageView alloc] initWithFrame:CGRectMake(mygap, 0, BOUNDS.size.width-2*mygap, BOUNDS.size.width*(280.0/750.0))];
        self.imgBtn.contentMode = UIViewContentModeScaleAspectFit;
        [self.imgBtn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,self.matchInfo.matchShow]] placeholderImage:[UIImage imageNamed:@"match_plo"]];
        CGFloat width = [self.matchShow[@"width"] floatValue];
        CGFloat height = [self.matchShow[@"height"] floatValue];
        self.imgBtn.height = height/width*(BOUNDS.size.width-2*mygap);
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@",preUrl,self.matchInfo.matchShow]);
        [headView addSubview:self.imgBtn];
        
        UILabel *lb1 =[[UILabel alloc] initWithFrame:CGRectMake(0, height/width*(BOUNDS.size.width-2*mygap), BOUNDS.size.width, BOUNDS.size.width*(70.0/750.0))];
        lb1.backgroundColor = [UIColor clearColor];
        lb1.text = @" 我的球队";
        lb1.font = Btn_font;
        [headView addSubview:lb1];
        [headView addSubview:self.teamCollectView];

        UILabel *lb2 =[[UILabel alloc] initWithFrame:CGRectMake(0, _teamCollectView.bottom, BOUNDS.size.width, BOUNDS.size.width*(70.0/750.0))];
        lb2.backgroundColor = [UIColor clearColor];
        if ([self.title isEqualToString:@"赛事积分"]) {
            UILabel *jifen = [[UILabel alloc] initWithFrame:CGRectMake(BOUNDS.size.width-80, 0, 80, 35)];
            jifen.backgroundColor = [UIColor clearColor];
            jifen.text = @"个人积分";
            jifen.font = Btn_font;
            [lb2 addSubview:jifen];
        }
        lb2.text = @" 已选队友";
        lb2.font = Btn_font;
        headView.height = lb2.bottom;
        [headView addSubview:lb2];
        _mTableView.tableHeaderView = headView;
        //判断是否能邀请
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
    }
    return _mTableView;
}
- (UIView*)createFootView{
    if (footView == nil) {
        footView = [[UIView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height-64-80, BOUNDS.size.width,80)];
        footView.backgroundColor = [UIColor whiteColor];
        countLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30)];
        countLb.backgroundColor = BackGray_dan;
        if (lowCount>0) {
        countLb.text = [NSString stringWithFormat:@"还能邀请%d-%d人",(int)lowCount,(int)topCount];
        }
        else{
        countLb.text = [NSString stringWithFormat:@"还能邀请%d人",(int)topCount];
        }
        [footView addSubview:countLb];
        [footView addSubview:[self createbottomBtn]];
    }
    return footView;
}
- (UIButton*)createbottomBtn{
    if (bottomBtn == nil) {
        
        bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomBtn.frame = CGRectMake(0, 30, UISCREENWIDTH, 49);
        [bottomBtn addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
        [bottomBtn setTitle:@"邀请替补" forState:UIControlStateNormal];
        [bottomBtn setImage:[UIImage imageNamed:@"addMenber"] forState:UIControlStateNormal];
        [bottomBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
        [bottomBtn setBackgroundColor:[UIColor whiteColor]];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, BOUNDS.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [bottomBtn addSubview:line];
    }
    return bottomBtn;
}
- (void)inviteClick{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NearByModel *model in _dataArray) {
        [arr addObject:[LVTools mToString:model.userId]];
    }
    ZHInviteFriendController *inviteVC= [[ZHInviteFriendController alloc] initWithBlockSelectedUsernames:arr];
    inviteVC.idStr = selectModel.teamId;//战队id
    inviteVC.nameStr =self.matchInfo.name;
    inviteVC.title = @"邀请好友";
    inviteVC.type = @"1";
    inviteVC.type = @"3";
    inviteVC.limit = topCount;
    inviteVC.chuanBlock = ^(NSArray *arr){
        
        
           };
    [self.navigationController pushViewController:inviteVC animated:YES];
}
- (UICollectionView*)teamCollectView{
    if (_teamCollectView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(60, 80);
        flowLayout.sectionInset = UIEdgeInsetsMake(mygap, mygap, mygap, mygap);
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = mygap*2;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        CGFloat width = [self.matchShow[@"width"] floatValue];
        CGFloat height = [self.matchShow[@"height"] floatValue];

        _teamCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.width*(70.0/750.0)+ height/width*(BOUNDS.size.width-2*mygap), BOUNDS.size.width, BOUNDS.size.width*(200.0/750.0)) collectionViewLayout:flowLayout];
        _teamCollectView.pagingEnabled = YES;
        _teamCollectView.scrollEnabled = NO;
        _teamCollectView.dataSource = self;
        _teamCollectView.backgroundColor = [UIColor whiteColor];
        [_teamCollectView registerClass:[ZHCollectionCell class] forCellWithReuseIdentifier:@"ZHCollectionCell"];
    }
    return _teamCollectView;
}
#pragma mark UITableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idece =@"idecell";
    ZHInviteCell *cell =[tableView dequeueReusableCellWithIdentifier:idece];
    if (cell == nil) {
        cell = [[ZHInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idece menbertype:MenberNearByType];
    }
    NearByModel *model = [_dataArray objectAtIndex:indexPath.row];
    [cell configModel:model];
    cell.distanceLb.hidden = YES;
    cell.timeLb.hidden = YES;
    cell.applyStatus.hidden = NO;
    if (indexPath.row == 0) {
        cell.statusLab.hidden = NO;
        cell.statusLab.origin = cell.timeLb.origin;
    }
    if ([self.title isEqualToString:@"赛事积分"]) {
        if([self.record[@"info"] isEqualToString:@"正在比赛"]||[LVTools mToString:self.record[@"info"]].length==0){
            cell.applyStatus.hidden = YES;
        }
        else{
            [cell.applyStatus setTitle:[NSString stringWithFormat:@"%@积分",model.scores] forState:UIControlStateNormal];
        }
        cell.nameLb.text = model.userName;
        [cell.nameLb sizeToFit];
        
        
    }
    else{
        //我的报名详情
        if ([model.inviteStatus isEqualToString:@"-1"]) {
            //队长
            cell.applyStatus.hidden = YES;
        }
        else{
            //非队长
            cell.applyStatus.hidden = NO;
            if ([model.inviteStatus isEqualToString:@"1"]) {
                [cell.applyStatus setTitle:@"已确认" forState:UIControlStateNormal];
                [cell.applyStatus setBackgroundColor:SystemBlue];
            }
            else if([model.inviteStatus isEqualToString:@"0"]){
                [cell.applyStatus setTitle:@"已拒绝" forState:UIControlStateNormal];
                [cell.applyStatus setBackgroundColor:color_red_dan];
            }
            else{
                [cell.applyStatus setTitle:@"未确认" forState:UIControlStateNormal];
                [cell.applyStatus setBackgroundColor:color_red_dan];
            }
        }
    }
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
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return teamArray.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ZHCollectionCell";
    ZHCollectionCell * cell = (ZHCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell configTeamDict:teamArray[indexPath.row]];
    cell.rankImg.hidden = YES;
    return cell;
}
- (void)nextOnclick{
    ZHSportDetailController *sportVC= [[ZHSportDetailController alloc] init];
    [self.navigationController pushViewController:sportVC animated:YES];
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
