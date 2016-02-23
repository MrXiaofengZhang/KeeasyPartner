//
//  WPCChangePhoneVC.m
//  yuezhan123
//
//  Created by admin on 15/7/16.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCChangePhoneVC.h"
#import "WPCChangeEmailVC.h"

@implementation WPCChangePhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _leftTime = 60;
    self.view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishAction)];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 20, UISCREENWIDTH, 44)];
    view1.backgroundColor = [UIColor whiteColor];
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 55, 16)];
    lab1.text = @"手机号:";
    lab1.font = Btn_font;
    [view1 addSubview:lab1];
    [view1 addSubview:self.phoneTF];
    if (!self.needShadow) {
        [view1 addSubview:self.phonelab];
    }
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, view1.bottom+10, UISCREENWIDTH, 44)];
    view2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view2];
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 55, 16)];
    lab2.text = @"验证码:";
    lab2.font = Btn_font;
    [view2 addSubview:lab2];
    [view2 addSubview:self.verifyTF];
    [view2 addSubview:self.verifylab];
    self.phonelab.hidden = YES;
    self.phoneTF.enabled = YES;
    self.needShadow = YES;

}
- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
}
- (UILabel *)verifylab {
    if (!_verifylab) {
        _verifylab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH-100, 0, 100, 44)];
        _verifylab.backgroundColor = NavgationColor;
        _verifylab.textColor = [UIColor whiteColor];
        _verifylab.font = Btn_font;
        _verifylab.textAlignment = NSTextAlignmentCenter;
        _verifylab.text = @"获取验证码";
        _verifylab.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [_verifylab addGestureRecognizer:tap];
    }
    return _verifylab;
}

- (UILabel *)phonelab {
    if (!_phonelab) {
        _phonelab = [[UILabel alloc] initWithFrame:CGRectMake(65, 14, 150, 16)];
        _phonelab.text = [LVTools mToString:[kUserDefault valueForKey:KUserMobile]];
        _phonelab.backgroundColor = [UIColor whiteColor];
        _phonelab.textColor = lightColor;
        _phonelab.font = Btn_font;
    }
    return _phonelab;
}

- (UITextField *)phoneTF {
    if (!_phoneTF) {
        _phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(65, 14, 150, 16)];
        _phoneTF.delegate = self;
        _phoneTF.font =Btn_font;
        _phoneTF.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTF.placeholder = @"请输入11位手机号码";
        _phonelab.text = @"13146518486";
    }
    return _phoneTF;
}

- (UITextField *)verifyTF {
    if (!_verifyTF) {
        _verifyTF = [[UITextField alloc] initWithFrame:CGRectMake(65, 14, 150, 16)];
        _verifyTF.delegate = self;
        _verifyTF.placeholder = @"请输入短信验证码";
        _verifyTF.keyboardType = UIKeyboardTypeNumberPad;
        _verifyTF.font = Btn_font;
    }
    return _verifyTF;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishAction {
    [self.view endEditing:YES];
    if (_leftTime <= 0) {
        [self showHint:@"验证超时，请重新验证"];
        return;
    }
    if (_phonelab.hidden == YES) {
        if (_phoneTF.text.length == 0) {
            [self showHint:@"手机号码不能为空"];
        }
    }
    if ([_verifyTF.text length] == 0) {
        [self showHint:@"验证码不能为空"];
        return;
    }
    
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setValue:_verifyTF.text forKey:@"mobileCode"];
    [dic setValue:_phonelab.hidden?_phoneTF.text:_phonelab.text forKey:@"mobile"];
    
    NSLog(@"****%@",[dic valueForKey:@"mobileCode"]);
    NSLog(@"****%@",[dic valueForKey:@"mobile"]);
    
    [self showHudInView:self.view hint:@"绑定中"];
    [DataService requestWeixinAPI:saveBindMobile parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"-------%@",result);
        if ([result[@"statusCodeInfo"] isEqualToString:@"更新成功"]) {
            [self showHint:@"手机号绑定成功"];
            [kUserDefault setValue:_phoneTF.text forKey:KUserMobile];
            [kUserDefault synchronize];
            self.chuanBlock(nil);
            [self.navigationController popViewControllerAnimated:YES];
            //是否绑定
            
//            if (self.isChangePhone) {
//                if (_phonelab.hidden == NO) {
//                    WPCChangePhoneVC *vc = [[WPCChangePhoneVC alloc] init];
//                    vc.title = @"更改手机";
//                    vc.phonelab.hidden = YES;
//                    vc.phoneTF.enabled = YES;
//                    vc.needShadow = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//            } else {
//                WPCChangeEmailVC *vc = [[WPCChangeEmailVC alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
//            }
        } else {
            [self showHint:result[@"statusCodeInfo"]];
        }
    }];
}
- (void)changelabText {
    _leftTime --;
    if (_leftTime > 0) {
        NSString *str = [NSString stringWithFormat:@"倒计时:(%lds)",(long)_leftTime];
        _verifylab.text = str;
        _verifylab.backgroundColor = [UIColor grayColor];
        _verifylab.userInteractionEnabled = NO;
    } else {
       
        [_timer setFireDate:[NSDate distantFuture]];
        _verifylab.text = @"获取验证码";
        _verifylab.backgroundColor = NavgationColor;
        _verifylab.userInteractionEnabled = YES;
    }
}

- (void)click:(UITapGestureRecognizer *)sender {
    //验证手机号码是否正确
    _leftTime = 60;
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:_phonelab.text forKey:@"mobile"];
    if (!_phonelab.hidden) {
        [dic setValue:_phonelab.text forKey:@"mobile"];
    } else {
        if ([LVTools isValidateMobile:_phoneTF.text]) {
            [dic setValue:_phoneTF.text forKey:@"mobile"];
        } else {
            [self showHint:@"请输入正确手机号码"];
            return;
        }
    }
    NSLog(@"----%@",[dic valueForKey:@"mobile"]);
    [DataService requestWeixinAPI:PostCode parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"%@",result);
        if ([result[@"statusCodeInfo"] isEqualToString:@"验证码发送成功"]) {
            //发送成功
            [self showHint:@"请在60s内输入验证码"];
            if(_timer==nil){
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changelabText) userInfo:nil repeats:YES];
        }
        else{
            [_timer setFireDate:[NSDate distantPast]];
        }
        } else {
            [self showHint:@"验证码发送失败，请重试"];
        }
    }];
}

@end
