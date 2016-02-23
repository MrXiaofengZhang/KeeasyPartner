//
//  ZHAppointBuildController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/7.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHAppointBuildController.h"
#import "ZHAppointSearchMapController.h"
#import "ZHInviteFriendController.h"
#import "ZHCollectionCell.h"
#import "ZHupdateImage.h"
#import "LVShareManager.h"
#import "NearByModel.h"
#import "LoginHomeZhViewController.h"
#import "WPCSportsTypeChooseVC.h"
#import "CityListViewController.h"

#define spaceWidth 10.0
#define nomalHeight 44.0
#define imageHeight 120.0
#define boardWidth 0.4f
#define shirtWidth UISCREENWIDTH/15.5
#define tColor [UIColor colorWithRed:0.553f green:0.553f blue:0.553f alpha:1.00f]
#define boardColor [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.00f]
#define kAlphaNum @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define SHIRT_COLOR_NOTI @"shirtColorNotification"
#define PUBLICITY_NOTI @"publicityNotification"
#define INVITE_FRIEND_NOTI @"inviteFriendNotification"


@interface ZHAppointBuildController ()<UITextFieldDelegate,UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,ZHRefreshDelegate,CityDelegate>{
    UIView *xuanyanView;
    NSString *sportTypecode;
    NSString *sportTypeStr;
    NSString *phoneStr;
    NSString *saizhiStr;
    NSString *numLimitStr;
    NSString *feeStr;
    NSString *duringStr;
    NSString *playTimeStr;
    NSString *provinceStr;
    NSString *provinceMeanStr;
    NSString *cityStr;
    NSString *citymeanStr;
    NSString *areastr;
    NSString *areameanstr;
    NSString *detailAddressStr;
    NSString *venueName;
    NSString *lat;
    NSString *lng;
    NSString *introduceStr;
    NSMutableString *friendstr;
    NSMutableArray *friendArray;
    BOOL colorOpen;
    BOOL imgInsert;
    BOOL friendInvite;
}
@property (nonatomic,strong) UIScrollView *RootView;
@property (nonatomic,strong) UILabel *typeLb;

@property (nonatomic,strong) UITextField *numLimitTf;
@property (nonatomic,strong) UITextField *yuezhanTitleTf;
@property (nonatomic,strong) UITextField *xuanyanTextView;
@property (nonatomic,strong) UILabel *beginTimeTf;
@property (nonatomic,strong) UITextField *duringTf;
@property (nonatomic,strong) UITextField *feeTf;
@property (nonatomic,strong) UITextField *saizhiTf;
@property (nonatomic,strong) UITextField *phoneTf;
@property (nonatomic,strong) UIView *shirtColor;

@property (nonatomic,strong) UILabel *addressTf;
@property (nonatomic,strong) UILabel *detailAddress;
@property (nonatomic,strong) UIImageView *ImageView;
@property (nonatomic,strong) UICollectionView *bottomScro;
@property (nonatomic,assign) CGRect convertFrame;
@property (nonatomic,assign) CGFloat keyBoardHeight;
@property (nonatomic,strong) UIView *grayView;
@property (nonatomic,strong) UIView *timeView;
@property (nonatomic,strong) UIDatePicker *datePicker;//日期
@property (nonatomic,strong) UIDatePicker *timePicker;//时分
@property (nonatomic,strong) UIImageView *detailShirt;
@property (nonatomic,strong) UIScrollView *allShirts;
@property (nonatomic,strong) UIView *imgBack;
@property (nonatomic,strong) UIView *friendView;
@property (nonatomic,strong) UIView *appointSwear;//约战宣言
@property (nonatomic,strong) UITextView *swearTextView;
@property (nonatomic,strong) UILabel *fuzzyLabel;//也可以对约战进行解释说明（最多140个字）
@property (nonatomic,strong) NSString *selectColor;

@end

@implementation ZHAppointBuildController

- (void)viewDidLoad {
    [super viewDidLoad];
    friendArray = [[NSMutableArray alloc] initWithCapacity:0];
    venueName = @"待定";
    _selectColor = @"";
    if ([self.title isEqualToString:@"修改约战"]) {
        sportTypecode = _datasource[@"sportsType"];
        sportTypeStr = _datasource[@"sportsTypeMeaning"];
        playTimeStr = _datasource[@"playTime"];
        cityStr = _datasource[@"city"];
    }
    [self navgationBarLeftReturn];
    [self createViews];
    
}

- (void)changeTitle:(NSString *)str
{
    self.title = str;
}

- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)jumpToLoginVC{
    LoginHomeZhViewController *loginVC = [[LoginHomeZhViewController alloc] init];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
}

- (void)buildAppointRequestWithPath:(NSString*)path AndUrl:(NSString*)url{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setValue:sportTypecode forKey:@"sportsType"];//运动类型代码
    [dic setValue:sportTypeStr forKey:@"sportsTypeMeaning"];
    [dic setObject:_yuezhanTitleTf.text forKey:@"title"];//约战标题
    [dic setObject:[kUserDefault objectForKey:kUserName] forKey:@"username"];//用户名
    [dic setValue:_phoneTf.text forKey:@"mobile"];//手机号
    [dic setObject:_selectColor forKey:@"color"];
    [dic setValue:_saizhiTf.text forKey:@"remarksType"];//约战赛制
    [dic setValue:_feeTf.text forKey:@"remarksFee"];//约战费用
    [dic setValue:_duringTf.text forKey:@"remarksTime"];//约战时长
    [dic setValue:playTimeStr forKey:@"playTime"];//约战时间
    [dic setValue:cityStr forKey:@"city"];//市区代码
    [dic setValue:citymeanStr forKey:@"cityMeaning"];
    [dic setValue:venueName forKey:@"venuesName"];//详细地址
    [dic setValue:lng forKey:@"longitude"];
    [dic setValue:_swearTextView.text forKey:@"introduce"];//约战宣言
    [dic setValue:lat forKey:@"latitude"];
    [dic setValue:@"YZFS_0001" forKey:@"playType"];//默认：YZFS_0001约战方式
    [dic setObject:now forKey:@"createtime"];//创建时间
    [dic setObject:[kUserDefault objectForKey:kUserName] forKey:@"createuser"];//创建人
    [dic setObject:now forKey:@"lmodifytime"];//修改时间
    [dic setObject:[kUserDefault objectForKey:kUserName] forKey:@"lmodifyuser"];//修改人
    [dic setValue:url forKey:@"url"];//约战图片
    if ([[LVTools mToString:_numLimitTf.text] length] == 0) {
        [dic setValue:@"5" forKey:@"applyLimit"];
    } else {
       [dic setValue:_numLimitTf.text forKey:@"applyLimit"];
    }
    [dic setValue:path forKey:@"path"];//图片完整路径
    [dic setValue:friendstr forKey:@"friendIdStr"];//获取好友ID用逗号为分隔符，如：22,23,24
    
    [self showHudInView:self.view hint:LoadingWord];
    if ([self.title isEqualToString:@"发起约战"]) {
        NSLog(@"dic =================== %@",dic);
        [DataService requestWeixinAPI:addPlayApply parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"post" completion:^(id result) {
            NSDictionary * resultDic = (NSDictionary *)result;
            NSLog(@"%@",resultDic);
            [self hideHud];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            if ([resultDic[@"statusCode"] isEqualToString:@"success"])
            {
                [self showHint:@"发布成功"];
                //返回并刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshAppoint object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                [self showHint:@"发布失败请重试!"];
            }
        }];
    } else {
        NSLog(@"idstring === %@",self.idString);
        [dic setValue:self.idString forKey:@"id"];
        NSLog(@"dic =================== %@",dic);
        [DataService requestWeixinAPI:updatePlayApply parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"post" completion:^(id result) {
            if ([result[@"statusCode"] isEqualToString:@"success"]) {
                NSArray *arr = [NSArray array];
                self.chuanBlock(arr);
                [self showHint:@"修改成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self showHint:@"修改失败请重试!"];
            }
        }];
    }
}
- (void)fabuClick:(id)sender{
    NSLog(@"发布");
    NSLog(@"%@",cityStr);
    NSLog(@"%@",citymeanStr);
    NSLog(@"aaa%@",_swearTextView.text);
    [self.view endEditing:YES];
    //判断
    if ([_typeLb.text isEqualToString:@" 运动类型:＊"]) {
        [self showHint:@"请选择运动类型"];
        return;
    }
    if ([[LVTools mToString:_yuezhanTitleTf.text] isEqualToString:@""]) {
        [self showHint:@"请输入约战标题"];
        return;
    }
    if ([[LVTools mToString:_yuezhanTitleTf.text] length] > 20) {
        [self showHint:@"标题不得多于20字"];
        return;
    }
    if ([[LVTools mToString: _swearTextView.text] isEqualToString:@""]) {
        [self showHint:@"请输入约战宣言"];
        return;
    }
    if ([[LVTools mToString:_swearTextView.text] length] > 140) {
        [self showHint:@"宣言不得多于140字"];
        return;
    }
    if ([_beginTimeTf.text isEqualToString:@" 开始时间:＊"]) {
        [self showHint:@"请选择开始时间"];
        return;
    }
    if ([_duringTf.text isEqualToString:@""]) {
        [self showHint:@"请输入比赛时长"];
        return;
    }
    if ([_feeTf.text isEqualToString:@""]) {
        [self showHint:@"请输入比赛费用"];
        return;
    }
    if ([[LVTools mToString:_phoneTf.text] length] > 0) {
        if (![LVTools isValidateMobile: _phoneTf.text]) {
            [self showHint:@"请输入真实有效的手机号"];
            return ;
        }
    }
    if ([[LVTools mToString:_numLimitTf.text] length] > 20) {
        [self showHint:@"人数限制不得超过20字"];
        return;
    }
    if ([_addressTf.text isEqualToString:@"        城市:＊"]) {
        [self showHint:@"请选择比赛地区"];
        return;
    }
    if ([_detailAddress.text isEqualToString:@" 详细地址:＊"]) {
        [self showHint:@"请选择比赛详细地址"];
        return;
    }
    if ([_ImageView.image isEqual:[UIImage imageNamed:@"applies_plo"]]) {
        [self showHint:@"请选择具体图片"];
        return;
    }
    [self selectPickerImage:_ImageView.image];
}
- (void)createViews
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(fabuClick:)];
    
    [self.view addSubview:self.RootView];
    [self.RootView addSubview:self.typeLb];
    
    [self.RootView addSubview:self.yuezhanTitleTf];
    [self createAppointSwearView];
    [self.RootView addSubview:self.beginTimeTf];
    [self.RootView addSubview:self.numLimitTf];
    [self.RootView addSubview:self.duringTf];
    [self.RootView addSubview:self.feeTf];
    [self.RootView addSubview:self.saizhiTf];
    [self.RootView addSubview:self.phoneTf];
    //wpc
    [self.RootView addSubview:self.shirtColor];
    [self.RootView addSubview:self.addressTf];
    [self.RootView addSubview:self.detailAddress];
    [self.view addSubview:self.grayView];
    [self.view addSubview:self.timeView];
    
    [self createImgBack];
    [self createFriendView];
    //ppppppp
    
    CGFloat arr[6] = {_beginTimeTf.bottom,_numLimitTf.bottom,_duringTf.bottom,_feeTf.bottom,_addressTf.bottom,_detailAddress.bottom};
    for (int i = 0; i < 6; i ++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(95, arr[i], UISCREENWIDTH-95, 0.5)];
        lineView.tag = 8000+i;
        lineView.backgroundColor = boardColor;
        [self.RootView addSubview:lineView];
    }
    
    CGFloat arr1[4] = {_typeLb.top,_addressTf.top,_imgBack.top,_friendView.top};
    for (int i = 0; i < 4; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(UISCREENWIDTH-35, arr1[i]+12, 20, 20);
        [btn setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
        btn.userInteractionEnabled = YES;
        [self.RootView addSubview:btn];
    }
    UIButton *whiteView = [[UIButton alloc] initWithFrame:CGRectMake(UISCREENWIDTH-30, _detailAddress.top, 30, _detailAddress.height)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [whiteView addTarget:self action:@selector(selectDetailAddress) forControlEvents:UIControlEventTouchUpInside];
    [self.RootView addSubview:whiteView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"Btn_loca"] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(selectDetailAddress) forControlEvents:UIControlEventTouchUpInside];
    btn.frame =  CGRectMake(UISCREENWIDTH-30, _detailAddress.top+11, 20, 22);
    [self.RootView addSubview:btn];
}

- (void)createAppointSwearView
{
    _appointSwear = [[UIView alloc] initWithFrame:CGRectMake(-1, _yuezhanTitleTf.bottom, UISCREENWIDTH+2, 120)];
    _appointSwear.backgroundColor = [UIColor whiteColor];
    _appointSwear.layer.borderWidth = 0.5;
    _appointSwear.layer.borderColor = [boardColor CGColor];
    [self.RootView addSubview:_appointSwear];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 95, 30)];
    NSString *str = @" 约战宣言:＊";
    lab.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
    lab.backgroundColor = [UIColor clearColor];
    [_appointSwear addSubview:lab];
    
    _swearTextView = [[UITextView alloc] initWithFrame:CGRectMake(96, 8, UISCREENWIDTH-107, 104)];
    _swearTextView.delegate = self;
    _swearTextView.layer.borderWidth = 0.5;
    _swearTextView.layer.borderColor = [boardColor CGColor];
    [_appointSwear addSubview:_swearTextView];
    
    
    _fuzzyLabel = [[UILabel alloc] initWithFrame:CGRectMake(_swearTextView.left+1, _swearTextView.bottom-17, _swearTextView.width-4, 14)];
    _fuzzyLabel.backgroundColor = [UIColor clearColor];
    _fuzzyLabel.textAlignment = NSTextAlignmentRight;
    _fuzzyLabel.text = @"也可以对约战进行解释说明(最多140个字)";
    _fuzzyLabel.textColor = RGBACOLOR(215, 215, 215, 1);
    _fuzzyLabel.font = [UIFont systemFontOfSize:12];
    if ([[LVTools mToString:_datasource[@"introduce"]] length] > 0) {
        _swearTextView.text = [LVTools mToString:_datasource[@"introduce"]];
        _fuzzyLabel.hidden = YES;
    }
    [_appointSwear addSubview:_fuzzyLabel];
}

- (UITextField*)yuezhanTitleTf{
    if (_yuezhanTitleTf == nil) {
        _yuezhanTitleTf = [[UITextField alloc] initWithFrame:CGRectMake(-1, _typeLb.bottom+spaceWidth, BOUNDS.size.width+2, nomalHeight)];
        _yuezhanTitleTf.delegate = self;
        _yuezhanTitleTf.leftViewMode = UITextFieldViewModeAlways;
        UILabel *leftView=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, nomalHeight)];
        NSString *str2 = @" 约战标题:＊";
        if ([[LVTools mToString:_datasource[@"title"]] length] > 0) {
            _yuezhanTitleTf.text = _datasource[@"title"];
        } else {
            _yuezhanTitleTf.placeholder = @"好标题容易吸引大波战士响应（20字以内）";
        }
        leftView.attributedText = [LVTools attributedStringFromText:str2 range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
        _yuezhanTitleTf.leftView = leftView;
        [_yuezhanTitleTf setValue:[UIFont systemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];
        _yuezhanTitleTf.backgroundColor = [UIColor whiteColor];
        _yuezhanTitleTf.textAlignment =NSTextAlignmentLeft;
        _yuezhanTitleTf.font = [UIFont systemFontOfSize:13];
        _yuezhanTitleTf.returnKeyType = UIReturnKeyDone;
    }
    return _yuezhanTitleTf;
}

- (void)createImgBack
{
    _imgBack = [[UIView alloc] init];
    _imgBack.frame = CGRectMake(-1, _detailAddress.bottom, BOUNDS.size.width+2, 180);
    
    _imgBack.userInteractionEnabled = YES;
    _imgBack.layer.borderWidth = 0;
    _imgBack.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 96, 30)];
    NSString *str = @" 上传美图:＊";
    label.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
    label.userInteractionEnabled = YES;
    [_imgBack addSubview:label];
    [self.RootView addSubview:_imgBack];
    
    _ImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_imgBack.width-150)/2.0+15, (_imgBack.height-150)/2.0, 150, 150)];
    _ImageView.image = [UIImage imageNamed:@"applies_plo"];
    _ImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ImageView.clipsToBounds = YES;
    if ([[LVTools mToString:_datasource[@"path"]] length] > 0) {
        [_ImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,_datasource[@"path"]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
    }
    [_imgBack addSubview:_ImageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sheetBounceOut)];
    [_imgBack addGestureRecognizer:tap];
}

- (void)createFriendView
{
    _friendView = [[UIView alloc] initWithFrame:CGRectMake(-1, _imgBack.bottom+spaceWidth, UISCREENWIDTH, nomalHeight)];
    _friendView.userInteractionEnabled = YES;
    _friendView.backgroundColor = [UIColor whiteColor];
    _friendView.layer.borderColor = [boardColor CGColor];
    _friendView.layer.borderWidth = boardWidth;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 80, 30)];
    label.text = @" 邀请好友:";
    label.userInteractionEnabled = YES;
    [_friendView addSubview:label];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionBounce)];
    [_friendView addGestureRecognizer:tap];
    
    [self.RootView addSubview:_friendView];
    self.RootView.contentSize = CGSizeMake(UISCREENWIDTH, _friendView.bottom+10);
}

- (void)collectionBounce
{
    [self.view endEditing:YES];
    ZHInviteFriendController *inviteVC= [[ZHInviteFriendController alloc] init];
    inviteVC.type = @"0";
    NSString *str = @"[";
    str = [str stringByAppendingString:[LVTools mToString:_yuezhanTitleTf.text]];
    str = [str stringByAppendingString:@"]"];
    inviteVC.nameStr = str;
    inviteVC.chuanBlock = ^(NSArray *arr){
        [friendArray removeAllObjects];
        if (friendstr == nil) {
            friendstr = [[NSMutableString alloc] init];
        }
        [friendstr setString:@""];
        for (NearByModel *model in arr) {
            [friendstr appendFormat:@"%@,",model.uid];
        }
        [_bottomScro removeFromSuperview];
        _bottomScro = nil;
        if (!_bottomScro) {
            [friendArray  addObjectsFromArray:arr];
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
            flowLayout.itemSize = CGSizeMake(60, 80);
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 0);
            flowLayout.minimumInteritemSpacing = 5;
            flowLayout.minimumLineSpacing = spaceWidth;
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
            int a = (UISCREENWIDTH-2*spaceWidth)/70;
            CGFloat height;
            if (friendArray.count == 0) {
                height = 0;
            } else {
                if (friendArray.count%a == 0) {
                    height = 80*([friendArray count]/a);
                } else {
                    height = 80*([friendArray count]/a + 1);
                }
            }
            //第一次创建时，默认是80的高度
            _bottomScro = [[UICollectionView alloc] initWithFrame:CGRectMake(spaceWidth,40, BOUNDS.size.width-2*spaceWidth, height) collectionViewLayout:flowLayout];
            _bottomScro.pagingEnabled = YES;
            _bottomScro.dataSource = self;
            _bottomScro.delegate = self;
            _bottomScro.backgroundColor = [UIColor whiteColor];
            [_bottomScro registerClass:[ZHCollectionCell class] forCellWithReuseIdentifier:@"ZHCollectionCell"];
            [_friendView addSubview:_bottomScro];
            _friendView.frame = CGRectMake(-1, _imgBack.bottom+spaceWidth, _addressTf.width, _bottomScro.bottom+10);
            self.RootView.contentSize = CGSizeMake(UISCREENWIDTH, _friendView.bottom+10);
        }
        NSLog(@"friendstr === %@",friendstr);
        [_bottomScro reloadData];
    };
    [self.navigationController pushViewController:inviteVC animated:YES];
}

- (void)sheetBounceOut
{
    [self.view endEditing:YES];
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取" otherButtonTitles:@"拍照", nil];
    [action showInView:self.view];
}

- (void)keyBoardChanged:(NSNotification*)notiy{
    _keyBoardHeight = [[[notiy userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
}
- (void)selectType{
    NSLog(@"选择运动类型");
    [self.view endEditing:YES];
    
    WPCSportsTypeChooseVC *vc = [[WPCSportsTypeChooseVC alloc] init];
    vc.multipleChoose = NO;
    vc.chuanBlock = ^(NSArray *arr){
        sportTypeStr = arr[0];
        NSString *str = [NSString stringWithFormat:@" 运动类型:＊%@",[arr objectAtIndex:0]];
        _typeLb.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
    };
    vc.sportCode = ^(NSArray *arr){
        sportTypecode = arr[0];
    };
    
    [self.navigationController pushViewController:vc animated:YES];

}
- (void)selectBegin{
    NSLog(@"选择开始时间");
    [self.view endEditing:YES];
    [self.grayView setHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        self.timeView.frame = CGRectMake(0, BOUNDS.size.height-64-_timeView.height, BOUNDS.size.width, _timeView.height);
    }];
}
- (void)selectAddress{
    NSLog(@"选择城市");
    [self.view endEditing:YES];
    
    CityListViewController *cityVC = [[CityListViewController alloc] init];
    cityVC.title = @"城市选择";
    cityVC.delegate = self;
    cityVC.citydelegate = self;
    cityVC.hasAllCountry = NO;
    UINavigationController *navi  =[[UINavigationController alloc] initWithRootViewController:cityVC];
    [self presentViewController:navi animated:YES completion:nil];
}



- (void)collectionClickAtCode:(NSString *)code andName:(NSString *)name andInfo:(NSDictionary *)dic{
    NSString *str2 = @"        城市:＊";
    str2 = [str2 stringByAppendingString:name];
    _addressTf.attributedText = [LVTools attributedStringFromText:str2 range:NSMakeRange(11, 1) andColor:[UIColor redColor]];
    citymeanStr = name;
    cityStr = code;
}

- (void)sendMsg:(NSString *)msg
{
    //地点
    NSString *str2 = @"        城市:＊";
    str2 = [str2 stringByAppendingString:msg];
    _addressTf.attributedText = [LVTools attributedStringFromText:str2 range:NSMakeRange(11, 1) andColor:[UIColor redColor]];
    citymeanStr = msg;
}

- (void)sendCityAreas:(NSDictionary *)dic {
    //
    cityStr = dic[@"regionId"];
}

- (void)selectDetailAddress{
    
    NSLog(@"选择详细地址");
    NSLog(@"1111%@",citymeanStr);
    [self.view endEditing:YES];
    NSLog(@"text === %@",_addressTf.text);
    if ([_addressTf.text isEqualToString:@"        城市:＊"]) {
        [self showHint:@"请先选择地区"];
    }
    else{
        ZHAppointSearchMapController *searchAddressVC =[[ZHAppointSearchMapController alloc] init];
        searchAddressVC.chuanBlock = ^(NSArray *arr){
            _detailAddress.text = [NSString stringWithFormat:@" 详细地址:%@",[arr objectAtIndex:0]];
            NSString *str = [NSString stringWithFormat:@" 详细地址:＊%@",[arr objectAtIndex:0]];
            _detailAddress.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
            detailAddressStr = [arr objectAtIndex:0];
            lng = [arr objectAtIndex:1];
            lat = [arr objectAtIndex:2];
            venueName = [arr objectAtIndex:3];
            NSLog(@"venuename == %@",venueName);
        };
        if ([citymeanStr hasSuffix:@"市"]) {
            //普通省市区
            searchAddressVC.cityMeaning = [citymeanStr substringWithRange:NSMakeRange(0, citymeanStr.length-1)];
            searchAddressVC.address = [citymeanStr substringWithRange:NSMakeRange(0, citymeanStr.length-1)];
            if([areameanstr isEqualToString:@"市辖区"]){
                searchAddressVC.address = [citymeanStr substringWithRange:NSMakeRange(0, citymeanStr.length-1)];
            }
        }
        else{
            if ([provinceMeanStr hasSuffix:@"市"]) {
                //直辖市
                searchAddressVC.cityMeaning =[provinceMeanStr substringWithRange:NSMakeRange(0, provinceMeanStr.length-1)];
                searchAddressVC.address = [provinceMeanStr substringWithRange:NSMakeRange(0, provinceMeanStr.length-1)];
            }
            else{
                //香港澳门行政
                searchAddressVC.cityMeaning = [provinceMeanStr substringToIndex:2];
                
                searchAddressVC.address = searchAddressVC.cityMeaning;
            }
        }
        [self.navigationController pushViewController:searchAddressVC animated:YES];
    }
}

- (void)selectFriend{
    NSLog(@"选择好友");
    [self.view endEditing:YES];
    ZHInviteFriendController *inviteVC= [[ZHInviteFriendController alloc] init];
    inviteVC.type = @"0";
    NSString *str = @"[";
    str = [str stringByAppendingString:[LVTools mToString:_yuezhanTitleTf.text]];
    str = [str stringByAppendingString:@"]"];
    inviteVC.nameStr = str;
    inviteVC.chuanBlock = ^(NSArray *arr){
        [friendArray removeAllObjects];
        if (friendstr == nil) {
            friendstr = [[NSMutableString alloc] init];
        }
        [friendstr setString:@""];
        for (NearByModel *model in arr) {
            [friendstr appendFormat:@"%@,",model.uid];
        }
        [friendArray  addObjectsFromArray:arr];
        if (friendArray.count > 0) {
            //todo
        }
        [_bottomScro reloadData];
    };
    [self.navigationController pushViewController:inviteVC animated:YES];
}
#pragma mark UIactionsheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=2) {
        [self presentImagePickerControllerWithIndex:buttonIndex];
    }
}
#pragma mark [选择图片]
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
    imageSize.height=150;
    imageSize.width=150;
    _ImageView.image = image;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [update requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"PLAY"} WithType:nil WithData:imageData With:^(NSDictionary * result) {
        [self hideHud];
        NSLog(@"======%@",[result objectForKey:@"statusCodeInfo"]);
        if ([[result objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
        {
            [self buildAppointRequestWithPath:[result objectForKey:@"path"] AndUrl:[result objectForKey:@"url"]];
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:
                                    @"请重试" delegate:nil cancelButtonTitle:@"确 定" otherButtonTitles: nil];
            [alertView show];
        }
        NSLog(@"result=%@",result);
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
#pragma mark getter
- (UIScrollView*)RootView{
    if (_RootView == nil) {
        _RootView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64)];
        _RootView.backgroundColor = [UIColor colorWithRed:0.933f green:0.933f blue:0.933f alpha:1.00f];
        _RootView.showsVerticalScrollIndicator = NO;
        _RootView.delegate = self;
    }
    return _RootView;
}
- (UILabel*)typeLb{
    if (_typeLb == nil) {
        _typeLb = [[UILabel alloc] initWithFrame:CGRectMake(-1, spaceWidth, BOUNDS.size.width+2, nomalHeight)];
        NSString *str2 = @" 运动类型:＊";
        if ([[LVTools mToString:_datasource[@"sportsTypeMeaning"]] length] > 0) {
            str2 = [str2 stringByAppendingString:[LVTools mToString:_datasource[@"sportsTypeMeaning"]]];
        }
        _typeLb.attributedText = [LVTools attributedStringFromText:str2 range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
        _typeLb.backgroundColor = [UIColor whiteColor];
        _typeLb.layer.borderWidth = boardWidth;
        _typeLb.layer.borderColor = boardColor.CGColor;
        _typeLb.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectType)];
        [_typeLb addGestureRecognizer:tap];
    }
    return _typeLb;
}


- (UILabel*)beginTimeTf{
    if (_beginTimeTf == nil) {
        _beginTimeTf = [[UILabel alloc] initWithFrame:CGRectMake(-1, _appointSwear.bottom, BOUNDS.size.width+2, nomalHeight)];
        _beginTimeTf.backgroundColor = [UIColor whiteColor];
        NSString *str2 = @" 开始时间:＊";
        if ([[LVTools mToString:_datasource[@"playTime"]] length] > 0) {
            str2 = [str2 stringByAppendingString:[LVTools mToString:_datasource[@"playTime"]]];
        }
        _beginTimeTf.attributedText = [LVTools attributedStringFromText:str2 range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
        _beginTimeTf.textAlignment =NSTextAlignmentLeft;
        _beginTimeTf.layer.borderWidth = 0;
        _beginTimeTf.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBegin)];
        [_beginTimeTf addGestureRecognizer:tap];
        
    }
    return _beginTimeTf;
}
- (UITextField*)numLimitTf
{
    if (_numLimitTf == nil) {
        _numLimitTf = [[UITextField alloc] initWithFrame:CGRectMake(-1, _beginTimeTf.bottom, BOUNDS.size.width+2, nomalHeight)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, nomalHeight)];
        NSString *str = @" 人数限制:   ";
        if ([[LVTools mToString:_datasource[@"applyLimit"]] length] > 0) {
            _numLimitTf.text = [LVTools mToString:_datasource[@"applyLimit"]];
        }
        title.text = str;
        _numLimitTf.backgroundColor = [UIColor whiteColor];
        _numLimitTf.layer.borderWidth = 0;
        _numLimitTf.delegate = self;
        _numLimitTf.leftViewMode = UITextFieldViewModeAlways;
        _numLimitTf.leftView = title;
        _numLimitTf.returnKeyType = UIReturnKeyDone;
    }
    return _numLimitTf;
}
- (UITextField*)duringTf{
    if (_duringTf == nil) {
        _duringTf = [[UITextField alloc] initWithFrame:CGRectMake(-1, _numLimitTf.bottom, BOUNDS.size.width+2, nomalHeight)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, nomalHeight)];
        NSString *str = @" 时长:＊";
        title.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(4, 1) andColor:[UIColor redColor]];
        title.textAlignment = NSTextAlignmentRight;
        _duringTf.backgroundColor = [UIColor whiteColor];
        _duringTf.delegate = self;
        _duringTf.layer.borderWidth = 0;
        _duringTf.leftViewMode = UITextFieldViewModeAlways;
        _duringTf.leftView = title;
        _duringTf.returnKeyType = UIReturnKeyDone;
        if ([[LVTools mToString:_datasource[@"remarksTime"]] length] > 0) {
            _duringTf.text = [LVTools mToString:_datasource[@"remarksTime"]];
        }
    }
    return _duringTf;
}
- (UITextField*)feeTf{
    if (_feeTf == nil) {
        _feeTf = [[UITextField alloc] initWithFrame:CGRectMake(-1, _duringTf.bottom, BOUNDS.size.width+2, nomalHeight)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, nomalHeight)];
        NSString *str = @" 费用:＊";
        title.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(4, 1) andColor:[UIColor redColor]];
        title.textAlignment = NSTextAlignmentRight;
        _feeTf.backgroundColor = [UIColor whiteColor];
        _feeTf.delegate = self;
        _feeTf.layer.borderWidth = 0;
        _feeTf.leftViewMode = UITextFieldViewModeAlways;
        _feeTf.leftView = title;
        _feeTf.returnKeyType = UIReturnKeyDone;
        if ([[LVTools mToString:_datasource[@"remarksFee"]] length] > 0) {
            _feeTf.text = [LVTools mToString:_datasource[@"remarksFee"]];
        }
    }
    return _feeTf;
}
- (UITextField*)saizhiTf{
    if (_saizhiTf == nil) {
        _saizhiTf = [[UITextField alloc] initWithFrame:CGRectMake(-1, _feeTf.bottom, BOUNDS.size.width+2, nomalHeight)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, nomalHeight)];
        _saizhiTf.backgroundColor = [UIColor whiteColor];
        NSString *str = @"        规则:";
        
        title.text = str;
        _saizhiTf.delegate = self;
        _saizhiTf.layer.borderWidth = 0;
        _saizhiTf.leftViewMode = UITextFieldViewModeAlways;
        _saizhiTf.leftView = title;
        _saizhiTf.returnKeyType = UIReturnKeyDone;
        if ([[LVTools mToString:_datasource[@"remarksType"]] length] > 0) {
            _saizhiTf.text = [LVTools mToString:_datasource[@"remarksType"]];
        }
    }
    return _saizhiTf;
}

- (UITextField*)phoneTf{
    if (_phoneTf == nil) {
        
        _phoneTf = [[UITextField alloc] initWithFrame:CGRectMake(-1,spaceWidth+_saizhiTf.bottom, BOUNDS.size.width+2, nomalHeight)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, nomalHeight)];
        NSString *str = @" 联系方式:   ";
        title.text = str;
        _phoneTf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _phoneTf.backgroundColor = [UIColor whiteColor];
        _phoneTf.delegate = self;
        _phoneTf.layer.borderWidth = boardWidth;
        _phoneTf.layer.borderColor = boardColor.CGColor;
        _phoneTf.leftViewMode = UITextFieldViewModeAlways;
        _phoneTf.leftView = title;
        _phoneTf.returnKeyType = UIReturnKeyDone;
        if ([[LVTools mToString:_datasource[@"mobile"]] length] > 0) {
            _phoneTf.text = [LVTools mToString:_datasource[@"mobile"]];
        }
    }
    return _phoneTf;
}

- (UIView*)shirtColor{
    if (_shirtColor == nil) {
        _shirtColor.backgroundColor = [UIColor whiteColor];
        _shirtColor = [[UIView alloc] initWithFrame:CGRectMake(-1, _phoneTf.bottom+spaceWidth, BOUNDS.size.width+2, nomalHeight*2)];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, nomalHeight)];
        view1.backgroundColor = [UIColor whiteColor];
        
        [_shirtColor addSubview:view1];
        view1.userInteractionEnabled = YES;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, nomalHeight)];
        lab.text = @" 球衣颜色:";
        [view1 addSubview:lab];
        _detailShirt = [[UIImageView alloc] initWithFrame:CGRectMake(lab.right+14, (44-shirtWidth)/2, shirtWidth, shirtWidth)];
        [view1 addSubview:_detailShirt];
        
        if ([[LVTools mToString:_datasource[@"color"]] length] > 0) {
            _detailShirt.image = [UIImage imageNamed:[NSString stringWithFormat:@"color_%@",[LVTools mToString:_datasource[@"color"]]]];
        }
        
        _allShirts = [[UIScrollView alloc] init];
        _allShirts.frame = CGRectMake(0, view1.bottom, UISCREENWIDTH, nomalHeight);
        _allShirts.contentOffset = CGPointMake(0, 0);
        _allShirts.backgroundColor = RGBACOLOR(238, 238, 238, 1);
        for (int i = 0; i < 10; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 900+i;
            btn.frame = CGRectMake(i*shirtWidth+(i+1)*shirtWidth/2, (44-shirtWidth)/2, shirtWidth, shirtWidth);
            [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"color_%d",i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(selectShirt:) forControlEvents:UIControlEventTouchUpInside];
            [_allShirts addSubview:btn];
        }
        
        [_shirtColor addSubview:self.allShirts];
    }
    return _shirtColor;
}

- (void)selectShirt:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        _detailShirt.image = [UIImage imageNamed:[NSString stringWithFormat:@"color_%d",(int)sender.tag-900]];
        _selectColor = [NSString stringWithFormat:@"%d",(int)sender.tag-900];
    } else {
        _detailShirt.image = nil;
        _selectColor = @"";
    }
}

- (UILabel*)addressTf{
    if (_addressTf == nil) {
        _addressTf = [[UILabel alloc] initWithFrame:CGRectMake(-1, _shirtColor.bottom, BOUNDS.size.width+2, nomalHeight)];
        _addressTf.backgroundColor = [UIColor whiteColor];
        
        NSString *str2 = @"        城市:＊";
        if ([[LVTools mToString:_datasource[@"cityMeaning"]] length] > 0) {
            citymeanStr = _datasource[@"cityMeaning"];
            str2 = [str2 stringByAppendingString:[LVTools mToString:_datasource[@"cityMeaning"]]];
        }
        _addressTf.attributedText = [LVTools attributedStringFromText:str2 range:NSMakeRange(11, 1) andColor:[UIColor redColor]];
        _addressTf.userInteractionEnabled = YES;
        _addressTf.layer.borderWidth = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAddress)];
        [_addressTf addGestureRecognizer:tap];
    }
    return _addressTf;
}
- (UILabel*)detailAddress{
    if (_detailAddress == nil) {
        _detailAddress = [[UILabel alloc] initWithFrame:CGRectMake(-1, _addressTf.bottom, BOUNDS.size.width+2-30, nomalHeight)];
        _detailAddress.backgroundColor = [UIColor whiteColor];
        
        _detailAddress.text = @" 详细地址:";
        NSString *str = @" 详细地址:＊";
        if ([[LVTools mToString:_datasource[@"venuesName"]] length] > 0) {
            str = [str stringByAppendingString:[LVTools mToString:_datasource[@"venuesName"]]];
            venueName = [LVTools mToString:_datasource[@"venuesName"]];
        }
        _detailAddress.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
        _detailAddress.userInteractionEnabled = YES;
        _detailAddress.layer.borderWidth = 0;
        _detailAddress.numberOfLines = 1;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectDetailAddress)];
        [_detailAddress addGestureRecognizer:tap];
    }
    return _detailAddress;
}

- (UIView*)grayView{
    if (_grayView == nil) {
        _grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64)];
        _grayView.backgroundColor = [UIColor blackColor];
        _grayView.alpha = 0.5;
        _grayView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGrayView)];
        [_grayView addGestureRecognizer:tap];
    }
    return _grayView;
}
- (void)hideGrayView{
    [self.grayView setHidden:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.timeView.frame= CGRectMake(0, BOUNDS.size.height-64, BOUNDS.size.width, _timeView.height);
    }];
}
- (UIView*)timeView{
    if (_timeView == nil) {
        _timeView = [[UIView alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height-64, BOUNDS.size.width, 216+30)];
        _timeView.backgroundColor = [UIColor whiteColor];
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30)];
        top.backgroundColor = NavgationColor;
        [_timeView addSubview:top];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelOnclick) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:cancelBtn];
        
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width-80, 0, 80, 30)];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn setTitle:@"确 定" forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okOnclick) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:okBtn];
        
        [_timeView addSubview:self.datePicker];
    }
    return _timeView;
}
- (UIDatePicker*)datePicker{
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,30, BOUNDS.size.width, 216)];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.minimumDate = [NSDate date];
        
    }
    return _datePicker;
}
- (UIDatePicker*)timePicker{
    if (_timePicker == nil) {
        _timePicker= [[UIDatePicker alloc] initWithFrame:CGRectMake(_datePicker.right, 30, BOUNDS.size.width-_datePicker.width, 216)];
        _timePicker.backgroundColor = [UIColor whiteColor];
        _timePicker.datePickerMode = UIDatePickerModeTime;
        _timePicker.minimumDate = [NSDate date];
    }
    return _timePicker;
}
- (void)cancelOnclick{
    [self hideGrayView];
}
- (void)okOnclick{
    NSString *resultStr = nil;
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    resultStr = [NSString stringWithFormat:@"%@",[df stringFromDate:_datePicker.date]];
    NSString *str = [NSString stringWithFormat:@" 开始时间:＊%@", resultStr];
    _beginTimeTf.attributedText = [LVTools attributedStringFromText:str range:NSMakeRange(6, 1) andColor:[UIColor redColor]];
    playTimeStr = resultStr;
    [self hideGrayView];
}
#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rc0 = [self.RootView convertRect:textField.frame toView:self.view];
    
    CGRect rc1 = [self.view convertRect:textField.frame fromView:self.RootView];
    _convertFrame = rc1;
    NSLog(@"1:%f\n2:%f",rc0.origin.y,rc1.origin.y);
    
    //开始编辑输入框的时候，软键盘出现，执行此事件
    CGRect frame = _convertFrame;
    int offset = frame.origin.y + textField.height - (self.view.frame.size.height - _keyBoardHeight);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
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


#pragma mark UICollectionViewDatasourse
#pragma mark UICollectViewDatasourse
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [friendArray count];
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ZHCollectionCell";
    ZHCollectionCell * cell = (ZHCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell configFriendModel:[friendArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma  mark UItextviewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([@"\n" isEqualToString:text] == YES) {
        _fuzzyLabel.alpha = 0;
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    _fuzzyLabel.alpha = 0;
    CGRect rc0 = [self.RootView convertRect:textView.frame toView:self.view];
    
    CGRect rc1 = [self.view convertRect:textView.frame fromView:self.RootView];
    _convertFrame = rc1;
    NSLog(@"1:%f\n2:%f",rc0.origin.y,rc1.origin.y);
    
    //开始编辑输入框的时候，软键盘出现，执行此事件
    CGRect frame = _convertFrame;
    int offset = frame.origin.y + textView.height - (self.view.frame.size.height - _keyBoardHeight);//键盘高度216
    
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    
}
//- (void)textViewDidEndEditing:(UITextView *)textView{
//    _fuzzyLabel.alpha = 1;
//    NSTimeInterval animationDuration = 0.30f;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    if (iOS7) {
//        self.view.frame =CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
//    }
//    else{
//        self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    }
//    [UIView commitAnimations];
//    
//}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:_RootView]) {
        [self.view endEditing:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
