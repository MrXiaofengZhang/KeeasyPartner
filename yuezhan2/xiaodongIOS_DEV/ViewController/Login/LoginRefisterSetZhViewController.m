//
//  LoginRefisterSetZhViewController.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/27.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LoginRefisterSetZhViewController.h"
#import "LVTextField.h"
#import "LoginLoginZhViewController.h"
#import "LVScrollView.h"
#import "LoginSetController.h"
@interface LoginRefisterSetZhViewController ()<UITextFieldDelegate,UIScrollViewDelegate>

@property (nonatomic, strong)LVScrollView * bgSc;
@property (nonatomic, strong)LVTextField * userName;
@property (nonatomic, strong)LVTextField * pwd1;
@property (nonatomic, strong)LVTextField * pwd2;
@property (nonatomic, strong)UIImageView *okImag1;
@property (nonatomic, strong)UIImageView *okImag2;
@property (nonatomic, strong)UIButton * postBtn;

@property (nonatomic, strong)NSString *myCode;
@property (nonatomic, strong)NSString *myMobile;
@end

@implementation LoginRefisterSetZhViewController

- (instancetype)initWithCode:(NSString *)codeStr WithMobile:(NSString *)MobileStr{
    self = [super init];
    if (self) {
        self.myCode = codeStr;
        self.myMobile = MobileStr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self navgationBarLeftReturn];
    self.view.backgroundColor = BackGray_dan;
    [self makeUI];
    
}

- (void)makeUI{
    [self.view addSubview:self.bgSc];
    //[self.bgSc addSubview:self.userName];
    [self.bgSc addSubview:self.pwd1];
    [self.bgSc addSubview:self.pwd2];
    [self.bgSc addSubview:self.postBtn];
    
//    _bgSc.backgroundColor =[UIColor orangeColor];
//    _stateTools.backgroundColor = [UIColor whiteColor];
//    _userName.backgroundColor =[UIColor whiteColor];
//    _pwd1.backgroundColor = [UIColor whiteColor];
//    _pwd2.backgroundColor = [UIColor whiteColor];
}
#pragma mark UITextFielddelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
  //这里假设键盘高度为246.0
    if (textField == _userName) {
        [UIView animateWithDuration:0.4 animations:^{
            if (64+60+246.0-BOUNDS.size.height>0) {
                 _bgSc.contentOffset = CGPointMake(0,64+60+246.0-BOUNDS.size.height>0);
            }
           
        }];
    }else if (textField == _pwd1){
        [UIView animateWithDuration:0.4 animations:^{
            _bgSc.contentOffset = CGPointMake(0, 64+60*2+246.0-BOUNDS.size.height>0);
        }];
    }else if (textField == _pwd2) {
        [UIView animateWithDuration:0.4 animations:^{
           _bgSc.contentOffset = CGPointMake(0, 64+60*3+246.0-BOUNDS.size.height>0);
        }];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([textField isEqual:_pwd1]){
        if (_pwd1.text.length<6||_pwd1.text.length>18) {
            [self showHint:@"密码长度不符!"];
            return;
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
       _bgSc.contentOffset = CGPointMake(0, 0);
    }];
}

- (UIButton *)postBtn{
    if (!_postBtn) {
        _postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _postBtn.frame = CGRectMake(10, _pwd2.bottom+40.0, CGRectGetWidth(BOUNDS)-20, 35);
        _postBtn.backgroundColor = [UIColor lightGrayColor];
        _postBtn.layer.cornerRadius = 5.0f;
        _postBtn.enabled = NO;
        if([self.title isEqualToString:@"修改密码"]){
        [_postBtn setTitle:@"完成" forState:UIControlStateNormal];
        }
        else{
            [_postBtn setTitle:@"下一步" forState:UIControlStateNormal];
        }
        [_postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _postBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        
        [_postBtn addTarget:self action:@selector(confirmButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _postBtn;
}

- (LVTextField *)pwd2{
    if (!_pwd2) {
        _pwd2 = [[LVTextField alloc] initWithFrame:CGRectMake(LEFTX,_pwd1.bottom+30.0f, CGRectGetWidth(BOUNDS)-4*LEFTX, 35.0) WithPlaceholder:@"请再次确认密码" Withtarget:self];
        _pwd2.secureTextEntry = YES;
        _pwd2.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd2.backgroundColor = [UIColor whiteColor];
        _pwd2.leftViewMode = UITextFieldViewModeAlways;
        UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(_pwd2.left, _pwd2.bottom, BOUNDS.size.width, 20)];
        label1.textAlignment = NSTextAlignmentLeft;
        label1.text = @"请输入与上方相同的密码";
        label1.font = Content_lbfont;
        label1.textColor = [UIColor lightGrayColor];
        label1.textAlignment = NSTextAlignmentLeft;
        _okImag2 = [[UIImageView alloc] initWithFrame:CGRectMake(_pwd2.right+mygap*2, _pwd2.top+mygap*2, 16.0, 15.0)];
        _okImag2.hidden = YES;
        _okImag2.image = [UIImage imageNamed:@"GOU"];
        [self.bgSc addSubview:_okImag2];

        [self.bgSc addSubview:label1];
    }
    return _pwd2;
}

- (LVTextField *)pwd1{
    if (!_pwd1) {
        _pwd1 = [[LVTextField alloc] initWithFrame:CGRectMake(LEFTX, 2*mygap, CGRectGetWidth(BOUNDS)-4*LEFTX, 35.0) WithPlaceholder:@"密码为6-18个字符" Withtarget:self];
        _pwd1.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd1.secureTextEntry = YES;
        _pwd1.backgroundColor = [UIColor whiteColor];
        _pwd1.leftViewMode = UITextFieldViewModeAlways;
        UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(_pwd1.left, _pwd1.bottom, BOUNDS.size.width, 20)];
        label1.textAlignment = NSTextAlignmentLeft;
        label1.text = @"请输入至少由6个数字，字母和符号组合的密码";
        label1.font = Content_lbfont;
        label1.textColor = [UIColor lightGrayColor];
        label1.textAlignment = NSTextAlignmentLeft;
        _okImag1 = [[UIImageView alloc] initWithFrame:CGRectMake(_pwd1.right+mygap*2, _pwd1.top+mygap*2, 16.0, 15.0)];
        _okImag1.hidden = YES;
        _okImag1.image = [UIImage imageNamed:@"GOU"];
        [self.bgSc addSubview:_okImag1];
        [self.bgSc addSubview:label1];

    }
    return _pwd1;
}

- (LVTextField *)userName{
    if (!_userName) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        label.text = @"昵  称:";
        label.textAlignment = NSTextAlignmentRight;
        
        _userName = [[LVTextField alloc] initWithFrame:CGRectMake(LEFTX, mygap*2, CGRectGetWidth(BOUNDS)-LEFTX, 50) WithPlaceholder:@"  请输入用户昵称" Withtarget:self];
        _userName.backgroundColor = [UIColor whiteColor];
        _userName.leftViewMode = UITextFieldViewModeAlways;
        

    }
    return _userName;
}
- (LVScrollView *)bgSc{
    if (!_bgSc) {
        _bgSc = [[LVScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(BOUNDS), CGRectGetHeight(BOUNDS)-64)];
        _bgSc.backgroundColor = [UIColor whiteColor];
        _bgSc.delegate = self;
        _bgSc.bounces = NO;
        _bgSc.pagingEnabled = NO;
        //_bgSc.contentSize = CGSizeMake(CGRectGetWidth(BOUNDS), CGRectGetHeight(BOUNDS)+100);
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKey)];
        [_bgSc addGestureRecognizer:tap];
    }
    return _bgSc;
}

- (void)closeKey{
    [_userName resignFirstResponder];
    [_pwd1 resignFirstResponder];
    [_pwd2 resignFirstResponder];
}
- (void)PopView{
    [WCAlertView showAlertWithTitle:nil message:@"确定要退出注册流程退出后资料将不被保存" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        //
        if(buttonIndex == 1){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}
#pragma  mark --注册最后一步
-(void)confirmButton{
    [self.view endEditing:YES];
    if (!(_pwd1.text.length>=6&&_pwd1.text.length<=16)){
        [self showHint:@"请至少输入6－16个数字、字母和符号的在在组合密码"];
        return;
    }
    else{
        if (![_pwd1.text isEqualToString:_pwd2.text]) {
            [self showHint:@"两次输入的密码不一致"];
            return;
        }
    }
    if([self.title isEqualToString:@"设置密码"]){
        LoginSetController *vc =[[LoginSetController alloc] init];
        vc.phone = _myMobile;
        vc.pwd = _pwd1.text;
    [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    return;
    //验证密码是否正确
    /*
    if ([LVTools isValidatePassWord:_pwd1.text]&&_pwd1.text.length>=6&&_pwd1.text.length<=20) {
    NSMutableDictionary * dic = [LVTools getTokenApp];
    
    [dic setValue:self.myMobile forKey:@"mobile"];
    [dic setValue:self.myCode forKey:@"mobileCode"];
    [dic setValue:_userName.text forKey:@"userName"];//账户昵称
    [dic setValue:_pwd1.text forKey:@"password"];//账户密码
        [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:confrimOwnInfo parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"\n\n\n------------\n%@",result);
        [self hideHud];
        NSDictionary * resultDic = result;
        if ([resultDic[@"statusCodeInfo"] isEqualToString:@"成功"]) {
            [kUserDefault setValue:self.myMobile forKey:KUserMobile];
            [kUserDefault setObject:self.myMobile forKey:KUserAcount];
            [kUserDefault synchronize];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            [self showHint:resultDic[@"statusCodeInfo"]];
        }
    }];
    }
    else{
        [self showHint:@"密码为6-20为子母数字和下划线"];
        
    }
     */
}


- (void)showMsg:(NSString *)msg{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITextfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isEqual:_pwd2]) {
        if (textField.text.length>=5) {
            _okImag2.hidden = NO;
        }
        else{
            _okImag2.hidden = YES;
        }

        if ([textField.text isEqualToString:@""]) {
            [_postBtn setBackgroundColor:[UIColor lightGrayColor]];
            _postBtn.enabled=YES;
            return YES;
        }
        if (![string isEqualToString:@""]||(textField.text.length!=1)) {
            [_postBtn setBackgroundColor:SystemBlue];
            _postBtn.enabled=YES;
            return YES;
        }
        
        [_postBtn setBackgroundColor:[UIColor lightGrayColor]];
        _postBtn.enabled=NO ;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
