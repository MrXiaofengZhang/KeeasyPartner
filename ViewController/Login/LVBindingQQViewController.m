//
//  LVBindingQQViewController.m
//  yuezhan123
//
//  Created by LV on 15/4/14.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVBindingQQViewController.h"
#import "LVBingNumberViewController.h"
#import "ZHupdateImage.h"
@interface LVBindingQQViewController ()

@property (nonatomic, strong)LVButton *bingBtn;
@property (nonatomic, strong)LVButton *firstBtn;//立即进入
@property (nonatomic, strong)UIImageView *headImgBtn;//用户头像
@property (nonatomic, strong)NSString *myQQid;
@property (nonatomic, strong)NSString *myUserName;
@property (nonatomic, strong)NSString *myType;
@end

@implementation LVBindingQQViewController

- (instancetype)initWithQQid:(NSString *)qqIdStr WithUserName:(NSString *)userName withType:(NSString*)type{
    self = [super init];
    if (self) {
        self.myQQid = qqIdStr;
        self.myUserName = userName;
        self.myType = type;
       
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden=NO;
    [self navgationBarLeftReturn];
     [self makeUI];
}

#pragma mark -- 创建界面
- (void)makeUI{
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, CGRectGetWidth(BOUNDS)-20, 18)];
    if([self.myType isEqualToString:@"1"]){
    label.text =[NSString stringWithFormat:@"尊敬的QQ用户%@,您好",_myUserName] ;
    }
    else if([self.myType isEqualToString:@"2"]){
        label.text =[NSString stringWithFormat: @"尊敬的微信用户%@,您好",_myUserName];
    }
    else{
        label.text =[NSString stringWithFormat:@"尊敬的新浪微博用户%@,您好",_myUserName];
    }
    [self.view addSubview:label];
    [self.view addSubview:self.headImgBtn];
    [self.view addSubview:self.bingBtn];
    [self.view addSubview:self.firstBtn];
    
}

#pragma mark --立即进入
- (void)firstClick{
    
    NSString * lng = [kUserDefault objectForKey:kLocationlng];
    NSString * lat = [kUserDefault objectForKey:kLocationLat];
    
    NSDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[NSNumber numberWithDouble:[lng doubleValue]] forKey:@"longitude"];
    [dic setValue:[NSNumber numberWithDouble:[lat doubleValue]] forKey:@"latitude"];
    [dic setValue:@"XB_0001" forKey:@"qqResGender"];
    [dic setValue:_myQQid forKey:@"openId"];
    [dic setValue:_myUserName forKey:@"userName"];
    [dic setValue:_myType forKey:@"type"];
    NSLog(@"-------------------------%@",dic);
    [self showHudInView:self.navigationController.view hint:@"正在登录"];
    [DataService requestWeixinAPI:qqRegister parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result)
     {
         NSLog(@"result === = = = = = == =  = = =%@",result);
         if ([result[@"statusCodeInfo"] isEqualToString:@"快速注册成功"]) {
             //后台注册成功
             //注册环信iM账号
             [[EaseMob sharedInstance].chatManager
              asyncRegisterNewAccount:[NSString stringWithFormat:@"%@",result[@"passport"][@"uid"]]
              password:@"123456"
              withCompletion:^(NSString *username, NSString *password, EMError *error) {
                  
                  if (!error) {
                      //环信账号注册成功
                      [self showHint:@"注册服务器成功"];
                      [kUserDefault setValue:username forKey:KEMuid];
                      [kUserDefault setValue:password forKey:KEMpwd];
                      [kUserDefault synchronize];
                      //登录环信账号
                      NSString * username = [NSString stringWithFormat:@"%@",result[@"passport"][@"uid"]];
                      NSString * password = [NSString stringWithFormat:@"123456"];
                      [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
                        //刷新消息个数
                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
                          if (!error && loginInfo) {
                              [self hideHud];
                              [self showHint:@"登陆服务器成功"];
                              [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                              [kUserDefault setValue:@"1" forKey:kUserLogin];
                              [kUserDefault setValue:result[@"passport"][@"uid"] forKey:kUserId];
                              [kUserDefault setValue:result[@"passport"][@"usernameY"] forKey:kUserName];
                              [kUserDefault setValue:result[@"passport"][@"password"] forKey:kUserPassword];
                              //[kUserDefault setValue:[LVTools mToString: result[@"passport"][@"username"]] forKey:KUserAcount];
                              [kUserDefault setValue:[LVTools mToString:result[@"passport"][@"iconPath"]] forKey:KUserIcon];

                              [kUserDefault synchronize];
                              NSLog(@"kuserdefault === %@",[kUserDefault valueForKey:kUserId]);
                              NSLog(@"kuserdefault === %@",[kUserDefault valueForKey:kUserName]);
                              NSLog(@"kuserdefault === %@",[kUserDefault valueForKey:KUserIcon]);
                              NSLog(@"kuserdefault === %@",[LVTools mToString:[kUserDefault valueForKey:KUserMobile]]);
                              
                              [[EaseMob sharedInstance].chatManager loadDataFromDatabase];

                              [self updateHeadImage];
                          }else{
                              [self showHint:[NSString stringWithFormat:@"登录服务器失败,失败原因:%@", error.description]];
                              
                          }
                      } onQueue:nil];
                  }else{
                      NSLog(@"注册失败%@",error.description);
                      if ([error.description isEqualToString:@"Username already exists"]) {
                          //直接登录
                          [kUserDefault setValue:username forKey:KEMuid];
                          [kUserDefault setValue:password forKey:KEMpwd];
                          [kUserDefault synchronize];
                          //登录环信账号
                          NSString * username = [NSString stringWithFormat:@"%@",result[@"passport"][@"uid"]];
                          NSString * password = [NSString stringWithFormat:@"123456"];
                          [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
                              //刷新消息个数
                              [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshMessageCount object:nil];
                              if (!error && loginInfo) {
                                  [self hideHud];
                                  [self showHint:@"登陆服务器成功"];
                                  [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                                  [kUserDefault setValue:@"1" forKey:kUserLogin];
                                  [kUserDefault setValue:result[@"passport"][@"uid"] forKey:kUserId];
                                  [kUserDefault setValue:result[@"passport"][@"usernameY"] forKey:kUserName];
                                  [kUserDefault setValue:result[@"passport"][@"password"] forKey:kUserPassword];
                                  [kUserDefault setValue:@"" forKey:KUserAcount];//不显示第三方登录的账号
                                  [kUserDefault setValue:[LVTools mToString:result[@"passport"][@"iconPath"]] forKey:KUserIcon];
                                  
                                  [kUserDefault synchronize];
                                  NSLog(@"kuserdefault === %@",[kUserDefault valueForKey:kUserId]);
                                  NSLog(@"kuserdefault === %@",[kUserDefault valueForKey:kUserName]);
                                  NSLog(@"kuserdefault === %@",[kUserDefault valueForKey:KUserIcon]);
                                  NSLog(@"kuserdefault === %@",[LVTools mToString:[kUserDefault valueForKey:KUserMobile]]);
                                  [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                                  
                                  [self updateHeadImage];
                              }
                            else{
                                  [self showHint:[NSString stringWithFormat:@"登录服务器失败,失败原因:%@", error.description]];
                                  
                              }
                          } onQueue:nil];

                      }
                      else{
                          
                      }
                      [self hideHud];
                      if ([error.description isEqualToString:@"Username already exists"]) {
                         
                          
                      }
                      //[self showHint:[NSString stringWithFormat:@"注册失败%@",error]];
                  }
              } onQueue:nil];
         }else{
             [self hideHud];
             [self showHint:@"网络异常，请重试"];
             
         }
     }];
}
- (void)updateHeadImage{
    [self showHudInView:self.view hint:@"图片上传中...."];
    NSData *imageData=UIImageJPEGRepresentation(_headImgBtn.image, kCompressqulitaty);
    if (imageData==nil) {
        imageData=UIImagePNGRepresentation(_headImgBtn.image);
    }
    NSMutableDictionary *dic=[LVTools getTokenApp];
    ZHupdateImage *update=[[ZHupdateImage alloc]init];
    [update requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"PERSONAL_LOGO"} WithType:nil WithData:imageData With:^(NSDictionary * result) {
        NSLog(@"statusCodeInfoOne=%@",[result objectForKey:@"statusCodeInfo"] );
        if ([[result objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
        {
            [dic setObject:[LVTools mToString:[result objectForKey:@"path"]] forKey:@"iconPath"];
            [dic setObject:[LVTools mToString:[result objectForKey:@"url"]] forKey:@"icon"];
            [dic setObject:[LVTools mToString:[kUserDefault objectForKey:kUserId]] forKey:@"uid"];
            [dic setObject:_myUserName forKey:@"userName"];
            [kUserDefault setObject:[LVTools mToString:[result objectForKey:@"path"]] forKey:KUserIcon];
            [kUserDefault synchronize];
            [DataService requestWeixinAPI:selfcenterinformation parsms:
             @{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                 
                 NSDictionary *dic=(NSDictionary *)result;
                 NSLog(@"result=%@",result);
                 NSLog(@"statusCodeInfo=%@",[dic objectForKey:@"statusCodeInfo"] );
                 if ([[dic objectForKey:@"statusCodeInfo"] isEqualToString:@"修改成功"])
                 {
                     [self hideHud];
                     //把个人信息保存到本地
                     [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSTATECHANGE_NOTIFICATION object:@YES userInfo:nil];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
                 else{
                     [self hideHud];
                     UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:@"请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                     [alertView show];
                 }
             }];
            
        }
        else
        {
            [self hideHud];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:
                                    @"请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
        
    }];

}

#pragma mark --【绑定已有账号】
- (void)bingClick{
    
    LVBingNumberViewController * vc = [[LVBingNumberViewController alloc] initWithQQid:self.myQQid withType:self.myType];
    [self.navigationController pushViewController:vc animated:YES];
}
- (UIImageView*)headImgBtn{
    if (_headImgBtn == nil) {
        _headImgBtn = [[UIImageView alloc]init];
        _headImgBtn.frame = CGRectMake((BOUNDS.size.width-60)/2.0, 60, 60, 60);
        _headImgBtn.layer.masksToBounds = YES;
        _headImgBtn.layer.cornerRadius = 30.0;
        [_headImgBtn sd_setImageWithURL:[NSURL URLWithString:_iconPath] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        
    }
    return _headImgBtn;
}
- (LVButton *)bingBtn{
    if (!_bingBtn) {
        
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, _headImgBtn.bottom+10, CGRectGetWidth(BOUNDS)-20, 14)];
        label2.text = @"如果您已经注册过约战账号:";
        label2.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label2];
        
        _bingBtn = [LVButton buttonWithType:UIButtonTypeCustom];
        _bingBtn.frame = CGRectMake(10, CGRectGetMaxY(label2.frame)+10, CGRectGetWidth(BOUNDS)-20, 45);
        _bingBtn.layer.cornerRadius = 4;
        _bingBtn.layer.masksToBounds = YES;
        [_bingBtn setTitle:@"绑定已有账号" forState:UIControlStateNormal];
        [_bingBtn setBackgroundColor:NavgationColor];
        [_bingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bingBtn addTarget:self action:@selector(bingClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bingBtn;
}
- (LVButton *)firstBtn{
    if (!_firstBtn) {
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_bingBtn.frame)+30, CGRectGetWidth(BOUNDS)-20, 14)];
        label2.text = @"快速登录:";
        label2.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label2];
        
        _firstBtn = [LVButton buttonWithType:UIButtonTypeCustom];
        _firstBtn.frame = CGRectMake(10, CGRectGetMaxY(label2.frame)+10, CGRectGetWidth(BOUNDS)-20, 45);
        _firstBtn.layer.cornerRadius = 4;
        _firstBtn.layer.masksToBounds = YES;
        [_firstBtn setTitle:@"立即进入" forState:UIControlStateNormal];
        [_firstBtn setBackgroundColor:NavgationColor];
        [_firstBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_firstBtn addTarget:self action:@selector(firstClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstBtn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
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
