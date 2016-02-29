//
//  AboutmeController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/2/23.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "AboutmeController.h"
#import "WPCCommentCell.h"
#import "WPCImageView.h"
#import "ImgShowViewController.h"
#import "CommentDetailController.h"
@interface AboutmeController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *commentArray;
    NSMutableArray *replyArray;
    NSInteger page;
    NSInteger rows;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UISegmentedControl *segContrl;
@end

@implementation AboutmeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    page = 1;
    rows = 10;
    [self navgationBarLeftReturn];
    [self.view addSubview:self.mTableView];
    [self MJRrefresh];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.segContrl.superview==nil) {
         [self.navigationController.navigationBar addSubview:self.segContrl];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.segContrl.superview) {
        [self.segContrl removeFromSuperview];
    }
}
#pragma mark getter
- (UISegmentedControl*)segContrl{
    if (_segContrl == nil) {
        _segContrl = [[UISegmentedControl alloc] initWithItems:@[@"回复我的",@"我的评论"]];
        _segContrl.frame = CGRectMake(124*propotion, 5, 500*propotion, 33);
        _segContrl.selectedSegmentIndex = 0;
        _segContrl.backgroundColor = [UIColor whiteColor];
        [_segContrl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        _segContrl.tintColor = SystemBlue;

    }
    return _segContrl;
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.hidden = YES;
        _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mTableView;
}
#pragma mark private
- (void)MJRrefresh{
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.mTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        if (weakSelf.segContrl.selectedSegmentIndex==0) {
            [replyArray removeAllObjects];
            [weakSelf.mTableView reloadData];
            [weakSelf loadData];
        }
        else{
            [commentArray removeAllObjects];
            [weakSelf.mTableView reloadData];
            [weakSelf loadData];
        }
    }];
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.mTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"11111");
        page++;
        [weakSelf loadData];
    }];
    [_mTableView.mj_header beginRefreshing];
}

- (void)segmentAction:(UISegmentedControl *)seg {
    page = 1;
    [self loadData];
}
- (void)loadData{
    NSString *optionStr = nil;
    if (_segContrl.selectedSegmentIndex==0) {
        optionStr = ReplyMe;
    }
    else{
        optionStr = myComment;
    }
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
    [dic setValue:[NSNumber numberWithInteger:page] forKey:@"page"];
    [dic setValue:[NSNumber numberWithInteger:rows] forKey:@"rows"];
    NSLog(@"%@",dic);
    request = [DataService requestWeixinAPI:optionStr parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"final result === %@",result);
        [self.mTableView.mj_header endRefreshing];
        [self.mTableView.mj_footer endRefreshing];
        [self hideHud];
        if ([result[@"status"] boolValue]) {
            if (_segContrl.selectedSegmentIndex==0) {
            if (replyArray==nil) {
                replyArray = [[NSMutableArray alloc] initWithCapacity:0];
                self.mTableView.hidden = NO;
            }
                if (page==1) {
                    [replyArray removeAllObjects];
                }
                [replyArray addObjectsFromArray:result[@"data"][@"replys"]];
//                for (NSDictionary *dic in result[@"data"]) {
//                    FriendListModel *model = [[FriendListModel alloc] init];
//                    if(![dic isKindOfClass:[NSNull class]]){
//                        [model setValuesForKeysWithDictionary:dic];
//                        [dataArray addObject:model];
//                    }
//                }
                
            }
            else{
                if (commentArray==nil) {
                    commentArray = [[NSMutableArray alloc] initWithCapacity:0];
                    self.mTableView.hidden = NO;
                }
                if (page==1) {
                    [commentArray removeAllObjects];
                }
                [commentArray addObjectsFromArray:result[@"data"][@"comments"]];
//                for (NSDictionary *dic in result[@"data"]) {
//                    TeamModel *teamModel = [[TeamModel alloc] init];
//                    [teamModel setValuesForKeysWithDictionary:dic];
//                    [dataArray addObject:teamModel];
//                }
            }
            [self.mTableView reloadData];
            if ([result[@"moreData"] boolValue]) {
                _mTableView.mj_footer.hidden = NO;
            }
            else{
                self.mTableView.mj_footer.hidden = YES;
            }
        }
        else{
            [self showHint:@"请重试"];
        }
    }];

}
- (void)scanImagesFromComment:(UITapGestureRecognizer *)sender {
    //ImgShowViewController
    WPCImageView *view = (WPCImageView *)sender.view;
    NSMutableArray *imagearr = [NSMutableArray array];
    for (int i = 0; i < [[commentArray objectAtIndex:view.row][@"commentImages"] count]; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,[[commentArray objectAtIndex:view.row][@"commentImages"][i] valueForKey:@"path"]];
        [imagearr addObject:str];
    }
    
    ImgShowViewController *vc = [[ImgShowViewController alloc] initWithSourceData:imagearr withIndex:sender.view.tag-400 hasUseUrl:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_segContrl.selectedSegmentIndex == 0) {
        return replyArray.count;
    }
    else{
    return commentArray.count;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    NSDictionary *contentDict = nil;
    if (self.segContrl.selectedSegmentIndex ==0) {
       contentDict = [replyArray objectAtIndex:indexPath.row];
    }
    else{
    contentDict = [commentArray objectAtIndex:indexPath.row];
    }
    [cell configTheCellContent:contentDict];
    cell.floorLb.text =[NSString stringWithFormat:@"%@", [NSString getCreateTime:[NSString stringWithFormat:@"%ld", [contentDict[@"createtime"] longValue]/1000]]];
    cell.morActionBtn.hidden = YES;
    cell.replyActionBtn.hidden = YES;
//    [cell.morActionBtn addTarget:self action:@selector(moreOnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.replyActionBtn addTarget:self action:@selector(replyOnClick:) forControlEvents:UIControlEventTouchUpInside];
    //评论里的图片tag为400+i
    if ([contentDict[@"commentImages"] count] > 0) {
        for (int i = 0; i < [contentDict[@"commentImages"] count]; i++) {
            WPCImageView *image = (WPCImageView *)[cell.contentView viewWithTag:400+i];
            image.row = indexPath.section-4;
            image.userInteractionEnabled = YES;
            UITapGestureRecognizer *commentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImagesFromComment:)];
            [image addGestureRecognizer:commentImgTap];
        }
//        cell.line.top = [LVTools sizeContent:contentDict[@"message"] With:11 With2:(UISCREENWIDTH-60-60)]+90.0+10.0;
    }
    else{
//        cell.line.top = [LVTools sizeContent:contentDict[@"message"] With:11 With2:(UISCREENWIDTH-60-60)]+40.0+10.0;
    }
        cell.line.hidden = YES;
       return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *contentArray = nil;
    if (self.segContrl.selectedSegmentIndex == 0) {
        contentArray = replyArray;
    }
    else{
        contentArray = commentArray;
    }
    if ([contentArray[indexPath.row][@"commentImages"] count] > 0) {
        return [LVTools sizeContent:contentArray[indexPath.row][@"message"] With:14 With2:(UISCREENWIDTH-60-60)]+130.0+10.0;
    }
    else{
        return [LVTools sizeContent:contentArray[indexPath.row][@"message"] With:14 With2:(UISCREENWIDTH-60-60)]+40.0+10.0;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *contentDic = nil;
    if (self.segContrl.selectedSegmentIndex == 0) {
        contentDic = [replyArray objectAtIndex:indexPath.row];
    }
    else{
        contentDic = [commentArray objectAtIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CommentDetailController *vc= [[CommentDetailController alloc] init];
    vc.title = @"赛事评论";
//    vc.commentDic = [commentsArray objectAtIndex:indexPath.section-4];
    if ([[LVTools mToString: contentDic[@"type"]] isEqualToString:@"2"]) {
        //评论
        vc.commentId = [LVTools mToString:contentDic[@"id"]];
    }
    else if ([[LVTools mToString:contentDic[@"type"]] isEqualToString:@"3"]){
        //回复
        vc.commentId = [LVTools mToString:contentDic[@"topId"]];
    }
    else{
        
    }
    vc.chuanBlock = ^(NSArray* arr){
      
    };
    [self.navigationController pushViewController:vc animated:YES];
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
