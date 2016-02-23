//
//  WPCDynamicVC.m
//  yuezhan123
//
//  Created by admin on 15/6/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCDynamicVC.h"
#import "ZHShuoCell.h"
#import "ZHTimeCell.h"
#import "WPCTimeMachineVC.h"
#import "ZHNewMesController.h"
#import "ImgShowViewController.h"
#import "ZHCommentController.h"
#import "WPCTimeDetailVC.h"
#import "ZHShuoModel.h"
#import "ZHAppointDetailController.h"
#import "WPCSportDetailVC.h"
#import "ZHTeamDetailController.h"
#import "GetAppliesModel.h"
#import "TeamModel.h"
#import "GetMatchListModel.h"
@interface WPCDynamicVC()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,ZHTimeCellDelegate>{
    NSMutableArray *dataArray;
    NSInteger pageNum;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UIImageView *headImg;
@property (nonatomic,strong) UILabel *nameLb;
@property (nonatomic,strong) UIImageView *mesImg;
@property (nonatomic,strong) UILabel *mesCountLb;
@property (nonatomic,strong) UIButton *MesBtn;
@end
@implementation WPCDynamicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self navgationBarLeftReturn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(fabuClick:)];
    self.title = @"时光机";
    pageNum = 1;
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self creatHeaderView];
    [self MJRefresh];
}
#pragma  mark --刷新
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.mTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum=1;
        [weakSelf loadTimeMessage];
    }];
    
    self.mTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock :^{
        pageNum=pageNum+1;
        [weakSelf loadTimeMessage];
    }];
    [self.mTableView.mj_header beginRefreshing];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    [self setNoNavigationBarline:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self setNoNavigationBarline:NO];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;

}
//加载时光机列表
- (void)loadTimeMessage{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setValue:[NSString stringWithFormat:@"%d",(int)pageNum] forKey:@"page"];
    [dic setValue:@"5" forKey:@"rows"];
    NSLog(@"param%@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getMessages parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        [self.mTableView.mj_header endRefreshing];
        [self.mTableView.mj_footer endRefreshing];
        NSDictionary *resultDic = (NSDictionary*)result;
        if ( [resultDic[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            if (pageNum==1) {
                [dataArray removeAllObjects];
            }
            if ([result[@"showList"] count]==0) {
                [self showHint:EmptyList];
            }
            else{
            for (NSDictionary *shouDic in resultDic[@"showList"]) {
                ZHShuoModel *model  = [[ZHShuoModel alloc] init];
                [model setValuesForKeysWithDictionary:shouDic];
                [dataArray addObject:model];
            }
                [self.mTableView reloadData];
            }
            
            if (pageNum == 1) {
                if([dataArray count]!=0){
                ZHShuoModel *newestModel=[dataArray objectAtIndex:0];
                [kUserDefault setValue:[LVTools mToString: newestModel.id] forKey:LOCALNEWESTMESSAGE];
                [kUserDefault synchronize];
                }
            }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
//赞
- (void)commitMessageWithShuoId:(NSString*)shuoId withIndex:(NSInteger)index AndType:(BOOL)type{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];//用户标识
    [dic setValue:@"0" forKey:@"type"];//类型：1留言，0点赞
    [dic setValue:shuoId forKey:@"mid"];//消息标示
    [self showHudInView:self.view hint:LoadingWord];
    NSLog(@"%@",dic);
    NSString *optionStr = nil;
    if (type) {
        optionStr = delZan;
    }
    else{
        optionStr = addComment;
    }
    [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
             //修改数据
            ZHShuoModel *model = (ZHShuoModel*)[dataArray objectAtIndex:index];
            if (type) {
                model.isAgree = @"0";
             model.messagesAgreenum = [NSString stringWithFormat:@"%d",  (int)([model.messagesAgreenum integerValue]-1)];
            }
            else{
            model.isAgree = @"1";
               model.messagesAgreenum = [NSString stringWithFormat:@"%d",  (int)([model.messagesAgreenum integerValue]+1)];
            }
            //刷新该行
            [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        }
        else{
            [self showHint:ErrorWord];
        }
        
    }];
}
//删除时光机
- (void)deleteShuoWithId:(NSString*)shuoId withIndex:(NSInteger)index{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uId"];//用户标识
    [dic setValue:shuoId forKey:@"id"];
    //[dic setValue:shuoId forKey:@"mid"];//消息标示
   
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:delMessages parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
         if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
             [dataArray removeObjectAtIndex:index];
             [_mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
         }
         else{
             [self showHint:ErrorWord];
         }
        
    }];
}
- (void)fabuClick:(id)sender{
    NSLog(@"发布");
    ZHCommentController *commentVC =[[ZHCommentController alloc] init];
    commentVC.fromStyle = StyelResultTimeMachine;
    commentVC.title = @"发布时光机";
    commentVC.count = 6;
    commentVC.chuanComment = ^(NSDictionary *dic){
        [dataArray removeAllObjects];
        pageNum = 1;
        [self loadTimeMessage];
    };
    [self.navigationController pushViewController:commentVC animated:YES];
}
- (void)newMesOnClick{
    NSLog(@"新动态");
    ZHNewMesController *newMesVC =[[ZHNewMesController alloc] init];
    __weak typeof(self) weakSelf = self;
    newMesVC.chuanBlock = ^(NSArray *arr) {
        weakSelf.messageNum = @"0";
        [weakSelf.mTableView reloadData];
    };
    [_MesBtn removeFromSuperview];
    [self.navigationController pushViewController:newMesVC animated:YES];
}
- (UIButton*)MesBtn{
    if (_MesBtn == nil) {
        _MesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _MesBtn.frame = CGRectMake((BOUNDS.size.width-120)/2.0, mygap*2, 120, 25.0);
        _MesBtn.layer.cornerRadius = mygap;
        [_MesBtn setBackgroundColor:[UIColor colorWithRed:0.533f green:0.565f blue:0.573f alpha:1.00f]];
        [_MesBtn addTarget:self action:@selector(newMesOnClick) forControlEvents:UIControlEventTouchUpInside];
        [_MesBtn addSubview:self.mesImg];
        [_MesBtn addSubview:self.mesCountLb];
    }
    return _MesBtn;
}
- (UIImageView*)mesImg{
    if (_mesImg == nil) {
                _mesImg = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 20, 20)];
//        if(self.newsMessages.count!=0){
//            NSDictionary *dic = [self.newsMessages objectAtIndex:0];
//            [_mesImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"iconPath"]]]] placeholderImage: [UIImage imageNamed:@"plhor_2"]];
//        }
        _mesImg.userInteractionEnabled = YES;
    }
    return _mesImg;
}
- (UILabel*)mesCountLb{
    if (_mesCountLb == nil) {
        _mesCountLb = [[UILabel alloc] initWithFrame:CGRectMake(_mesImg.right, 2, _MesBtn.width-_mesImg.right, 20)];
        _mesCountLb .textColor = [UIColor whiteColor];
        if(![self.messageNum isEqualToString:@"0"]){
        _mesCountLb.text = [NSString stringWithFormat:@"%@条新消息",self.messageNum];
        }
        _mesCountLb.textAlignment = NSTextAlignmentCenter;
        _mesCountLb.font = Content_lbfont;
        UIImageView *img= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        img.frame = CGRectMake(_mesCountLb.width-20, 0, 20, 20);
    }
    return _mesCountLb;
}
#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView==nil) {
        _mTableView =[[UITableView alloc] initWithFrame:CGRectMake(0, -64, BOUNDS.size.width, BOUNDS.size.height) style:UITableViewStylePlain];
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mTableView.backgroundColor = BackGray_dan;
        _mTableView.scrollsToTop = YES;
        _mTableView.tableHeaderView = [self createHeaderView];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        }
    return _mTableView;
}

- (UIImageView *)createHeaderView {
    //修改了 全部向上平移64
    UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENWIDTH/750*494)];
    backImg.image = [UIImage imageNamed:@"backGround1"];
    backImg.userInteractionEnabled = YES;
    
//    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backbtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    backbtn.frame = CGRectMake(10, 30, 36, 24);
//    [backbtn addTarget:self action:@selector(backvc) forControlEvents:UIControlEventTouchUpInside];
//    [backImg addSubview:backbtn];
//    
//    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
//    titleLab.text = @"时光机";
//    titleLab.center = CGPointMake(UISCREENWIDTH/2, 42);
//    titleLab.textColor = [UIColor whiteColor];
//    titleLab.textAlignment = NSTextAlignmentCenter;
//    titleLab.font = [UIFont systemFontOfSize:20];
//    [backImg addSubview:titleLab];
    
    UIImageView *headimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 153*UISCREENWIDTH/750, 153*UISCREENWIDTH/750)];
    headimg.layer.cornerRadius = headimg.width/2;
    headimg.center = CGPointMake(UISCREENWIDTH/2, backImg.height*270/494);
    [headimg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",preUrl,[LVTools mToString:[kUserDefault objectForKey:KUserIcon]]]] placeholderImage: [UIImage imageNamed:@"plhor_2"]];;
    headimg.layer.masksToBounds = YES;
    [backImg addSubview:headimg];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 20)];
    lab.center = CGPointMake(UISCREENWIDTH/2, headimg.bottom+15);
    lab.textColor = [UIColor whiteColor];
    lab.text = [kUserDefault objectForKey:kUserName];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:17];
    [backImg addSubview:lab];
    
//    UIButton *fabubtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [fabubtn setTitle:@"发布" forState:UIControlStateNormal];
//    [fabubtn setBackgroundColor:[UIColor clearColor]];
//    [fabubtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    fabubtn.frame = CGRectMake(BOUNDS.size.width-20-40, 32, 40, 20);
//    [fabubtn addTarget:self action:@selector(fabuClick:) forControlEvents:UIControlEventTouchUpInside];
//    [backImg addSubview:fabubtn];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 150, 20)];
    btn.center = CGPointMake(UISCREENWIDTH/2, lab.bottom+15);
    [btn setTitle:@"进入我的时光机>>" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = Content_lbfont;
    [btn addTarget:self action:@selector(selfTimeOnclick) forControlEvents:UIControlEventTouchUpInside];
    [backImg addSubview:btn];
    
    return backImg;
}

-(void)selfTimeOnclick{
    WPCTimeMachineVC *vc = [[WPCTimeMachineVC alloc] init];
    vc.userId =[LVTools mToString: [kUserDefault objectForKey:kUserId]];
    vc.userName = [kUserDefault objectForKey:kUserName];
    [self.navigationController pushViewController:vc animated:YES];
    NSLog(@"进入我的时光机>>");
}
- (UIImageView*)headImg{
    if (_headImg == nil) {
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake((BOUNDS.size.width-60)/2.0, 100.0f, 60.0f, 60.0f)];
        _headImg.image = [UIImage imageNamed:@"plhor_2"];
        _headImg.layer.masksToBounds  =YES;
        _headImg.layer.cornerRadius = 30.0;
    }
    return _headImg;
}
- (UILabel*)nameLb{
    if (_nameLb == nil) {
        _nameLb = [[UILabel alloc] initWithFrame:CGRectMake(0, _headImg.bottom+mygap, BOUNDS.size.width, 20)];
        _nameLb.text = @"seven";
        _nameLb.textAlignment = NSTextAlignmentCenter;
        _nameLb.textColor = [UIColor whiteColor];
        _nameLb.font = Btn_font;
    }
    return _nameLb;
}
#pragma mark uitableViewdatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHShuoModel *model = [dataArray objectAtIndex:indexPath.row];
    if ([[LVTools mToString:model.type] isEqualToString:@"1"]) {
        static NSString *timeCell= @"timecell";
        ZHTimeCell *cell =(ZHTimeCell*)[tableView dequeueReusableCellWithIdentifier:timeCell];
        if (cell ==nil) {
            cell = [[ZHTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCell];
            cell.delegate = self;
        }
        cell.contentLb.text = [LVTools mToString:model.info];
        [cell.headImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",preUrl,[LVTools mToString:model.icon]]]  forState:UIControlStateNormal placeholderImage: [UIImage imageNamed:@"plhor_2"]];
        cell.headImg.tag = 400+indexPath.row;
        [cell.headImg addTarget:self action:@selector(headImgOnclick:) forControlEvents:UIControlEventTouchUpInside];
        cell.nameLb.text = [LVTools mToString:model.userName];
        cell.timeLb.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[model.time longLongValue]/1000]];
        cell.visitCount.text =[NSString stringWithFormat: @"%@人觉得很赞",[LVTools mToString:model.messagesAgreenum]];
        cell.zanBtn.tag = 100+indexPath.row;
        cell.commentBtn.tag = 200+indexPath.row;
        cell.removeBtn.tag = 300+indexPath.row;
        cell.imgCollection.tag = 400+indexPath.row;
        cell.imgArray =model.timeMachineList;
        if ([[LVTools mToString:model.uid] isEqualToString:[kUserDefault objectForKey:kUserId]]) {
            cell.removeBtn.hidden = NO;
        }
        else{
            cell.removeBtn.hidden = YES;
        }
        [cell.imgCollection reloadData];
        if ([[LVTools mToString: model.isAgree] isEqualToString:@"0"]) {
            //未点赞
            cell.zanBtn.selected = NO;
        }
        else{
            //已点赞
            cell.zanBtn.selected = YES;
        }
        [cell.zanBtn addTarget:self action:@selector(zanOnCLick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentBtn addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.removeBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell reDrawViews];
        return cell;
    }
    else{
    static NSString *timeCell= @"shuocell";
    ZHShuoCell *cell =(ZHShuoCell*)[tableView dequeueReusableCellWithIdentifier:timeCell];
    if (cell ==nil) {
        cell = [[ZHShuoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCell];
    }
        NSString *str = @"";
        if([[LVTools mToString: model.type] isEqualToString:@"2"]){
            //发起约战
            str = [NSString stringWithFormat:@"%@发起了约战",model.userName];
            
        }
        else if([[LVTools mToString: model.type] isEqualToString:@"3"]){
            //创建战队
            str = [NSString stringWithFormat:@"%@创建了战队",model.userName];
        }
        else if([[LVTools mToString: model.type] isEqualToString:@"4"]){
            //报名赛事消息
            str = [NSString stringWithFormat:@"%@报名了赛事",model.userName];
        }
        else{
            //分享链接
            str = [NSString stringWithFormat:@"%@分享了链接",model.userName];
        }
        NSRange rang = [str rangeOfString:[LVTools mToString:model.userName]];
        cell.nameLb.attributedText = [LVTools attributedStringFromText:str range:rang andColor:NavgationColor];
        cell.contentLb.text = [LVTools mToString:model.info];
        [cell.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",preUrl,[LVTools mToString:model.icon]]]  forState:UIControlStateNormal placeholderImage: [UIImage imageNamed:@"plhor_2"]];
        [cell.mImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model.infoIcon]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
        cell.timeLb.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[model.time longLongValue]/1000]];
        cell.visitCount.text =[NSString stringWithFormat: @"%@人觉得很赞",[LVTools mToString:model.messagesAgreenum]];
        cell.headImg.tag = 400+indexPath.row;
        [cell.headImg addTarget:self action:@selector(headImgOnclick:) forControlEvents:UIControlEventTouchUpInside];
        cell.zanBtn.tag = 100+indexPath.row;
        cell.commentBtn.tag = 200+indexPath.row;
        cell.removeBtn.tag = 300+indexPath.row;
        [cell.zanBtn addTarget:self action:@selector(zanOnCLick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentBtn addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.removeBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        if ([[LVTools mToString:model.uid] isEqualToString:[kUserDefault objectForKey:kUserId]]) {
            cell.removeBtn.hidden = NO;
        }
        else{
            cell.removeBtn.hidden = YES;
        }
        if ([[LVTools mToString: model.isAgree] isEqualToString:@"0"]) {
            //未点赞
            cell.zanBtn.selected = NO;
        }
        else{
            //已点赞
            cell.zanBtn.selected = YES;
        }

    return cell;
}
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHShuoModel *model = [dataArray objectAtIndex:indexPath.row];
    
    if ([[LVTools mToString:model.type] isEqualToString:@"1"]) {
        if (BOUNDS.size.width==320.0) {
            if (model.timeMachineList.count==0) {
                return 140.0+10.0;
            }
            else if (model.timeMachineList.count>0&&model.timeMachineList.count<4){
                return 218.0+10.0;
            }
            else{
                return 297.0+10.0;
            }
            
        }
        else if(BOUNDS.size.width == 375.0){
            if (model.timeMachineList.count==0) {
                return 140.0+10.0;
            }
            else if (model.timeMachineList.count>0&&model.timeMachineList.count<4){
                return 232.0+10.0;
            }
            else{
                return 325.0+10.0;
            }
        
        }
        else{
            if (model.timeMachineList.count==0) {
                return 140.0+10.0;
            }
            else if (model.timeMachineList.count>0&&model.timeMachineList.count<4){
                return 242.0+10.0;
            }
            else{
                 return 344.0+10.0;
            }

           
        }
    }
    else{
    return 170.0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.messageNum isEqualToString:@"0"]) {
        return 0;
    }
    return 45.0;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v =[[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 45.0)];
    for (UIView *view in v.subviews) {
        [view removeFromSuperview];
    }
    if (![self.messageNum isEqualToString:@"0"]) {
        [v addSubview:self.MesBtn];
    }
    return v;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //详情
    ZHShuoModel *model = [dataArray objectAtIndex:indexPath.row];
    if ([[LVTools mToString:model.type] isEqualToString:@"1"]) {
    WPCTimeDetailVC  *timeDetail = [[WPCTimeDetailVC alloc] init];
    timeDetail.shouModel = model;
    timeDetail.index = indexPath;
    timeDetail.deleteBlock = ^(NSIndexPath *index){
        [dataArray removeObjectAtIndex:index.row];
        [_mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
    };
    [self.navigationController pushViewController:timeDetail animated:YES];
    }
    else if ([[LVTools mToString:model.type] isEqualToString:@"2"]){
        //约战详情
        ZHAppointDetailController *zhappointDetailVC =[[ZHAppointDetailController alloc] init];
        
        GetAppliesModel *appointModel =[[GetAppliesModel alloc]init];
        appointModel.id =[LVTools mToString: model.go];
        appointModel.username = model.userName;
        appointModel.userLogoPath = model.icon;
        appointModel.uid = model.uid;
        zhappointDetailVC.model = appointModel;
        zhappointDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:zhappointDetailVC animated:YES];

    }
    else if ([[LVTools mToString:model.type] isEqualToString:@"3"]){
        //战队详情
        ZHTeamDetailController *zhteamVC =[[ZHTeamDetailController alloc] init];
        TeamModel *tmodel =[[TeamModel alloc] init];
        tmodel.id = [LVTools mToString:model.go];
        tmodel.teamName = model.info;
        zhteamVC.teamModel = tmodel;
        zhteamVC.teamId = tmodel.id;
        [self.navigationController pushViewController:zhteamVC animated:YES];
        
    }
    else if ([[LVTools mToString:model.type] isEqualToString:@"4"]){
        //赛事详情
        WPCSportDetailVC *sportVC =[[WPCSportDetailVC alloc] init];
        GetMatchListModel *appointModel =[[GetMatchListModel alloc]init];
        appointModel.id =[LVTools mToString: model.go];
        sportVC.MatchModel = appointModel;
        [self.navigationController pushViewController:sportVC animated:YES];
    }
    else if ([[LVTools mToString:model.type] isEqualToString:@"5"]){
        //分享链接
    }
    else{
        
    }
}
//去掉heaview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 45;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
//    NSLog(@"%d",(int)(scrollView.contentOffset.y));
//    if (scrollView.contentOffset.y<=-64.0) {
//        scrollView.contentOffset = CGPointMake(0, -64.0);
//    }
}
#pragma mark ZHTimeCellDelegate
- (void)mcollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%d",(int)(indexPath.row));
    ZHShuoModel *model =[dataArray objectAtIndex:collectionView.tag-400];
    NSMutableArray *urlArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dic in model.timeMachineList) {
        [urlArr addObject:[NSString stringWithFormat:@"%@%@",preUrl,[dic objectForKey:@"path"]]];
    }
    ImgShowViewController *imgshowVC =[[ImgShowViewController alloc] initWithSourceData:urlArr withIndex:indexPath.row hasUseUrl:YES];
    [self.navigationController pushViewController:imgshowVC animated:YES];
}
- (void)creatHeaderView {
    [self.view addSubview:self.mTableView];
}

- (void)zanOnCLick:(UIButton*)btn {
    NSLog(@"%d",(int)(btn.tag));
    
    ZHShuoModel *model = (ZHShuoModel*)[dataArray objectAtIndex:btn.tag-100];
    NSLog(@"%@",[LVTools mToString: model.id]);
    
        //取消赞
        [self commitMessageWithShuoId:[LVTools mToString:model.id] withIndex:btn.tag-100 AndType:btn.selected];
    }
- (void)commentClick:(UIButton*)btn{
    NSLog(@"%d",(int)(btn.tag));
    ZHShuoModel *model = [dataArray objectAtIndex:btn.tag-200];
    
    WPCTimeDetailVC  *timeDetail = [[WPCTimeDetailVC alloc] init];
    timeDetail.shouModel = model;
    timeDetail.index = [NSIndexPath indexPathForRow:btn.tag-200 inSection:0];
    [self.navigationController pushViewController:timeDetail animated:YES];
}
- (void)deleteClick:(UIButton*)btn{
    ZHShuoModel *model = (ZHShuoModel*)[dataArray objectAtIndex:btn.tag-300];
     NSLog(@"%@",[LVTools mToString: model.id]);
    [self deleteShuoWithId:[LVTools mToString:model.id] withIndex:btn.tag-300];
}
- (void)backvc {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)headImgOnclick:(UIButton*)btn{
    ZHShuoModel *model = [dataArray objectAtIndex:btn.tag-400];
    WPCTimeMachineVC *vc = [[WPCTimeMachineVC alloc] init];
    vc.userId = [LVTools mToString:model.uid];
    vc.userName = [LVTools mToString:model.userName];
    vc.iconPath = model.icon;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
