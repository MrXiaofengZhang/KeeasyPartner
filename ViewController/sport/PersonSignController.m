//
//  PersonSignController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/3/21.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "PersonSignController.h"
#import "ZHTeamDetaillCell.h"
#import "StateController.h"
#import "GetMatchListModel.h"
#import "AppDelegate.h"
@interface PersonSignController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UIButton *selectBtn;
    UITextField *partmentTf;//学院
    UITextField *hospatolTf;//系
    UIButton *btn;
    UITextField *_tempTextField;
    CGRect _preFrame;
}
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation PersonSignController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    [self.view addSubview:self.mTableView];
    btn =[[UIButton alloc] initWithFrame:CGRectMake(0, self.mTableView.bottom, BOUNDS.size.width, 44.0)];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    btn.enabled = NO;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(bomingOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)keyBoardAppear:(NSNotification *)notification {
    
    AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    double keyboardHeight = keyboardRect.size.height;
    CGRect rc0 = CGRectZero;
    
        rc0 = [_tempTextField.superview convertRect:_tempTextField.frame toView:ap.window];
        
    
    if (rc0.origin.y+rc0.size.height > UISCREENHEIGHT-keyboardHeight) {
        float offsetY = (rc0.origin.y+rc0.size.height) - (UISCREENHEIGHT-keyboardHeight);
        CGRect r = _mTableView.frame;    //view为textField所在需要调整的view
        _preFrame = r;      //记录大小以便调整回来
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        r.origin.y = r.origin.y - offsetY;
        _mTableView.frame = r;   //调整view的y值
        [UIView commitAnimations];
    }
}


- (void)keyBoardHide:(NSNotification *)notification {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        _mTableView.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64-44);   //
        [UIView commitAnimations];
}

- (void)keyBoardChangeFrame:(NSNotification *)notification {
    
}


- (void)bomingOnClick{
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.matchInfo.id forKey:@"matchId"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    if (partmentTf.text.length==0) {
    if ([self.matchInfo.needAcademic boolValue]) {
        [self showHint:@"学院信息为必填项"];
        return;
    }
        }
    else{
        [dic setValue:partmentTf.text forKey:@"academic"];
    }
    if (hospatolTf.text.length == 0) {
        if ([self.matchInfo.needDepartment boolValue]) {
            [self showHint:@"系别信息为必填项"];
            return;
        }
    }
    else{
         [dic setValue:hospatolTf.text forKey:@"department"];
    }
    
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:singleSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            [WCAlertView showAlertWithTitle:@"✅报名成功" message:@"你已报名成功，系统审核成功后会在消息中心通知您" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                //
                //通知球队成员
                
                self.chuanBlock(nil);
                [self.navigationController popViewControllerAnimated:YES];
            } cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
        }
        else{
            if (result[@"info"]) {
                [self showHint:result[@"info"]];
            }
            else{
            [self showHint:ErrorWord];
            }
        }
    }];
}
#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0-44.0) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 80)];
        UIButton *protocolBtn = [[UIButton alloc] initWithFrame:CGRectMake((BOUNDS.size.width-200)/2.0, 20, 200, 40)];
        [protocolBtn setTitle:@"《校动平台赛事免责确认书》" forState:UIControlStateNormal];
        protocolBtn.titleLabel.font = Btn_font;
        [protocolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [protocolBtn addTarget:self action:@selector(protocolClick) forControlEvents:UIControlEventTouchUpInside];
        
        [bottomView addSubview:protocolBtn];
        selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(protocolBtn.left-20, 30, 20, 20)];
        [selectBtn setImage:[UIImage imageNamed:@"selectCheck"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"selecedCheck"] forState:UIControlStateSelected];
        [selectBtn addTarget:self action:@selector(selectonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:selectBtn];
        _mTableView.tableFooterView = bottomView;
    }
    return _mTableView;
}
//系
- (UITextField*)getHospatolTf{
    if (hospatolTf == nil) {
        hospatolTf = [[UITextField alloc] initWithFrame:CGRectMake(BOUNDS.size.width*.36, 0, 150, 44.0)];
        if([self.matchInfo.needDepartment boolValue]){
            hospatolTf.placeholder = @"必填";
        }
        else{
        hospatolTf.placeholder = @"选填";
        }
        hospatolTf.returnKeyType = UIReturnKeyDone;
        hospatolTf.delegate = self;
    }
    return hospatolTf;
}
//院
- (UITextField*)getPartmentTf{
    if (partmentTf == nil) {
        partmentTf = [[UITextField alloc] initWithFrame:CGRectMake(BOUNDS.size.width*.36, 0, 150, 44.0)];
        if([self.matchInfo.needAcademic boolValue]){
            partmentTf.placeholder = @"必填";
        }
        else{
        partmentTf.placeholder = @"选填";
        }
        partmentTf.returnKeyType = UIReturnKeyNext;
        partmentTf.delegate = self;
    }
    return partmentTf;
}

- (void)selectonClick:(UIButton*)sender{
    sender.selected = !sender.selected;
    btn.enabled = [self canSign];
}
- (void)protocolClick{
    StateController *vc =[[StateController alloc] init];
    vc.chuanBlock = ^(NSArray *arr){
        selectBtn.selected = YES;
        if ([self canSign]) {
            btn.selected = YES;
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (BOOL)canSign{
    if (selectBtn.selected) {
        //四种情况下可以报名
        if(![self.matchInfo.needAcademic boolValue]&&![self.matchInfo.needDepartment boolValue]){
            [btn setBackgroundColor:SystemBlue];
            return YES;
        }
        if ([self.matchInfo.needAcademic boolValue]&&![self.matchInfo.needDepartment boolValue]) {
            if (partmentTf.text.length>0) {
                [btn setBackgroundColor:SystemBlue];
                return YES;
            }
        }
        if (![self.matchInfo.needAcademic boolValue]&&[self.matchInfo.needDepartment boolValue]) {
            if (hospatolTf.text.length>0) {
                [btn setBackgroundColor:SystemBlue];
                return YES;
            }
        }
        if ([self.matchInfo.needAcademic boolValue]&&[self.matchInfo.needDepartment boolValue]) {
            if (partmentTf.text.length>0&&hospatolTf.text.length>0) {
                [btn setBackgroundColor:SystemBlue];
                return YES;
            }
            
        }
        return NO;
    }
    else{
        [btn setBackgroundColor:[UIColor lightGrayColor]];
        
    }
    return NO;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==4) {
        return 4;
    }
    else{
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHTeamDetaillCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCell"];
    if (cell == nil) {
        cell = [[ZHTeamDetaillCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"personCell"];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"运动类型:";
        NSString *sportType  =[LVTools mToString: self.matchInfo.type];
        if ([sportType isEqualToString:@"1"]) {
            cell.detailTextLabel.text = @"篮球";
        }
        else if([sportType isEqualToString:@"2"]){
            cell.detailTextLabel.text = @"足球";
        }
        else{
            cell.detailTextLabel.text = @"其它";
        }
        
    }
    else if (indexPath.section == 1){
        cell.textLabel.text = @"昵称:";
        cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:kUserName]];
    }
    else if (indexPath.section == 2){
        cell.textLabel.text = @"真实姓名:";
        cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserRealName]];
    }
    else if (indexPath.section == 3){
        cell.textLabel.text = @"手机号:";
        cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserMobile]];
    }
    else{
        if (indexPath.row==0) {
            cell.textLabel.text = @"学校:";
            cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserSchoolName]];
        }
        else if(indexPath.row==1){
            cell.textLabel.text = @"入学年份:";
            cell.detailTextLabel.text = [LVTools mToString:[kUserDefault objectForKey:KUserYear]];
        }
        else if (indexPath.row==2){
            cell.textLabel.text = @"院:";
            cell.detailTextLabel.text = @"";
            [cell.contentView addSubview:[self getPartmentTf]];
        }
        else{
            cell.textLabel.text = @"系:";
            cell.detailTextLabel.text = @"";
            [cell.contentView addSubview:[self getHospatolTf]];
        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0f;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:partmentTf]) {
        [hospatolTf becomeFirstResponder];
    }
    else{
        [self.view endEditing:YES];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _tempTextField = textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    btn.enabled = [self canSign];
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
