//
//  LVBingNumberViewController.m
//  yuezhan123
//
//  Created by LV on 15/4/14.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVBingNumberViewController.h"
#import "LVTextField.h"

@interface LVBingNumberViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)LVTextField *userName;
@property (nonatomic, strong)LVTextField *pwd;
@property (nonatomic, strong)LVButton *postBtn;
@property (nonatomic, strong)NSString *myQQid;
@property (nonatomic, strong)NSString *myType;
@end



@implementation LVBingNumberViewController

- (instancetype)initWithQQid:(NSString *)QQid withType:(NSString *)type{
    self = [super init];
    if (self) {
        self.myQQid = QQid;
        self.myType = type;
        [self makeUI];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"绑定已有账号";
    [self navgationBarLeftReturn];
    self.view.backgroundColor = BackGray_dan;
}

#pragma mark --初始化界面
- (void)makeUI{
    [self.view addSubview:self.userName];
    [self.view addSubview:self.pwd];
    [self.view addSubview:self.postBtn];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self.view addGestureRecognizer:tap];
}

- (void)click{
    [self.userName resignFirstResponder];
    [self.pwd resignFirstResponder];
}
#pragma mark --登陆环信服务器
- (void)loginEM:(NSDictionary *)result{
    [self showHudInView:self.navigationController.view hint:@"正在登录..."];
    
    
    NSLog(@"%@",result);
    
    [[EaseMob sharedInstance].chatManager
     asyncRegisterNewAccount:[NSString stringWithFormat:@"%@",result[@"passport"][@"uid"]]
     password:@"123456"
     withCompletion:^(NSString *username, NSString *password, EMError *error) {
         
         if (!error) {
             [self showHint:@"注册服务器成功"];
             NSLog(@"\n%@\n%@\n%@",username,password,error);
             [kUserDefault setValue:username forKey:KEMuid];
             [kUserDefault setValue:password forKey:KEMpwd];
             [kUserDefault setObject:username forKey:kUserId];
             [kUserDefault synchronize];
         }else{
             NSLog(@"注册失败%@",error);
             [self hideHud];
            // [self showHint:[NSString stringWithFormat:@"注册失败%@",error]];
         }
     } onQueue:nil];
    
    NSString * username = [NSString stringWithFormat:@"%@",result[@"passport"][@"uid"]];
    NSString * password = [NSString stringWithFormat:@"%@",@"123456"];
    
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
        
        NSLog(@"%@\n%@",loginInfo,error);
        NSLog(@"\n登陆的信息：%@\n登陆的错误：%@ 未读消息个数%ld",loginInfo,error, (unsigned long)[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]);
        //刷新消息个数
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
        if (!error && loginInfo) {
            [self showHint:@"登录服务器成功"];
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            [kUserDefault setValue:@"1" forKey:kUserLogin];
            [kUserDefault setValue:[LVTools mToString:result[@"passport"][@"uid"]] forKey:kUserId];
            [kUserDefault setValue:[LVTools mToString:result[@"passport"][@"usernameY"]] forKey:kUserName];
            [kUserDefault setValue:@"123456" forKey:kUserPassword];
            [kUserDefault setValue:[LVTools mToString: result[@"passport"][@"username"]] forKey:KUserAcount];
            [kUserDefault setValue:[LVTools mToString:result[@"passport"][@"iconPath"]] forKey:KUserIcon];
            [kUserDefault synchronize];
            //发通知刷新个人中新页面
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSTATECHANGE_NOTIFICATION object:@YES userInfo:nil];
            [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self showHint:[NSString stringWithFormat:@"登录服务器失败,失败原因:%@", error.description]];

            
        }
        [self hideHud];
    } onQueue:nil];

    
}


- (void)postClick{
    [self click];
    if (_userName.text.length == 0) {
        [self showHint:@"账户名不为空"];
        return;
    }else if (_pwd.text.length == 0){
        [self showHint:@"密码不能为空"];
        return;
    }
    NSString * lat = [kUserDefault objectForKey:kLocationLat];
    NSString * lng = [kUserDefault objectForKey:kLocationlng];
    NSDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[NSNumber numberWithDouble:[lat doubleValue]] forKey:@"latitude"];
    [dic setValue:[NSNumber numberWithDouble:[lng doubleValue]] forKey:@"longitude"];
    [dic setValue:_userName.text forKey:@"username"];//已有账户名
    [dic setValue:_pwd.text forKey:@"password"];//已有账号的密码
     [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:yuezhanlogin parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if(![[dic objectForKey:@"status"] isKindOfClass:[NSNull class]]){
        if ([result[@"status"] boolValue]) {
             NSDictionary * dic = [LVTools getTokenApp];
            [dic setValue:[NSNumber numberWithDouble:[lat doubleValue]] forKey:@"latitude"];
            [dic setValue:[NSNumber numberWithDouble:[lng doubleValue]] forKey:@"longitude"];
            [dic setValue:_userName.text forKey:@"mobile"];//已有账户名
            [dic setValue:_pwd.text forKey:@"password"];//已有账号的密码
            [dic setValue:_myQQid forKey:@"openId"];
            [dic setValue:@"" forKey:@"uid"];//uid获取
            [dic setValue:_myType forKey:@"type"];
            [self showHudInView:self.navigationController.view  hint:@"正在绑定登录"];
            [DataService requestWeixinAPI:bindQQAccount parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                
                
                if ([result[@"statusCodeInfo"] isEqualToString:@"绑定失败"])
                {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:result[@"errorCodeInfo"] message:@"请您检查您的账号或者密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    [self hideHud];
                }else{
                    //登陆环信
                    [self hideHud];
                    [self loginEM:result];
                }
            }];

        }
        else{
            [WCAlertView showAlertWithTitle:@"登录失败" message:@"账号或密码错误，请重新输入" customizationBlock:nil completionBlock:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        }
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
    
}

- (LVButton *)postBtn{
    if (!_postBtn) {
        _postBtn = [LVButton buttonWithType:UIButtonTypeCustom];
        _postBtn.frame =CGRectMake(10, CGRectGetMaxY(_pwd.frame)+20, CGRectGetWidth(BOUNDS)-20, 40);
        [_postBtn setTitle:@"绑定登录" forState:UIControlStateNormal];
        _postBtn.layer.cornerRadius = 4;
        _postBtn.layer.masksToBounds = YES;
        [_postBtn setBackgroundColor:NavgationColor];
        [_postBtn addTarget:self action:@selector(postClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _postBtn;
}

- (LVTextField *)userName{
    if (!_userName) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 14)];
        label.text = @"已有账号名:";
        label.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label];
        _userName = [[LVTextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame)+10, CGRectGetWidth(BOUNDS)-20, 40) WithPlaceholder:@"请输入已有账号名" Withtarget:self];
        _userName.backgroundColor = [UIColor whiteColor];
        _userName.leftViewMode = UITextFieldViewModeAlways;
        _userName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    }
    return _userName;
}
- (LVTextField *)pwd{
    if (!_pwd) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_userName.frame)+20, 100, 14)];
        label.text = @"已有账号密码:";
        label.font = [UIFont systemFontOfSize:14];
        
        [self.view addSubview:label];
        _pwd = [[LVTextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame)+10, CGRectGetWidth(BOUNDS)-20, 40) WithPlaceholder:@"请输入已有账号密码" Withtarget:self];
        _pwd.backgroundColor = [UIColor whiteColor];
        _pwd.secureTextEntry = YES;
        _pwd.leftViewMode = UITextFieldViewModeAlways;
        _pwd.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    }
    return _pwd;
}

- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
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
