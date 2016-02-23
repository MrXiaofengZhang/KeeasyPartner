//
//  ZHFoundViewController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/16.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHFoundViewController.h"
#import "ZHVenueController.h"
#import "WPCDynamicVC.h"
#import "LVNearByViewController.h"
#import "WPCTeamHpVC.h"
#import "ZHShuoModel.h"
#import "LoginHomeZhViewController.h"
#define cellHeight 48.0f
@interface ZHFoundViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *msgCount;//系统推送的消息个数
    BOOL newDynamic;//判断时光机是否有新动态的标志
    UILabel *countlab ;
    NSString *messages;
    ZHShuoModel *newestShou;
    UIImageView *img;
    UIView *redDotView;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation ZHFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发现";
    messages = @"0";
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:2];
    NSDictionary *firstDic= @{@"title":@"时光机",@"imgName":@"timeMach"};
    [self.dataArray addObject:@[firstDic]];
    NSArray *titleArr = @[@"场馆",@"战队",@"附近的人"];
    NSArray *imgNameArr = @[@"venueMach",@"zhanTeam",@"nearBody"];
    NSMutableArray *secondArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i=0; i<titleArr.count; i++) {
        NSDictionary *Dic= @{@"title":[titleArr objectAtIndex:i],@"imgName":[imgNameArr objectAtIndex:i]};
        [secondArr addObject:Dic];
    }
    msgCount = @"1";//先设定为0
    newDynamic = YES;//先假定有
    [self.dataArray addObject:secondArr];
    [self.view addSubview:self.mTableView];
//    [self getAboutmeNum];
//    [self getNewestMessage];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *islogin = [LVTools mToString:[kUserDefault objectForKey:kUserLogin]];
    if([islogin isEqualToString:@"1"]){
    [self getAboutmeNum];
    [self getNewestMessage];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
#pragma mark private
/**
 *  获取好友最新一条动态
 */
- (void)getNewestMessage{
    newestShou = nil;
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setValue:@"1" forKey:@"page"];
    [dic setValue:@"1" forKey:@"rows"];
    NSLog(@"param%@",dic);
    [DataService requestWeixinAPI:getMessages parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
       
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary*)result;
        if ( [resultDic[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            if ([result[@"showList"] count]==0) {
                newestShou = nil;
            }
            else{
            for (NSDictionary *shouDic in resultDic[@"showList"]) {
                ZHShuoModel *model  = [[ZHShuoModel alloc] init];
                [model setValuesForKeysWithDictionary:shouDic];
                newestShou = model;
                NSLog(@"-----------%@",[LVTools mToString:model.id]);
            }
                if ([[LVTools mToString:newestShou.id] isEqualToString:[kUserDefault objectForKey:LOCALNEWESTMESSAGE]]||newestShou==nil) {
                    //没有新动态
                    img.hidden = YES;
                    redDotView.hidden = YES;
                }
                else{
                    //有新动态
                    //设置图片和红点
                    img.hidden = NO;
                    redDotView.hidden = NO;
                    [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,newestShou.icon]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
                }
            }
            
        }
        else{
            [self showHint:ErrorWord];
        }
    }];

}
/**
 *  获取与我相关的个数
 */
- (void)getAboutmeNum{
    NSDictionary *dic  =[LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:aboutMeNum parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST"  completion:^(id result) {
        //
        NSLog(@"%@",result);
        [self hideHud];
        if ( [result[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            //
            NSString *unreadNum = [NSString stringWithFormat:@"%@",result[@"aboutMeNum"]];
            messages = unreadNum;
            if (![unreadNum isEqualToString:@"0"]) {
                countlab.text = unreadNum;
                countlab.hidden = NO;
            }
            else{
                countlab.hidden = YES;
            }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
#pragma mark Getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *view = [[UIView alloc] init];
        _mTableView.tableFooterView = view;
        
    }
    return _mTableView;
}
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.dataArray objectAtIndex:section] count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.font = Btn_font;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-0.5, UISCREENWIDTH, 0.5)];
        lineView.backgroundColor = RGBACOLOR(210, 210, 210, 1);
        [cell.contentView addSubview:lineView];
        
        UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        arrowImg.frame = CGRectMake(UISCREENWIDTH-35, (cellHeight-20)/2, 20, 20);
        [cell.contentView addSubview:arrowImg];
    }
    NSDictionary *dic = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[dic objectForKey:@"imgName"]];
    cell.textLabel.text = [dic objectForKey:@"title"];
    
    if (indexPath.row == 0) {
        UIView *secondLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 0.5)];
        secondLine.backgroundColor = RGBACOLOR(210, 210, 210, 1);
        [cell.contentView addSubview:secondLine];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        //时光机
        if (img==nil) {
            img = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-cellHeight*1.4, cellHeight/6, cellHeight*2/3, cellHeight*2/3)];
            img.hidden = YES;
            [cell.contentView addSubview:img];
        
            redDotView = [[UIView alloc] init];
            redDotView.frame = CGRectMake(CGRectGetMaxX(img.frame)-4, CGRectGetMinY(img.frame)-4, 8, 8);
            redDotView.layer.cornerRadius = 4;
            redDotView.layer.masksToBounds = YES;
            redDotView.hidden = YES;
            redDotView.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:redDotView];
           
                countlab = [[UILabel alloc] initWithFrame:CGRectMake( 110, cellHeight/3, cellHeight/3, cellHeight/3)];
                countlab.layer.cornerRadius = cellHeight/6;
                countlab.layer.masksToBounds = YES;
                countlab.textAlignment = NSTextAlignmentCenter;
                countlab.backgroundColor = [UIColor redColor];
                countlab.font = [UIFont systemFontOfSize:10];
            countlab.hidden = YES;
                countlab.textColor = [UIColor whiteColor];
                [cell.contentView addSubview:countlab];
        }
        
        }
    
    return cell;
}
#pragma mark UITableDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
     NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //时光机
            
           
            if ([islogin isEqualToString:@"1"]) {
                WPCDynamicVC *dynamic = [[WPCDynamicVC alloc] init];
                dynamic.messageNum = messages;
                dynamic.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:dynamic animated:YES];
            }
            else{
                LoginHomeZhViewController * vc = [[LoginHomeZhViewController alloc] init];
                UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }

            
            

        }
    }
    else{
        if (indexPath.row == 0) {
            //场馆
            ZHVenueController *venueVC = [[ZHVenueController alloc] init];
            venueVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:venueVC animated:YES];
        }
        else if (indexPath.row == 1){
            //战队
            WPCTeamHpVC *vc = [[WPCTeamHpVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.title = @"战队";
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            LVNearByViewController *vc = [[LVNearByViewController alloc] init];
            vc.title = @"附近的人";
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
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
