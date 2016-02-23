//
//  WPCTimeMachineVC.m
//  yuezhan123
//
//  Created by admin on 15/5/18.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCTimeMachineVC.h"
#import "WPCTimeMachineCell.h"
#import "ImgShowViewController.h"
#import "WPCTimeDetailVC.h"
#import "ZHShuoModel.h"
#import "ZHCommentController.h"
#import "ZHAppointDetailController.h"
#import "GetAppliesModel.h"
#import "ZHTeamDetailController.h"
#import "TeamModel.h"
#import "WPCSportDetailVC.h"
#import "GetMatchListModel.h"
typedef NS_ENUM(NSInteger, ActivityType) {
    ActivityTypeGroup,                  // 加入了群组
    ActivityTypeTeam,                 //组建了站队
    ActivityTypeAppoint,                 //发起了越战
    ActivityTypeSport,                 //报名了赛事
    ActivityTypeRecord                 //分享了跑步记录
};

@interface WPCTimeMachineVC () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    NSInteger pageNum;
    NSMutableArray *resultArray;
}

@property (nonatomic, strong) UITableView *timeTableView;
@property (nonatomic, copy) NSString *testString;
@property (nonatomic, assign) ActivityType testActivityType;
@property (nonatomic, strong) NSMutableArray *testTypeArray;

@end

@implementation WPCTimeMachineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //test data
    self.testTypeArray = [[NSMutableArray alloc] initWithCapacity:0];
    pageNum = 1;
    if ([_userId isEqualToString:[kUserDefault objectForKey:kUserId]]) {
        self.title = @"我的时光机";
    }
    else{
        self.title = @"Ta的时光机";
    }

    [self navgationBarLeftReturn];
   
    
    [self initialInterface];
    [self loadMyMessages];
    [self MJRefresh];
}
#pragma  mark --刷新
- (void)MJRefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.timeTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum=1;
        [weakSelf loadMyMessages];
    }];
    
    self.timeTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        pageNum=pageNum+1;
        [weakSelf loadMyMessages];
    }];
}

//加载我的时光机
- (void)loadMyMessages{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.userId forKey:@"uid"];//用户标识
    [dic setValue:[NSString stringWithFormat:@"%d",(int)pageNum] forKey:@"page"];
    [dic setValue:@"5" forKey:@"rows"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getMyMessages parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        [_timeTableView.mj_header endRefreshing];
        [_timeTableView.mj_footer endRefreshing];
       if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
           if (!resultArray) {
               resultArray = [[NSMutableArray alloc] initWithCapacity:0];
               [_testTypeArray addObject:resultArray];
           }
           if (pageNum == 1) {
               [resultArray removeAllObjects];
           }
        for (NSDictionary *dic in result[@"showList"]) {
               ZHShuoModel *model  =[[ZHShuoModel alloc]init];
               [model setValuesForKeysWithDictionary:dic];
               if ([[LVTools mToString: model.type] isEqualToString:@"1"]) {
                   //普通
                   if (model.timeMachineList.count == 0) {
                       model.dynamicType = DynamicTypeString;
                   }
                   else{
                       model.dynamicType = DynamicTypeImgAndWord;
                   }
               }
               else{
                   model.dynamicType = DynamicTypeActivity;
               }
               [resultArray addObject:model];
           }
           if([result[@"showList"] count]!=0){
                [_timeTableView reloadData];
           }
           else{
               [self showHint:EmptyList];
           }
        }
       else{
           [self showHint:ErrorWord];
       }
    }];
}

- (UIView *)createHeaderView {
    UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENWIDTH/750*494)];
    backImg.image = [UIImage imageNamed:@"backGround1"];
    backImg.userInteractionEnabled = YES;
    
//    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backbtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    backbtn.frame = CGRectMake(10, 30, 36, 24);
//    [backbtn addTarget:self action:@selector(backvc) forControlEvents:UIControlEventTouchUpInside];
//    [backImg addSubview:backbtn];
    
//    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
//    if ([_userId isEqualToString:[kUserDefault objectForKey:kUserId]]) {
//        titleLab.text = @"我的时光机";
//    }
//    else{
//    titleLab.text = @"Ta的时光机";
//    }
//    titleLab.center = CGPointMake(UISCREENWIDTH/2, 42);
//    titleLab.textColor = [UIColor whiteColor];
//    titleLab.textAlignment = NSTextAlignmentCenter;
//    titleLab.font = [UIFont systemFontOfSize:20];
//    [backImg addSubview:titleLab];
    
    UIImageView *headimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 153*UISCREENWIDTH/750, 153*UISCREENWIDTH/750)];
    headimg.layer.cornerRadius = headimg.width/2;
    headimg.center = CGPointMake(UISCREENWIDTH/2, backImg.height*270/494);
    if ([_userId isEqualToString:[kUserDefault objectForKey:kUserId]]) {
        NSLog(@"aaa ===== %@",[NSString stringWithFormat:@"%@%@",preUrl,[kUserDefault objectForKey:KUserIcon]]);
    [headimg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[kUserDefault objectForKey:KUserIcon]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    }
    else{
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@",preUrl,_iconPath]);
        [headimg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,_iconPath]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    }
    headimg.layer.masksToBounds = YES;
    [backImg addSubview:headimg];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 20)];
    lab.center = CGPointMake(UISCREENWIDTH/2, headimg.bottom+15);
    lab.textColor = [UIColor whiteColor];
    lab.text = self.userName;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:17];
    [backImg addSubview:lab];
    
    
    if ([_userId isEqualToString:[kUserDefault objectForKey:kUserId]]) {
      //代表是自己，同时今天没有发表动态
            UIView *carryview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 687*UISCREENWIDTH/750)];
            [carryview addSubview:backImg];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, backImg.bottom+80*UISCREENWIDTH/750, 175*UISCREENWIDTH/750-10, 60*UISCREENWIDTH/750)];
            lab.text = @"今天";
            lab.textAlignment = NSTextAlignmentCenter;
            [carryview addSubview:lab];
            
            UIView *verticalView = [[UIView alloc] initWithFrame:CGRectMake(UISCREENWIDTH*176/750-0.5, 518*UISCREENWIDTH/750, 0.5, 190*UISCREENWIDTH/750)];
            verticalView.backgroundColor = RGBACOLOR(220, 220, 220, 1);
            [carryview addSubview:verticalView];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(166*UISCREENWIDTH/750, 592*UISCREENWIDTH/750, 10, 10)];
            img.backgroundColor = RGBACOLOR(220, 220, 220, 1);
            img.layer.cornerRadius = 10/2;
            img.layer.masksToBounds = YES;
            [carryview addSubview:img];
            
            UIImageView *bigImg = [[UIImageView alloc] initWithFrame:CGRectMake(224*UISCREENWIDTH/750, 524*UISCREENWIDTH/759, 170*UISCREENWIDTH/750, 170*UISCREENWIDTH/750)];
            bigImg.image = [UIImage imageNamed:@"timeMachine1"];
            bigImg.userInteractionEnabled = YES;
            [carryview addSubview:bigImg];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sheetBounce)];
            [bigImg addGestureRecognizer:tap];
            
            UILabel *textlab1 = [[UILabel alloc] initWithFrame:CGRectMake(bigImg.right+5, bigImg.top+50*UISCREENWIDTH/750, 100, 15)];
            textlab1.text = @"拍一张照片";
            textlab1.font = [UIFont systemFontOfSize:14];
            [carryview addSubview:textlab1];
            
            UILabel *textlab2 = [[UILabel alloc] initWithFrame:CGRectMake(bigImg.right+5, textlab1.bottom+3, 150, 15)];
            textlab2.text = @"开始你的约战生活吧！";
            textlab2.font = [UIFont systemFontOfSize:14];
            [carryview addSubview:textlab2];
            
            return carryview;
        
    } else {
        return backImg;
    }
}

- (void)sheetBounce {
    ZHCommentController *commentVC =[[ZHCommentController alloc] init];
    commentVC.fromStyle = StyelResultTimeMachine;
    commentVC.title = @"发布时光机";
    commentVC.count = 6;
    commentVC.chuanComment = ^(NSDictionary *dic){
        
        pageNum = 1;
        [self loadMyMessages];
    };
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"1");
    } else if (buttonIndex == 1) {
        NSLog(@"2");
    } else {
        
    }
}

- (void)backvc {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)initialDataSource
//{
//    //create simulated data
//    _testTypeArray = [NSMutableArray array];
//    NSArray *arr = @[[NSNumber numberWithInteger:DynamicTypeActivity],[NSNumber numberWithInteger:DynamicTypeImgAndWord],[NSNumber numberWithInteger:DynamicTypeString]];
//    for (int i = 0; i < arc4random()%3+3; i ++) {
//        NSMutableArray *tempArr = [NSMutableArray array];
//        for (int j = 0; j < arc4random()%3+3; j ++) {
//            [tempArr addObject:arr[arc4random()%3]];
//        }
//        [_testTypeArray addObject:tempArr];
//    }
//    [_timeTableView reloadData];
//}

- (void)initialInterface
{
    _timeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, UISCREENWIDTH, UISCREENHEIGHT) style:UITableViewStylePlain];
    _timeTableView.dataSource = self;
    _timeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _timeTableView.delegate = self;
    _timeTableView.showsVerticalScrollIndicator = NO;
    _timeTableView.tableHeaderView = [self createHeaderView];
    [self.view addSubview:_timeTableView];
}

#pragma mark -- tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_testTypeArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    WPCTimeMachineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WPCTimeMachineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    ZHShuoModel *model = (ZHShuoModel*)[[_testTypeArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    CGFloat height = [LVTools sizeContent:[LVTools mToString: model.info] With:13 With2:UISCREENWIDTH-10-UISCREENWIDTH/750*225]+20;
    cell.dynamicType = model.dynamicType;
    CGFloat detailHeight = (cell.dynamicType == DynamicTypeActivity) ? UISCREENWIDTH*140/750 : ((cell.dynamicType == DynamicTypeImgAndWord) ? UISCREENWIDTH/750*210 : height);
    [cell makeUIByDictionaryInfo:model andCellHeight:detailHeight];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell.dynamicType == DynamicTypeImgAndWord) {
        cell.typeImg.image = [UIImage imageNamed:@"timeMachine1"];
    } else if (cell.dynamicType == DynamicTypeActivity) {
        cell.typeImg.image = [UIImage imageNamed:@"timeMachine2"];
    }
    cell.carryView.tag = 100+indexPath.row;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
    [cell.carryView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    cell.imgScanView.tag = 200+indexPath.row;
    [cell.imgScanView addGestureRecognizer:tap2];

    return cell;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    //详情
//    ZHShuoModel *model = [_testTypeArray[0] objectAtIndex:indexPath.row];
//    if ([[LVTools mToString:model.type] isEqualToString:@"1"]) {
//        
//        
//        WPCTimeDetailVC  *timeDetail = [[WPCTimeDetailVC alloc] init];
//        timeDetail.shouModel = model;
//        timeDetail.index = indexPath;
//        timeDetail.deleteBlock = ^(NSIndexPath *index){
//            [_testTypeArray[0] removeObjectAtIndex:index.row];
//            [_timeTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
//        };
//        [self.navigationController pushViewController:timeDetail animated:YES];
//    }
//    else if ([[LVTools mToString:model.type] isEqualToString:@"2"]){
//        //约战详情
//        ZHAppointDetailController *zhappointDetailVC =[[ZHAppointDetailController alloc] init];
//        
//        GetAppliesModel *appointModel =[[GetAppliesModel alloc]init];
//        appointModel.id =[LVTools mToString: model.go];
//        appointModel.username = model.userName;
//        appointModel.userLogoPath = model.icon;
//        appointModel.uid = model.uid;
//        zhappointDetailVC.model = appointModel;
//        zhappointDetailVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:zhappointDetailVC animated:YES];
//        
//    }
//    else if ([[LVTools mToString:model.type] isEqualToString:@"3"]){
//        //战队详情
//        ZHTeamDetailController *zhteamVC =[[ZHTeamDetailController alloc] init];
//        TeamModel *tmodel =[[TeamModel alloc] init];
//        tmodel.id = [LVTools mToString:model.go];
//        tmodel.teamName = model.info;
//        zhteamVC.teamModel = tmodel;
//        zhteamVC.teamId = tmodel.id;
//        [self.navigationController pushViewController:zhteamVC animated:YES];
//        
//    }
//    else if ([[LVTools mToString:model.type] isEqualToString:@"4"]){
//        //赛事详情
//        WPCSportDetailVC *sportVC =[[WPCSportDetailVC alloc] init];
//        GetMatchListModel *appointModel =[[GetMatchListModel alloc]init];
//        appointModel.id =[LVTools mToString: model.go];
//        sportVC.MatchModel = appointModel;
//        [self.navigationController pushViewController:sportVC animated:YES];
//    }
//    else if ([[LVTools mToString:model.type] isEqualToString:@"5"]){
//        //分享链接
//    }
//    else{
//        
//    }
//
//
//}
- (void)itemClick:(UITapGestureRecognizer *)tap {
    ZHShuoModel *model = [_testTypeArray[0] objectAtIndex:tap.view.tag-100];
    if ([[LVTools mToString: model.type] isEqualToString:@"1"]) {
    WPCTimeDetailVC *vc = [[WPCTimeDetailVC alloc] init];
    vc.shouModel = model;
    vc.index = [NSIndexPath indexPathForRow:tap.view.tag-100 inSection:0];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)imgClick:(UITapGestureRecognizer *)tap {
    ZHShuoModel *model =[resultArray objectAtIndex:tap.view.tag-200];
    
    NSMutableArray *urlArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dic in model.timeMachineList) {
        [urlArr addObject:[NSString stringWithFormat:@"%@%@",preUrl,[dic objectForKey:@"path"]]];
    }
    ImgShowViewController *imgShow = [[ImgShowViewController alloc] initWithSourceData:urlArr withIndex:0 hasUseUrl:YES];
    imgShow.data = urlArr;
    imgShow.isSelf = NO;
    [self.navigationController pushViewController:imgShow animated:YES];
}

#pragma mark -- tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZHShuoModel *model =_testTypeArray[indexPath.section][indexPath.row];
    DynamicType type = model.dynamicType;
    return (type == DynamicTypeActivity) ? UISCREENWIDTH*140/750 : ((type == DynamicTypeImgAndWord) ? UISCREENWIDTH/750*210 : [LVTools sizeContent:_testString With:13 With2:UISCREENWIDTH-10-UISCREENWIDTH/750*225]+40);
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *carryView = [[UIView alloc] init];
//    carryView.backgroundColor = [UIColor whiteColor];
//    
//    UILabel *monthLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, UISCREENWIDTH*176/750-10, 20)];
//    monthLab.textAlignment = NSTextAlignmentLeft;
//    monthLab.text = @"4月";
//    monthLab.font = Title_font;
//    [carryView addSubview:monthLab];
//    
//    UIView *grayLineView = [[UIView alloc] initWithFrame:CGRectMake(UISCREENWIDTH*176/750-0.5, 0, 0.5, 20)];
//    grayLineView.backgroundColor = RGBACOLOR(220, 220, 220, 1);
//    [carryView addSubview:grayLineView];
//    
//    return carryView;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _testTypeArray.count;
}

////去掉heaview粘性
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat sectionHeaderHeight = 20;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}



- (void)tapTheImage
{
    
}



- (void)loadData
{
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self setNoNavigationBarline:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
