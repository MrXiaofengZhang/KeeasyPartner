//
//  WPCCommentVC.m
//  yuezhan123
//
//  Created by admin on 15/6/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCCommentVC.h"
#import "WPCCommentCell.h"
#import "ZHCommentController.h"
#import "HcCustomKeyboard.h"
#import "WPCFriednMsgVC.h"
#import "AppDelegate.h"
#import "LoginLoginZhViewController.h"
#import "WPCMyOwnVC.h"
#import "WPCImageView.h"
#import "ImgShowViewController.h"

@interface WPCCommentVC()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong)UITableView *tableview;
@property (nonatomic, assign)NSInteger deleteIndex;
@property (nonatomic, strong)NSString *urlString;
@property (nonatomic, strong)NSString *contentstring;
@property (nonatomic, strong)NSString *partnerId;
@property (nonatomic, strong)NSString *partnerName;
@property (nonatomic, strong)NSString *replayUrlString;
@property (nonatomic, strong)NSMutableArray *actualArr;//本文件内用到的实际数组.h里面的arr主要用于回传

@end

@implementation WPCCommentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PopView)];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64-30-20) style:UITableViewStylePlain];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableview];
    self.actualArr = [NSMutableArray array];
    if (!self.isMe) {
        [self.actualArr addObjectsFromArray:self.arr];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, _tableview.bottom+mygap, UISCREENWIDTH-20, 30)];
        label.text = @"  我也要说一句...";
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13];
        label.layer.borderColor = [RGBACOLOR(230, 230, 230, 1) CGColor];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumptocommetVC)];
        [label addGestureRecognizer:tap];
        label.layer.borderWidth = 0.5;
        label.layer.borderColor = [RGBACOLOR(210, 210, 210, 1) CGColor];
        [self.view addSubview:label];
    } else {
        _tableview.frame = CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64);
        [self loadData];
    }
}

- (void)PopView{
    self.chuanBlock(self.arr);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData {
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
    if (self.fromStyle == StyleResultComment) {//约战详情里的关于我的评论
        [dic setValue:self.idString forKey:@"playId"];
        _urlString = aboutMe;
    } else if (self.fromStyle == StyleResultMatch) {//赛事详情里关于我的评论
        [dic setValue:self.idString forKey:@"matchId"];
        _urlString = aboutMacthMe;
    }
    
    [DataService requestWeixinAPI:_urlString parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            NSMutableArray *temparr = [NSMutableArray arrayWithArray:result[@"aboutMeInteracts"]];
            [self.actualArr addObjectsFromArray:temparr];
            [_tableview reloadData];
            [self.clearDelegate clearUpCommentNum];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _actualArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    WPCCommentCell *cell = (WPCCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
//    WPCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID commentType:WPCAppointCommentType];
    }
    for (UIView *view in cell.contentView.subviews) {
        view.clipsToBounds = YES;
    }
    [cell configTheplayContent:[_actualArr objectAtIndex:indexPath.row]];
    cell.headImgView.tag = 4800+indexPath.row;
    [cell.headImgView addTarget:self action:@selector(userInfoOnclick:) forControlEvents:UIControlEventTouchUpInside];
    cell.morActionBtn.tag = 4900+indexPath.row;
    [cell.morActionBtn addTarget:self action:@selector(morActionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //评论里的图片tag为400+i
    if ([[_actualArr objectAtIndex:indexPath.row][@"commentShowList"] count] > 0) {
        for (int i = 0; i < [[_actualArr objectAtIndex:indexPath.row][@"commentShowList"] count]; i++) {
            WPCImageView *image = (WPCImageView *)[cell.contentView viewWithTag:400+i];
            image.row = indexPath.row;
            image.userInteractionEnabled = YES;
            UITapGestureRecognizer *commentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImagesFromComment:)];
            [image addGestureRecognizer:commentImgTap];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scanImagesFromComment:(UITapGestureRecognizer *)sender {
    //ImgShowViewController
    WPCImageView *view = (WPCImageView *)sender.view;
    NSMutableArray *imagearr = [NSMutableArray array];
    for (int i = 0; i < [[_actualArr objectAtIndex:view.row][@"commentShowList"] count]; i ++) {
        
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,[[_actualArr objectAtIndex:view.row][@"commentShowList"][i] valueForKey:@"path"]];
        [imagearr addObject:str];
    }
    
    ImgShowViewController *vc = [[ImgShowViewController alloc] initWithSourceData:imagearr withIndex:sender.view.tag-400 hasUseUrl:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumptocommetVC
{
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
        ZHCommentController *ComentVC = [[ZHCommentController alloc] init];
        ComentVC.fromStyle = self.fromStyle;
        ComentVC.idstring = self.idString;
        ComentVC.title = @"写评论";
        ComentVC.count = 3;
        ComentVC.chuanComment = ^(NSDictionary *dic) {
            [self.arr insertObject:dic atIndex:0];
            [_actualArr insertObject:dic atIndex:0];
            [_tableview reloadData];
        };
        [self.navigationController pushViewController:ComentVC animated:YES];
    } else {
        [self jumpToLoginVC];
    }
}

- (void)jumpToLoginVC {
    LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_actualArr objectAtIndex:indexPath.row];
    NSString *tempStr;
    if ([[LVTools mToString:[dic objectForKey:@"parentId"]] isEqualToString:@""]) {
        tempStr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
    }
    else{
        tempStr = [NSString stringWithFormat:@"@%@:%@",[dic objectForKey:@"parentName"],[dic objectForKey:@"message"]];
    }
    CGFloat height = [LVTools sizeContent:tempStr With:14 With2:(UISCREENWIDTH-60-50)];
    if ([dic[@"commentShowList"] count] > 0) {
        height += 50;
    }
    return height + 55;
}

- (void)morActionBtnClick:(UIButton *)sender
{
    _deleteIndex = sender.tag - 4900;
    //先判断是否登陆，然后判断是不是自己的评论
    NSString *isLogin = [kUserDefault valueForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
        if ([[LVTools mToString:_actualArr[_deleteIndex][@"userId"]] isEqualToString:[kUserDefault valueForKey:kUserId]]) {//是自己
            UIActionSheet *actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"回复" otherButtonTitles:@"删除", nil];
            actionsheet.delegate = self;
            actionsheet.tag = 1400;
            [actionsheet showInView:self.view];
        } else {//不是自己
            UIActionSheet *actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"回复" otherButtonTitles:nil, nil];
            actionsheet.delegate = self;
            actionsheet.tag = 1401;
            [actionsheet showInView:self.view];
        }
    } else {
        [self jumpToLoginVC];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1400) {
        if (buttonIndex == 0) {
            //回复
            _partnerId = [NSString stringWithFormat:@"%@",[_actualArr objectAtIndex:_deleteIndex][@"id"]];
            _partnerName = _actualArr[_deleteIndex][@"userName"];
            [[HcCustomKeyboard customKeyboard] textViewShowView:self customKeyboardDelegate:self andState:YES];
        } else if (buttonIndex == 1) {
            NSDictionary *dic = [LVTools getTokenApp];
            [dic setValue:_actualArr[_deleteIndex][@"id"] forKey:@"id"];
            [DataService requestWeixinAPI:delInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                if ([result[@"statusCode"] isEqualToString:@"success"]) {
                    [self showHint:@"评论删除成功"];
                    [_actualArr removeObjectAtIndex:_deleteIndex];
                    [_arr removeObjectAtIndex:_deleteIndex];
                    [_tableview reloadData];
                } else {
                    [self showHint:@"评论删除失败"];
                }
            }];
        }
    } else if (actionSheet.tag == 1401) {
        if (buttonIndex == 0) {
            _partnerId = [NSString stringWithFormat:@"%@",[_actualArr objectAtIndex:_deleteIndex][@"id"]];
            _partnerName = _actualArr[_deleteIndex][@"userName"];
            [[HcCustomKeyboard customKeyboard] textViewShowView:self customKeyboardDelegate:self andState:YES];
        }
    }
}

#pragma mark -- HcCustomKeyboardDelegate
-(void)talkBtnClick:(UITextView *)textViewGet
{
    if ([LVTools stringContainsEmoji:textViewGet.text]) {
        [self showHint:@"后台暂不支持表情符号"];
        return;
    }
    _contentstring = [NSString stringWithFormat:@"%@",textViewGet.text];
    if (_contentstring.length > 0) {
        [self insertRequest];
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

- (void)insertRequest{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    if (self.fromStyle == StyleResultComment) {
        [dic setValue:self.idString forKey:@"playId"];
        _replayUrlString = addInteract;
    } else if (self.fromStyle == StyleResultMatch) {
        [dic setValue:self.idString forKey:@"matchId"];
        _replayUrlString = addMatchInteract;
    }
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setObject:optionReply forKey:@"type"];//回复
    [dic setObject:_contentstring forKey:@"message"];
    [dic setObject:[NSString stringWithFormat:@"%@", [NSDate  date]]  forKey:@"interactTime"];//评论时间
    [dic setObject:_partnerId forKey:@"parentId"];//回复的评论的id，回复留言时填充
    NSLog(@"idstring === %@",self.idString);
    NSLog(@"detaildic ==== %@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:_replayUrlString parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
        {
            NSMutableDictionary *objectdict = [[NSMutableDictionary alloc] initWithDictionary:result[@"list"]];
            [self showHint:@"回复成功"];
            [objectdict setValue:[kUserDefault valueForKey:KUserIcon] forKey:@"iconPath"];
            [objectdict setValue:_partnerName forKey:@"parentName"];
            [objectdict setObject:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]*1000] forKey:@"interactTime"];
            [objectdict setValue:[kUserDefault valueForKey:kUserName] forKey:@"userName"];
            [self.arr insertObject:objectdict atIndex:0];
            [_actualArr insertObject:objectdict atIndex:0];
            [_tableview reloadData];
        }
        else{
            [self showHint:@"操作失败,请重试!"];
        }
    }];
}

- (void)userInfoOnclick:(UIButton *)sender
{
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
    NSInteger index = sender.tag - 4800;
    //先判断这个uid和自己是不是同一个人，不是，才进入查看资料
    if ([[kUserDefault objectForKey:kUserId] isEqualToString:_actualArr[index][@"uid"]]) {
        WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
        vc.basicVC = NO;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
        vc.uid = _actualArr[index][@"uid"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    }
    else{
        [self jumpToLoginVC];
    }
}

@end
