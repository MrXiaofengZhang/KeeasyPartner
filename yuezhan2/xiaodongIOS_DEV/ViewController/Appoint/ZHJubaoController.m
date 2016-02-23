//
//  ZHJubaoController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHJubaoController.h"

#define kLIAOJIEXIANGQING_BTN_TITLE_COLOR ([UIColor redColor])

#define kTOUSU_CELL_LABEL_TAG 101
#define kTOUSU_CELL_BTN_TAG 102

#define kTOUSU_CELL_HEIGHT 44
#define kTOUSU_CELL_ROWS 5

@interface ZHJubaoController ()<UITextViewDelegate>

@end

@implementation ZHJubaoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.title = @"举报";
    self.view.backgroundColor = BackGray_dan;
    [self navgationBarLeftReturn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(faSong)];
    [self loadTouSuView];
}
- (void)loadTouSuView{
    UILabel *titleLb =[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 20)];
    titleLb.backgroundColor = [UIColor clearColor];
    titleLb.text = @"请选择举报原因";
    titleLb.font = Content_lbfont;
    titleLb.textColor = Content_lbColor;
    [self.view addSubview:titleLb];
    // 选择投诉原因
    _touSuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, BOUNDS.size.width, kTOUSU_CELL_HEIGHT*4) style:UITableViewStylePlain];
    _touSuTableView.backgroundColor = [UIColor whiteColor];
    _touSuTableView.delegate = self;
    _touSuTableView.dataSource = self;
    _touSuTableView.scrollEnabled = NO;
    [self.view addSubview:_touSuTableView];
    
    // 投诉原因
    _touSuReasonArr = @[@"色情低俗",@"广告骚扰",@"政治敏感",@"违法(暴力恐怖/违禁品等)"];
    
    //初始化的时候 如果下面的路径不存在该文件  那么初始化的数组就是空的
//    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/reason.txt"];
//    
//    NSFileManager *fileManger = [NSFileManager defaultManager];
//    
//    if ([fileManger fileExistsAtPath:filePath]) {
//        
//        _selectReasonArr = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//        
//    }else{
//        
//        _selectReasonArr = [[NSMutableArray alloc] initWithCapacity:0];
//    }
    _selectReasonArr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithLong:0], nil];
    [self createContentView];
}
- (void)createContentView{
    if(_ContentView == nil){
        
        UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0,_touSuTableView.bottom+40, BOUNDS.size.width, 140)];
        back.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:back];
        UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(0, 30, 80, 40)];
        lab.text = @"补充说明:";
        [back addSubview:lab];
        UILabel *titleLb =[[UILabel alloc] initWithFrame:CGRectMake(0, back.top-20, 80, 20)];
        titleLb.backgroundColor = [UIColor clearColor];
        titleLb.text = @"请举证(选填)";
        titleLb.font = Content_lbfont;
        titleLb.textColor = Content_lbColor;
        [self.view addSubview:titleLb];
        _ContentView = [[UITextView alloc] initWithFrame:CGRectMake(lab.right, 20, BOUNDS.size.width-lab.right-2*mygap, 100)];
        _ContentView.layer.masksToBounds = YES;
        _ContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _ContentView.layer.borderWidth = 0.3;
        _ContentView.layer.cornerRadius = 5.0;
        _ContentView.delegate = self;
        UILabel *holdlab = [[UILabel alloc] initWithFrame:CGRectMake(_ContentView.width-100, _ContentView.height-20, 100, 20)];
        holdlab.text = @"(最多50个字)";
        holdlab.tag = 100;
        holdlab.font = Content_lbfont;
        holdlab.textColor = [UIColor lightGrayColor];
        [_ContentView addSubview:holdlab];
        [back addSubview:_ContentView];
    }
   
}
#pragma mark - 导航栏按钮方法 -

- (void)faSong{
    [self.view endEditing:YES];
//    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/reason.txt"];
//    [_selectReasonArr writeToFile:filePath atomically:YES];
//    NSLog(@"Save__%@",_selectReasonArr);
    [WCAlertView showAlertWithTitle:nil message:@"确定举报么" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
            [self addreport];
        }
    } cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
}
- (void)addreport{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setObject:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setObject:self.reportId forKey:@"reportId"];
    if (self.commenentId) {
        [dic setValue:self.commenentId forKey:@"commentId"];
    }
    [dic setObject:_ContentView.text forKey:@"content"];
    if (_selectReasonArr.count>0) {
    [dic setValue:_selectReasonArr[0] forKey:@"reportType"];
    }
    [DataService requestWeixinAPI:xdAddReport parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        [self hideHud];
        if ([resultDic[@"status"] boolValue])
        {
            [self performSelector:@selector(alertShowAction) withObject:self afterDelay:0.5];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];

}
- (void)alertShowAction {
    [WCAlertView showAlertWithTitle:@"已提交" message:@"您的举报已经提交到后台等待处理,处理结果将通过本平台反馈至您的信息中心,感谢您的支持." customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        //
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } cancelButtonTitle:@"确定" otherButtonTitles: nil];
}

- (void)backOff{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate  -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kTOUSU_CELL_HEIGHT;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //多选
    //设置 单元格选中样式
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        BOOL isExist = NO;
//        
//        for (NSNumber *number in _selectReasonArr) {
//            
//            int selectedIndex = [number intValue];
//            
//            if (selectedIndex == indexPath.row) {
//                isExist = YES;
//            }else{
//                
//            }
//        }
//        // 获取到我所点击的单元格对象
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        
//        if (isExist) {
//            
//            NSNumber *number = [NSNumber numberWithLong:indexPath.row];
//            [_selectReasonArr removeObject:number];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            
//        }else{
//            
//            NSNumber *number = [NSNumber numberWithLong:indexPath.row];
//            [_selectReasonArr addObject:number];
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
    //单选
    //判断是否存在
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
            BOOL isExist = NO;
    
            for (NSNumber *number in _selectReasonArr) {
    
                int selectedIndex = [number intValue];
    
                if (selectedIndex == indexPath.row) {
                    isExist = YES;
                }else{
    
                }
            }
    if(isExist){
        //不处理
    }
    else{
        //移除并刷新
        [_selectReasonArr removeAllObjects];
        NSNumber *number = [NSNumber numberWithLong:indexPath.row];
        [_selectReasonArr addObject:number];
        [_touSuTableView reloadData];
    }
    
}


#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return kTOUSU_CELL_ROWS;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIndetifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
        cell.backgroundColor=[UIColor clearColor];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    // 遍历 选中的数组 的内容
    for (NSNumber *number in _selectReasonArr) {
        
        if (indexPath.row == [number intValue]) {
            
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
    }
    
    cell.textLabel.text = [_touSuReasonArr objectAtIndex:indexPath.row];
    
    
    return cell;
}
#pragma mark UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([@"\n" isEqualToString:text] == YES) {
        [textView resignFirstResponder];
        
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    UIView *holdView = [textView viewWithTag:100];
    if (textView.text.length == 0) {
    holdView.hidden = YES;
    }
    //开始编辑输入框的时候，软键盘出现，执行此事件
    int offset = _touSuTableView.bottom+40+20 + textView.height - (self.view.frame.size.height - 246.0);//键盘高度216
    
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    UIView *holdView = [textView viewWithTag:100];
    if (textView.text.length == 0) {
    holdView.hidden = NO;
    }
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    if (iOS7) {
        self.view.frame =CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    }
    else{
        self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
