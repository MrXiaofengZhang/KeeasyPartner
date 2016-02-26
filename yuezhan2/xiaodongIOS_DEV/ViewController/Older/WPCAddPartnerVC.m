//
//  WPCAddPartnerVC.m
//  yuezhan123
//
//  Created by admin on 15/7/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCAddPartnerVC.h"
#import "NearByModel.h"
#import "NearByTableViewCell.h"
#import "LoginLoginZhViewController.h"
#import "WPCFriednMsgVC.h"
#import "UMSocial.h"
#define shareHeight 70.0
@interface WPCAddPartnerVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UMSocialUIDelegate>{
    NSInteger page;
}

@property (nonatomic, strong)UITextField *textField;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *NearByArray;
@end

@implementation WPCAddPartnerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    self.view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    self.title = @"添加好友";
    page = 0;
    self.NearByArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.view addSubview:self.textField];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(_textField.right+10, 10, 60, 30);
    [btn setTitle:@"查找" forState:UIControlStateNormal];
    [btn setTitleColor:NavgationColor forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [self makeUI];
    [self initOther];
    
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,shareHeight+_textField.bottom+10+shareHeight+mygap, CGRectGetWidth(BOUNDS), CGRectGetHeight(BOUNDS) - 49 - 25-self.textField.height-(shareHeight*2+mygap*2)) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.hidden = YES;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (void)makeUI{
    [self.view addSubview:self.tableView];
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_textField.text.length!=0) {
        [weakSelf loadData];
        }
    }];
    
}
#pragma  mark --加载数据
- (void)loadData{
    //环信搜索
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:self.textField.text forKey:@"keyword"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    page ++;
    [dic setValue:[NSString stringWithFormat:@"%d",(int)page] forKey:@"page"];
    [dic setValue:@"10" forKey:@"rows"];
    [self showHudInView:self.view hint:LoadingWord];
    request =[DataService requestWeixinAPI:getFriendByUsername parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"%@",result);
        NSDictionary * resultDic = (NSDictionary *)result;
        if ([resultDic[@"status"] boolValue])
        {
            
            for (NSDictionary *dic in resultDic[@"data"])
            {
                NearByModel * model = [[NearByModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [self.NearByArray addObject:model];
                [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:model] Key:[NSString stringWithFormat:@"xd%@", [LVTools mToString: model.userId]]];
            }
            if ([resultDic[@"friendList"] count]==0) {
                [self showHint:EmptyList];
            }
            if (self.NearByArray.count==0) {
                self.tableView.hidden = YES;
            }
            else{
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
            if ([resultDic[@"moreData"] boolValue]) {
                
            }
            else{
                _tableView.mj_footer = nil;
            }

        }else{
            [self showHint:ErrorWord];
        }
    }];
}

- (void)initOther{
    NSArray *arry = @[@"手机通讯录",@"微信好友",@"朋友圈",@"新浪微博",@"人人网",@"QQ好友"];
    for (NSInteger row=0; row<2; row++) {
        for (NSInteger col=0; col<3; col++) {
            UIButton *myview = [[UIButton alloc] initWithFrame:CGRectMake(col*(BOUNDS.size.width/3.0), row*shareHeight+_textField.bottom+10, BOUNDS.size.width/3.0, shareHeight)];
            myview.backgroundColor = [UIColor whiteColor];
            myview.tag = row*3+col+100;
            myview.layer.borderWidth = 0.5;
            myview.layer.borderColor = BackGray_dan.CGColor;
            [myview addTarget:self action:@selector(otherFriend:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:myview];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake((myview.width-55)/2.0, 5, 55, 41)];
            image.image =[UIImage imageNamed:[NSString stringWithFormat:@"from_%d",(int)(row*3+col+1)]];
            [myview addSubview:image];
            
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, image.bottom,myview.width, 20)];
            lb.text = [arry objectAtIndex:(row*3+col)];
            lb.font = Content_lbfont;
            lb.textAlignment = NSTextAlignmentCenter;
            lb.textColor = [UIColor lightGrayColor];
            [myview addSubview:lb];
        }
    }
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, UISCREENWIDTH-90, 30)];
        _textField.delegate = self;
        [_textField setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
        _textField.backgroundColor = [UIColor whiteColor];
        UIImageView *temp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 26.5, 20)];
        temp.image = [UIImage imageNamed:@"blue_search"];
        _textField.leftView = temp;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.placeholder = @"手机号/昵称";
    }
    return _textField;
}

- (void)otherFriend:(UIButton *)btn {
//    NSArray *nameArray=@[@"手机通讯录",@"微信好友",@"QQ好友",@"新浪微博",@"人人网",@"扫一扫"];
    //设置分享内容
    NSString *shareText = @"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。 http://www.umeng.com/social";
    UIImage *shareImage = [UIImage imageNamed:@"appImg"];
    if ([[LVTools mToString: [kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
        shareText = @"来和我一起战斗吧！come on！";
    }
    else{
        shareText = @"来和我一起战斗吧！come on！";
    }

    if (btn.tag-100==0) {
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:nil socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSms];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        
    }
    else if (btn.tag-100==1){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        
    }
    else if (btn.tag-100==2){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatTimeline];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        
    }
    else if (btn.tag-100==3){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        
    }
    else if (btn.tag-100==4){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToRenren];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        
    }
    else if (btn.tag-100==5){
        [[UMSocialControllerService defaultControllerService] setShareText:shareText shareImage:shareImage socialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
        snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    }

}

- (void)searchAction {
    [self.view endEditing:YES];
    if (self.textField.text.length!=0) {
        [self.NearByArray removeAllObjects];
        page=0;
        [self loadData];
    }
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self searchAction];
    return YES;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NearByModel *model = [self.NearByArray objectAtIndex:indexPath.row];
    NSString * uidStr = [NSString stringWithFormat:@"%@",model.userId];
    WPCFriednMsgVC * vc = [[WPCFriednMsgVC alloc] init];
    vc.uid = uidStr;
    [self.navigationController pushViewController:vc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    NSLog(@"%d",self.NearByArray.count);
    return self.NearByArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NearByTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[NearByTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID2"];
    }
    NearByModel * model = self.NearByArray[indexPath.row];
    [cell configModel:model];
    cell.locationLabel.hidden = YES;
    UIImageView *imgview = (UIImageView *)[cell.contentView viewWithTag:1001];
    imgview.hidden = YES;
    __weak typeof(self) weakSelf = self;
    cell.addFirend = ^(BOOL isLogin,NSString * uid,NSString * userName){
        
        if (isLogin)
        {
            [WCAlertView showAlertWithTitle:nil message:[NSString stringWithFormat:@"是否添加%@为好友?",userName] customizationBlock:^(WCAlertView *alertView) {
                //
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                //
                if(buttonIndex == 1){
                    [self addFriendWith:uid AndName:userName withIndex:indexPath];
                    
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"添加", nil];
        }else
        {
            //进入登录界面
            LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
            [weakSelf.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
        }
    };
    
    cell.chatFirend = ^(NSString * uid,NSString * userName){
        NSString * uidStr = [NSString stringWithFormat:@"%@",uid];
        WPCFriednMsgVC * vc = [[WPCFriednMsgVC alloc] init];
        vc.uid = uidStr;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}
- (void)addFriendWith:(NSString*)fuid AndName:(NSString*)userName withIndex:(NSIndexPath*)index{
    //            BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:[NSString stringWithFormat:@"%@",uid] message:@"我要添加你为好友" error:nil];
    //            if (isSuccess) {
    //                NSLog(@"发送好友请求成功");
    //            }
    //
    //            //好友同意我为好友
    //
    //            //同意加好友
    //           BOOL isSuccess2 = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:[NSString stringWithFormat:@"%@",uid] error:nil];
    //            if (isSuccess2) {
    //                NSLog(@"发送同意成功");
    //            }
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    NSString * myId = [kUserDefault objectForKey:kUserId];
    //NSString * myname = [kUserDefault objectForKey:kUserName];
    
    [dic setValue:[NSString stringWithFormat:@"%@",myId] forKey:@"uid"];
    [dic setValue:[NSString stringWithFormat:@"%@",fuid] forKey:@"fuid"];
    [dic setValue:userName forKey:@"fusername"];
    [dic setValue:@"1" forKey:@"status"];
    [self showHudInView:self.view hint:@"添加中..."];
    //添加好友
    [DataService requestWeixinAPI:addFrirend parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            [self showHint:@"添加成功!"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshOldList object:nil];
            // 移除黑名单
            [[EaseMob sharedInstance].chatManager unblockBuddy:[LVTools mToString:[LVTools mToString:fuid]]];
            NearByModel *model = [_NearByArray objectAtIndex:index.row];
            model.isFriend = @"true";
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
            //发送加好友通知
            
        }else{
            [self showHint:ErrorWord];
        }
    }];
    
}
@end
