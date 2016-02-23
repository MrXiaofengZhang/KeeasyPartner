//
//  WPCChangeEmailVC.m
//  yuezhan123
//
//  Created by admin on 15/7/16.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCChangeEmailVC.h"

@implementation WPCChangeEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更改邮箱";
    self.view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, UISCREENWIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 50, 16)];
    lab.text = @"邮箱:";
    lab.font = Btn_font;
    [view addSubview:lab];
    
    [view addSubview:self.textField];
    [self.view addSubview:view];
    [self makeNavigationBarButton];
}

- (void)makeNavigationBarButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
}

- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmAction {
    [self.view endEditing:YES];
    if ([LVTools isValidateEmail:_textField.text]) {
        //完成，向服务器传参
    } else {
        [self showHint:@"邮箱格式不正确，请重新输入" andHeight:200];
    }
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(80, 14, UISCREENWIDTH-100, 16)];
        _textField.delegate = self;
        _textField.placeholder = @"请输入正确的邮箱地址";
        
    }
    return _textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
