//
//  LoginLoginZhViewController.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/26.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LoginLoginZhViewController.h"
#import<CoreLocation/CoreLocation.h>
#import "LoginRegisterZhViewController.h"
#import "XGPush.h"
#define HIGHT 60.0f
@interface LoginLoginZhViewController ()
{
    UIButton *_loginButton;
    UIButton *_forgatPassButton;
    NSString *_latitude;
    NSString *_longitude;
    CLLocationManager *_manage;
}
@end

@implementation LoginLoginZhViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBar.hidden=NO;
    [self navgationBarLeftReturn];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pic"]];
//    UIImageView *backimage = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    backimage.image = [UIImage imageNamed:@"pic"];
//    backimage.userInteractionEnabled = YES;
//    backimage.contentMode = UIViewContentModeScaleToFill;
//    [self.view addSubview:backimage];
    NSArray *imageArray=[[NSArray alloc]initWithObjects:@"LoginUserName", @"LoginPassWord",nil];
     NSArray *stringArray=[[NSArray alloc]initWithObjects:@"请输入手机号", @"请输入密码",nil];
    
    
    for (int i=0;i<2 ; i++)
    {
        UIImageView  *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0,0, 24.0, 15.5)];
        imageView.image=[UIImage imageNamed:[imageArray objectAtIndex:i]];
        imageView.contentMode = UIViewContentModeRight;
        UITextField *textField=[[UITextField alloc]initWithFrame:CGRectMake(LEFTX, (HIGHT*i)+20.0+HIGHT+100.0f+45, UISCREENWIDTH-LEFTX*2,40.f)];
        textField.font = Btn_font;
        textField.leftView = imageView;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.backgroundColor = [UIColor whiteColor];
        textField.delegate=self;
        textField.tag=100+i;
        if(i==1)
        {
            textField.secureTextEntry=YES;
            textField.returnKeyType = UIReturnKeyGo;
        }
        else{
            textField.text = [kUserDefault objectForKey:KUserAcount];
        }
        textField.placeholder=[stringArray objectAtIndex:i];
        
        [self.view addSubview:textField];
    }
   _loginButton=[[UIButton alloc]initWithFrame:CGRectMake(LEFTX, 2*HIGHT+20+HIGHT+150.0f, UISCREENWIDTH-LEFTX*2,40.0)];
    _loginButton.layer.cornerRadius=5;
    _loginButton.backgroundColor=[UIColor colorWithRed:169/255.0 green:169/255.0 blue:169/255.0 alpha:1];
    [_loginButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
     _loginButton.enabled=NO ;
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(UISCREENWIDTH-85-LEFTX/2, _loginButton.bottom+10, 100, 20)];
    registerBtn.titleLabel.font = Btn_font;
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    _forgatPassButton=[[UIButton alloc]initWithFrame:CGRectMake(LEFTX/2, _loginButton.bottom+10, 100, 20)];
    _forgatPassButton.titleLabel.font = Btn_font;
    [_forgatPassButton setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [_forgatPassButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_forgatPassButton addTarget:self action:@selector(forgetOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_forgatPassButton];
    [self.view addSubview:_loginButton];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(mygap, 25.0, 30.0, 20.0)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(PopView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}
- (void)registerOnClick:(id)sender{
    LoginRegisterZhViewController *registerVC =[[LoginRegisterZhViewController alloc] init];
    registerVC.title=@"注 册";
    [self.navigationController pushViewController:registerVC animated:YES];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
        CGRect keyboardBounds;
        [keyboardBoundsValue getValue:&keyboardBounds];
        //UIEdgeInsets e = UIEdgeInsetsMake(0, 0, keyboardBounds.size.height, 0);
        _keyboardHeight = keyboardBounds.size.height;
        
        
        //开始编辑输入框的时候，软键盘出现，执行此事件
        //CGRect rc0 = [textField.superview convertRect:textField.frame toView:self.view];等效
        CGRect rc1 = [self.view convertRect:_selectedTf.frame fromView:_selectedTf.superview];
        int offset = rc1.origin.y + _selectedTf.height - (self.view.frame.size.height - _keyboardHeight);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        NSLog(@"%d",offset);
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset >=0)
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
        
        //        [[self tableView] setScrollIndicatorInsets:e];
        //        [[self tableView] setContentInset:e];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    }
#endif
}

- (void)forgetOnClick:(id)sender{
    //忘记密码
    LoginRegisterZhViewController *forgetVC= [[LoginRegisterZhViewController alloc] init];
    forgetVC.title = @"忘记密码";
    [self.navigationController pushViewController:forgetVC animated:YES];
}
#pragma mark-UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 101) {
        [self buttonClick];
    }
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _selectedTf = textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
   
        self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextField *textFieldOne=(UITextField *)[self.view viewWithTag:textField.tag==100?101:100];
    if ([textFieldOne.text isEqualToString:@""]) {
        [_loginButton setBackgroundColor:[UIColor lightGrayColor]];
         _loginButton.enabled=NO ;

        return YES;
    }
    if (![string isEqualToString:@""]||(textField.text.length!=1)) {
        [_loginButton setBackgroundColor:SystemBlue];
        _loginButton.enabled=YES;
            return YES;
    }
 
   [_loginButton setBackgroundColor:[UIColor lightGrayColor]];
    _loginButton.enabled=NO ;
    
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i<2; i++) {
        UITextField *textField=(UITextField *)[self.view viewWithTag:100+i];
        [textField resignFirstResponder];
    }
}

-(void)buttonClick
{
    [self.view endEditing:YES];
    UITextField *textField=(UITextField *)[self.view viewWithTag:100];
    UITextField *textFieldtwo=(UITextField *)[self.view viewWithTag:101];
    NSMutableDictionary *dic=[LVTools getTokenApp];
    NSString * lat =[LVTools mToString: [kUserDefault valueForKey:kLocationLat]];
    NSString * lng =[LVTools mToString: [kUserDefault valueForKey:kLocationlng]];
    [dic setObject:textField.text forKey:@"mobile"];
    [dic setObject:textFieldtwo.text forKey:@"password"];
    [dic setObject:lng forKey:@"longitude"];
    [dic setObject:lat forKey:@"latitude"];
    NSLog(@"%@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:yuezhanlogin parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result)
    {
        [self hideHud];
        NSDictionary *dic=(NSDictionary *)result;
        NSLog(@"%@",result);
        if(![dic objectForKey:@"error"]){
        if ([[dic objectForKey:@"status"] boolValue])
        {
            //环信的注册【1】
            [self showHudInView:self.view hint:LoadingWord];
            [[EaseMob sharedInstance].chatManager
             asyncRegisterNewAccount:[NSString stringWithFormat:@"%@",dic[@"data"][@"user"][@"userId"]]
             password:@"123456"
             withCompletion:^(NSString *username, NSString *password, EMError *error) {
                 [self hideHud];
                 if (!error) {
                     NSLog(@"\n%@\n%@\n%@",username,password,error);
                     [kUserDefault setValue:username forKey:KEMuid];
                     [kUserDefault setValue:password forKey:KEMpwd];
                     [kUserDefault synchronize];
                     [self loginEaseWithUserInfo:dic];
                 }else{
                     NSLog(@"注册失败%@",error);
                     [self hideHud];
                     //[self showHint:[NSString stringWithFormat:@"注册失败%@",error]];
                     if (error.errorCode == EMErrorServerDuplicatedAccount) {
                         [self loginEaseWithUserInfo:dic];
                     }
                 }
             } onQueue:nil];

            
                   }
        else
        {
            [WCAlertView showAlertWithTitle:@"登录失败" message:@"账号或密码错误，请重新输入" customizationBlock:nil completionBlock:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        }
        }
        else{
            [self showHint:ErrorWord];
        }
        
    }];
}
- (void)loginEaseWithUserInfo:(NSDictionary*)dic{
    [self showHudInView:self.view hint:LoadingWord];
    //环信登陆【2】
    //NSString * username = [kUserDefault valueForKey:KEMuid];
    //NSString * password = [kUserDefault valueForKey:KEMpwd];
    NSString * username = [NSString stringWithFormat:@"%@",dic[@"data"][@"user"][@"userId"]];
    //NSString * password = [NSString stringWithFormat:@"%@",dic[@"passport"][@"password"]];
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:@"123456" completion:^(NSDictionary *loginInfo, EMError *error) {
        [self hideHud];
        NSLog(@"\n登陆的信息：%@\n登陆的错误：%@ 未读消息个数%ld",loginInfo,error, (unsigned long)[[EaseMob sharedInstance].chatManager totalUnreadMessagesCount]);
        //刷新消息个数
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
        if ((!error && loginInfo)||[error.description isEqualToString:@"Already logged"]) {
            [self showHint:@"登录服务器成功"];
            NSLog(@"%@",dic);
            //个人信息保存到本地
            [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:dic[@"data"]] Key:[NSString stringWithFormat:@"xd%@", [LVTools mToString: dic[@"data"][@"user"][@"userId"]]]];
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            [kUserDefault setValue: dic[@"data"][@"user"][@"userId"] forKey:kUserId];
            [kUserDefault setValue: dic[@"data"][@"user"][@"realName"] forKey:KUserRealName];
            [kUserDefault setValue: dic[@"data"][@"user"][@"nickName"] forKey:kUserName];
            [kUserDefault setValue:dic[@"data"][@"user"][@"mobile"] forKey:KUserAcount];
            [kUserDefault setValue:dic[@"data"][@"user"][@"mobile"] forKey:KUserMobile];
            [kUserDefault setValue:dic[@"data"][@"path"] forKey:KUserIcon];
            [kUserDefault setValue:dic[@"data"][@"user"][@"schoolId"] forKey:KUserSchoolId];
            [kUserDefault setValue:dic[@"data"][@"schoolName"] forKey:KUserSchoolName];
            [kUserDefault setValue:@"1" forKey:kUserLogin];
            
            [[NSUserDefaults standardUserDefaults]synchronize];
            [XGPush setAccount:[LVTools mToString:[kUserDefault objectForKey:KUserMobile]]];
            //发通知刷新个人中新页面
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSTATECHANGE_NOTIFICATION object:@YES userInfo:nil];
            [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [self showHint:[NSString stringWithFormat:@"登录服务器失败,失败原因:%@",error.description]];
        }
    } onQueue:nil];

}
- (void)PopView{
    [self dismissViewControllerAnimated:YES completion:nil];
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
