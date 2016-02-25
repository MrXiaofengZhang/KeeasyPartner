//
//  EditViewController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/6.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic,strong) UITextField *editTf;
@property (nonatomic,strong) UITextView *editTv;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BackGray_dan;
    [self navgationBarLeftReturn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    if (self.isEditSign) {
        [self.view addSubview:self.editTv];
        self.editTv.text = self.contentStr;
    }
    else{
        [self.view addSubview:self.editTf];
        self.editTf.text = self.contentStr;
    }
}
- (void)save:(id)sender{
    //判错处理
    NSString *paramStr = nil;
    if (self.isEditSign) {
        paramStr = _editTv.text;
    }
    else{
        paramStr = _editTf.text;
    }
    if ([LVTools deleteSpace:paramStr].length==0) {
        [self showHint:@"该字符无效或不能为空"];
        return;
    }
    NSString *keyStr = nil;
    if ([self.title isEqualToString:@"昵称"]) {
        keyStr = @"nickName";
    }
    else if([self.title isEqualToString:@"个性签名"]){
        keyStr = @"signature";
    }
    else if([self.title isEqualToString:@"真实姓名"]){
        keyStr = @"realName";
    }
    else if([self.title isEqualToString:@"手机号码"]){
        keyStr = @"mobile";
    }
    if (keyStr) {
        [self updateUserInfoWithKey:keyStr AndValue:paramStr];
    }
    else{
        [self showHint:@"未知属性"];
    }
    
}
- (UITextField*)editTf{
    if (_editTf==nil) {
        _editTf = [[UITextField alloc] initWithFrame:CGRectMake(0, mygap*2, BOUNDS.size.width, 44.0)];
        _editTf.returnKeyType = UIReturnKeyDone;
        _editTf.backgroundColor = [UIColor whiteColor];
        _editTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mygap, 0)];
        _editTf.leftViewMode = UITextFieldViewModeAlways;
        _editTf.delegate = self;
    }
    return _editTf;
}
- (UITextView*)editTv{
    if (_editTv == nil) {
        _editTv = [[UITextView alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, BOUNDS.size.width-4*mygap, 120.0)];
        _editTv.returnKeyType = UIReturnKeyDone;
        _editTv.backgroundColor = [UIColor whiteColor];
        _editTv.delegate = self;
    }
    return _editTv;
}
#pragma mark 修改信息
- (void)updateUserInfoWithKey:(NSString*)key AndValue:(NSString*)value{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:KUserMobile] forKey:@"mobile"];
    [dic setValue:value forKey:key];
    [DataService requestWeixinAPI:resetPassword parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"重置密码返回的信息：%@",result);
        NSDictionary * dic = (NSDictionary *)result;
        if ([dic[@"status"] boolValue]) {
         //修改本地缓存并回调block
           
            [_infoDic[@"user"] setObject:value forKey:key];
            [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:_infoDic] Key:[NSString stringWithFormat:@"xd%@", [LVTools mToString: [kUserDefault objectForKey:kUserId]]]];
            
            if ([key isEqualToString:@"nickName"]) {
                [kUserDefault setObject:value forKey:kUserName];
            }
            [kUserDefault synchronize];
            self.chuanBlock(@[value]);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            if ([LVTools mToString: dic[@"error"]].length>0) {
                [self showHint:ErrorWord];
            }
            else{
                [self showHint:ErrorWord];
            }
        }
    }];
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark UITextViewDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *anyOne = [touches anyObject];
    if ([anyOne.view isEqual:self.view]) {
        [self.view endEditing:YES];
    }
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
