//
//  ZHYingzhanController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHYingzhanController.h"
#import "ZHGenderView.h"

#define BtnWidth  (BOUNDS.size.width-2*mygap*5)/4.0
@interface ZHYingzhanController ()<UITextFieldDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) UISegmentedControl *segCon;
@property (nonatomic,strong) UIView *topView;//个人
@property (nonatomic,strong) UIScrollView *teamTopView;//团队
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UITextField *phoneTf;
@property (nonatomic,strong) UITextField *liuyanTf;
@property (nonatomic,strong) NSMutableArray *teamInfoArray;
@property (nonatomic,assign) NSInteger teamIndex;
@property (nonatomic,strong) NSMutableDictionary *chuanDictionary;
@property (nonatomic,strong) NSString *teamName;
@property (nonatomic,strong) NSString *teamPath;
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic,strong) UITextField *selectedTf;
@end

@implementation ZHYingzhanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BackGray_dan;
    _teamIndex = -1;
    _keyboardHeight = 216.0f;
    [self navgationBarLeftReturn];
    [self loadMyTeamInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
        CGRect keyboardBounds;
        [keyboardBoundsValue getValue:&keyboardBounds];
        //UIEdgeInsets e = UIEdgeInsetsMake(0, 0, keyboardBounds.size.height, 0);
        _keyboardHeight = keyboardBounds.size.height;
        
        
        //开始编辑输入框的时候，软键盘出现，执行此事件
        //CGRect rc0 = [textField.superview convertRect:textField.frame toView:self.view];等效
        CGRect rc1 = [self.view convertRect:_selectedTf.frame fromView:_selectedTf.superview];
        int offset = rc1.origin.y + _selectedTf.height - (self.view.frame.size.height - _keyboardHeight);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        NSLog(@"%d",offset);
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset >=0)
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];

//        [[self tableView] setScrollIndicatorInsets:e];
//        [[self tableView] setContentInset:e];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    }
#endif
}

- (void)createUI{
    [self.view addSubview:self.teamTopView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.segCon.superview==nil) {
        [self.navigationController.navigationBar addSubview:self.segCon];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.segCon.superview) {
        [self.segCon removeFromSuperview];
    }
}

#pragma mark -- 获取自己战队信息

- (void)loadMyTeamInfo {
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
    [DataService requestWeixinAPI:getCreateTeam parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"%@",result);
        NSLog(@"1");
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            _teamInfoArray = [NSMutableArray arrayWithArray:result[@"createTeamList"]];
            [self createUI];
        } else {
            [self showHint:@"页面加载失败，请重试"];
        }
    }];
}

#pragma mark Getter
- (UISegmentedControl*)segCon{
    if (_segCon == nil) {
        _segCon = [[UISegmentedControl alloc] initWithItems:@[@"个人应战",@"战队应战"]];
        _segCon.frame = CGRectMake((BOUNDS.size.width-200)/2.0, 7, BOUNDS.size.width*0.6, 30);
        _segCon.selectedSegmentIndex = 0;
        _segCon.tintColor = [UIColor colorWithRed:0.831f green:0.933f blue:0.996f alpha:1.00f];
        [_segCon addTarget:self action:@selector(changeOnClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _segCon;
}
- (void)changeOnClick:(UISegmentedControl*)seg{
    if (seg.selectedSegmentIndex == 0) {
        _topView.hidden = NO;
        _teamTopView.scrollEnabled = NO;
    }
    else{
        _topView.hidden = YES;
        _teamTopView.scrollEnabled = YES;
    }
}

- (UIView*)topView{
    if (_topView == nil) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, mygap*2, BOUNDS.size.width, BtnWidth+20)];
        _topView.backgroundColor = [UIColor whiteColor];
        [self initPerson];
    }
    return _topView;
}
- (UIScrollView*)teamTopView{
    if (_teamTopView == nil) {
        _teamTopView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mygap*2, BOUNDS.size.width, BtnWidth+20)];
        _teamTopView.backgroundColor = [UIColor whiteColor];
        _teamTopView.showsHorizontalScrollIndicator = NO;
        [self initTeam];
    }
    return _teamTopView;
}
- (UIView*)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _teamTopView.bottom+mygap*2, BOUNDS.size.width, 200)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, 20, BOUNDS.size.width-2*mygap*2, 30)];
        lab.text  = @"确定参加本次应战?";
        [_bottomView addSubview:lab];
        [_bottomView addSubview:self.phoneTf];
        [_bottomView addSubview:self.liuyanTf];
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setFrame:CGRectMake(100, _liuyanTf.bottom+20, 50, 30)];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setBackgroundColor:BackGray_dan];
        cancel.layer.masksToBounds = YES;
        cancel.layer.cornerRadius = 2.0;
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancelOnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:cancel];
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [okBtn setFrame:CGRectMake(BOUNDS.size.width-100-50, _liuyanTf.bottom+20, 50, 30)];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        [okBtn setBackgroundColor:NavgationColor];
        okBtn.layer.masksToBounds = YES;
        okBtn.layer.cornerRadius = 2.0;
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okOnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:okBtn];
    }
    return _bottomView;
}
- (void)cancelOnClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)okOnClick{
    
    NSLog(@"发布");
    [self.view endEditing:YES];
    NSDictionary *dic = [LVTools getTokenApp];
    if (_segCon.selectedSegmentIndex == 0) {
        [dic setValue:[kUserDefault valueForKey:kUserName] forKey:@"username"];
    } else {
        if (!_teamInfoArray) {
            [self showHint:@"球队列表请求失败"];
            return;
        }
        if (_teamInfoArray.count == 0) {
            [self showHint:@"您还没创建自己的球队"];
            return;
        }
        if (_teamIndex == -1) {
            [self showHint:@"战队报名请选择战队"];
            return;
        }
        [dic setValue:_teamInfoArray[_teamIndex][@"id"] forKey:@"teamId"];
        [dic setValue:_teamInfoArray[_teamIndex][@"captainName"] forKey:@"username"];
        [dic setValue:_teamInfoArray[_teamIndex][@"sportsType"] forKey:@"sportsType"];
    }
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
    [dic setValue:self.idString forKey:@"applyId"];
    [dic setValue:[LVTools mToString:_phoneTf.text] forKey:@"mobile"];
    [dic setValue:[LVTools mToString:_liuyanTf.text] forKey:@"remark"];
    NSLog(@"dic ===== %@",dic);
    [self showHudInView:self.view hint:@"应战中"];
    [DataService requestWeixinAPI:addPlayReply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"ying zhan result == %@",result);
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            _chuanDictionary = [[NSMutableDictionary alloc] initWithDictionary:result[@"replyList"][0]];
            if (_segCon.selectedSegmentIndex == 1) {
                [_chuanDictionary setValue:_teamInfoArray[_teamIndex][@"teamName"] forKey:@"teamName"];
                [_chuanDictionary setValue:_teamInfoArray[_teamIndex][@"iconPath"] forKey:@"teamPath"];
            } else {
                [_chuanDictionary setValue:[kUserDefault valueForKey:KUserIcon] forKey:@"iconPath"];
            }
            NSArray *arr = [NSArray arrayWithObject:_chuanDictionary];
            self.chuanBlock(arr);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:@"应战失败，请重试"];
        }
    }];
}
- (UITextField*)phoneTf{
    if (_phoneTf == nil) {
        _phoneTf = [[UITextField alloc] initWithFrame:CGRectMake(mygap*2, 50, BOUNDS.size.width-2*mygap*2, 40.0)];
        _phoneTf.layer.masksToBounds = YES;
        _phoneTf.layer.cornerRadius = 5.0;
        _phoneTf.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _phoneTf.layer.borderWidth = 0.3;
        UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        lab.text = @" 电话:";
        lab.font = Btn_font;
        lab.textColor = [UIColor lightGrayColor];
        lab.textAlignment = NSTextAlignmentLeft;
        [lab sizeToFit];
        _phoneTf.leftViewMode = UITextFieldViewModeAlways;
        _phoneTf.leftView = lab ;
        _phoneTf.placeholder = @"(选填)";
        _phoneTf.returnKeyType = UIReturnKeyDone;
        _phoneTf.text =[LVTools mToString: [kUserDefault objectForKey:KUserMobile]];
        _phoneTf.delegate = self;
    }
    return _phoneTf;
}
- (UITextField*)liuyanTf{
    if (_liuyanTf == nil) {
        _liuyanTf = [[UITextField alloc] initWithFrame:CGRectMake(mygap*2, _phoneTf.bottom+mygap*2, BOUNDS.size.width-2*mygap*2, 40)];
        _liuyanTf.layer.masksToBounds = YES;
        _liuyanTf.layer.cornerRadius = 5.0;
        _liuyanTf.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _liuyanTf.layer.borderWidth = 0.3;
        _liuyanTf.returnKeyType = UIReturnKeyDone;
        UILabel *lab =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        lab.text = @" 给他留言:";
        lab.font = Btn_font;
        lab.textColor = [UIColor lightGrayColor];
        lab.textAlignment = NSTextAlignmentLeft;
        [lab sizeToFit];
        _liuyanTf.leftViewMode = UITextFieldViewModeAlways;
        _liuyanTf.leftView = lab ;
        _liuyanTf.placeholder = @"说点什么吧";
        _liuyanTf.delegate = self;
    }
    return _liuyanTf;
}
- (void)initPerson{
    UIImageView *headV = [[UIImageView alloc] initWithFrame:CGRectMake(mygap*2, mygap*2, 80, 80)];
    [headV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[kUserDefault valueForKey:KUserIcon]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    [_topView addSubview:headV];
    UILabel *nameLb =[[UILabel alloc] initWithFrame:CGRectMake(headV.right+mygap*2, 30, 40,20)];
    nameLb.text = [kUserDefault valueForKey:kUserName];
    nameLb.font = Btn_font;
    [nameLb sizeToFit];
    [_topView addSubview:nameLb];
    
    ZHGenderView *genderView = [[ZHGenderView alloc] initWithFrame:CGRectMake(nameLb.left, nameLb.bottom, 40, 20) WithGender:@"XB_0001" AndAge:@"20"];
    [_topView addSubview:genderView];
    
    NSArray *imgArr = [_userInfo.loveSportsMeaning componentsSeparatedByString:@","];
    for (NSInteger i=0;i<imgArr.count;i++) {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(genderView.right+mygap+i*25, genderView.top-mygap, 20, 20)];
        imageV.image = [UIImage imageNamed:[imgArr objectAtIndex:i]];
        [_topView addSubview:imageV];
    }

}
- (void)initTeam{

    if (_teamInfoArray.count == 0) {
        
    } else {
        for (NSInteger i=0; i<_teamInfoArray.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(mygap*2+(BtnWidth+2*mygap)*i, 0, BtnWidth, BtnWidth)];
            [btn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,_teamInfoArray[i][@"iconPath"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(selectedOnClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(btn.width-20, btn.height-20, 22, 22)];
            image.contentMode = UIViewContentModeScaleToFill;
            image.image = [UIImage imageNamed:@"selecedCheck"];
            image.hidden  = YES;
            [btn addSubview:image];
            UILabel *lb =[[UILabel alloc] initWithFrame:CGRectMake(btn.left, btn.bottom, btn.width, 20)];
            lb.tag = 200+i;
            lb.text = [LVTools mToString:_teamInfoArray[i][@"teamName"]];
            lb.font = Content_lbfont;
            lb.textAlignment = NSTextAlignmentCenter;
            [_teamTopView addSubview:btn];
            [_teamTopView addSubview:lb];
        }
    }
    _teamTopView.contentSize = CGSizeMake((BtnWidth+3*mygap)*_teamInfoArray.count, 100);
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _selectedTf = textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)selectedOnClick:(UIButton*)btn{
    _teamIndex = btn.tag - 100;
    for (UIView *v in _teamTopView.subviews) {
        UIView *img =   [v.subviews lastObject];
        if (![v isEqual:_topView]) {
            if (v.tag==btn.tag) {
                img.hidden = NO;
            }
            else{
                img.hidden = YES;
            }
        }
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
