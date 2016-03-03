//
//  ZHAppointBaomingController.m
//  Yuezhan123
//
//  Created by zhangxiaofeng on 15/3/24.
//  Copyright (c) 2015年 zhangxiaofeng. All rights reserved.
//

#import "ZHAppointBaomingController.h"
#import "ZHRenshuController.h"
#import "ZHAgreementViewController.h"
#import "ZHOrderController.h"
#import "ZHBaomingCell.h"
#import "ZHItem.h"
#import "ZHSportOrderController.h"
#import "ZHTaocanModel.h"
#import "DownRequestManager.h"
#import <QuickLook/QuickLook.h>

#define Btn_sapce 20.0
#define Btn_width 80.0
#define top_space 10.0
#define Btn_height 30.0
#define sexLine 1
#define closizeLine 3
#define cardLine 5
#define sportTypeLine 7
#define BtnWidth  (BOUNDS.size.width-2*mygap*5)/4.0
@interface ZHAppointBaomingController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,ZHRefreshDelegate,UPPayPluginDelegate,UIDocumentInteractionControllerDelegate>{
    ZHItem *sexModel;
    ZHItem *saizhiModel;
    ZHItem *cardModel;
    UIButton *selectBtn;
    NSString *sportMeaning;
    DownRequestManager *downloadManager;
    UIButton *downLoad;
    UIButton *update;
}

@property (nonatomic,strong) UIDocumentInteractionController *docInteractionController;
@property (nonatomic,strong) NSArray *renshuList;
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UIScrollView *teamTopView;//团队
@property (nonatomic,strong) UILabel *baomingfeiLb;
@property (nonatomic,strong) UILabel *yajinLb;
@property (nonatomic,strong) UILabel *countLb;
@property (nonatomic,strong) UILabel *accountLb;
@property (nonatomic,strong) UILabel *matchName;//比赛名字
@property (nonatomic,strong) NSArray *personArray;
@property (nonatomic,strong) NSArray *teamArray;
@property (nonatomic,strong) NSMutableArray *perReArray;
@property (nonatomic,strong) NSMutableArray *teamReArray;
@property (nonatomic,strong)  UIButton *okBtn;
@property (nonatomic,strong) UIActionSheet *sexSheet;
@property (nonatomic,strong) UIActionSheet *cardSheet;
@property (nonatomic,strong) UIActionSheet *saizhiSheet;

@property (nonatomic,assign) CGRect convertFrame;
@property (nonatomic,assign) CGFloat keyBoardHeight;
@property (nonatomic,strong) NSIndexPath *selectIndexPath;
@property (nonatomic,strong) NSArray *myTeamArray;
@property (nonatomic,strong) NSString *teamName;
@property (nonatomic,strong) NSString *teamId;

@end

@implementation ZHAppointBaomingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self navgationBarLeftReturn];
    //_baoMingtype = BaomingPersonal;//开始为个人报名
    self.personArray = [[NSArray alloc] initWithObjects:@"姓       名:*",@"性       别:*",@"手机号码:*",@"服装尺码:",@"邮       箱:",@"证件类型:*",@"证 件 号:*",@"项目组别:*",@"紧急联系人:*",@"紧急联系人电话:*", nil];
    if (self.isModify) {
        NSString *genderstr = nil;
        for (int i = 0; i < _sexList.count; i ++) {
            if ([[_sexList[i] sysCode] isEqualToString:self.signupInfo[@"gender"]]) {
                genderstr = [_sexList[i] sysName];
            }
        }
        NSString *cardstr = nil;
        for (int i = 0; i < _cardList.count; i ++) {
            if ([[_cardList[i] sysCode] isEqualToString:self.signupInfo[@"certificateType"]]) {
                cardstr = [_cardList[i] sysName];
            }
        }
        NSString *projectCategoryStr = nil;
        for (int i = 0; i < _msaizhiList.count; i ++) {
            if ([[_msaizhiList[i] sysCode] isEqualToString:self.signupInfo[@"groupType"]]) {
                projectCategoryStr = [_msaizhiList[i] sysName];
            }
        }
        self.perReArray = [[NSMutableArray alloc] initWithObjects:[LVTools mToString:self.signupInfo[@"userName"]],genderstr,[LVTools mToString:self.signupInfo[@"mobile"]],[LVTools mToString:self.signupInfo[@"clothingSize"]],[LVTools mToString:self.signupInfo[@"email"]],cardstr,[LVTools mToString:self.signupInfo[@"certificateNum"]],projectCategoryStr,[LVTools mToString:self.signupInfo[@"leaderName"]],[LVTools mToString:self.signupInfo[@"leaderMobile"]], nil];
    } else {
        self.perReArray = [[NSMutableArray alloc] initWithObjects:[kUserDefault valueForKey:kUserName],[[_sexList objectAtIndex:0] sysName],[LVTools mToString:[kUserDefault valueForKey:KUserMobile]],@"不限",@"无",[[_cardList objectAtIndex:0] sysName],@"",[[_msaizhiList objectAtIndex:0] sysName],@"",@"", nil];
    }
    
    sexModel=[_sexList objectAtIndex:0];
    cardModel =[_cardList objectAtIndex:0];
    saizhiModel = [_msaizhiList objectAtIndex:0];
    _teamName = @"";
    _teamId = @"-1";
    self.teamArray = [[NSArray alloc] initWithObjects:@"领 队 姓 名:*",@"领队手机号码:*",@"队 长 姓 名:*",@"队长手机号码:*",@"项 目 组 别:*",@"参 赛 人 数:*", nil];
    if (self.isModify) {
        NSString *projectCategoryStr = nil;
        for (int i = 0; i < _msaizhiList.count; i ++) {
            if ([[_msaizhiList[i] sysCode] isEqualToString:[LVTools mToString:self.signupInfo[@"groupType"]]]) {
                projectCategoryStr = [_msaizhiList[i] sysName];
            }
        }
        NSString *numberString = [LVTools mToString:self.signupInfo[@"memberNum"]];
        if (numberString.length > 0) {
            numberString = [numberString stringByAppendingString:@"人"];
        } else {
            numberString = @"";
        }
        self.teamReArray = [[NSMutableArray alloc] initWithObjects:[LVTools mToString:self.signupInfo[@"leaderName"]],[LVTools mToString:self.signupInfo[@"leaderMobile"]],[LVTools mToString:self.signupInfo[@"captainName"]],[LVTools mToString:self.signupInfo[@"captainMobile"]],projectCategoryStr,numberString, nil];
    } else {
        self.teamReArray = [[NSMutableArray alloc] initWithObjects:[kUserDefault valueForKey:kUserName],[LVTools mToString:[kUserDefault valueForKey:KUserMobile]],[kUserDefault valueForKey:kUserName],[LVTools mToString:[kUserDefault valueForKey:KUserMobile]],[[_msaizhiList objectAtIndex:0] sysName],@"", nil];
    }
    if (_baoMingtype == BaomingInfo) {
        [self creatbackView];
    }
    else{
        [self createViews];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSuccess:) name:DOWNLOAD_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFail:) name:DOWNLOAD_FAILED_NOTIFICATION object:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)downloadSuccess:(NSNotification *)info {
    NSLog(@"info.userinfo%@",info.userInfo);
    NSString *str = info.userInfo[@"detailFile"];
    if ([str isEqualToString:_matchModel.signUpPath]) {
        [downLoad setTitle:@"打开" forState:UIControlStateNormal];
    }
}

- (void)downloadFail:(NSNotification *)info {
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)getMyTeamArray {
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
    [DataService requestWeixinAPI:getCreateTeam parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"%@",result);
        NSLog(@"1");
        if ([result[@"statusCode"] isEqualToString:@"success"]) {
            _myTeamArray = [NSMutableArray arrayWithArray:result[@"createTeamList"]];
            [self initTeam];
        } else {
            [self showHint:@"页面加载失败，请重试"];
        }
    }];
}

- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)creatbackView{
    self.view.backgroundColor = BackGray_dan;
    UIImageView *bludeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, BOUNDS.size.width, 664.0*BOUNDS.size.width/750.0)];
    bludeView.image = [UIImage imageNamed:@"backgroundView"];
    bludeView.userInteractionEnabled = YES;
    [self.view addSubview:bludeView];
    
    update = [UIButton buttonWithType:UIButtonTypeCustom];
    [update setFrame:CGRectMake((BOUNDS.size.width-100)/2.0, BOUNDS.size.width/2.0, 100, 30)];
    [update setTitle:@"上传" forState:UIControlStateNormal];
    [update setTitleColor:NavgationColor forState:UIControlStateNormal];
    [update setBackgroundColor:BackGray_dan];
    update.layer.cornerRadius = 5.0;
    update.layer.borderWidth = 0.3;
    update.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [update addTarget:self action:@selector(upOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [bludeView addSubview:update];

    downLoad = [UIButton buttonWithType:UIButtonTypeCustom];
    [downLoad setFrame:CGRectMake((BOUNDS.size.width-100)/2.0, update.bottom+20, 100, 30)];
    [downLoad setTitle:@"下载" forState:UIControlStateNormal];
    [downLoad setTitleColor:NavgationColor forState:UIControlStateNormal];
    [downLoad setBackgroundColor:BackGray_dan];
    downLoad.layer.cornerRadius = 5.0;
    downLoad.layer.borderWidth = 0.3;
    downLoad.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [downLoad addTarget:self action:@selector(downOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [bludeView addSubview:downLoad];
    
    
    UILabel *textLb = [[UILabel alloc] initWithFrame:CGRectMake(10, bludeView.bottom+10, BOUNDS.size.width-20, 40.0)];
    textLb.font = Content_lbfont;
    textLb.backgroundColor = [UIColor clearColor];
    textLb.textAlignment = NSTextAlignmentCenter;
    textLb.numberOfLines = 0;
    NSString *text = @"提示:如手机未安装word查看工具,请到www.yuezhan123.com进行报名,谢谢合作!";
    textLb.attributedText = [LVTools attributedStringFromText:text range:[text rangeOfString:@"www.yuezhan123.com"] andColor:NavgationColor];
    [self.view addSubview:textLb];
}
- (void)downOnclick:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"下载"]) {
        downloadManager = [DownRequestManager sharedDownRequestManager];
        [downloadManager createOneOperationWithFileName:_matchModel.matchName andFormat:_matchModel.signUpExt andPath:_matchModel.signUpPath];
    } else {
        //打开文件
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject] stringByAppendingFormat:@"/%@.%@",_matchModel.matchName,_matchModel.signUpExt];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath isDirectory:YES];
        [self setupDocumentControllerWithURL:url];
        [self.docInteractionController presentOptionsMenuFromRect:CGRectMake(0, 64, 1500, 40) inView:self.view  animated:YES];
    }
}

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
        self.docInteractionController.UTI = @"com.microsoft.word.doc";
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

- (void)upOnclick:(UIButton *)sender{
    
}
- (void)keyBoardChanged:(NSNotification*)notiy{
    //由于tableview不是从零开始的所以要减
    _keyBoardHeight = [[[notiy userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height-_mTableView.top;
}
- (void)changeOnClick:(UISegmentedControl*)seg{
    
}
- (UIActionSheet*)sexSheet{
    if (_sexSheet == nil) {
        _sexSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle: nil otherButtonTitles: nil];
        for (NSInteger i=0; i<[self.sexList count]; i++) {
            [_sexSheet addButtonWithTitle:[(ZHItem*)[_sexList objectAtIndex:i] sysName]];
        }
    }
    return _sexSheet;
}
- (UIActionSheet*)cardSheet{
    if (_cardSheet == nil) {
        _cardSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        for (NSInteger i=0; i<[self.cardList count]; i++) {
            [_cardSheet addButtonWithTitle:[[_cardList objectAtIndex:i] sysName]];
        }
    }
    return _cardSheet;
}
- (UIActionSheet*)saizhiSheet{
    if (_saizhiSheet == nil) {
        _saizhiSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        for (NSInteger i=0; i<[self.msaizhiList count]; i++) {
            [_saizhiSheet addButtonWithTitle:[[_msaizhiList objectAtIndex:i] sysName]];
        }
    }
    return _saizhiSheet;
}
- (UIScrollView*)teamTopView{
    if (_teamTopView == nil) {
        _teamTopView = [[UIScrollView alloc] initWithFrame:CGRectMake(-1, 30.0, BOUNDS.size.width+2, 130)];
        _teamTopView.backgroundColor = [UIColor whiteColor];
        _teamTopView.layer.borderColor = BackGray_dan.CGColor;
        _teamTopView.layer.borderWidth = 0.5;
        [self getMyTeamArray];
        
    }
    return _teamTopView;
}
- (void)initTeam{
    if (_myTeamArray.count == 0) {
        _teamTopView.height = 0.0f;
        UIView *headView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30.0)];
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30.0)];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.text = [LVTools mToString:self.matchModel.matchName];
        titleView.font = Btn_font;
        [headView addSubview:titleView];
//        if (_baoMingtype == BaomingTeamal) {
//
//        }
//        NSLog(@"%@",NSStringFromCGRect(headView.frame));
        _mTableView.tableHeaderView = headView;
    } else {
        _teamTopView.height = 130.0f;
        for (NSInteger i=0; i<_myTeamArray.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(mygap*2+(BtnWidth+2*mygap)*i, mygap*2, BtnWidth, BtnWidth)];
            [btn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,_myTeamArray[i][@"iconPath"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(selectedOnClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(btn.width-20, btn.height-20, 22, 22)];
            image.contentMode = UIViewContentModeScaleToFill;
            image.image = [UIImage imageNamed:@"selecedCheck"];
            image.hidden  = YES;
            [btn addSubview:image];
            UILabel *nameLb= [[UILabel alloc] initWithFrame:CGRectMake(btn.left, btn.bottom, btn.width, 30)];
            nameLb.textAlignment = NSTextAlignmentCenter;
            nameLb.font = Btn_font;
            nameLb.text = [LVTools mToString:_myTeamArray[i][@"teamName"]];
            [_teamTopView addSubview:nameLb];
            [_teamTopView addSubview:btn];
        }
        _teamTopView.contentSize = CGSizeMake(UISCREENWIDTH/3.8*_myTeamArray.count, _teamTopView.height);
    }
}
- (void)selectedOnClick:(UIButton*)btn{
    
    for (UIView *v in _teamTopView.subviews) {
        UIView *img =   [v.subviews lastObject];
        if (v.tag==btn.tag) {
            img.hidden = NO;
        }
        else{
            img.hidden = YES;
        }
    }
    _teamId = [LVTools mToString:_myTeamArray[btn.tag-100][@"id"]];
    _teamName = _myTeamArray[btn.tag-100][@"teamName"];
    NSLog(@"%@",_teamId);
}
- (void)openUrlOnclick{
    NSLog(@"打开网站");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"www.yuezhan123.com"]];
}
- (void)createViews{
    [self.view addSubview:self.mTableView];
    _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_okBtn setFrame:CGRectMake(0, _mTableView.bottom, BOUNDS.size.width, kBottombtn_height)];
    [_okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_okBtn setTitleColor:NavgationColor forState:UIControlStateNormal];
    [_okBtn setBackgroundColor:[UIColor colorWithRed:0.965f green:0.969f blue:0.973f alpha:1.00f]];
    [_okBtn addTarget:self action:@selector(okOnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_okBtn addSubview:line];
    [self.view addSubview:_okBtn];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)okOnClick:(UIButton*)btn{

    //协议
    if (selectBtn.selected != YES) {
        [self showHint:@"必须同意本平台相关规定才能报名"];
        return;
    }
    //信息完整
    if (_baoMingtype == BaomingPersonal) {
        for (NSInteger i=0; i<self.perReArray.count-1; i++) {
            
            if ([[LVTools mToString:[self.perReArray objectAtIndex:i]] isEqualToString:@""]) {
                [self showHint:@"您填写的报名信息不完整!"];
                return;
            }
        }
        //验证手机号
        if ([LVTools mToString:[self.perReArray objectAtIndex:2]].length!=11) {
            [self showHint:@"请输入正确手机号"];
            return;
        }
        if (![LVTools isValidateMobile:[LVTools mToString:[self.perReArray objectAtIndex:2]]]) {
            [self showHint:@"请输入正确手机号"];
            return;
        }
        if ([LVTools mToString:[self.perReArray objectAtIndex:9]].length!=11) {
            [self showHint:@"请输入正确手机号"];
            return;
        }
        if (![LVTools isValidateMobile:[LVTools mToString:[self.perReArray objectAtIndex:9]]]) {
            [self showHint:@"请输入正确手机号"];
            return;
        }
        //验证身份证
        if ([[self.perReArray objectAtIndex:5] isEqualToString:@"身份证"]) {
            if(![LVTools isValidateIdentityCard:[LVTools mToString:[self.perReArray objectAtIndex:6]]]){
                [self showHint:@"您输入的身份证不合法,请重新输入"];
                return;
            }
        }
    }
    else{
        for (NSInteger i=0; i<self.teamReArray.count; i++) {
            if ([[self.teamReArray objectAtIndex:i] isEqualToString:@""]) {
                [self showHint:@"您填写的报名信息不完整!"];
                return;
            }
        }
//        if ([_teamId isEqualToString:@""]) {
//            [self showHint:@"团队报名需选择团队"];
//            return;
//        }
    }
    //收集信息
    [WCAlertView showAlertWithTitle:@"提示" message:@"是否确定报名" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex==1) {
            [self signMatchRequest];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}
- (void)signMatchRequest{
    //报名数据请求
    NSMutableDictionary * dic = [LVTools getTokenApp];
   
    [dic setValue:[kUserDefault objectForKey:kUserId]forKey:@"uid"];
    [dic setValue:[kUserDefault objectForKey:kUserName]forKey:@"username"];
    [dic setValue:_matchModel.registrationFee forKey:@"unitPrice"];
    [dic setValue:self.matchModel.matchName forKey:@"orderName"];
    
    NSMutableDictionary *matchSignupInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    [matchSignupInfo setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
    if (self.isModify) {
        [matchSignupInfo setValue:self.signupInfo[@"id"] forKey:@"id"];
    }
    if (_baoMingtype == BaomingPersonal) {
        [dic setValue:@"1" forKey:@"quantity"];
        [dic setValue:@"DDLX_0003"forKey:@"orderType"];
        [dic setValue:self.matchModel.registrationFee forKey:@"amount"];
        
        [matchSignupInfo setObject:singleMark forKey:@"signupType"];
        [matchSignupInfo setValue:self.matchModel.id forKey:@"matchId"];
        [matchSignupInfo setValue:[kUserDefault objectForKey:kUserId]forKey:@"uid"];
        NSArray *person = @[@"userName",@"gender",@"mobile",@"clothingSize",@"email",@"certificateType",@"certificateNum",@"groupType",@"leaderName",@"leaderMobile"];
        [self.perReArray replaceObjectAtIndex:1 withObject:sexModel.sysCode];
        [self.perReArray replaceObjectAtIndex:5 withObject:cardModel.sysCode];
        [self.perReArray replaceObjectAtIndex:7 withObject:saizhiModel.sysCode];
        
        for (NSInteger i=0; i<[person count]; i++) {
            [matchSignupInfo setObject:[self.perReArray objectAtIndex:i] forKey:[person objectAtIndex:i]];
        }
        [matchSignupInfo setObject:self.matchModel.matchName forKey:@"matchName"];
        [matchSignupInfo setValue:@"1" forKey:@"memberNum"];
        [dic setObject:matchSignupInfo forKey:@"matchSignupInfo"];
    }
    else{
        
        int number = [[self.teamReArray[5] substringToIndex:[self.teamReArray[5] length]-1] intValue];
        CGFloat fee = [[LVTools mToString:_matchModel.registrationFee] floatValue];
        [dic setValue:[NSString stringWithFormat:@"%d",number] forKey:@"quantity"];
        [dic setValue:@"DDLX_0002"forKey:@"orderType"];
        [dic setValue:[NSString stringWithFormat:@"%.2f",number*fee] forKey:@"amount"];
        
        
        [matchSignupInfo setObject:teamMark forKey:@"signupType"];
        NSArray *team = @[@"leaderName",@"leaderMobile",@"captainName",@"captainMobile",@"groupType"];
        [matchSignupInfo setValue:self.matchModel.id forKey:@"matchId"];
        [matchSignupInfo setValue:[kUserDefault objectForKey:kUserId]forKey:@"uid"];
        [self.teamReArray replaceObjectAtIndex:4 withObject:saizhiModel.sysCode];
        for (NSInteger i=0; i<[team count]; i++) {
            [matchSignupInfo setObject:[self.teamReArray objectAtIndex:i] forKey:[team objectAtIndex:i]];
        }
        [matchSignupInfo setValue:[NSString stringWithFormat:@"%d",number] forKey:@"memberNum"];
        [matchSignupInfo setObject:self.matchModel.matchName forKey:@"matchName"];
        [matchSignupInfo setValue:_teamId forKey:@"teamId"];
        [matchSignupInfo setValue:_teamName forKey:@"teamName"];
        [dic setObject:matchSignupInfo forKey:@"matchSignupInfo"];
    }
    [self showHudInView:self.view hint:LoadingWord];
    NSString *urlString = nil;
    if (self.isModify) {
        urlString = modifySignUp;
    } else {
        urlString = matchSignup;
    }
    NSLog(@"urlstring ========================= %@",urlString);
    NSLog(@"dic =====%@",dic);
    [DataService requestWeixinAPI:urlString parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"lalalalalal ＝＝＝ %@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCodeInfo"] isEqualToString:@"成功"])
        {
            NSArray *chuanarr = [NSArray arrayWithObject:result[@"signupInfo"]];
            self.chuanBlock(chuanarr);
            
            if ([[LVTools mToString:self.matchModel.registrationFee] floatValue] == 0) {//没报名费
                [self showHint:@"报名成功!"];
                [self PopView];
            } else {
                ZHSportOrderController *vc = [[ZHSportOrderController alloc] init];
                if ([urlString isEqualToString:modifySignUp]) {
                    vc.orderId = [LVTools mToString:resultDic[@"oId"]];
                    vc.orderName = [LVTools mToString:resultDic[@"orderName"]];
                    vc.orderNum = [LVTools mToString:resultDic[@"orderNum"]];
                    vc.orderCost = [LVTools mToString:resultDic[@"amount"]];
                    vc.isVerify = [LVTools mToString:resultDic[@"isVerify"]];
                } else if ([urlString isEqualToString:matchSignup]) {
                    vc.orderId = [LVTools mToString:resultDic[@"oId"]];
                    vc.isVerify = [LVTools mToString:resultDic[@"isVerify"]];
                    vc.orderCost = [LVTools mToString:result[@"order"][@"amount"]];
                    vc.orderName = [LVTools mToString:result[@"order"][@"orderName"]];
                    vc.orderNum = [LVTools mToString:result[@"order"][@"orderNum"]];
                }
                vc.number = _countLb.text;
                vc.detalModel = self.matchModel;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else if ([resultDic[@"statusCodeInfo"] isEqualToString:@"报名人数已满"]){
            [self showHint:@"报名人数已满"];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
#pragma mark [银联支付]
- (void)UPPayPluginResult:(NSString *)result{
    NSLog(@"%@",result);
    if ([result isEqualToString:@"success"]) {
        //刷新页面，隐藏按钮
        
        [WCAlertView showAlertWithTitle:@"提示" message:@"支付成功!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles: nil];
    }
    else if([result isEqualToString:@"fail"]){
        [WCAlertView showAlertWithTitle:@"提示" message:@"支付失败!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
    }
    else if([result isEqualToString:@"cancel"]){
        [WCAlertView showAlertWithTitle:@"提示" message:@"您已经取消支付!" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
    }
    else{
        
    }

}
- (void)agreeOnClick:(UIButton*)btn{
    btn.selected = !btn.selected;
    _okBtn.selected = btn.selected;
}
- (void)agreeContentOnClick:(id)sender{
    //协议内容
    NSLog(@"协议具体内容");
    ZHAgreementViewController *agreeVC =[[ZHAgreementViewController alloc] init];
    agreeVC.title = @"赛事报名声明书";
    agreeVC.urlstring = [NSString stringWithFormat:@"%@%@",preUrl,kProtocolUrl];
    [self.navigationController pushViewController:agreeVC animated:YES];
}
#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0-kBottombtn_height) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        UIView *headView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30.0)];
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30.0)];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.text = [LVTools mToString:self.matchModel.matchName];
        titleView.font = Btn_font;
        [headView addSubview:titleView];
        if (_baoMingtype == BaomingTeamal) {
            [headView addSubview:self.teamTopView];
            headView.height = self.teamTopView.bottom;
        }
        NSLog(@"%@",NSStringFromCGRect(headView.frame));
        _mTableView.tableHeaderView = headView;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
        UIImageView *grayView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, BOUNDS.size.width-10*2, 60)];
        [grayView setImage:[UIImage imageNamed:@"blueLine"]];
        [footView addSubview:grayView];
        NSArray *titleArray = @[@"报名费",@"押金",@"数量",@"总价"];
        NSArray *lbArray = @[self.baomingfeiLb,self.yajinLb,self.countLb,self.accountLb];
        for (NSInteger i= 0; i<[titleArray count]; i++) {
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(i*(grayView.frame.size.width/4.0), 0, grayView.frame.size.width/4.0, grayView.height/2.0)];
            titleLab.backgroundColor = [UIColor clearColor];
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.text = [titleArray objectAtIndex:i];
            titleLab.font = Btn_font;
            titleLab.textColor = [UIColor whiteColor];
            [grayView addSubview:titleLab];
            UILabel *contentLb = (UILabel*)[lbArray objectAtIndex:i];
            contentLb.frame =CGRectMake(titleLab.frame.origin.x, grayView.height/2.0, titleLab.frame.size.width, 20) ;
            contentLb.textAlignment = NSTextAlignmentCenter;
            contentLb.font = Btn_font;
            contentLb.textColor = [UIColor whiteColor];
            [grayView addSubview:contentLb];
        }
        [self.matchName setFrame:CGRectMake(0, grayView.bottom+5, BOUNDS.size.width, grayView.height/2.0)];
        [footView addSubview:self.matchName];
        selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectBtn setFrame:CGRectMake(5, _matchName.bottom, 27.0f, 27.0f)];
        [selectBtn setBackgroundImage:[UIImage imageNamed:@"agree_selected"] forState:UIControlStateSelected];
        [selectBtn setBackgroundImage:[UIImage imageNamed:@"agree_select"] forState:UIControlStateNormal];
        [selectBtn addTarget:self action:@selector(agreeOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:selectBtn];
        UILabel *ruleLb = [[UILabel alloc] initWithFrame:CGRectMake(27.0+5, selectBtn.top, BOUNDS.size.width-27, selectBtn.height*2)];
        ruleLb.numberOfLines = 0;
        ruleLb.text = @"《约战123平台法律责任免除与权利放弃说明书》";
        ruleLb.font = Btn_font;
        [ruleLb sizeToFit];
        [footView addSubview:ruleLb];
        ruleLb.left = (BOUNDS.size.width - ruleLb.width)/2.0;
        [selectBtn setFrame:CGRectMake(ruleLb.left-15.0, _matchName.bottom, 20, 20)];
        [footView setFrame:CGRectMake(0, 0, BOUNDS.size.width, ruleLb.bottom+40)];
        ruleLb.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreeContentOnClick:)];
        [ruleLb addGestureRecognizer:tap];
        _mTableView.tableFooterView = footView;
    }
    return _mTableView;
}
- (UILabel*)baomingfeiLb{
    if (_baomingfeiLb == nil) {
        _baomingfeiLb = [[UILabel alloc] initWithFrame:CGRectZero];
        if(self.matchModel.registrationFee){
        _baomingfeiLb.text =[NSString stringWithFormat:@"%@元",[LVTools mToString: self.matchModel.registrationFee]];
        }
        else{
            _baomingfeiLb.text= @"0元";
        }
    }
    return _baomingfeiLb;
}
- (UILabel*)yajinLb{
    if (_yajinLb == nil) {
        _yajinLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _yajinLb.text = @"0元";
    }
    return _yajinLb;
}

- (UILabel*)countLb{
    if (_countLb == nil) {
        _countLb = [[UILabel alloc] initWithFrame:CGRectZero];
        if (self.isModify) {
            _countLb.text = [LVTools mToString:self.teamReArray[5]];
        } else {
            _countLb.text = @"1";
        }
    }
    return _countLb;
}

- (UILabel*)accountLb{
    if (_accountLb == nil) {
        _accountLb = [[UILabel alloc] initWithFrame:CGRectZero];
        CGFloat account = 0;
        if (self.isModify) {
//            account = [[LVTools mToString: self.matchModel.registrationFee] doubleValue] * [[LVTools mToString:self.teamReArray[5]] intValue];
        } else {
//            account = [[LVTools mToString: self.matchModel.registrationFee] doubleValue];
        }
        account = [[LVTools mToString: self.matchModel.registrationFee] doubleValue];
        _accountLb.text = [NSString stringWithFormat:@"%.2f元",account];
    }
    return _accountLb;
}
- (UILabel*)matchName{
    if (_matchName == nil) {
        _matchName = [[UILabel alloc] initWithFrame:CGRectZero];
        _matchName.textAlignment = NSTextAlignmentCenter;
        _matchName.text = [LVTools mToString:self.matchModel.matchName];
        _matchName.font = Btn_font;
    }
    return _matchName;
}

#pragma mark UItableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_baoMingtype == BaomingPersonal){
        return [self.personArray count];
    }
    else{
        return [self.teamArray count];
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHBaomingCell *cell = [[ZHBaomingCell alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 44.0)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *content = nil;
    NSString *title = nil;
    //selectBtn.selected = NO;
    if (_baoMingtype == BaomingPersonal) {
        cell.contentFiled.tag = 100+indexPath.row;
        title=[self.personArray objectAtIndex:indexPath.row];
        content = [self.perReArray objectAtIndex:indexPath.row];
        if (indexPath.row == 2 || indexPath.row == 9) {
            cell.contentFiled.keyboardType = UIKeyboardTypeNumberPad;
        }
    }
    else{
        cell.contentFiled.tag = 200+indexPath.row;
        title=[self.teamArray objectAtIndex:indexPath.row];
        content = [self.teamReArray objectAtIndex:indexPath.row];
        if (indexPath.row == 1 || indexPath.row == 3) {
            cell.contentFiled.keyboardType = UIKeyboardTypeNumberPad;
        }
    }
    cell.titleLb.text = title;
    if ([title hasSuffix:@"*"]) {
        NSRange rang = [title rangeOfString:@"*"];
        cell.titleLb.attributedText = [LVTools attributedStringFromText:title range:rang andColor:color_red_dan];
    }
    cell.contentFiled.text = content;
    cell.contentFiled.placeholder = @"必填";
    //自适应高度

    CGFloat width= [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 30.0) options:NSStringDrawingUsesLineFragmentOrigin  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17.0],NSFontAttributeName,nil] context:nil].size.width;
    cell.titleLb.frame = CGRectMake(10, 7, width, 30.0);
    cell.contentFiled.frame = CGRectMake(cell.titleLb.right, cell.titleLb.top, BOUNDS.size.width-cell.titleLb.right, cell.titleLb.height);
    cell.contentFiled.delegate = self;
    cell.contentFiled.enabled = NO;
    if (_baoMingtype == BaomingPersonal) {
        if (indexPath.row==sexLine) {
            
            cell.contentFiled.enabled= NO;
            //NSLog(@"%f",cell.titleLb.right+5);
        }
        else if(indexPath.row == cardLine){
            
             cell.contentFiled.enabled = NO;
            //NSLog(@"%f",cell.titleLb.right+5);
        }
        else if (indexPath.row == sportTypeLine){
            cell.contentFiled.enabled = NO;
        }
        else if (indexPath.row == 8){
            cell.contentFiled.placeholder = @"请输入备注信息";
        } else if (indexPath.row == 6) {
            cell.contentFiled.placeholder = @"购买保险必填";
        }
    }
    else{
        if (indexPath.row==5) {
            cell.contentFiled.enabled = NO;
            //NSLog(@"%f",cell.titleLb.right+5);
        }
        else if (indexPath.row == 6){
            cell.contentFiled.placeholder = @"请输入队员姓名以顿号隔开(选填)";
        }
    }
    cell.separatorInset = UIEdgeInsetsMake(0, cell.titleLb.right, 0, 0);
    return cell;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZHBaomingCell *cell =(ZHBaomingCell*)[tableView cellForRowAtIndexPath:indexPath];
    CGRect rc1 = [self.view convertRect:cell.contentFiled.frame fromView:cell];
    _convertFrame = rc1;
    _selectIndexPath=indexPath;
    //[self clipBox];
    if (_baoMingtype == BaomingPersonal) {
        if (indexPath.row == sexLine) {
            [self.sexSheet showInView:self.view];
            [self.view endEditing:YES];
        }
        else if(indexPath.row ==cardLine ){
            [self.cardSheet showInView:self.view];
            [self.view endEditing:YES];
        }
        else if (indexPath.row == sportTypeLine){
            //项目类型
            [self.saizhiSheet showInView:self.view];
            [self.view endEditing:YES];
        }
        else{
            cell.contentFiled.enabled = YES;
            [cell.contentFiled becomeFirstResponder];
        }
    }
    else if(_baoMingtype == BaomingTeamal){
        if (indexPath.row==5) {
            [self.view endEditing:YES];
            ZHRenshuController *renshuVc =[[ZHRenshuController alloc] init];
            renshuVc.delegate =self;
            [self.navigationController pushViewController:renshuVc animated:YES];
            
        }
        else{
            cell.contentFiled.enabled = YES;
            [cell.contentFiled becomeFirstResponder];

        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    //开始编辑输入框的时候，软键盘出现，执行此事件
    CGRect frame = _convertFrame;
    int offset = frame.origin.y + textField.height - (self.view.frame.size.height - _keyBoardHeight);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset >=0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    //收集报名信息
    
    if(_baoMingtype == BaomingPersonal){
        
        [_perReArray replaceObjectAtIndex:textField.tag-100 withObject:textField.text];
    }
    else{
        [_teamReArray replaceObjectAtIndex:textField.tag-200 withObject:textField.text];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
       return YES;
}
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSArray *dataArray = nil;
    NSMutableArray *reDataArray = [NSMutableArray array];
    NSInteger index = 0;
    if ([actionSheet isEqual:_sexSheet]) {
        reDataArray = self.perReArray;
        dataArray = _sexList;
        index = sexLine;
        sexModel = [_sexList objectAtIndex:buttonIndex];
    }
    else if([actionSheet isEqual:_cardSheet]){
         reDataArray = self.perReArray;
        dataArray = _cardList;
        index = cardLine;
        cardModel = [_cardList objectAtIndex:buttonIndex];
    }
    else if([actionSheet isEqual:_saizhiSheet]){
         reDataArray = self.perReArray;
        dataArray = _msaizhiList;
        index = sportTypeLine;
        saizhiModel = [_msaizhiList objectAtIndex:buttonIndex];
    }
    if ([[dataArray objectAtIndex:buttonIndex] sysName]) {
        [reDataArray replaceObjectAtIndex:index withObject:[[dataArray objectAtIndex:buttonIndex] sysName]];
    }
    [_mTableView reloadData];
}
#pragma mark [获得参赛人数]
- (void)sendMsg:(NSString *)renshu{
    [self.teamReArray replaceObjectAtIndex:5 withObject:renshu];
    [self.mTableView reloadData];
    NSString *num = [renshu substringToIndex:renshu.length-1];
    _countLb.text = num;
    CGFloat account = [num intValue]*[[LVTools mToString: self.matchModel.registrationFee] doubleValue];
    _accountLb.text = [NSString stringWithFormat:@"%.2f元",account];
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
