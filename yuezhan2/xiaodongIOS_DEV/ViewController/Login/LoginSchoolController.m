//
//  LoginSchoolController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/3.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "LoginSchoolController.h"
#import "CityListViewController.h"
#import "SchoolsController.h"
#define leftBoard_w 20.0f
@interface LoginSchoolController ()<UIPickerViewDataSource,UIPickerViewDelegate,CityDelegate>{
    UIButton *finishBtn;
    UIButton *schoolBtn;
    UIButton *yearBtn;
    UIView *btnV;
    NSDictionary *schoolInfo;
}
@property (nonatomic,strong) UIPickerView *yearPicker;
@end

@implementation LoginSchoolController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"学校信息";
    [self navgationBarLeftReturn];
    
    [self makeUI];
}
- (void)PopView{
    [WCAlertView showAlertWithTitle:nil message:@"确定要退出注册流程退出后资料将不被保存" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        //
        if(buttonIndex == 1){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}

- (void)makeUI{
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(finishOnClick)];
    UILabel *textLb = [[UILabel alloc] initWithFrame:CGRectMake(leftBoard_w, 20.0, BOUNDS.size.width-2*leftBoard_w, 20.0)];
    textLb.text = @"请选择您当前就读的大学";
    textLb.font = Content_lbfont;
    textLb.textColor = [UIColor lightGrayColor];
    [self.view addSubview:textLb];
    self.view.backgroundColor = [UIColor whiteColor];
    schoolBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftBoard_w, 44.0f, BOUNDS.size.width-2*leftBoard_w, 40.0)];
    [schoolBtn setTitle:@"请选择学校" forState:UIControlStateNormal];
    [schoolBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
    schoolBtn.layer.cornerRadius = 5.0f;
    schoolBtn.layer.borderWidth = 1.0f;
    [schoolBtn addTarget:self action:@selector(schoolOnclick) forControlEvents:UIControlEventTouchUpInside];
    schoolBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:schoolBtn];
    
    
    UILabel *textLb1 = [[UILabel alloc] initWithFrame:CGRectMake(leftBoard_w, schoolBtn.bottom+20.0, BOUNDS.size.width-2*leftBoard_w, 20.0)];
    textLb1.text = @"请选择您入学年份";
    textLb1.font = Content_lbfont;
    textLb1.textColor = [UIColor lightGrayColor];
    [self.view addSubview:textLb1];
    yearBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftBoard_w, textLb1.bottom+4.0f, BOUNDS.size.width-2*leftBoard_w, 40.0)];
    [yearBtn setTitle:@"请选择入学年份" forState:UIControlStateNormal];
    [yearBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
    yearBtn.layer.cornerRadius = 5.0f;
    yearBtn.layer.borderWidth = 1.0f;
    [yearBtn addTarget:self action:@selector(yearOnClick) forControlEvents:UIControlEventTouchUpInside];
    yearBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:yearBtn];
    
    finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftBoard_w, yearBtn.bottom+44.0f, BOUNDS.size.width-2*leftBoard_w, 40.0)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishBtn setBackgroundColor:[UIColor lightGrayColor]];
    finishBtn.enabled = NO;
    [finishBtn addTarget:self action:@selector(finishOnClick) forControlEvents:UIControlEventTouchUpInside];
    finishBtn.layer.cornerRadius = 5.0f;
    finishBtn.layer.borderWidth = 1.0f;
    finishBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:finishBtn];
    [self.view addSubview:self.yearPicker];

}
#pragma mark getter
- (UIPickerView*)yearPicker{
    if (_yearPicker == nil) {
        _yearPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height+30, BOUNDS.size.width, 216.0)];
        _yearPicker.delegate = self;
        _yearPicker.backgroundColor = [UIColor colorWithRed:0.824f green:0.835f blue:0.859f alpha:1.00f];
        btnV = [[UIView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height-64, BOUNDS.size.width, 30)];
        btnV.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:btnV];
        
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-40, 0, 40, 30)];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        [okBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okOnClick) forControlEvents:UIControlEventTouchUpInside];
        [btnV addSubview:okBtn];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:SystemBlue forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelOnClick) forControlEvents:UIControlEventTouchUpInside];
        [btnV addSubview:cancelBtn];
    }
    return _yearPicker;
}
- (void)getSchoolListInfo{
    
}
#pragma mark private
- (void)finishOnClick{
    //注册用户
    NSMutableDictionary *dic=[LVTools getTokenApp];
    [dic setObject:_phone forKey:@"mobile"];
    [dic setObject:_pwd forKey:@"password"];
    [dic setObject:_nickName forKey:@"nickName"];
    [dic setObject:_realName forKey:@"realName"];
    [dic setObject:_sexStr forKey:@"gender"];
    [dic setObject: schoolInfo[@"id"] forKey:@"schoolId"];
    [dic setObject:yearBtn.titleLabel.text forKey:@"enrollment"];
    [dic setObject:_headImgId forKey:@"face"];
    NSLog(@"%@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:xiaodongRegister parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result)
     {
         NSLog(@"%@",result);
         [self hideHud];
         if ([result[@"status"] isKindOfClass:[NSNull class]]||!result[@"status"]) {
             [self showHint:ErrorWord];
         }
         else{
             if ([result[@"status"] boolValue]) {
                 //注册环信后台
//                 [self showHudInView:self.view hint:LoadingWord];
//                 [[EaseMob sharedInstance].chatManager
//                  asyncRegisterNewAccount:[NSString stringWithFormat:@"%@",result[@"data"][@"user"][@"userId"]]
//                  password:@"123456"
//                  withCompletion:^(NSString *username, NSString *password, EMError *error) {
//                      [self hideHud];
//                      if (!error) {
//                          NSLog(@"\n%@\n%@\n%@",username,password,error);
//                          [kUserDefault setValue:username forKey:KEMuid];
//                          [kUserDefault setValue:password forKey:KEMpwd];
//                          [kUserDefault synchronize];
//                      }else{
//                          NSLog(@"注册失败%@",error);
//                          [self showHint:[NSString stringWithFormat:@"注册失败%@",error]];
//                          if (error.errorCode == EMErrorServerDuplicatedAccount) {
//                              
//                          }
//                      }
//                  } onQueue:nil];

                 [WCAlertView showAlertWithTitle:@"注册成功,请登录" message:nil customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                     //
                     [self.navigationController popToRootViewControllerAnimated:YES];
                 } cancelButtonTitle:@"确定" otherButtonTitles: nil];
             }
             else{
                 [self showHint:result[@"info"]];
             }
         }
     }];
    
}

- (void)yearOnClick{
    [UIView animateWithDuration:0.3f animations:^{
        self.yearPicker.frame = CGRectMake(0, BOUNDS.size.height-216.0f, BOUNDS.size.width, 216.0);
        btnV.top = BOUNDS.size.height-246.0;
    }];
}
- (void)schoolOnclick{
    SchoolsController *schoolVC =[[SchoolsController alloc] init];
    schoolVC.title = @"选择所在院校";
    schoolVC.chuanBlock = ^(NSArray *arr){
      [schoolBtn setTitle:[arr objectAtIndex:0][@"name"] forState:UIControlStateNormal];
        schoolInfo = [arr objectAtIndex:0];
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:schoolVC];
    [self presentViewController:navi animated:YES completion:nil];
    if((![schoolBtn.titleLabel.text isEqualToString:@"请选择学校"])&&(![yearBtn.titleLabel.text isEqualToString:@"请选择入学年份"])){
        finishBtn.enabled = YES;
        [finishBtn setBackgroundColor:SystemBlue];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIPickViewDelegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 10;
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",(int)(2016-row)];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //isYear = YES;
    //[yearBtn setTitle:[NSString stringWithFormat:@"%ld",(2015-row)] forState:UIControlStateNormal];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *anyTouch = [touches anyObject];
    if ([anyTouch.view isEqual:self.view]) {
        [self cancelOnClick];
    }
}
- (void)cancelOnClick{
    [UIView animateWithDuration:0.3f animations:^{
        self.yearPicker.frame = CGRectMake(0, BOUNDS.size.height+30.0, BOUNDS.size.width, 216.0);
        btnV.frame = CGRectMake(0, BOUNDS.size.height, BOUNDS.size.width, 30.0);
    }];
}
- (void)okOnClick{
    [yearBtn setTitle:[NSString stringWithFormat:@"%d",(int)(2016-(int)[_yearPicker selectedRowInComponent:0])] forState:UIControlStateNormal];
    [self cancelOnClick];
    if((![schoolBtn.titleLabel.text isEqualToString:@"请选择学校"])&&(![yearBtn.titleLabel.text isEqualToString:@"请选择入学年份"])){
        finishBtn.enabled = YES;
        [finishBtn setBackgroundColor:SystemBlue];
    }

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
