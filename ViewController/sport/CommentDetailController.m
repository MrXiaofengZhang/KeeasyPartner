//
//  CommentDetailController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/15.
//  Copyright © 2015年 LV. All rights reserved.
//  评论详情

#import "CommentDetailController.h"
#import "ReplyCell.h"
#import "WPCCommentCell.h"
#import "ZHJubaoController.h"
#import "LoginLoginZhViewController.h"
#import "HcCustomKeyboard.h"
@interface CommentDetailController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,HcCustomKeyboardDelegate>{
    NSMutableArray *replyArray;
    NSString *replyId;
    NSString *replyName;
    HcCustomKeyboard *textView;
}
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation CommentDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    replyId = nil;
    replyArray = [[NSMutableArray alloc] initWithArray:_commentDic[@"replys"]];
    [self.view addSubview:self.mTableView];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mTableView.tableFooterView = [[UIView alloc] init];
    }
    return _mTableView;
}
#pragma mark private
- (void)moreOnClick{
    NSLog(@"举报");
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
    [action showInView:self.view];
    }
 }
- (void)replyComentOnClick:(id)sender{
    //回复评论
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else{
    replyId = nil;
    replyName = self.commentDic[@"userName"];
    [self replyOnClick];
    }
}
- (void)replyOnClick{
    NSLog(@"回复");
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else{
        textView = [HcCustomKeyboard customKeyboard];
        [textView textViewShowView:self customKeyboardDelegate:self andState:YES];
        textView.mTextView.placeholder = [NSString stringWithFormat:@"回复%@:",replyName];
    }
}
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [replyArray count]+1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        WPCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comentcell"];
        if (cell == nil) {
            cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"comentcell" commentType:WPCSportCommentType];
        }
        cell.index = indexPath;
        [cell configTheCellContent:self.commentDic];
        [cell.morActionBtn addTarget:self action:@selector(moreOnClick) forControlEvents:UIControlEventTouchUpInside];
        [cell.replyActionBtn addTarget:self action:@selector(replyComentOnClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([self.commentDic[@"commentImages"] count] > 0) {
            cell.line.top = [LVTools sizeContent:self.commentDic[@"message"] With:11 With2:(UISCREENWIDTH-60-60)]+90.0+20.0;
        }
        else{
            cell.line.top = [LVTools sizeContent:self.commentDic[@"message"] With:11 With2:(UISCREENWIDTH-60-60)]+40.0+20.0;
        }

        if ([self.commentDic[@"replys"] count]==0) {
            cell.line.hidden = YES;
        }
        else{
            cell.line.hidden = NO;
        }

        return cell;

    }
    else{
    ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replyCell"];
    if (cell==nil) {
        cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replyCell"];
    }
    [cell configDic:replyArray[indexPath.row-1]];
    return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        //return BOUNDS.size.width*(193.0/750.0);
        if ([self.commentDic [@"commentImages"] count] > 0) {
            return [LVTools sizeContent:self.commentDic[@"message"] With:14 With2:(UISCREENWIDTH-60-50)]+90.0+15.0;
        }
        else{
            return [LVTools sizeContent:self.commentDic[@"message"] With:14 With2:(UISCREENWIDTH-60-50)]+40.0+15.0;
        }
    }
    else{
        NSDictionary *dic = replyArray[indexPath.row-1];
        NSString *time = [NSString getCreateTime:[NSString stringWithFormat:@"%lld", [dic[@"createtime"] longLongValue]/1000]];
        NSString *contentstr = [NSString stringWithFormat:@"%@:%@ %@",dic[@"userName"],dic[@"message"],time];
        return [LVTools sizeContent:contentstr With:11.0 With2:BOUNDS.size.width-50.0-mygap*2]+2*mygap;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row!=0){
        //回复  回复
        NSDictionary *dic = replyArray[indexPath.row-1];
        replyId = dic[@"id"];
        replyName = dic[@"userName"];
        [self replyOnClick];
    }
}
-(void)talkBtnClick:(UITextView *)textViewGet{
    NSLog(@"%@",textViewGet);
    if ([LVTools stringContainsEmoji:textViewGet.text]) {
        [self showHint:@"暂不支持表情符号"];
        return;
    }
    if (textViewGet.text.length > 0) {
        [self insertRequest:textViewGet.text];
    } else {
        //提示内容不能为空
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 20)];
        label.center = CGPointMake(UISCREENWIDTH/2, UISCREENHEIGHT/2-100);
        label.layer.cornerRadius = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"内容不能为空";
        [self.view addSubview:label];
        label.backgroundColor = [UIColor lightGrayColor];
        label.alpha = 0.8;
        [UIView animateWithDuration:0.8 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }
}
- (void)insertRequest:(NSString*)commentStr{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:_commentDic[@"matchId"] forKey:@"matchId"];
    [dic setValue:_commentDic[@"id"] forKey:@"topId"];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
    [dic setValue:replyId forKey:@"parentId"];
    [dic setValue:@"3" forKey:@"type"];
    [dic setValue:commentStr forKey:@"message"];
    [dic setValue:@[] forKey:@"ids"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:addMatchInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"final result === %@",result);
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if ([result[@"status"] boolValue]) {
            [self showHint:@"回复成功"];
            [replyArray addObject:@{@"message":commentStr,
                                    @"topId":_commentDic[@"id"],
                                    @"userName":[kUserDefault objectForKey:kUserName],
                                    @"userId":[kUserDefault objectForKey:kUserId],
                                    @"createtime":[NSNumber numberWithLongLong: (long)[[NSDate date] timeIntervalSince1970]*1000]
                                    }];
            [self.mTableView reloadData];
            [self.commentDic setObject:replyArray forKey:@"replys"];
            self.chuanBlock(@[self.commentDic]);
        } else {
            [self showHint:@"发表失败，请重试"];
        }
    }];
//    {
//        createtime = 1451977197000;
//        createuser = 25;
//        face = "/upload/pic/personal/myLogo/52156869_1451899128868.png";
//        id = 15;
//        interactTime = "<null>";
//        lastName = "<null>";
//        matchId = 5;
//        message = "\U4e0d\U9519 ";
//        parentId = "<null>";
//        topId = "<null>";
//        type = 3;
//        userId = "<null>";
//        userName = "\U82cf\U683c\U5170\U77ee\U811a\U9a6c";
//    },
}
#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (!buttonIndex== [actionSheet cancelButtonIndex]) {
        ZHJubaoController *jubaoVc= [[ZHJubaoController alloc] init];
        jubaoVc.reportId = [LVTools mToString:self.commentDic[@"createuser"]];
        jubaoVc.commenentId = self.commentDic[@"id"];
        [self.navigationController pushViewController:jubaoVc animated:YES];
    }
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
