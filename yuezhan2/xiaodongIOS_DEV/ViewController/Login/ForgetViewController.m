//
//  ForgetViewController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ForgetViewController.h"
#import "LVTextField.h"
#import "LVScrollView.h"
@interface ForgetViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    UIImageView *_okImag1;
    UIImageView *_okImag2;
}
@property (nonatomic, strong)LVScrollView * bgSc;
@property (nonatomic, strong)LVTextField * tel;
@property (nonatomic, strong)LVTextField * pwd;
@property (nonatomic, strong)UIButton * nextBtn;
@end

@implementation ForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=NO;
    [self navgationBarLeftReturn];
    self.title = @"重置密码";
    [self makeUI];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)makeUI{
    [self.view addSubview:self.bgSc];
    [self.bgSc addSubview:self.tel];
    [self.bgSc addSubview:self.pwd];
    [self.bgSc addSubview:self.nextBtn];
    
    _tel.backgroundColor = [UIColor whiteColor];
    _pwd.backgroundColor = [UIColor whiteColor];
    
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _tel) {
    }else if (textField == _pwd){
        
        if (_tel.text.length == 0) {
            [_tel becomeFirstResponder];
            [self showHint:@"请输入新密码"];
        }else{
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark UITextfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isEqual:_pwd]) {
        if (textField.text.length>=5) {
            _okImag2.hidden = NO;
        }
        else{
            _okImag2.hidden = YES;
        }
        
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
    else{
        if (textField.text.length>=5) {
            _okImag1.hidden = NO;
        }
        else{
            _okImag1.hidden = YES;
        }
    }
    return YES;
}


- (void)showMsg:(NSString *)msg{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _tel) {
        
    }else if (textField == _pwd){
       
    }
}


- (UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.frame = CGRectMake(10, CGRectGetMaxY(_pwd.frame)+mygap*2+40, CGRectGetWidth(_bgSc.frame)-20, 35);
        _nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _nextBtn.layer.cornerRadius = mygap;
        [_nextBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _nextBtn.backgroundColor = [UIColor lightGrayColor];
        _nextBtn.enabled = NO;
        [_nextBtn addTarget:self action:@selector(nextClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

#pragma  mark --【重置密码】
- (void)nextClick{
    [self.view endEditing:YES];
    if(_tel.text.length==0||_pwd.text.length==0){
        [self showHint:@"请填写完整信息"];
        return;
    }
    if (_tel.text.length<6||_tel.text.length>18) {
        [self showHint:@"密码长度为6-18位有效字符"];
        return;
    }
    if(![_tel.text isEqualToString:_pwd.text]){
        [self showHint:@"两次输入的密码不一致"];
        return;
    }
        NSMutableDictionary * dic = [LVTools getTokenApp];
        [dic setValue:_mobile forKey:@"mobile"];
        [dic setValue:_pwd.text forKey:@"password"];
        [DataService requestWeixinAPI:resetPassword parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            NSLog(@"重置密码返回的信息：%@",result);
            NSDictionary * dic = (NSDictionary *)result;
           
            if (![dic[@"status"] isKindOfClass:[NSNull class]]) {
                if ([dic[@"status"] boolValue]) {
                    [self showMsg:dic[@"info"]];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                else{
                    [self showMsg:dic[@"info"]];
                }
            }else{
                [self showHint:ErrorWord];
            }
        }];
}
- (LVTextField *)pwd{
    if (!_pwd) {
        _pwd = [[LVTextField alloc] initWithFrame:CGRectMake(LEFTX, CGRectGetMaxY(self.tel.frame)+mygap*2+20, CGRectGetWidth(BOUNDS)-4*LEFTX, 35.0) WithPlaceholder:@"  请确认您的新密码" Withtarget:self];
        _pwd.keyboardType = UIKeyboardTypeDefault;
        _pwd.secureTextEntry = YES;
        _pwd.leftViewMode = UITextFieldViewModeAlways;
        _pwd.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(_pwd.left, _pwd.bottom, BOUNDS.size.width, 20)];
        label1.textAlignment = NSTextAlignmentLeft;
        label1.text = @"请输入至少由6个数字，字母和符号组合的密码";
        label1.font = Content_lbfont;
        label1.textColor = [UIColor lightGrayColor];
        label1.textAlignment = NSTextAlignmentLeft;
        _okImag2 = [[UIImageView alloc] initWithFrame:CGRectMake(_tel.right+mygap*2, _tel.top+mygap*2, 16.0, 15.0)];
        _okImag2.hidden = YES;
        _okImag2.image = [UIImage imageNamed:@"GOU"];
        [self.bgSc addSubview:label1];
        [self.bgSc addSubview:_okImag1];
    }
    return _pwd;
}

- (LVTextField *)tel{
    if (!_tel) {
        _tel = [[LVTextField alloc] initWithFrame:CGRectMake(LEFTX, mygap*2, CGRectGetWidth(BOUNDS)-4*LEFTX, 35.0) WithPlaceholder:@"  请输入新密码" Withtarget:self];
        _tel.keyboardType = UIKeyboardTypeDefault;
        _tel.secureTextEntry = YES;
        _tel.leftViewMode = UITextFieldViewModeAlways;
        _tel.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(_tel.left, _tel.bottom, BOUNDS.size.width, 20)];
        label1.textAlignment = NSTextAlignmentLeft;
        label1.text = @"请输入至少由6个数字，字母和符号组合的密码";
        label1.font = Content_lbfont;
        label1.textColor = [UIColor lightGrayColor];
        label1.textAlignment = NSTextAlignmentLeft;
        _okImag1 = [[UIImageView alloc] initWithFrame:CGRectMake(_tel.right+mygap*2, _tel.top+mygap*2, 16.0, 15.0)];
        _okImag1.hidden = YES;
        _okImag1.image = [UIImage imageNamed:@"GOU"];
        [self.bgSc addSubview:label1];
        [self.bgSc addSubview:_okImag1];
    }
    return _tel;
}
- (LVScrollView*)bgSc{
    if (!_bgSc) {
        _bgSc = [[LVScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(BOUNDS), CGRectGetHeight(BOUNDS)-64)];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAll)];
        [_bgSc addGestureRecognizer:tap];
    }
    return _bgSc;
}
- (void)resignAll{
    [self.tel resignFirstResponder];
    [self.pwd resignFirstResponder];
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
