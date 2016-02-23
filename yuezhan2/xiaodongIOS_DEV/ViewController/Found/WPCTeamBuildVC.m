//
//  WPCTeamBuildVC.m
//  yuezhan123
//
//  Created by admin on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCTeamBuildVC.h"
#import "WPCSportsTypeChooseVC.h"
#import "AppDelegate.h"
#import "ZHupdateImage.h"
#import "TeamModel.h"
#import "SchoolsController.h"

@interface WPCTeamBuildVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *sportcodeString;
    NSString *schoolId;
}

@property (nonatomic, strong)UITableView *tableview;
@property (nonatomic, strong)UITextView *textview1;//口号d
@property (nonatomic, strong)UILabel *placeholderLabel;
@property (nonatomic, strong)UITextField *textField1;//战队名称
@property (nonatomic, strong)UITextField *textField2;//组建人
@property (nonatomic, strong)UITextField *textField3;//手机号
@property (nonatomic, strong)UITextField *textField4;//常出没地
@property (nonatomic, strong)UITextField *textField5;//已加入的俱乐部
@property (nonatomic, strong)UITextField *textField6;//学校
@property (nonatomic, strong)UITextField *textField7;//院
@property (nonatomic, strong)UITextField *textField8;//系
@property (nonatomic, strong)UITextField *textField9;//公司名称或职业

@property (nonatomic, strong)UILabel *contentLab1;//运动类型
@property (nonatomic, strong)UIView *footerview;

@property (nonatomic, strong)UIImageView *bigImg;
@property (nonatomic, strong)UITextField *tempTextField;
@property (nonatomic, strong)UITextView *tempTextView;
@property (nonatomic, assign)CGRect preFrame;
@property (nonatomic, assign)BOOL viewHasMove;
@property (nonatomic, assign)BOOL tfOrtv;//默认yes，代表是textfield
@property (nonatomic, assign)BOOL isStudent;
@property (nonatomic, assign)BOOL isOthers;

@property (nonatomic, strong)UIButton *stuBtn;
@property (nonatomic, strong)UIButton *otherBtn;
@property (nonatomic, strong)UILabel *statusLab;

@property (nonatomic, strong)UIView *sectionheader;

@end

@implementation WPCTeamBuildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _tfOrtv = YES;
    _isStudent = YES;
    _isOthers = NO;
    [self navgationBarLeftReturn];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self initialInterface];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyBoardAppear:(NSNotification *)notification {
    
    AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    double keyboardHeight = keyboardRect.size.height;
    CGRect rc0 = CGRectZero;
    if (_tfOrtv) {
        rc0 = [_tempTextField.superview convertRect:_tempTextField.frame toView:ap.window];
     
    } else {
        rc0 = [_tempTextView.superview convertRect:_tempTextView.frame toView:ap.window];
       
    }
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


- (void)keyBoardHide:(NSNotification *)notification {
    if (_viewHasMove) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        _tableview.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64);   //
        [UIView commitAnimations];
        _viewHasMove = NO;
    }
}

- (void)keyBoardChangeFrame:(NSNotification *)notification {
    
}

- (void)initialInterface {
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64) style:UITableViewStylePlain];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 0.5)];
    view.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    _tableview.tableFooterView = view;
    [self.view addSubview:_tableview];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmBuildTheTeam)];
    
}
#pragma mark [上传图片]
-(void)selectPickerImage:(UIImage *)image
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self showHudInView:self.view hint:@"图片上传中...."];
    NSData *imageData=UIImageJPEGRepresentation(image, kCompressqulitaty);
    if (imageData==nil) {
        imageData=UIImagePNGRepresentation(image);
    }
    NSMutableDictionary *dic=[LVTools getTokenApp];
    ZHupdateImage *update=[[ZHupdateImage alloc]init];
    [update requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"TEAM_LOGO"} WithType:nil WithData:imageData With:^(NSDictionary * result) {
        [self hideHud];
        NSLog(@"%@",result);
        if ([[result objectForKey:@"status"] boolValue]) {
            [self buildTeamRequestWithPath:result[@"data"][@"id"] AndUrl:[result objectForKey:@"url"]];
        } else {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:
                                    @"请重试" delegate:nil cancelButtonTitle:@"确 定" otherButtonTitles: nil];
            [alertView show];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        NSLog(@"result=%@",result);
    }];
}

- (void)buildTeamRequestWithPath:(NSString*)path AndUrl:(NSString*)url{
    
    [self showHudInView:self.view hint:LoadingWord];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"creatorId"];
    [dic setValue:sportcodeString forKey:@"sportsType"];
    [dic setValue:_textField1.text forKey:@"teamName"];
    [dic setValue:[kUserDefault objectForKey:KUserMobile] forKey:@"creatorMobile"];
    [dic setValue:path forKey:@"teamFace"];
    //[dic setValue:@"" forKey:@"province"];
    //[dic setValue:@"北京" forKey:@"provinceMeaning"];
    //[dic setValue:@"" forKey:@"city"];
    //[dic setValue:@"北京" forKey:@"cityMeaning"];
    //[dic setValue:@"" forKey:@"area"];
    //[dic setValue:@"朝阳区" forKey:@"areaMeaning"];
//    if(self.isStudent){
//    [dic setValue:StudentType forKey:@"teamType"];
//    }
//    else{
//        [dic setValue:AdultType forKey:@"teamType"];
//    }
    //[dic setValue:_textField6.text forKey:@"university"];
    [dic setValue:_textField3.text forKey:@"creatorMobile"];
    [dic setValue:_textview1.text forKey:@"slogan"];
    //[dic setValue:_textField9.text forKey:@"introduce"];
    [dic setValue:now forKey:@"createtime"];
    //[dic setValue:[kUserDefault valueForKey:kUserName] forKey:@"captainName"];
    //[dic setValue:now forKey:@"lmodifytime"];
    //[dic setValue:@"" forKey:@"lmodifyuser"];
    [dic setValue:[kUserDefault objectForKey:kLocationlng] forKey:@"longitude"];
    [dic setValue:[kUserDefault objectForKey:kLocationLat] forKey:@"latitude"];
    [dic setValue:[kUserDefault objectForKey:KUserSchoolId] forKey:@"schoolId"];//校
    [dic setValue:_textField7.text forKey:@"academic"];//院
    [dic setValue:_textField8.text forKey:@"department"];//系
    [dic setValue:_textField4.text forKey:@"often"];//常出没地
    [dic setValue:_textField5.text forKey:@"club"];
    NSLog(@"%@",dic);
    NSString *urlstring = nil;
    if ([self.title isEqualToString:@"组建球队"]) {
        urlstring = addTeam;
    } else if ([self.title isEqualToString:@"修改球队信息"]) {
        [dic setValue:self.idstring forKey:@"teamId"];
        urlstring = modifyTeam;
    }
    
    request = [DataService requestWeixinAPI:urlstring parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"%@",result);
        if ([result[@"status"] boolValue]) {
            if ([self.title isEqualToString:@"组建球队"]) {
                [self showHint:@"组建队伍成功"];
                NSArray *arr = @[];
                self.chuanBlock(arr);
            } else if ([self.title isEqualToString:@"修改球队信息"]) {
                [self showHint:@"修改球队成功"];
                NSArray *arr = @[];
                self.chuanBlock(arr);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            if(result[@"info"]){
                [self showHint:result[@"info"]];
            }
            else{
            [self showHint:ErrorWord];
            }
        }
    }];
}

- (void)confirmBuildTheTeam {
    [self.view endEditing:YES];
    //逻辑判断
    if (_contentLab1.text.length == 0) {
        [self showHint:@"请选择运动类型"];
        return;
    }
    if (_textField1.text.length == 0) {
        [self showHint:@"请填写球队名称"];
        return;
    }
    if (_textField1.text.length>16) {
        [self showHint:@"球队名字不能超过16个字符"];
        return;
    }
    if (_textview1.text.length == 0) {
        [self showHint:@"请填写球队口号"];
        return;
    }
    if (_textField3.text.length == 0) {
        [self showHint:@"请填写您的联系电话"];
        return;
    }
    if (self.isStudent) {
        if (_textField6.text.length == 0) {
            [self showHint:@"请填写学校名称"];
            return;
        }
    }
    if ([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]) {
        [self selectPickerImage:self.bigImg.image];
    }
    else{
        [self showHint:@"请先登录"];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    CGFloat sectionHeaderHeight = 20*propotion;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (void)studentClick {
    _isStudent = YES;
    _isOthers = NO;
    _stuBtn.selected = YES;
    _otherBtn.selected = NO;
    [_tableview reloadSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)otherClick {
    _isStudent = NO;
    _isOthers = YES;
    _stuBtn.selected = NO;
    _otherBtn.selected = YES;
    [_tableview reloadSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationNone];
}

- (UILabel *)statusLab {
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 35*propotion, 250*propotion, 40*propotion)];
        NSString *str = @"身份:＊";
        _statusLab.textAlignment = NSTextAlignmentRight;
        _statusLab.font = Btn_font;
        _statusLab.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(3, 1) andColor:[UIColor redColor]];
    }
    return _statusLab;
}

- (UIButton *)stuBtn {
    if (!_stuBtn) {
        _stuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stuBtn.frame = CGRectMake(_statusLab.right+20*propotion, 35*propotion, 112*propotion, 40*propotion);
        [_stuBtn setTitle:@"学生" forState:UIControlStateNormal];
        _stuBtn.layer.cornerRadius = _stuBtn.height/2;
        _stuBtn.layer.masksToBounds = YES;
        [_stuBtn.titleLabel setFont:Btn_font];
        [_stuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_stuBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_stuBtn setBackgroundImage:[LVTools buttonImageFromColor:NavgationColor withFrame:_stuBtn.bounds] forState:UIControlStateSelected];
        [_stuBtn setBackgroundImage:[LVTools buttonImageFromColor:[UIColor whiteColor] withFrame:_stuBtn.bounds] forState:UIControlStateNormal];
        [_stuBtn addTarget:self action:@selector(studentClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stuBtn;
}

- (UIButton *)otherBtn {
    if (!_otherBtn) {
        _otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _otherBtn.frame = CGRectMake(_stuBtn.right+40*propotion, 35*propotion, 112*propotion, 40*propotion);
        [_otherBtn setTitle:@"其他" forState:UIControlStateNormal];
        _otherBtn.layer.cornerRadius = _otherBtn.height/2;
        _otherBtn.layer.masksToBounds = YES;
        [_otherBtn.titleLabel setFont:Btn_font];
        [_otherBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_otherBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_otherBtn setBackgroundImage:[LVTools buttonImageFromColor:NavgationColor withFrame:_otherBtn.bounds] forState:UIControlStateSelected];
        [_otherBtn setBackgroundImage:[LVTools buttonImageFromColor:[UIColor whiteColor] withFrame:_otherBtn.bounds] forState:UIControlStateNormal];
        [_otherBtn addTarget:self action:@selector(otherClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherBtn;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 6) {
        if (_isStudent == YES) {
            return 3;
        }
        if (_isOthers == YES) {
            return 1;
        }
        return 0;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 6) {
        //return 108*propotion;
        return 20*propotion;
    } else {
        return 20*propotion;
    }
}

- (UIView *)sectionheader {
    if (!_sectionheader) {
        _sectionheader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 20*propotion)];
        _sectionheader.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    }
    return _sectionheader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 6) {
        if (self.sectionheader.subviews.count == 0) {
//            [self.sectionheader addSubview:self.statusLab];
//            [self.sectionheader addSubview:self.stuBtn];
//            [self.sectionheader addSubview:self.otherBtn];
        }
        return self.sectionheader;
    } else {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 80*propotion;
            break;
        case 1:
            return 600*propotion;
            break;
        case 2:
            return 80*propotion;
            break;
        case 3:
            return 80*propotion;
            break;
        case 4:
            return 80*propotion;
            break;
        case 5:
            return 80*propotion;
            break;
        case 6:
            if (_isStudent == NO && _isOthers == NO) {
                return 0;
            }
            if (_isStudent == YES) {
                return 80*propotion;
            }
            if (_isOthers == YES) {
                return 80*propotion;
            }
            break;
        default:
            return 0;
            break;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    switch (indexPath.section) {
        case 0:
        {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250*propotion, 80*propotion)];
            NSString *str = @"运动类型:＊";
            lab.font = Btn_font;
            lab.textAlignment = NSTextAlignmentRight;
            lab.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(5, 1) andColor:[UIColor redColor]];
            [cell.contentView addSubview:lab];
            if (_contentLab1==nil) {
            _contentLab1 = [[UILabel alloc] initWithFrame:CGRectMake(250*propotion+5, 0, 300*propotion, 80*propotion)];
            _contentLab1.font = Btn_font;
            }
            [cell.contentView addSubview:_contentLab1];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-20-(80*propotion-20), 10, 80*propotion-20, 80*propotion-20)];
            img.image = [UIImage imageNamed:@"arrow"];
            [cell.contentView addSubview:img];
            if (self.model) {

                _contentLab1.text =[LVTools convertSportFromCode:[LVTools mToString: self.model.sportsType]];

                NSString *path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
                NSArray *arr = [NSArray arrayWithContentsOfFile:path];
                for (int i = 0; i < arr.count; i ++) {
                    if ([arr[i][@"sport2"] isEqualToString:self.model.sportsType]) {
                        _contentLab1.text = arr[i][@"name"];
                    }
                }
            }
        }
            break;
        case 1:
        {
            UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250*propotion, 80*propotion)];
            NSString *str = @"球队名称:＊";
            lab1.font = Btn_font;
            lab1.textAlignment = NSTextAlignmentRight;
            lab1.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(5, 1) andColor:[UIColor redColor]];
            [cell.contentView addSubview:lab1];
            
            UIView *firstLine = [[UIView alloc] initWithFrame:CGRectMake(223*propotion, 80*propotion, UISCREENWIDTH-223*propotion, 0.5)];
            firstLine.backgroundColor = lightColor;
            [cell.contentView addSubview:firstLine];
            if (_textField1 == nil) {
            _textField1 = [[UITextField alloc] initWithFrame:CGRectMake(250*propotion+5, 5, UISCREENWIDTH-255*propotion-20, 80*propotion-10)];
            _textField1.font = Btn_font;
            _textField1.delegate = self;
            }
            [cell.contentView addSubview:_textField1];
            if (self.model) {
                _textField1.text =[LVTools mToString: self.model.teamName];
            }

            UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, lab1.bottom+5, 250*propotion, 80*propotion-10)];
            NSString *str2 = @"球队队标:＊";
            lab2.font = Btn_font;
            lab2.textAlignment = NSTextAlignmentRight;
            lab2.attributedText = [LVTools attributedStringFromText:str2 range:NSMakeRange(5, 1) andColor:[UIColor redColor]];
            [cell.contentView addSubview:lab2];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-20-(80*propotion-20), 10+80*propotion, 80*propotion-20, 80*propotion-20)];
            img.image = [UIImage imageNamed:@"arrow"];
            [cell.contentView addSubview:img];
            if (_bigImg ==nil) {
            _bigImg = [[UIImageView alloc] initWithFrame:CGRectMake(269*propotion, 154*propotion, 206*propotion, 206*propotion)];
            }
            _bigImg.userInteractionEnabled = YES;
            _bigImg.image = [UIImage imageNamed:@"applies_plo"];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImg)];
            [_bigImg addGestureRecognizer:tap];
            [cell.contentView addSubview:_bigImg];
            if (self.model) {
                [_bigImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,self.model.path]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            }
            
            UIView *secondLine = [[UIView alloc] initWithFrame:CGRectMake(223*propotion, 378*propotion, UISCREENWIDTH-223*propotion, 0.5)];
            secondLine.backgroundColor = lightColor;
            [cell.contentView addSubview:secondLine];
            
            UILabel *lab3 = [[UILabel alloc] initWithFrame:CGRectMake(0, secondLine.bottom, 250*propotion, 80*propotion)];
            NSString *str3 = @"口号:＊";
            lab3.font = Btn_font;
            lab3.textAlignment = NSTextAlignmentRight;
            lab3.attributedText = [LVTools attributedStringFromText:str3 range:NSMakeRange(3, 1) andColor:[UIColor redColor]];
            [cell.contentView addSubview:lab3];
            if (_textview1==nil) {
            _textview1 = [[UITextView alloc] initWithFrame:CGRectMake(lab3.right+5, secondLine.bottom, UISCREENWIDTH-lab3.right-20, 200*propotion)];
            _textview1.font = Btn_font;
            _textview1.delegate = self;
            }
            [cell.contentView addSubview:_textview1];
            

            if (_placeholderLabel==nil) {
            _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 80, 80*propotion)];
            _placeholderLabel.text = @"(50字以内)";
            _placeholderLabel.font = Btn_font;
            _placeholderLabel.textColor = lightColor;
            }
            [_textview1 addSubview:_placeholderLabel];
            if (self.model) {
                _textview1.text =[LVTools mToString: self.model.slogan];
                _placeholderLabel.hidden = YES;
            }
        }
            break;
        case 2:
        {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250*propotion, 80*propotion)];
            NSString *str = @"球队经理人:＊";
            lab.font = Btn_font;
            lab.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(str.length-1, 1) andColor:[UIColor redColor]];
            lab.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:lab];
            if (_textField2 == nil) {
            _textField2 = [[UITextField alloc] initWithFrame:CGRectMake(lab.right+5, 0, UISCREENWIDTH-lab.right-20, 80*propotion)];
            _textField2.font = Btn_font;
            _textField2.delegate = self;
            }
            [_textField2 setText:[kUserDefault valueForKey:kUserName]];
            _textField2.userInteractionEnabled = NO;
            [cell.contentView addSubview:_textField2];
            
        }
            break;
        case 3:
        {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250*propotion, 80*propotion)];
            NSString *str = @"手机号:＊";
            lab.font = Btn_font;
            lab.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(4, 1) andColor:[UIColor redColor]];
            lab.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:lab];
            if (_textField3==nil) {
                _textField3 = [[UITextField alloc] initWithFrame:CGRectMake(lab.right+5, 0, UISCREENWIDTH-lab.right-20, 80*propotion)];
                _textField3.font = Btn_font;
                _textField3.delegate = self;
            }
            [_textField3 setText:[[kUserDefault valueForKey:KUserMobile] stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
            _textField3.userInteractionEnabled = NO;
            [cell.contentView addSubview:_textField3];
            if (self.model) {
            [_textField3 setText:[[kUserDefault valueForKey:KUserMobile] stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
            }
        }
            break;
        case 4:
        {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220*propotion, 80*propotion)];
            NSString *str = @"常出没地:";
            lab.text = str;
            lab.font = Btn_font;
            lab.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:lab];
            if (_textField4 == nil) {
                _textField4 = [[UITextField alloc] initWithFrame:CGRectMake(250*propotion+5, 0, UISCREENWIDTH-255*propotion-20, 80*propotion)];
                _textField4.font = Btn_font;
                _textField4.delegate = self;
            }
            [cell.contentView addSubview:_textField4];
            if (self.model) {
                _textField4.text =[LVTools mToString: self.model.often];
            }
        }
            break;
        case 5:
        {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220*propotion, 80*propotion)];
            NSString *str = @"所属俱乐部:";
            lab.text = str;
            lab.font = Btn_font;
            lab.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:lab];
            if (_textField5 == nil) {
                _textField5 = [[UITextField alloc] initWithFrame:CGRectMake(250*propotion+5, 0, UISCREENWIDTH-255*propotion-20, 80*propotion)];
                _textField5.font = Btn_font;
                _textField5.delegate = self;
            }
            [cell.contentView addSubview:_textField5];
            if (self.model) {
                _textField5.text =[LVTools mToString:self.model.club];
            }
        }
            break;
        case 6:
        {
            if (_isStudent == YES) {
                if (indexPath.row == 0) {
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250*propotion, 80*propotion)];
                    NSString *str = @"学校:＊";
                    lab.font = Btn_font;
                    lab.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(3, 1) andColor:[UIColor redColor]];
                    lab.textAlignment = NSTextAlignmentRight;
                    [cell.contentView addSubview:lab];
                    
                    if (_textField6 == nil) {
                        _textField6 = [[UITextField alloc] initWithFrame:CGRectMake(lab.right+5, 0, UISCREENWIDTH-lab.right-90*propotion, 79.5*propotion)];
                        _textField6.font = Btn_font;
                        _textField6.enabled = NO;
                        _textField6.text = [kUserDefault objectForKey:KUserSchoolName];
                        _textField6.delegate = self;
                    }
                    [cell.contentView addSubview:_textField6];
                    if (self.model) {
                        _textField6.text = [LVTools mToString:self.model.schoolName];
                    }
                    
//                    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-20-(80*propotion-20), 10, 80*propotion-20, 80*propotion-20)];
//                    img.image = [UIImage imageNamed:@"arrow"];
//                    [cell.contentView addSubview:img];

                }
                if (indexPath.row == 1) {
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220*propotion, 80*propotion)];
                    NSString *str = @"学院:";
                    lab.text = str;
                    lab.font = Btn_font;
                    lab.textAlignment = NSTextAlignmentRight;
                    [cell.contentView addSubview:lab];
                    
                    if (_textField7 == nil) {
                        _textField7 = [[UITextField alloc] initWithFrame:CGRectMake(250*propotion+5, 0, UISCREENWIDTH-255*propotion-90*propotion, 79.5*propotion)];
                        _textField7.font = Btn_font;
                        _textField7.delegate = self;
                    }
                    [cell.contentView addSubview:_textField7];
                    
                    if (self.model) {
                        _textField7.text = [LVTools mToString:self.model.academic];
                    }
                }
                if (indexPath.row == 2) {
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220*propotion, 80*propotion)];
                    NSString *str = @"系别:";
                    lab.text = str;
                    lab.font = Btn_font;
                    lab.textAlignment = NSTextAlignmentRight;
                    [cell.contentView addSubview:lab];
                    
                    if (_textField8 == nil) {
                        _textField8 = [[UITextField alloc] initWithFrame:CGRectMake(250*propotion+5, 0, UISCREENWIDTH-255*propotion-20, 79.5*propotion)];
                        _textField8.font = Btn_font;
                        _textField8.delegate = self;
                    }
                    [cell.contentView addSubview:_textField8];
                    
                    if (self.model) {
                        _textField8.text = [LVTools mToString:self.model.department];
                    }

                }
            }
            if (_isOthers == YES) {
                UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220*propotion, 79.5*propotion)];
                NSString *str = @"公司或职业:";
                lab.text = str;
                lab.font = Btn_font;
                lab.textAlignment = NSTextAlignmentRight;
                [cell.contentView addSubview:lab];
                
                if (_textField9 == nil) {
                    _textField9 = [[UITextField alloc] initWithFrame:CGRectMake(250*propotion+5, 0, UISCREENWIDTH-255*propotion-20, 79.5*propotion)];
                    _textField9.font = Btn_font;
                    _textField9.delegate = self;
                }
                [cell.contentView addSubview:_textField9];
                if (self.model) {
                    _textField9.text = [LVTools mToString:self.model.introduce];
                }
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)changeImg {
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
    _bigImg.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //跳转到运动类型界面
        WPCSportsTypeChooseVC *vc = [[WPCSportsTypeChooseVC alloc] init];
        vc.multipleChoose = NO;
        vc.chuanBlock = ^(NSArray *arr){
            _contentLab1.text = [arr objectAtIndex:0];
        };
        vc.sportCode = ^(NSArray *arr) {
            sportcodeString = [NSString stringWithFormat:@"%@",[arr objectAtIndex:0]];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 6 && indexPath.row == 0) {
//        SchoolsController *vc = [[SchoolsController alloc] init];
//        vc.title = @"大学选择";
//        vc.chuanBlock = ^(NSArray *arr){
//            _textField6.text = arr[0][@"name"];
//            schoolId = arr[0][@"id"];
//        };
//        UINavigationController *navi  =[[UINavigationController alloc] initWithRootViewController:vc];
//        [self presentViewController:navi animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _tempTextField = textField;
    _tfOrtv = YES;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _tfOrtv = NO;
    _tempTextView = textView;
    _placeholderLabel.hidden = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    if (textView.text.length > 0) {
        _placeholderLabel.hidden = YES;
    } else {
        _placeholderLabel.hidden = NO;
    }
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([@"\n" isEqualToString:text] == YES) {
        _placeholderLabel.alpha = 0;
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
