//
//  WPCMyOwnPersonalInfoVC.m
//  yuezhan123
//
//  Created by admin on 15/5/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCMyOwnPersonalInfoVC.h"
#import "AppDelegate.h"
#import "ZHupdateImage.h"
#import "SelfInformationModel.h"
#import "WPCSportsTypeChooseVC.h"
#import "SelfInforAddrZhViewController.h"
@interface WPCMyOwnPersonalInfoVC () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIView *timeView;
    NSString *userName;
    NSArray *_areaArray;
    NSString *loveSports;
    NSArray *tfArray;
}
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSArray *preArray;
@property (nonatomic, strong) NSArray *keyArray;
@property (nonatomic, strong)UITextField *tempTextField;
@property (nonatomic, strong)UITextView *tempTextView;
@property (nonatomic, assign)CGRect preFrame;
@property (nonatomic, assign)BOOL viewHasMove;
@property (nonatomic, strong)UIButton *editbtn;
@property (nonatomic, strong)UIDatePicker *datePicker;
@property (nonatomic, strong)SelfInformationModel *model;

@property (nonatomic, strong)UITextField *tf0;
@property (nonatomic, strong)UITextField *tf1;
@property (nonatomic, strong)UITextField *tf2;
@property (nonatomic, strong)UITextField *tf3;
@property (nonatomic, strong)UITextField *tf4;
@property (nonatomic, strong)UITextField *tf5;
@property (nonatomic, strong)UITextField *tf6;
@property (nonatomic, strong)UITextField *tf7;
@property (nonatomic, strong)UITextField *tf8;
@property (nonatomic, strong)UITextField *tf9;


@end

@implementation WPCMyOwnPersonalInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"_dict === %@",_dict);
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    _preArray = @[@[@"昵       称：",@"个性签名：",@"性       别："],@[@"生       日：",@"身高(cm)：",@"体重(kg)：",@"所  在  地："],@[@"体育爱好：",@"喜欢的俱乐部：",@"喜欢的体育明星："]];
    _keyArray = @[@[@"userName",@"sign",@"genderName"],@[@"birthday",@"height",@"weight",@"addr"],@[@"loveSportsMeaning",@"loveClub",@"loveStar"]];
    tfArray = @[@[self.tf0,self.tf1,self.tf2],@[self.tf3,self.tf4,self.tf5,self.tf6],@[self.tf7,self.tf8,self.tf9]];
    [self initialInterface];
    [self initialDatasoruce];
    [self createdatePickerview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)createdatePickerview {
    timeView = [[UIView alloc] initWithFrame:CGRectMake(0, UISCREENHEIGHT, BOUNDS.size.width, 246)];
    timeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:timeView];
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30)];
    top.backgroundColor = NavgationColor;
    [timeView addSubview:top];
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 40, 30)];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelOnClick) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:btn];
    
    UIButton *btn1 =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(BOUNDS.size.width-40, 0, 40, 30)];
    [btn1 setTitle:@"完成" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(finishOnClick) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:btn1];
    
    [timeView addSubview:self.datePicker];
}

- (void)cancelOnClick{
    [UIView animateWithDuration:0.3 animations:^{
        timeView.frame =CGRectMake(0, UISCREENHEIGHT, BOUNDS.size.width, 246);
    }];
}
- (void)finishOnClick{
    NSString *birthday = [NSString getStringFormat:_datePicker.date Format:@"yyy-MM-dd"];
    self.tf3.text = birthday;
    [self cancelOnClick];
}

- (UIDatePicker*)datePicker{
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, BOUNDS.size.width, 216)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.maximumDate = [NSDate date];
        
    }
    return _datePicker;
}

- (void)keyBoardAppear:(NSNotification *)notification {
    
    AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    double keyboardHeight = keyboardRect.size.height;
    NSLog(@"sd");
    CGRect rc0 = CGRectZero;
    rc0 = [_tempTextField.superview convertRect:_tempTextField.frame toView:ap.window];
   
    if (rc0.origin.y+rc0.size.height > UISCREENHEIGHT-keyboardHeight) {
        float offsetY = (rc0.origin.y+rc0.size.height) - (UISCREENHEIGHT-keyboardHeight);
        CGRect r = _tableview.frame;    //view为textField所在需要调整的view
        _preFrame = r;      //记录大小以便调整回来
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        r.origin.y = r.origin.y - offsetY;
        _tableview.frame = r;   //调整view的y值
        [UIView commitAnimations];
        _viewHasMove = YES;  //记录是否调整
    }
}

- (void)confirmAction {
    //提交修改的数据
    
    NSMutableDictionary *dic=[LVTools getTokenApp];
        
    if (!loveSports) {
        NSString *code = [LVTools mToString:self.dict[@"loveSports"]];
        loveSports = code;
    }
    
    
    userName =[LVTools mToString:self.tf0.text];
    
    [dic setObject:[LVTools mToString:self.tf0.text] forKey:@"lmodifyuser"];
    
    [dic setObject:[LVTools mToString:self.tf0.text] forKey:@"userName"];
    
    [dic setObject:self.tf1.text forKey:@"sign"];
    
    [dic setObject:[self.tf2.text isEqualToString:@"男"]?@"XB_0001":@"XB_0002" forKey:@"gender"];
    
    if ([self.tf3.text length] > 0) {
        [dic setObject:self.tf3.text forKey:@"birthday"];
    } else {
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [formatter stringFromDate:now];
        [dic setObject:dateString forKey:@"birthday"];
    }
    
    NSLog(@"birthday ==== %@",[dic valueForKey:@"birthday"]);
    
    [dic setObject:self.tf4.text forKey:@"height"];
    
    [dic setObject:self.tf5.text forKey:@"weight"];
    
    [dic setObject:self.tf6.text forKey:@"addr"];
    
    [dic setObject:[LVTools mToString:loveSports] forKey:@"loveSports"];
    
    [dic setObject:self.tf8.text forKey:@"loveClub"];
    
    [dic setObject:self.tf9.text forKey:@"loveStar"];
    
    [dic setObject:[LVTools mToString: [self.dict valueForKey:@"ID"]] forKey:@"id"];
    
    [dic setObject:[LVTools mToString: [self.dict valueForKey:@"uid"]] forKey:@"uid"];
    
    NSDate *date=[NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [dic setObject:[formatter stringFromDate:date] forKey:@"lmodifytime"];
    
    if (_areaArray.count!=0) {
        
        [dic setObject:[LVTools mToString:[_areaArray objectAtIndex:0]] forKey:@"province"];
        NSString *string=[NSMutableString stringWithString:[_areaArray objectAtIndex:1]];
        NSLog(@"mutablestring=%@",string);
        string=[string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dic setObject:[LVTools mToString: string] forKey:@"provinceMeaning"];
        if (_areaArray.count!=2) {
            [dic setObject:[_areaArray objectAtIndex:2] forKey:@"city"];
            NSString *stringtwo=[_areaArray objectAtIndex:3];
            [dic setObject:[LVTools mToString:stringtwo] forKey:@"cityMeaning"];
            [dic setObject:[LVTools mToString: [_areaArray objectAtIndex:5]] forKey:@"area"];
            NSString *stringthree=[_areaArray objectAtIndex:5];
            [dic setObject:[LVTools mToString: stringthree] forKey:@"areaMeaning"];
        }
    }

    
        /*
         Integer id;//ID
         Integer uid;//uid
         String userName;//用户名
         String icon;//icon
         String iconPath;//iconPath
         String gender;//性别
         String height;//身高
         String weight;//体重
         Date birthday;//生日
         String mobile;//手机号（需要绑定，此处不赋值）
         String email;//邮件 （需要绑定，此处不赋值）
         String loveSports;//喜爱的运动
         String loveClub;//喜欢的俱乐部
         String loveStar;//喜欢的体育明星
         String addr;//所在地
         String province;//省份代码
         String provinceMeaning;//省份
         String city;//市区代码
         String cityMeaning;//市区
         String area;//区域代码
         String areaMeaning;//区域
         Integer integral;//积分不赋值
         Date lmodifytime;
         String lmodifyuser;}
     */
    NSLog(@"个人信息%@",dic);
        [self showHudInView:self.view hint:LoadingWord];
        request =  [DataService requestWeixinAPI:selfcenterinformation parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
            [self hideHud];
            NSDictionary *dic=(NSDictionary *)result;
            if ([[dic objectForKey:@"statusCodeInfo"] isEqualToString:@"修改成功"])
            {
                UIAlertView *AlertView=[[UIAlertView alloc]initWithTitle:@"修改成功！" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [AlertView show];
                //刷新个人信息
                if ([self.delegate respondsToSelector:@selector(sendMsg:)]) {
                    [self.delegate sendMsg:userName];
                }
                
                //刷新约战首页
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshAppoint object:nil];
                [kUserDefault setObject:userName forKey:kUserName];
                [kUserDefault synchronize];
                [self.navigationController popViewControllerAnimated:YES];

            }
            else
            {
                UIAlertView *AlertView=[[UIAlertView alloc]initWithTitle:@"修改失败！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [AlertView show];
            }
        }];
}

- (void)keyBoardHide:(NSNotification *)notification {
    if (_viewHasMove) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        _tableview.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height);   //
        [UIView commitAnimations];
        _viewHasMove = NO;
    }
}

- (void)keyBoardChangeFrame:(NSNotification *)notification {
    
}

- (void)initialDatasoruce
{
    UIView *view = (UIView *)[self.view viewWithTag:2700];
    [LVTools createTheSortsLab:_dict inView:view];
    
    UIButton *image = (UIButton *)[self.view viewWithTag:2703];
    if ([[LVTools mToString:_dict[@"iconPath"]] length] != 0) {
        NSString *imgstr = [NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:_dict[@"iconPath"]]];
        [image sd_setBackgroundImageWithURL:[NSURL URLWithString:imgstr] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    } else {
        [image setBackgroundImage:[UIImage imageNamed:@"plhor_2"] forState:UIControlStateNormal];
    }
    
    UIButton *namelab = (UIButton *)[self.view viewWithTag:2704];
    if ([[LVTools mToString:_dict[@"userName"]] length] != 0) {
        [namelab setTitle:[LVTools mToString:_dict[@"userName"]] forState:UIControlStateNormal];
    } else {
        [namelab setTitle:@"无名" forState:UIControlStateDisabled];
    }
    
    UILabel *signLab = (UILabel *)[self.view viewWithTag:2705];
    if ([[LVTools mToString:_dict[@"sign"]] length] != 0) {
        signLab.text = [LVTools mToString:_dict[@"sign"]];
    } else {
        
    }
}

- (void)initialInterface
{
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT) style:UITableViewStylePlain];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.backgroundColor = RGBACOLOR(247, 247, 247, 1);
    _tableview.showsVerticalScrollIndicator = NO;
    
    _tableview.tableHeaderView = [self createTheHeaderView];

    _tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 49.0)];
    
    [self.view addSubview:_tableview];
}

- (UIView *)createTheHeaderView
{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    UIImage *image1 = [UIImage imageNamed:@"back"];
    UIView *headview = [LVTools headerViewWithbackgroudcolor:[UIImage imageNamed:@"backGround1"] backBtn:image1 settingBtn:nil beginTag:2700 islogin:islogin isHide:NO];
    headview.tag = 2700;
    
    _editbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editbtn.frame = CGRectMake(UISCREENWIDTH-50-10, 20+6, 50, 30);
    [_editbtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_editbtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_editbtn addTarget:self action:@selector(editinfo:) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:_editbtn];
    
    UIButton *btn1 = (UIButton *)[headview viewWithTag:2701];
    [btn1 addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIButton *img = (UIButton *)[headview viewWithTag:2703];
    [img addTarget:self action:@selector(imgclick) forControlEvents:UIControlEventTouchUpInside];
    img.userInteractionEnabled = YES;
    
    return headview;
}

- (void)imgclick {
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取" otherButtonTitles:@"拍照", nil];
    action.tag = 501;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 501) {
        if (buttonIndex!=2) {
            [self presentImagePickerControllerWithIndex:buttonIndex];
        }
    } else {
        if (buttonIndex==1) {
            self.tf2.text=@"女";
            [_dict setValue:@"女" forKey:@"genderName"];
        }
        else
        {
            self.tf2.text=@"男";
            [_dict setValue:@"男" forKey:@"genderName"];
        }
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

#pragma mark-UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    CGSize imageSize=image.size;
    imageSize.height=121;
    imageSize.width=121;
    //image=[self imageWithImage:image scaledToSize:imageSize];
    [self performSelector:@selector(selectPickerImage:) withObject:image afterDelay:0.1];
}
-(void)selectPickerImage:(UIImage *)image
{
    [self showHudInView:self.view hint:@"图片上传中...."];
    NSData *imageData=UIImageJPEGRepresentation(image, kCompressqulitaty);
    if (imageData==nil) {
        imageData=UIImagePNGRepresentation(image);
    }
    NSMutableDictionary *dic=[LVTools getTokenApp];
    ZHupdateImage *update=[[ZHupdateImage alloc]init];
    UIButton *img = (UIButton *)[self.view viewWithTag:2703];
    [update requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"PERSONAL_LOGO"} WithType:nil WithData:imageData With:^(NSDictionary * result) {
        NSString *iconPath=nil;
        if ([[result objectForKey:@"statusCode"] isEqualToString:@"success"])
        {
            [dic setObject:[result objectForKey:@"path"] forKey:@"iconPath"];
            iconPath = [LVTools mToString:[result objectForKey:@"path"]];
            [dic setObject:[result objectForKey:@"url"] forKey:@"icon"];
            [dic setObject:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
            [dic setObject:_dict[@"userName"] forKey:@"userName"];
            [DataService requestWeixinAPI:selfcenterinformation parsms:
             @{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                 NSDictionary *dic=(NSDictionary *)result;
                 NSLog(@"result=%@",result);
                 NSLog(@"statusCodeInfo=%@",[dic objectForKey:@"statusCodeInfo"] );
                 if ([[dic objectForKey:@"statusCode"] isEqualToString:@"success"]) {
                     [self hideHud];
                     [kUserDefault setValue:iconPath forKey:KUserIcon];
                     [kUserDefault synchronize];
                     [img setBackgroundImage:image forState:UIControlStateNormal];
                     //刷新约战首页
                     [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshAppoint object:nil];
                 } else {
                     [self hideHud];
                     UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:@"请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                     [alertView show];
                 }
             }];
        }
        else
        {
            [self hideHud];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:
                                    @"请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}
//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void)editinfo:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"编辑"]) {
        sender.selected = YES;
        [sender setTitle:@"保存" forState:UIControlStateNormal];
        self.tf0.userInteractionEnabled = YES;
        self.tf1.userInteractionEnabled = YES;
        self.tf4.userInteractionEnabled = YES;
        self.tf5.userInteractionEnabled = YES;
        self.tf8.userInteractionEnabled = YES;
        self.tf9.userInteractionEnabled = YES;
        [self.tf0 becomeFirstResponder];
    } else {
        if (self.tf0.text.length > 8) {
            [self showHint:@"昵称最多8个字符"];
            return;
        }
        if ([self.tf0.text length] == 0) {
            [self showHint:@"昵称不能为空"];
            return;
        }
        sender.selected = NO;
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        [self.view endEditing:YES];
        [self confirmAction];
    }
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 4;
    } else {
        return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 10;
    }
}

- (UITextField *)tf0 {
    if (!_tf0) {
        _tf0 = [[UITextField alloc] init];
        _tf0.delegate = self;
        _tf0.font = Btn_font;
        _tf0.userInteractionEnabled = NO;
        _tf0.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf0.text = [LVTools mToString:[self.dict valueForKey:_keyArray[0][0]]];
    }
    return _tf0;
}
- (UITextField *)tf1 {
    if (!_tf1) {
        _tf1 = [[UITextField alloc] init];
        _tf1.delegate = self;
        _tf1.font = Btn_font;
        _tf1.userInteractionEnabled = NO;
        _tf1.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf1.text = [LVTools mToString:[self.dict valueForKey:_keyArray[0][1]]];
    }
    return _tf1;
}
- (UITextField *)tf2 {
    if (!_tf2) {
        _tf2 = [[UITextField alloc] init];
        _tf2.delegate = self;
        _tf2.font = Btn_font;
        _tf2.userInteractionEnabled = NO;
        _tf2.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf2.text = [LVTools mToString:[self.dict valueForKey:_keyArray[0][2]]];
    }
    return _tf2;
}
- (UITextField *)tf3 {
    if (!_tf3) {
        _tf3 = [[UITextField alloc] init];
        _tf3.delegate = self;
        _tf3.font = Btn_font;
        _tf3.userInteractionEnabled = NO;
        _tf3.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf3.text = [LVTools mToString:[self.dict valueForKey:_keyArray[1][0]]];
    }
    return _tf3;
}
- (UITextField *)tf4 {
    if (!_tf4) {
        _tf4 = [[UITextField alloc] init];
        _tf4.delegate = self;
        _tf4.font = Btn_font;
        _tf4.userInteractionEnabled = NO;
        _tf4.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf4.text = [LVTools mToString:[self.dict valueForKey:_keyArray[1][1]]];
    }
    return _tf4;
}
- (UITextField *)tf5 {
    if (!_tf5) {
        _tf5 = [[UITextField alloc] init];
        _tf5.delegate = self;
        _tf5.font = Btn_font;
        _tf5.userInteractionEnabled = NO;
        _tf5.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf5.text = [LVTools mToString:[self.dict valueForKey:_keyArray[1][2]]];
    }
    return _tf5;
}

- (UITextField *)tf6 {
    if (!_tf6) {
        _tf6 = [[UITextField alloc] init];
        _tf6.delegate = self;
        _tf6.font = Btn_font;
        _tf6.userInteractionEnabled = NO;
        _tf6.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf6.text = [LVTools mToString:[self.dict valueForKey:_keyArray[1][3]]];
    }
    return _tf6;
}
- (UITextField *)tf7 {
    if (!_tf7) {
        _tf7 = [[UITextField alloc] init];
        _tf7.delegate = self;
        _tf7.font = Btn_font;
        _tf7.userInteractionEnabled = NO;
        _tf7.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf7.text = [LVTools mToString:[self.dict valueForKey:_keyArray[2][0]]];
    }
    return _tf7;
}
- (UITextField *)tf8 {
    if (!_tf8) {
        _tf8 = [[UITextField alloc] init];
        _tf8.delegate = self;
        _tf8.font = Btn_font;
        _tf8.userInteractionEnabled = NO;
        _tf8.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf8.text = [LVTools mToString:[self.dict valueForKey:_keyArray[2][1]]];
    }
    return _tf8;
}
- (UITextField *)tf9 {
    if (!_tf9) {
        _tf9 = [[UITextField alloc] init];
        _tf9.delegate = self;
        _tf9.font = Btn_font;
        _tf9.userInteractionEnabled = NO;
        _tf9.textColor = RGBACOLOR(70, 70, 70, 1);
        _tf9.text = [LVTools mToString:[self.dict valueForKey:_keyArray[2][2]]];
    }
    return _tf9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    NSString *labeltext = _preArray[indexPath.section][indexPath.row];
    CGFloat width = [LVTools sizeWithStr:labeltext With:16 With2:18.0];
    UILabel *titlelab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, width, 42)];
    titlelab.text = labeltext;
    titlelab.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:titlelab];

    titlelab.textColor = RGBACOLOR(150, 150, 150, 1);
    
    UITextField *textField = tfArray[indexPath.section][indexPath.row];
    textField.frame = CGRectMake(CGRectGetMaxX(titlelab.frame), 0, UISCREENWIDTH-CGRectGetMaxX(titlelab.frame)-30, 42);
    
//    NSString *textstr = [LVTools mToString:[self.dict valueForKey:_keyArray[indexPath.section][indexPath.row]]];
//    if (textstr.length != 0) {
//        NSString *contentStr =[LVTools mToString:[self.dict valueForKey:_keyArray[indexPath.section][indexPath.row]]];
//        textField.text =contentStr;
//    } else {
//        textField.text = @"";
//    }
    [cell.contentView addSubview:textField];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"sfsfsfsfsfsfsfsfsfsfsfsfsf");
    if (_editbtn.selected) {
        if (indexPath.section == 0) {
            if (indexPath.row == 2) {
                [self.view endEditing:YES];
                UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"请选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"男" otherButtonTitles:@"女", nil];
                actionSheet.tag = 502;
                [actionSheet showInView:self.view];
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                //生日选择
                [self.view endEditing:YES];
                [UIView animateWithDuration:0.3 animations:^{
                    timeView.frame=CGRectMake(0, UISCREENHEIGHT-246, BOUNDS.size.width, 246);
                }];
            }
            if (indexPath.row == 3) {
                //所在地
                SelfInforAddrZhViewController *addr=[[SelfInforAddrZhViewController alloc]init];
                addr.regionid=@"1";
                addr.title=@"区域";
                [self.navigationController pushViewController:addr animated:YES];
                addr.chuanBlock=^(NSArray *arr) {
                    _areaArray=[NSArray arrayWithArray:arr];
                    NSLog(@"area=%@",arr);
                    NSMutableString *string=[[NSMutableString alloc]init];
                    for (int i=0; i<arr.count/2; i++)
                    {
                        if (![string isEqual:[arr objectAtIndex:(2*i+1)]])
                        {
                            if (i!=0) {
                                [string appendFormat:@"/%@",[arr objectAtIndex:(2*i+1)]];
                                
                            }
                            else
                            {
                                [string appendString:[arr objectAtIndex:(2*i+1)]];
                            }
                        }
                    }
                    self.tf6.text=string;
                };
            }
        }
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                //体育爱好
                WPCSportsTypeChooseVC *vc = [[WPCSportsTypeChooseVC alloc] init];
                vc.multipleChoose = YES;
                vc.chuanBlock = ^ (NSArray *arr) {
                    if (arr&&arr.count!=0) {
                    NSString *str = arr[0];
                    for (int i = 1; i < arr.count; i ++) {
                        str = [str stringByAppendingFormat:@",%@",arr[i]];
                    }
                    self.tf7.text = str;
                    }
                    UIView *view = (UIView *)[self.view viewWithTag:2700];
                    [LVTools createTheSortsLab:_dict inView:view];
                    [self.dict setObject:self.tf7.text forKey:@"loveSportsMeaning"];
                };
                vc.sportCode = ^ (NSArray *arr) {
                    if (arr&&arr.count!=0) {
                    NSString *str = arr[0];
                    for (int i = 1; i < arr.count; i ++) {
                        str = [str stringByAppendingFormat:@",%@",arr[i]];
                    }
                    loveSports = [NSString stringWithString:str];
                    }
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _tempTextField = textField;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark --- tableview delegate

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
