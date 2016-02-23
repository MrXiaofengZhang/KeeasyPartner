//
//  LoginLoginZhViewController.h
//  yuezhan123
//
//  Created by zhoujin on 15/3/26.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface LoginLoginZhViewController : BaseViewController<UITextFieldDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic,strong) UITextField *selectedTf;
@end
