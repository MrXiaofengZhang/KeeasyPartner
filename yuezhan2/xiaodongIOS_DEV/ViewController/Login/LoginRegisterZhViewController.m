//
//  LoginRegisterZhViewController.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/26.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LoginRegisterZhViewController.h"
#import "LoginRefisterSetZhViewController.h"
#import "LVTextField.h"
#import "LVScrollView.h"
#import "ForgetViewController.h"
#import "ZHAgreementViewController.h"
@interface LoginRegisterZhViewController ()<UITextFieldDelegate,UIScrollViewDelegate>
{
    NSTimer *timer;
}
@property (nonatomic, strong)LVScrollView * bgSc;
@property (nonatomic, strong)LVTextField * tel;
@property (nonatomic, strong)LVTextField * pwd;
@property (nonatomic, strong)UIButton * postBtn;
@property (nonatomic, strong)UIButton * nextBtn;

@property (nonatomic, strong)UILabel * cerfierLabel;

@end

@implementation LoginRegisterZhViewController

static  int number;

- (void)viewDidLoad {
    [super viewDidLoad];
    number = 60;
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=NO;
    [self navgationBarLeftReturn];
    [self makeUI];
    }
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}
- (void)makeUI{
    [self.view addSubview:self.bgSc];
    [self.bgSc addSubview:self.tel];
    [self.bgSc addSubview:self.pwd];
    [self.bgSc addSubview:self.postBtn];
    [self.bgSc addSubview:self.nextBtn];
    if([self.title isEqualToString:@"注 册"]){
    [self.bgSc addSubview:self.cerfierLabel];
    }
    _tel.backgroundColor = [UIColor whiteColor];
    _pwd.backgroundColor = [UIColor whiteColor];

    
}

- (UILabel *)cerfierLabel{
    if (!_cerfierLabel) {
        _cerfierLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_nextBtn.frame)+mygap, 100, 13)];
        _cerfierLabel.text = @"注册即表示同意";
        _cerfierLabel.textAlignment = NSTextAlignmentRight;
        _cerfierLabel.font = [UIFont systemFontOfSize:13];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cerfierLabel.frame), CGRectGetMaxY(_nextBtn.frame)+mygap, 140, 14)];
        label.text = @"《校动用户协议》";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = SystemBlue;
        [self.bgSc addSubview:label];
        
//        self.bgSc.userInteractionEnabled = YES;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userCerfierClick)];
        [label addGestureRecognizer:tap];
    }
    return _cerfierLabel;
}
#pragma mark --用户协议
- (void)userCerfierClick{
    ZHAgreementViewController *agreement=[[ZHAgreementViewController alloc]init];
    agreement.title=@"用户协议";
    agreement.urlstring=[NSString stringWithFormat:@"%@%@",preUrl,kProtocolUrl];
    [self.navigationController pushViewController:agreement animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _tel) {
       
    }else if (textField == _pwd){
        
        if (_tel.text.length == 0) {
            
        }else{
            
        }
    }
}



- (void)showMsg:(NSString *)msg{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _tel) {
        
//        if (_tel .text.length ==11) {
//            
//            NSMutableDictionary * dic = [LVTools getTokenApp];
//            [dic setValue:_tel.text forKey:@"mobile"];
//        [DataService requestWeixinAPI:validateAccount parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
//            NSLog(@"-------%@",result);
//            [self.view endEditing:YES];
//            if([self.title isEqualToString:@"忘记密码"]){
//                //忘记密码
//                if ([result[@"statusCode"] isEqualToString:@"success"]) {
//                    //逻辑判断
//                    if ([result[@"statusCodeInfo"] isEqualToString:@"已经存在"]) {
//                        [_pwd becomeFirstResponder];
//                        _postBtn.enabled = YES;
//                    }
//                    else{
//                        [self showMsg:@"该手机号还没有注册"];
//                        //[self showHint:@"该手机号还没有注册"];
//                        _postBtn.enabled = NO;
//                    }
//                }
//                else{
//                    [self showHint:ErrorWord];
//                }
//            }
//            else{
//            if ([result[@"statusCode"] isEqualToString:@"success"]) {
//                //逻辑判断
//                if ([result[@"statusCodeInfo"] isEqualToString:@"可以使用"]) {
//                    [_pwd becomeFirstResponder];
//                    _postBtn.enabled = YES;
//                }
//                else{
//                    [self showMsg:@"该手机号已经注册过"];
//                    _postBtn.enabled = NO;
//                }
//            }
//            else{
//                [self showHint:ErrorWord];
//            }
//            }
//        }];
//        }
    }else if (textField == _pwd){
        if (_pwd.text.length == 0) {
           
        }
    }
}


- (UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.frame = CGRectMake(LEFTX, CGRectGetMaxY(_pwd.frame)+mygap*2+30.0, CGRectGetWidth(_bgSc.frame)-LEFTX*2, 35.0f);
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setBackgroundColor:[UIColor lightGrayColor]];
        _nextBtn.layer.cornerRadius = 5.0;
        _nextBtn.enabled = NO;
        [_nextBtn addTarget:self action:@selector(nextClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

#pragma  mark --【短信验证码验证】
- (void)nextClick{

    [self.view endEditing:YES];
    
//    LoginRefisterSetZhViewController * vc = [[LoginRefisterSetZhViewController alloc] initWithCode:_pwd.text WithMobile:_tel.text];
//    if ([self.title isEqualToString:@"忘记密码"]) {
//        vc.title = @"修改密码";
//    }
//    else{
//        vc.title = @"设置密码";
//    }
//    [self.navigationController pushViewController:vc animated:YES];
//    return;
    
    
    if(_tel.text.length == 11&&_pwd.text.length==6){
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:_tel.text forKey:@"mobile"];
    [dic setValue:_pwd.text forKey:@"code"];
    [DataService requestWeixinAPI:confrimCode parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"发送验证码返回信息：%@",result);
        NSDictionary * dic = (NSDictionary *)result;
        if ([dic[@"status"] isKindOfClass:[NSNull class]]) {
            [self showHint:ErrorWord];
        }
        if (![dic[@"status"] boolValue]) {
            [self showMsg:@"验证码错误,请确认"];
        }else{
            if([self.title isEqualToString:@"忘记密码"]){
                ForgetViewController *forgetVC =[[ForgetViewController alloc] init];
                forgetVC.mobile = _tel.text;
                [self.navigationController pushViewController:forgetVC animated:YES];
            }
            else{
            LoginRefisterSetZhViewController * vc = [[LoginRefisterSetZhViewController alloc] initWithCode:_pwd.text WithMobile:_tel.text];
                vc.title = @"设置密码";
            [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }];
    }
    else{
        [self showHint:@"请检查所填内容是否正确!"];
    }
}

- (UIButton *)postBtn{
    if (!_postBtn) {
        _postBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _postBtn.frame = CGRectMake(_pwd.right+LEFTX, _pwd.top, LEFTX*5, 35.0);
        _postBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_postBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _postBtn.layer.cornerRadius = 5.0f;
        [_postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_postBtn setBackgroundColor:SystemBlue];
        [_postBtn addTarget:self action:@selector(postRegister) forControlEvents:UIControlEventTouchUpInside];
    }
    return _postBtn;
}



#pragma mark --发送验证码
- (void)postRegister{
    [self.view endEditing:YES];
        if (_tel.text.length ==11 &&[LVTools isPureInt:_tel.text]){
            NSMutableDictionary * dic = [LVTools getTokenApp];
            [dic setValue:_tel.text forKey:@"mobile"];
            [self showHudInView:self.view hint:LoadingWord];
            [DataService requestWeixinAPI:validateAccount parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                NSLog(@"-------%@",result);
                [self hideHud];
                [self.view endEditing:YES];
                if([self.title isEqualToString:@"忘记密码"]){
                    //忘记密码
                    if (![result[@"status"] isKindOfClass:[NSNull class]]) {
                        //逻辑判断
                        if ([result[@"status"] boolValue]) {
                           
                            _postBtn.enabled = YES;
                            if (_tel.text.length==11) {
                                if (timer ==nil) {
                                    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCycle:) userInfo:nil repeats:YES];
                                }
                                _postBtn.backgroundColor = [UIColor lightGrayColor];
                                _postBtn.enabled = NO;
                                [timer setFireDate:[NSDate distantPast]];//开启定时器
                                
                                NSMutableDictionary * dic = [LVTools getTokenApp];
                                [dic setValue:_tel.text forKey:@"mobile"];
                                [DataService requestWeixinAPI:PostCode parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                                    NSLog(@"-------%@",result);
                                    
                                    if ([result[@"status"] boolValue]) {
                                        //逻辑判断
                                        //等待短信
                                    }
                                    else{
                                        //暂停定时器
                                        [timer setFireDate:[NSDate distantFuture]];//暂停定时器
                                        number = 60;
                                        _postBtn.backgroundColor = SystemBlue;
                                        _postBtn.enabled  =YES;
                                        [_postBtn setTitle:@"重发验证码" forState:UIControlStateNormal];
                                    }
                                }];
                            }else{
                                [self showMsg:@"请输入正确的手机号"];
                            }
                        }
                        else{
                            [self showMsg:@"该手机号还没有注册"];
                            //[self showHint:@"该手机号还没有注册"];
                            _postBtn.enabled = NO;
                        }
                    }
                    else{
                        [self showHint:ErrorWord];
                    }
                }
                else{
                    if (![result[@"status"] isKindOfClass:[NSNull class]]) {
                        //逻辑判断
                        if (![result[@"status"] boolValue]) {
                            if (_tel.text.length==11) {
                                if (timer ==nil) {
                                    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCycle:) userInfo:nil repeats:YES];
                                }
                                _postBtn.backgroundColor = [UIColor lightGrayColor];
                                _postBtn.enabled = NO;
                                [timer setFireDate:[NSDate distantPast]];//开启定时器
                                
                                NSMutableDictionary * dic = [LVTools getTokenApp];
                                [dic setValue:_tel.text forKey:@"mobile"];
                                [DataService requestWeixinAPI:PostCode parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                                    NSLog(@"-------%@",result);
                                    
                                    if ([result[@"status"] boolValue]) {
                                        //逻辑判断
                                        //等待短信
                                    }
                                    else{
                                        //暂停定时器
                                        [timer setFireDate:[NSDate distantFuture]];//暂停定时器
                                        number = 60;
                                        _postBtn.backgroundColor = SystemBlue;
                                        _postBtn.enabled  =YES;
                                        [_postBtn setTitle:@"重发验证码" forState:UIControlStateNormal];
                                    }
                                }];
                                
                            }else{
                                [self showMsg:@"请输入正确的手机号"];
                            }

                        }
                        else{
                            [self showMsg:@"该手机号已经注册过"];
                        }
                    }
                    else{
                        [self showHint:ErrorWord];
                    }
                }
            }];
        }
        else{
            [self showHint:@"请输入正确的手机号"];
        }
}

- (void)timeCycle:(NSTimer *)time{
    [_postBtn setTitle:[NSString stringWithFormat:@"还有(%d)s",number] forState:UIControlStateNormal];
    number --;
    if (number == 0) {
        number = 60;
        [timer setFireDate:[NSDate distantFuture]];
        _postBtn.enabled = YES;
        [_postBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _postBtn.backgroundColor = SystemBlue;
    }
}


- (LVTextField *)pwd{
    if (!_pwd) {
        _pwd = [[LVTextField alloc] initWithFrame:CGRectMake(LEFTX, self.tel.bottom+40.0f, LEFTX*10, 35.0f) WithPlaceholder:@"  请输入验证码" Withtarget:self];
        _pwd.keyboardType = UIKeyboardTypeNumberPad;
        _pwd.leftViewMode = UITextFieldViewModeAlways;
        
    }
    return _pwd;
}

- (LVTextField *)tel{
    if (!_tel) {
        _tel = [[LVTextField alloc] initWithFrame:CGRectMake(LEFTX, mygap*2, CGRectGetWidth(self.bgSc.frame)-2*LEFTX, 35.0) WithPlaceholder:@"  请输入11位手机号码" Withtarget:self];
        
        _tel.keyboardType = UIKeyboardTypeNumberPad;
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(_tel.left, _tel.bottom+3.0f, _tel.width, 20)];
        lb.text = @"登录或重设密码时，需要用到此号码";
        lb.font = Content_lbfont;
        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = [UIColor lightGrayColor];
        [self.view addSubview:lb];
    }
    return _tel;
}
- (LVScrollView*)bgSc{
    if (!_bgSc) {
        _bgSc = [[LVScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(BOUNDS), CGRectGetHeight(BOUNDS)-64)];
        _bgSc.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAll)];
        [_bgSc addGestureRecognizer:tap];
    }
    return _bgSc;
}
- (void)resignAll{
    [self.tel resignFirstResponder];
    [self.pwd resignFirstResponder];
}
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isEqual:_pwd]) {
        if ([textField.text isEqualToString:@""]) {
            [_nextBtn setBackgroundColor:[UIColor lightGrayColor]];
            _nextBtn.enabled=YES;
            return YES;
        }
        if (![string isEqualToString:@""]||(textField.text.length!=1)) {
            [_nextBtn setBackgroundColor:SystemBlue];
            _nextBtn.enabled=YES;
            return YES;
        }
        
        [_nextBtn setBackgroundColor:[UIColor lightGrayColor]];
        _nextBtn.enabled=NO ;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
