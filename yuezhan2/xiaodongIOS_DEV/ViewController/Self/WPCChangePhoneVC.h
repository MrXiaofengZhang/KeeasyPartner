//
//  WPCChangePhoneVC.h
//  yuezhan123
//
//  Created by admin on 15/7/16.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"

@interface WPCChangePhoneVC : BaseViewController<UITextFieldDelegate>

@property (nonatomic, strong)UITextField *phoneTF;
@property (nonatomic, strong)UITextField *verifyTF;
@property (nonatomic, strong)UILabel *verifylab;
@property (nonatomic, assign)BOOL isChangePhone;//yes代表手机更改，no代表邮箱更改
@property (nonatomic, strong)UILabel *phonelab;
@property (nonatomic, assign)NSInteger leftTime;//验证码的剩余时间
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)BOOL needShadow;

@end
