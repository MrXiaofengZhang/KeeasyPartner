//
//  LoginSetController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/3.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "LoginSetController.h"
#import "LoginSchoolController.h"
#import "LVTextField.h"
#import "ZHupdateImage.h"
#define headImageView_w 80.0f
#define leftBoard 20.0f
#define textfield_h 30.0f
#define btn_w 40.0f
@interface LoginSetController ()<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSString *sexStr;
    BOOL isIcon;
    UIImageView *iconImg;
}
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) LVTextField *nickNameTf;
@property (nonatomic,strong) LVTextField *realNameTf;
@property (nonatomic,strong) UIImageView *okImg;
@property (nonatomic,strong) UIButton *maleBtn;
@property (nonatomic,strong) UIButton *femaleBtn;
@property (nonatomic,strong) UIButton *nextBtn;
@end

@implementation LoginSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"完善基本资料";
    sexStr = @"1";
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
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStyleBordered target:self action:@selector(nextOnClick)];
    
    [self.view addSubview:self.headImageView];
    [self.view addSubview:iconImg];
    [self.view addSubview:self.nickNameTf];
    [self.view addSubview:self.realNameTf];
    
    UILabel *sexLb = [[UILabel alloc] initWithFrame:CGRectMake(leftBoard, self.realNameTf.bottom+44.0f, 40.0, 30.0f)];
    sexLb.text = @"性别:";
    sexLb.textAlignment = NSTextAlignmentLeft;
    sexLb.textColor = [UIColor lightGrayColor];
    [self.view addSubview:sexLb];
    
    [self.view addSubview:self.maleBtn];
    [self.view addSubview:self.femaleBtn];

    UILabel *sexLbText = [[UILabel alloc] initWithFrame:CGRectMake(self.realNameTf.left, self.maleBtn.bottom+mygap, _realNameTf.width, 20)];
    sexLbText.font = Content_lbfont;
    sexLbText.textColor = [UIColor lightGrayColor];
    sexLbText.textAlignment = NSTextAlignmentRight;
    sexLbText.text = @"请选择真实性别,注册后不可更改";
    [self.view addSubview:sexLbText];
    
    [self.view addSubview:self.nextBtn];
}
- (UIImageView*)okImg{
    if (_okImg == nil) {
        _okImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"性别选择icon"]];
        _okImg.frame = CGRectMake(30.0, 12.0, 18.0, 18.0);
    }
    return _okImg;
}
#pragma mark getter
- (UIImageView*)headImageView{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((BOUNDS.size.width-headImageView_w)/2.0f, 44.0f, headImageView_w, headImageView_w)];
        
        _headImageView.layer.cornerRadius = headImageView_w/2.0f;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.backgroundColor = [UIColor lightGrayColor];
        _headImageView.userInteractionEnabled = YES;
        
        iconImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
        iconImg.frame = CGRectMake(_headImageView.right-30.0, _headImageView.bottom-30.0, 30.0, 30.0);
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 30.0f, _headImageView.width, 20.0f)];
        lb.text = @"点击上传头像";
        lb.font = Content_lbfont;
        lb.textAlignment = NSTextAlignmentCenter;
        lb.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headOnClick)];
        [_headImageView addGestureRecognizer:tap];
        [_headImageView addSubview:lb];
    }
    return _headImageView;
}
- (LVTextField*)nickNameTf{
    if (_nickNameTf == nil) {
        _nickNameTf = [[LVTextField alloc] initWithFrame:CGRectMake(leftBoard, self.headImageView.bottom+44.0f, BOUNDS.size.width-2*leftBoard, 35.0) WithPlaceholder:@"昵称" Withtarget:self];
        _nickNameTf.leftViewMode = UITextFieldViewModeAlways;
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, textfield_h, textfield_h)];
        img.image = [UIImage imageNamed:@"LoginUserName"];
        img.contentMode = UIViewContentModeCenter;
        _nickNameTf.leftView = img;
        _nickNameTf.layer.masksToBounds = YES;
        _nickNameTf.layer.cornerRadius = 5.0;
    }
    return _nickNameTf;
}
- (LVTextField*)realNameTf{
    if (_realNameTf == nil) {
        _realNameTf = [[LVTextField alloc] initWithFrame:CGRectMake(leftBoard, self.nickNameTf.bottom+leftBoard, BOUNDS.size.width-2*leftBoard, 35.0) WithPlaceholder:@"姓名" Withtarget:self];
        _realNameTf.leftViewMode = UITextFieldViewModeAlways;
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, textfield_h, textfield_h)];
        img.image = [UIImage imageNamed:@"LoginUserName"];
        img.contentMode = UIViewContentModeCenter;
        _realNameTf.leftView = img;
        _realNameTf.layer.masksToBounds = YES;
        _realNameTf.layer.cornerRadius = 5.0;
        UILabel *textLb = [[UILabel alloc] initWithFrame:CGRectMake(self.realNameTf.left, self.realNameTf.bottom, _realNameTf.width, _realNameTf.height)];
        textLb.text = @"请填写真实姓名,姓名仅用于赛事报名!";
        textLb.font = Content_lbfont;
        textLb.textAlignment = NSTextAlignmentRight;
        textLb.textColor = [UIColor lightGrayColor];
        [self.view addSubview:textLb];
    }
    return _realNameTf;
}
- (UIButton*)maleBtn{
    if (_maleBtn == nil) {
        _maleBtn = [[UIButton alloc] initWithFrame:CGRectMake(LEFTX*6, self.realNameTf.top+88.0, btn_w, btn_w*0.6)];
        [_maleBtn setBackgroundColor:NavgationColor];
        [_maleBtn setImage:[UIImage imageNamed:@"男"] forState:UIControlStateNormal];
        _maleBtn.layer.cornerRadius = 5.0f;
        [_maleBtn addTarget:self action:@selector(maleBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
        [_maleBtn addSubview:self.okImg];
    }
    return _maleBtn;
}
- (UIButton*)femaleBtn{
    if (_femaleBtn == nil) {
        _femaleBtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-LEFTX*6-btn_w*0.6, self.maleBtn.top, btn_w, btn_w*0.6)];
        [_femaleBtn setBackgroundColor:[UIColor colorWithRed:0.973f green:0.192f blue:0.643f alpha:1.00f]];
        [_femaleBtn setImage:[UIImage imageNamed:@"女"] forState:UIControlStateNormal];
        _femaleBtn.layer.cornerRadius = 5.0f;
        [_femaleBtn addTarget:self action:@selector(femaleBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _femaleBtn;
}
- (UIButton*)nextBtn{
    if (_nextBtn == nil) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(LEFTX, _femaleBtn.bottom+30.0, BOUNDS.size.width-2*LEFTX, 35.0)];
        [_nextBtn setBackgroundColor:SystemBlue];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _nextBtn.layer.cornerRadius = 5.0f;
        [_nextBtn addTarget:self action:@selector(nextOnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}
#pragma mark private
- (void)headOnClick{
    NSLog(@"点击上传头像");
    [self.view endEditing:YES];
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取" otherButtonTitles:@"拍照", nil];
    [action showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex!=2) {
        [self presentImagePickerControllerWithIndex:buttonIndex];
    }
}

-(void)presentImagePickerControllerWithIndex:(NSInteger)index
{
    UIImagePickerControllerSourceType sourceType;
    if (index==0) {
        sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        sourceType =UIImagePickerControllerSourceTypeCamera;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *pickerController=[[UIImagePickerController alloc]init];
        pickerController.delegate=self;
        pickerController.sourceType=sourceType;
        pickerController.allowsEditing=YES;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    CGSize imageSize=image.size;
    imageSize.height=150;
    imageSize.width=150;
    _headImageView.image = image;
    isIcon = YES;
    iconImg.hidden = YES;
    //去掉文字
    for (UIView *subView in _headImageView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [subView removeFromSuperview];
        }
    }
}
- (void)uploadLogo{
    [self showHudInView:self.view hint:@"图片上传中...."];
    NSData *imageData=UIImageJPEGRepresentation(_headImageView.image, kCompressqulitaty);
    if (imageData==nil) {
        imageData=UIImagePNGRepresentation(_headImageView.image);
    }
    NSMutableDictionary *dic=[LVTools getTokenApp];
    ZHupdateImage *update=[[ZHupdateImage alloc]init];
    [update requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"PERSONAL_LOGO"} WithType:nil WithData:imageData With:^(NSDictionary * result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([[result objectForKey:@"status"] boolValue]) {
            LoginSchoolController *SchoolVc =[[LoginSchoolController alloc] init];
            SchoolVc.headImgId = result[@"data"][@"id"];
            SchoolVc.phone = _phone;
            SchoolVc.pwd = _pwd;
            SchoolVc.sexStr = sexStr;
            SchoolVc.realName = _realNameTf.text;
            SchoolVc.nickName = _nickNameTf.text;
            [self.navigationController pushViewController:SchoolVc animated:YES];
        } else {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:
                                    @"请重试" delegate:nil cancelButtonTitle:@"确 定" otherButtonTitles: nil];
            [alertView show];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        NSLog(@"result=%@",result);
    }];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextOnClick{
    NSLog(@"下一步");
    [self.view endEditing:YES];
    if(isIcon){
        if([LVTools deleteSpace: _nickNameTf.text].length==0){
            [self showHint:@"请填写昵称"];
            return;
        }
        if([LVTools deleteSpace: _nickNameTf.text].length>15){
            [self showHint:@"昵称不能超过15个字符"];
            return;
        }
        if ([LVTools deleteSpace:_realNameTf.text].length == 0) {
            [self showHint:@"请填写真实姓名"];
            return;
        }
    [self uploadLogo];
    }
    else{
        [self showHint:@"请上传个人头像"];
    }
}
- (void)maleBtnOnClick{
    if (![_maleBtn.subviews containsObject:_okImg]) {
        [_okImg removeFromSuperview];
        [_maleBtn addSubview:self.okImg];
    }
    sexStr = @"1";
}
- (void)femaleBtnOnClick{
    if (![_femaleBtn.subviews containsObject:_okImg]) {
        [_okImg removeFromSuperview];
        [_femaleBtn addSubview:self.okImg];
    }
    sexStr = @"0";
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
