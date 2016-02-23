//
//  LoginHomeZhViewController.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/26.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LoginHomeZhViewController.h"
#import "LoginLoginZhViewController.h"//登录
#import "LoginRegisterZhViewController.h"//注册
#import "LVBindingQQViewController.h"//绑定QQ界面

#import "WXApi.h"
#import "UMSocial.h"
#import "AppDelegate.h"


#define bili 414.0/720.0
#define spaceWidth 15.0
#define bordWhidth 0.5
#define lineHeight 50.0
@interface LoginHomeZhViewController ()

@end

@implementation LoginHomeZhViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)createViews{
    //设置背景
    UIImageView *picImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.width*(884.0/750.0))];
    picImg.image = [UIImage imageNamed:@"pic"];
    picImg.contentMode = UIViewContentModeTop;
    [self.view addSubview:picImg];
    
    UIView *whiteV = [[UIView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height-(750*bili), BOUNDS.size.width, 750*bili)];
    whiteV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteV];
    
    UIImageView *whiteImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, whiteV.top-BOUNDS.size.width*(56.0/750.0), BOUNDS.size.width, BOUNDS.size.width*(56.0/750.0))];
    whiteImage.image = [UIImage imageNamed:@"white"];
    whiteImage.hidden = YES;
    [self.view addSubview:whiteImage];
    //添加按钮和线条
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 40)];//20
    lab.text = @"第三方登录";
    lab.font = Content_lbfont;
    lab.textColor = [UIColor colorWithRed:0.612f green:0.624f blue:0.631f alpha:1.00f];
    lab.textAlignment = NSTextAlignmentCenter;
    [whiteV addSubview:lab];
    
    for (NSInteger i=0; i<3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((BOUNDS.size.width-2*spaceWidth-3*37)/2.0+(37+spaceWidth)*i, lab.bottom, 37, 37)];
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Thirdlog_%.2ld",(long)(i+1)]] forState:UIControlStateNormal];
        btn.tag = 102+i;
        if (i==1) {
            if(![WXApi isWXAppInstalled]){
                btn.hidden = YES;
            }
        }
        
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [whiteV addSubview:btn];
    }
    //37
    UIView *line1 =[[UIView alloc] initWithFrame:CGRectMake(spaceWidth, lab.bottom+spaceWidth*2+37, BOUNDS.size.width-2*spaceWidth, bordWhidth)];
    line1.backgroundColor = [UIColor clearColor];
    [whiteV addSubview:line1];
    //登录注册
    NSArray *array =@[@"登录",@"注册"];
    
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(BOUNDS.size.width*0.1, line1.bottom, BOUNDS.size.width*0.8, 35.0)];
    back.layer.cornerRadius = 15.0;
    back.layer.borderColor = BackGray_dan.CGColor;
    back.layer.borderWidth = 0.1;
    back.backgroundColor = [UIColor colorWithRed:0.949f green:0.953f blue:0.957f alpha:1.00f];
    [whiteV addSubview:back];
    for (int i=0; i<2; i++)
    {
        if(i==1){
            UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(back.width/2.0, 5, bordWhidth, 25.0)];
            midLine.backgroundColor = [UIColor colorWithRed:0.914f green:0.918f blue:0.922f alpha:1.00f];
            [back addSubview:midLine];
        }
        UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.tag=100+i;
        button.titleLabel.font = Btn_font;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(back.width/2*i,0, back.width/2, back.height);
        [back addSubview:button];
    }
    UIView *line2 =[[UIView alloc] initWithFrame:CGRectMake(spaceWidth, line1.bottom+lineHeight+bordWhidth+spaceWidth+15.0, BOUNDS.size.width-2*spaceWidth, bordWhidth)];
    line2.backgroundColor = [UIColor lightGrayColor];
    [whiteV addSubview:line2];
    
    
    UIButton *noLoginBtn=[[UIButton alloc] initWithFrame:CGRectMake((BOUNDS.size.width-100)/2.0, line1.bottom+lineHeight+bordWhidth+spaceWidth, 100, 30)];
    [noLoginBtn setTitle:@"直接进入>>" forState:UIControlStateNormal];
    noLoginBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [noLoginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    noLoginBtn.tag = 200;
    [noLoginBtn setBackgroundColor:[UIColor whiteColor]];
    [noLoginBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [whiteV addSubview:noLoginBtn];
    
    //最后计算白色背景的高度
    whiteV.frame = CGRectMake(0,BOUNDS.size.height- (noLoginBtn.bottom+spaceWidth), BOUNDS.size.width, noLoginBtn.bottom+spaceWidth);
    //这里需要做判断
    if(picImg.bottom<whiteV.top){
        whiteImage.frame = CGRectMake(0, picImg.bottom-BOUNDS.size.width*(56.0/750.0), BOUNDS.size.width, BOUNDS.size.width*(56.0/750.0));
    }
    else{
    whiteImage.frame = CGRectMake(0, whiteV.top-BOUNDS.size.width*(56.0/750.0), BOUNDS.size.width, BOUNDS.size.width*(56.0/750.0));
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    self.navigationController.navigationBar.hidden=YES;
    self.tabBarController.tabBar.hidden=YES;
    [self createViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popBlockView) name:@"popView" object:nil];
}
- (void)popBlockView{
    [self PopView];
}
- (void)PopView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"popView" object:nil];
}
-(void)buttonClick:(UIButton *)button
{
    switch (button.tag) {
        case 100:
        {
            LoginLoginZhViewController *login=[[LoginLoginZhViewController alloc]init];
            login.title=@"登 录";
            login.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:login animated:YES];
        }
            break;
        case 101:
        {
            LoginRegisterZhViewController *login=[[LoginRegisterZhViewController alloc]init];
            login.title=@"注 册";
            [self.navigationController pushViewController:login animated:YES];
        }
            break;
        case 102:
        {
            //QQ
            [self LoginClickTargetWithType:@"1"];
        }
            break;
        case 103:{
            //微信
            [self LoginClickTargetWithType:@"2"];
        }
            break;
        case 104:{
            //微博
            [self LoginClickTargetWithType:@"3"];
                   }
            break;
        case 200:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}
#pragma mark --第三方登录
- (void)LoginClickTargetWithType:(NSString*)type{
    NSString *platmType = nil;
    if([type isEqualToString:@"1"]){
        //qq
        platmType=UMShareToQQ;
    }
    else if([type isEqualToString:@"2"]){
        //微信
        platmType=UMShareToWechatSession;
    }
    else if([type isEqualToString:@"3"]){
        //微博
        platmType=UMShareToSina;
    }
    UMSocialSnsPlatform * snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platmType];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity * response){
        if (response.responseCode == UMSResponseCodeSuccess){
            UMSocialAccountEntity * snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platmType];
            NSLog(@"%@",snsAccount);
            //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
            NSString * lat = [kUserDefault objectForKey:kLocationLat];
            NSString * lng = [kUserDefault objectForKey:kLocationlng];
            NSDictionary * dic2 = [LVTools getTokenApp];
            [dic2 setValue:snsAccount.usid forKey:@"openId"];
            [dic2 setValue:lng  forKey:@"longitude"];
            [dic2 setValue:lat  forKey:@"latitude"];
            [dic2 setValue:type forKey:@"type"];
            [self showHudInView:self.view hint:@"正在验证..."];
            NSLog(@"dic2 ====== %@",dic2);
            NSLog(@"%@",dic2);
            [DataService requestWeixinAPI:isBindQQAccount parsms:@{@"param":[LVTools configDicToDES:dic2]} method:@"post" completion:^(id result) {
                [self hideHud];
                NSLog(@"%@",result);
                if ([result[@"statusCode"] isEqualToString:@"success"]) {
                [self showHint:result[@"statusCodeInfo"]];
                if ([result[@"statusCodeInfo"] isEqualToString:@"未绑定"]){ //没有绑定QQ账户
                    LVBindingQQViewController * vc2 = [[LVBindingQQViewController alloc] initWithQQid:snsAccount.usid WithUserName:snsAccount.userName withType:type];
                    vc2.iconPath = snsAccount.iconURL;
                    vc2.title = @"账号绑定";
                    [self.navigationController pushViewController:vc2 animated:YES];
                }else if([result[@"statusCodeInfo"] isEqualToString:@"已绑定"]){//直接登录界面
                    [self login:result];
                }
                    else
                    {
                       //其他情况
                    }
                }
                else{
                    [self showHint:ErrorWord];
                }
            }];
        }
    });
}
#pragma  mark --登陆
- (void)login:(NSDictionary *)result{
    if (1) {
       
        [[EaseMob sharedInstance].chatManager
         asyncRegisterNewAccount:[NSString stringWithFormat:@"%@",result[@"passport"][@"uid"]]
         password:@"123456"
         withCompletion:^(NSString *username, NSString *password, EMError *error) {
            
             if (!error) {
                 [self showHint:@"注册服务器成功"];
                 NSLog(@"环信的用户名和密码:\n%@\n%@\n%@",username,password,error);
                 [kUserDefault setValue:username forKey:KEMuid];
                 [kUserDefault setValue:password forKey:KEMpwd];
                 [kUserDefault synchronize];
             }else{
                 NSLog(@"注册失败%@",error);
                 [self hideHud];
                 //[self showHint:[NSString stringWithFormat:@"注册失败%@",error]];
             }
         } onQueue:nil];
        
        NSString * username = [NSString stringWithFormat:@"%@",result[@"passport"][@"uid"]];
        NSString * password = [NSString stringWithFormat:@"123456"];
        [self showHudInView:self.view hint:LoadingWord];
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
            [self hideHud];
            NSLog(@"%@\n%@",loginInfo,error);
            NSLog(@"\n登陆的信息：%@\n登陆的错误：%@ 未读消息个数%ld",loginInfo,error, (unsigned long)[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]);
            //刷新消息个数
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
            if (!error && loginInfo) {
                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                [self showHint:@"登录服务器成功"];
                [kUserDefault setValue:@"1" forKey:kUserLogin];
                [kUserDefault setValue:[LVTools mToString: result[@"passport"][@"uid"]] forKey:kUserId];
                [kUserDefault setValue:@"123456" forKey:kUserPassword];
                [kUserDefault setValue:[LVTools mToString: result[@"passport"][@"usernameY"]] forKey:kUserName];
                [kUserDefault setValue:[LVTools mToString: result[@"passport"][@"mobile"]] forKey:KUserMobile];
                [kUserDefault setValue:@"" forKey:KUserAcount];//不显示第三方登录的账号
                [kUserDefault setValue:[LVTools mToString:result[@"passport"][@"iconPath"]] forKey:KUserIcon];
                [kUserDefault synchronize];
                NSLog(@"%@",result);
                //发通知刷新个人中新页面
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSTATECHANGE_NOTIFICATION object:@YES userInfo:nil];
                [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                [self showHint:[NSString stringWithFormat:@"登录服务器失败,失败原因:%@",error.description]];
            }
            
        } onQueue:nil];
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
