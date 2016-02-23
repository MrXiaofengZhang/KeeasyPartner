//
//  WPCTimeDetailVC.m
//  yuezhan123
//
//  Created by admin on 15/7/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCTimeDetailVC.h"
#import "ImgShowViewController.h"
#import "WPCCommentCell.h"
#import "WPCCustomKeyboard.h"
#import "ZHShuoModel.h"
@interface WPCTimeDetailVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>{
    NSMutableArray *zanArray;
    NSMutableArray *commentArray;
    NSInteger selectComentIndex;//选中的评论 -1表示未选择评论
    NSMutableArray *allCommentArray;
    UILabel *nameLab;
}

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UIScrollView *praiseScroll;
@property (nonatomic, assign) CGFloat headHeight;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, strong) UIView *footerView;


@end

@implementation WPCTimeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _headHeight = 0;
    if([[kUserDefault objectForKey:kUserId] isEqualToString:[LVTools mToString: self.shouModel.uid]])
    _isSelf = YES;
    else
        _isSelf = NO;
    self.title = @"详情";
    selectComentIndex = -1;
    self.view.backgroundColor = [UIColor whiteColor];
    zanArray = [[NSMutableArray alloc] initWithCapacity:0];
    commentArray=[[NSMutableArray alloc] initWithCapacity:0];
    [self initialInterface];
    [self loadTimeMessageDetail];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
//加载时光机详情
- (void)loadTimeMessageDetail{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[LVTools mToString: self.shouModel.id] forKey:@"id"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getMessageDetail parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary*)result;
        nameLab.text = [LVTools mToString:result[@"message"][@"userName"]];
        if ( [resultDic[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            [zanArray addObjectsFromArray:resultDic[@"agree"]];
            [_table reloadData];
            [self setZanImag];
            //整理评论和回复，按时间排序
            allCommentArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < [resultDic[@"comments"] count]; i ++) {
                [allCommentArray addObject:[LVTools mToString:[resultDic[@"comments"] objectAtIndex:i][@"id"]]];
            }
            for (int i = 0; i < [resultDic[@"reply"] count]; i ++) {
                [allCommentArray addObject:[LVTools mToString:[resultDic[@"reply"] objectAtIndex:i][@"id"]]];
            }
            if ([allCommentArray count] >1) {
                [LVTools sortArrayWithArray:allCommentArray andAscend:NO];
//                [allCommentArray sortedArrayUsingSelector:@selector(compare:)];
                for (int i = 0; i < allCommentArray.count; i ++) {
                    for (int j = 0; j < [resultDic[@"comments"] count]; j ++) {
                        if ([[LVTools mToString:[resultDic[@"comments"] objectAtIndex:j][@"id"]] isEqualToString:allCommentArray[i]]) {
                            [commentArray addObject:[resultDic[@"comments"] objectAtIndex:j]];
                        }
                    }
                    for (int k = 0; k < [resultDic[@"reply"] count]; k ++) {
                        if ([[LVTools mToString:[resultDic[@"reply"] objectAtIndex:k][@"id"]] isEqualToString:allCommentArray[i]]) {
                            [commentArray addObject:[resultDic[@"reply"] objectAtIndex:k]];//评论回复信息
                        }
                    }
                }
            }
            else{
                [commentArray addObjectsFromArray:resultDic[@"comments"]];
                [commentArray addObjectsFromArray:resultDic[@"reply"]];
            }
            [_table reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
//删除评论
- (void)delCommentWith:(NSString*)comentId withIndex:(NSInteger)index{
    NSLog(@"%@",comentId);
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:comentId forKey:@"id"];//消息标示

    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:delComment parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary*)result;
        if ( [resultDic[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            
            [commentArray removeObjectAtIndex:index];
            [_table deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}

- (void)initialInterface {
   [self createNavigationBar];
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, UISCREENWIDTH, UISCREENHEIGHT-64-49) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    _table.showsVerticalScrollIndicator = NO;
    _table.tableHeaderView = [self createHeaderView];
    
    UIView *view = [[UIView alloc] init];
    _table.tableFooterView = view;
    
    [self.view addSubview:_table];
    [self createFooterView];
}

- (void)createFooterView {
//    _footerView = [[UIView alloc] initWithFrame:CGRectMake(-0.5, UISCREENHEIGHT-48.5, UISCREENWIDTH+1, 49)];
//    _footerView.backgroundColor = RGBACOLOR(230, 230, 230, 1);
//    _footerView.layer.borderWidth = 0.5;
//    _footerView.layer.borderColor = [RGBACOLOR(183, 183, 183, 1) CGColor];
//    [self.view addSubview:_footerView];
//    
//    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, UISCREENWIDTH-10-52, 29)];
//    textField.layer.cornerRadius = 3;
//    textField.layer.borderWidth = 0.5;
//    textField.layer.borderColor = [RGBACOLOR(183, 183, 183, 1) CGColor];
//    textField.delegate = self;
//    [textField setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
//    textField.placeholder = @"评论";
//    [_footerView addSubview:textField];
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(UISCREENWIDTH-43, 10, 29, 29);
//    btn.layer.cornerRadius = btn.width/2;
//    [btn addTarget:self action:@selector(expressClick) forControlEvents:UIControlEventTouchUpInside];
//    btn.backgroundColor = [UIColor redColor];
//    [_footerView addSubview:btn];
    [[WPCCustomKeyboard customKeyboard] textViewShowView:self customKeyboardDelegate:self];
}
#pragma mark -- HcCustomKeyboardDelegate
-(void)talkBtnClick:(UITextView *)textViewGet
{
    if ([LVTools stringContainsEmoji:textViewGet.text]) {
        [self showHint:@"后台暂不支持表情符号"];
        return;
    }
    NSLog(@"%@",[WPCCustomKeyboard customKeyboard].mTextView.text);
    
    
    NSMutableDictionary *dict = [LVTools getTokenApp];
    [dict setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];//用户标识
    
    [dict setValue:[LVTools mToString:self.shouModel.id] forKey:@"mid"];//消息标示
    [dict setValue:[WPCCustomKeyboard customKeyboard].mTextView.text forKey:@"info"];
    if(selectComentIndex==-1){
        NSLog(@"评论");
        [dict setValue:@"1" forKey:@"type"];//类型：2回复 1留言，0点赞
    }
    else{
        NSLog(@"回复");
        NSDictionary *commentDic = [commentArray objectAtIndex:selectComentIndex];
        [dict setValue:@"2" forKey:@"type"];//类型：2回复 1留言，0点赞
        [dict setValue:[LVTools mToString:commentDic[@"id"]] forKey:@"pid"];
    }
    selectComentIndex = -1;
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:addComment parsms:@{@"param":[LVTools configDicToDES: dict]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
            [self showHint:@"操作成功"];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [dic setObject:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
            [dic setObject:[kUserDefault objectForKey:KUserIcon] forKey:@"iconPath"];
            [dic setObject:[kUserDefault objectForKey:kUserName] forKey:@"userName"];
            [dic setObject:dict[@"info"] forKey:@"info"];
            [dic setObject:result[@"id"] forKey:@"id"];
            [dic setObject: [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]*1000] forKey:@"time"];
            [commentArray insertObject:dic atIndex:0];
            [_table insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];

}
//- (void)expressClick {
//    //
//    NSLog(@"%@",[WPCCustomKeyboard customKeyboard].mTextView.text);
//    NSMutableDictionary *dic = [LVTools getTokenApp];
//    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];//用户标识
//    [dic setValue:@"1" forKey:@"type"];//类型：1留言，0点赞
//    [dic setValue:[LVTools mToString:self.shouModel.id] forKey:@"mid"];//消息标示
//    [dic setValue:[WPCCustomKeyboard customKeyboard].mTextView.text forKey:@"info"];
//    [self showHudInView:self.view hint:LoadingWord];
//        [DataService requestWeixinAPI:addComment parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
//        [self hideHud];
//        NSLog(@"%@",result);
//        if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
//
//        }
//    }];
//}
- (void)createNavigationBar {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 30, 36, 24);
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lab =[[UILabel alloc] init];
    lab.text = @"详情";
    lab.font = [UIFont systemFontOfSize:20];
   [self.view addSubview:  [LVTools selfNavigationWithColor:NavgationColor leftBtn:btn rightBtn:nil titleLabel:lab]];
}
- (UIView *)createHeaderView {
    
    UIView *view = [[UIView alloc] init];
    
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, UISCREENWIDTH/750*100, UISCREENWIDTH/750*100)];
    headImg.layer.cornerRadius = headImg.width/2;
    headImg.layer.masksToBounds = YES;
    [headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,self.shouModel.icon]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    [view addSubview:headImg];
    
    nameLab = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, 10, 150, 20)];
    nameLab.font = Title_font;
    nameLab.text = [LVTools mToString:self.shouModel.userName];
    nameLab.textColor = RGBACOLOR(88, 154, 202, 1);
    [view addSubview:nameLab];
    
    _headHeight = nameLab.bottom;
    
    NSString *str = [LVTools mToString:self.shouModel.info];
    if (str.length > 0) {
        CGFloat height = [LVTools sizeContent:str With:14 With2:UISCREENWIDTH-headImg.right-10];
        UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.left, _headHeight+5, UISCREENWIDTH-headImg.right-10, height)];
        contentLab.text = str;
        contentLab.font = [UIFont systemFontOfSize:14];
        contentLab.numberOfLines = -1;
        [view addSubview:contentLab];
        _headHeight = contentLab.bottom;
    }
    
    NSArray *arr = self.shouModel.timeMachineList;
    if (arr.count == 0) {
        //donothing
    } else if (arr.count == 1) {
        
        UIImageView *bigOneImg = [[UIImageView alloc] initWithFrame:CGRectMake(nameLab.left, _headHeight+5, UISCREENWIDTH/750*350, UISCREENWIDTH/750*350)];
        bigOneImg.contentMode = UIViewContentModeScaleAspectFill;
        bigOneImg.clipsToBounds = YES;
        [bigOneImg sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",preUrl,[[arr objectAtIndex:0] objectForKey:@"path"]]] placeholderImage: [UIImage imageNamed:@"applies_plo"]];
        [view addSubview:bigOneImg];
        _headHeight = bigOneImg.bottom;
    } else {
        for (int i = 0; i < arr.count; i ++) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(nameLab.left+UISCREENWIDTH/750*180*(i%3), _headHeight+5+UISCREENWIDTH/750*180*(i/3), UISCREENWIDTH/750*170, UISCREENWIDTH/750*170)];
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.clipsToBounds = YES;
            [img sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",preUrl,[[arr objectAtIndex:i] objectForKey:@"path"]]] placeholderImage: [UIImage imageNamed:@"applies_plo"]];
            [view addSubview:img];
            if (i == arr.count - 1) {
                _headHeight = img.bottom;
            }
        }
    }
    
    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.left, _headHeight+10, 50, 15)];
    timeLab.text = [LVTools compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:[self.shouModel.time longLongValue]/1000]];
    timeLab.font = Content_lbfont;
    timeLab.textColor = [UIColor lightGrayColor];
    [view addSubview:timeLab];
    
    _headHeight = timeLab.bottom;
    
    if (_isSelf) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn.titleLabel setFont:Content_lbfont];
        [deleteBtn setTitleColor:NavgationColor forState:UIControlStateNormal];
        deleteBtn.frame = CGRectMake(timeLab.right, timeLab.top, 40, 15);
        [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:deleteBtn];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _headHeight+10, UISCREENWIDTH, 0.5)];
    lineView.backgroundColor = RGBACOLOR(210, 210, 210, 1);
    [view addSubview:lineView];
    _headHeight = lineView.bottom;
    
    UIButton *praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    praiseBtn.frame = CGRectMake(10, _headHeight+40*UISCREENWIDTH/750, 48*UISCREENWIDTH/750, 48*UISCREENWIDTH/750);
    [praiseBtn setImage:[UIImage imageNamed:@"praise"] forState:UIControlStateNormal];
    [view addSubview:praiseBtn];
    
    _praiseScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(praiseBtn.right+10, _headHeight, UISCREENWIDTH-praiseBtn.right-10, 128*UISCREENWIDTH/750)];
    _praiseScroll.showsHorizontalScrollIndicator = NO;
    [view addSubview:_praiseScroll];
    _headHeight = _praiseScroll.bottom;
    
        view.frame = CGRectMake(0, 0, UISCREENWIDTH, _headHeight);
    
    return view;
}
-(void)setZanImag{
    for (int i = 0; i < [zanArray count]; i ++) {
        NSDictionary *dic = [zanArray objectAtIndex:i];
        UIImageView *praiseImg = [[UIImageView alloc] initWithFrame:CGRectMake(102*i*UISCREENWIDTH/750, 27*UISCREENWIDTH/750, 75*UISCREENWIDTH/750, 75*UISCREENWIDTH/750)];
        [praiseImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[dic objectForKey:@"iconPath"]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        praiseImg.layer.cornerRadius = praiseImg.width/2;
        praiseImg.layer.masksToBounds = YES;
        [_praiseScroll addSubview:praiseImg];
        if (i == [zanArray count]-1) {
            _praiseScroll.contentSize = CGSizeMake(praiseImg.right, 128*UISCREENWIDTH/750);
        }
    }

}
- (void)deleteAction {
    NSLog(@"删除动态");
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uId"];//用户标识
    [dic setValue:[LVTools mToString:self.shouModel.id] forKey:@"id"];
    //[dic setValue:shuoId forKey:@"mid"];//消息标示
    
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:delMessages parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
            [self showHint:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self showHint:@"操作失败"];
        }
    }];
}

#pragma mark -- tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [commentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"cell";
    WPCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if (!cell) {
        cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier commentType:WPCSportCommentType];
    }
    NSDictionary *dic = [commentArray objectAtIndex:indexPath.row];
    [cell configTheCellContent:dic];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.morActionBtn.tag = indexPath.row +100;
    [cell.morActionBtn addTarget:self action:@selector(moreActionOnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64*UISCREENWIDTH/750;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 64*UISCREENWIDTH/750)];
    lab.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    lab.text = [NSString stringWithFormat:@"   共%d条评论",(int)[commentArray count]];
    lab.textColor = lightColor;
    return lab;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [commentArray objectAtIndex:indexPath.row];
    NSString *tempStr;
    if ([[LVTools mToString:[dic objectForKey:@"parentId"]] isEqualToString:@""]) {
        tempStr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]];
    }
    else{
        tempStr = [NSString stringWithFormat:@"@%@:%@",[dic objectForKey:@"parentName"],[dic objectForKey:@"info"]];
    }
    CGFloat height = [LVTools sizeContent:tempStr With:14 With2:(UISCREENWIDTH-60-50)];
    if ([dic[@"imgArray"] count] > 0) {
        height += 50;
    }
    return height + 55;
}

#pragma mark -- tableview delegate


- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)moreActionOnClick:(UIButton*)btn{
    NSDictionary *commentDic = [commentArray objectAtIndex:btn.tag-100];
    selectComentIndex = btn.tag-100;
    UIActionSheet *actionsheet = nil;
    if ([[LVTools mToString:[commentDic objectForKey:@"uid"]] isEqualToString:[kUserDefault objectForKey:kUserId]]) {
        actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
    }
    else{
    actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复", nil];
    }
    [actionsheet showInView:self.view];
}
#pragma mark UIActionsheetDeleagate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSDictionary *commentDic = [commentArray objectAtIndex:selectComentIndex];
    NSLog(@"%@",commentDic);
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        //取消
        NSLog(@"取消");
        selectComentIndex = -1;
    }
    else if(buttonIndex == [actionSheet destructiveButtonIndex]){
       //删除
        [self delCommentWith:[LVTools mToString:commentDic[@"id"]]withIndex:selectComentIndex];
        selectComentIndex = -1;
    }
    else{
        //回复
        [[WPCCustomKeyboard customKeyboard].mTextView becomeFirstResponder];
        [WPCCustomKeyboard customKeyboard].mTextView.text = [NSString stringWithFormat:@"@%@:", commentDic[@"userName"]];
    }
}
@end
