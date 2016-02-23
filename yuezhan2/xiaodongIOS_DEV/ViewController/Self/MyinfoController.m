//
//  MyinfoController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/16.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "MyinfoController.h"
#import "ZHTeamDetaillCell.h"
#import "EditViewController.h"
#import "WPCSportsTypeChooseVC.h"
#import "ZHupdateImage.h"
@interface MyinfoController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSArray *titleArr;
    NSMutableArray *contentArr;
    UIImageView *image;
    UIView *timeView;
}
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, strong)UIDatePicker *datePicker;
@end

@implementation MyinfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人资料";
    titleArr = @[@"更换头像",@"昵称",@"性别",@"年龄",@"个性签名",@"体育爱好"];
    NSString *genderStr = [self.infoDic[@"user"][@"gender"] boolValue]?@"男":@"女";
    //计算年龄
    NSString *age = @"0";
    NSString *birthday = [LVTools mToString:self.infoDic[@"user"][@"birthday"]];
    if(birthday.length==0){
        age = @"0";
    }
    else{
        age = [LVTools fromDateToAge:[NSDate dateWithTimeIntervalSince1970:[self.infoDic[@"user"][@"birthday"] floatValue]/1000]];
    }
    contentArr = [[NSMutableArray alloc] initWithArray:  @[@"",[kUserDefault objectForKey:kUserName],genderStr,age,[LVTools mToString:self.infoDic[@"user"][@"signature"]],[LVTools mToString:self.infoDic[@"user"][@"loveSports"]]]];
    image = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width-70.0, 5.0, 34.0, 34.0)];
    image.layer.cornerRadius = 17.0;
    image.layer.masksToBounds = YES;

    [self navgationBarLeftReturn];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveOnClick)];
    [self.view addSubview:self.mTableView];
    [self createdatePickerview];
}
- (void)saveOnClick{
    
}
- (void)createdatePickerview {
    timeView = [[UIView alloc] initWithFrame:CGRectMake(0, UISCREENHEIGHT-64.0, BOUNDS.size.width, 246)];
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
        timeView.frame =CGRectMake(0, UISCREENHEIGHT-64.0, BOUNDS.size.width, 246);
    }];
}
- (void)finishOnClick{
    NSString *birthday = [NSString getStringFormat:_datePicker.date Format:@"yyy-MM-dd"];
    //self.tf3.text = birthday;
    

    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:KUserMobile] forKey:@"mobile"];
    [dic setValue:birthday forKey:@"birthday"];
    [DataService requestWeixinAPI:resetPassword parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"重置密码返回的信息：%@",result);
        NSDictionary * dic = (NSDictionary *)result;
        if ([dic[@"status"] boolValue]) {
            [contentArr replaceObjectAtIndex:3 withObject:[LVTools fromDateToAge:_datePicker.date]];
            [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            //修改本地缓存
            [_infoDic[@"user"] setValue:[NSNumber numberWithLong:[_datePicker.date timeIntervalSince1970]*1000] forKey:@"birthday"];
            [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:_infoDic] Key:[NSString stringWithFormat:@"xd%@", [LVTools mToString: [kUserDefault objectForKey:kUserId]]]];
        }
        else{
            
        }
    }];
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

- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0) style:UITableViewStyleGrouped];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
         _mTableView.tableFooterView = [[UIView alloc] init];
        
    }
    return _mTableView;
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHTeamDetaillCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infocell"];
    if (cell == nil) {
        cell = [[ZHTeamDetaillCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"infocell"];
    }
    cell.textLabel.text = [titleArr objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [contentArr objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        [image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,self.infoDic[@"path"]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        if (!image.superview) {
            [cell.contentView addSubview:image];
        }
    }
    if (indexPath.row == 2){
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //修改头像
        UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取" otherButtonTitles:@"拍照", nil];
        [action showInView:self.view];
    }
    else if (indexPath.row == 2){
        //性别不可编辑
        [self showHint:@"性别不可修改"];
    }
    else if (indexPath.row == 3){
        //编辑生日
        [self.view endEditing:YES];
            [UIView animateWithDuration:0.3 animations:^{
            timeView.frame=CGRectMake(0, UISCREENHEIGHT-64.0-246, BOUNDS.size.width, 246);
        }];

    }
    else if (indexPath.row == 5){
        //编辑运动爱好
        WPCSportsTypeChooseVC *vc = [[WPCSportsTypeChooseVC alloc] init];
        vc.multipleChoose = YES;
        vc.ishoppy = YES;
        vc.infoDic =[[NSMutableDictionary alloc] initWithDictionary: self.infoDic];
        if ([LVTools mToString: [contentArr objectAtIndex:indexPath.row]].length>0) {
        vc.chooseArray = [[NSMutableArray alloc] initWithArray:[[contentArr objectAtIndex:indexPath.row] componentsSeparatedByString:@","]];
        }
        vc.chuanBlock = ^ (NSArray *arr) {
            if (arr&&arr.count!=0) {
                NSString *str = arr[0];
                for (int i = 1; i < arr.count; i ++) {
                    str = [str stringByAppendingFormat:@",%@",arr[i]];
                }
                [contentArr replaceObjectAtIndex:indexPath.row withObject:str];
                [self.mTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                [contentArr replaceObjectAtIndex:indexPath.row withObject:@""];
                [self.mTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        vc.sportCode = ^ (NSArray *arr) {
            if (arr&&arr.count!=0) {
                NSString *str = arr[0];
                for (int i = 1; i < arr.count; i ++) {
                    str = [str stringByAppendingFormat:@",%@",arr[i]];
                }
                //loveSports = [NSString stringWithString:str];
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        EditViewController *editVc =[[EditViewController alloc] init];
        editVc.infoDic =[[NSMutableDictionary alloc] initWithDictionary: self.infoDic];
        if (indexPath.row==4) {
            editVc.isEditSign = YES;
        }
        else{
            editVc.isEditSign = NO;
        }
        editVc.chuanBlock = ^(NSArray *arr){
            [contentArr replaceObjectAtIndex:indexPath.row withObject:arr[0]];
            [self.mTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self showHint:@"修改信息成功"];
        };
        editVc.title = [titleArr objectAtIndex:indexPath.row];
        editVc.contentStr = [contentArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:editVc animated:YES];
    }
}

#pragma mark 上传头像
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
    UIImage *image1=[info objectForKey:UIImagePickerControllerEditedImage];
    CGSize imageSize=image1.size;
    imageSize.height=150;
    imageSize.width=150;
    [self uploadLogoWithImg:image1];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)uploadLogoWithImg:(UIImage*)img{
    [self showHudInView:self.view hint:@"图片上传中...."];
    NSData *imageData=UIImageJPEGRepresentation(img, kCompressqulitaty);
    if (imageData==nil) {
        imageData=UIImagePNGRepresentation(img);
    }
    NSMutableDictionary *dic=[LVTools getTokenApp];
    ZHupdateImage *update=[[ZHupdateImage alloc]init];
    [update requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"PERSONAL_LOGO"} WithType:nil WithData:imageData With:^(NSDictionary * result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([[result objectForKey:@"status"] boolValue]) {
            [self showHudInView:self.view hint:@"修改头像中"];
            NSString *iconPath = result[@"data"][@"path"];
            NSMutableDictionary * dic = [LVTools getTokenApp];
            [dic setValue:[kUserDefault objectForKey:KUserMobile] forKey:@"mobile"];
            [dic setValue:result[@"data"][@"id"] forKey:@"face"];
            [DataService requestWeixinAPI:resetPassword parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                [self hideHud];
                NSLog(@"重置密码返回的信息：%@",result);
                NSDictionary * dic = (NSDictionary *)result;
                if ([dic[@"status"] boolValue]) {
                    image.image = img;
                    [self showHint:@"修改头像成功"];
                    //修改本地缓存
                    [_infoDic setValue:iconPath forKey:@"path"];
                    [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:_infoDic] Key:[NSString stringWithFormat:@"xd%@",[LVTools mToString: [kUserDefault objectForKey:kUserId]]]];
                    [kUserDefault setObject:iconPath forKey:KUserIcon];
                    [kUserDefault synchronize];
                }
                else{
                    [self showHint:@"修改头像失败"];
                }
            }];

        } else {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:
                                    @"请重试" delegate:nil cancelButtonTitle:@"确 定" otherButtonTitles: nil];
            [alertView show];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
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
