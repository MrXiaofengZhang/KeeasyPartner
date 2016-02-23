//
//  WPCSportDetailVC.m
//  yuezhan123
//
//  Created by admin on 15/7/7.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCSportDetailVC.h"
#import "WPCCommentCell.h"
#import "ImgShowViewController.h"
#import "ZHCommentController.h"
#import "LoginHomeZhViewController.h"
#import "LVShareManager.h"
#import "WPCCommentVC.h"
#import "WPCFriednMsgVC.h"
#import "WPCMyOwnVC.h"
#import "HcCustomKeyboard.h"
#import "ZHInviteFriendController.h"
#import "PopoverView.h"
#import "ZHSportInfoController.h"
#import "ZHAppointBaomingController.h"
#import "GetMatchListModel.h"
#import "ZHItem.h"
#import "WPCImageView.h"
#import "WPCApplyDetailVC.h"


static NSString *headCollectID = @"headCollectID";
@interface WPCSportDetailVC () <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,CommentClearUpDelegate>

@property (nonatomic, strong)NSArray *keysArray;//返回的info里面的字典keys
@property (nonatomic, strong)NSArray *preArray;//头部数组
@property (nonatomic, strong)UICollectionView *headCollection;
@property (nonatomic, strong)UITableView *tableview;
@property (nonatomic, strong)UIView *firstView;
@property (nonatomic, strong)UIView *secondView;
@property (nonatomic, assign)BOOL hasApply;
@property (nonatomic, assign)BOOL needVerify;
@property (nonatomic, assign)BOOL isTimeOut;//判断比赛是否已经报名截止
@property (nonatomic, strong)NSMutableDictionary *wholeInfoDic;
@property (nonatomic, strong)NSArray *matchPicArray;//赛事图片数组
@property (nonatomic, strong)NSMutableArray *msgArray;
@property (nonatomic, strong)NSMutableArray *replyMsgArray;
@property (nonatomic, strong)NSMutableArray *praiseArray;
@property (nonatomic, strong)NSMutableArray *liuyanArray;
@property (nonatomic, strong)GetMatchListModel *detailModel;
@property (nonatomic, assign)NSInteger deleteIndex;
@property (nonatomic, strong)NSString *optionStr;
@property (nonatomic, strong)NSString *partnerId;
@property (nonatomic, strong)NSString *partnerName;
@property (nonatomic, strong)NSString *contentstring;
@property (nonatomic, strong)UIView *carryView;
@property (nonatomic, assign)BOOL hasRedHeart;
@property (nonatomic, strong)UIScrollView *dianzanScrollview;
@property (nonatomic, strong)NSMutableArray *baomingList;
@property (nonatomic, strong)UIButton *aboutMeBtn;
@property (nonatomic, assign)BOOL isModify;
@property (nonatomic, assign)BOOL needPay;
@property (nonatomic, strong)NSString *aboutMeNumString;
@property (nonatomic, assign)BOOL hasPay;

@end

@implementation WPCSportDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"赛事详情";
    _hasPay = NO;
    _hasRedHeart = NO;
    [self navgationBarLeftReturn];
    self.view.backgroundColor = [UIColor whiteColor];
    _preArray = [[NSArray alloc] initWithObjects:@"简介",@"规则",@"须知",@"赛果",@"积分",@"新赛程", nil];
    _keysArray = [[NSArray alloc] initWithObjects:@"主办:",@"承办:",@"费用:",@"城市:",@"比赛时间:",@"报名截止:",@"联系电话:", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePayStatuse) name:PAY_SUCCESS object:nil];
    [self initialDatasource];
}

- (void)initialInterface {
    [self createTableView];
    [self createBottomView];
}

- (UIView *)createHeaderView {
    [self createFirstView];
    [self createSecondView];
    UIView *view = [[UIView alloc] init];
    [view addSubview:_firstView];
    [view addSubview:_secondView];
    view.frame = CGRectMake(0, 0, UISCREENWIDTH, _secondView.bottom);
    return view;
}

- (void)createTableView {
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-64-49) style:UITableViewStylePlain];
    _tableview.dataSource = self;
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.delegate = self;
    _tableview.tableHeaderView = [self createHeaderView];
    [self.view addSubview:_tableview];
}
- (void)createBottomView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _tableview.bottom, UISCREENWIDTH, 49)];
    view.backgroundColor = RGBACOLOR(245, 245, 245, 1);
    [self.view addSubview:view];
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [RGBACOLOR(205, 205, 205, 1) CGColor];
    UIView *gapLine = [[UIView alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2-0.25, 5, 0.5, 35)];
    gapLine.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [view addSubview:gapLine];
    
    //新版中，最下面的两个按钮
    NSArray *arr1 = @[@"invite_wpc",@"baoming_wpc"];
    NSArray *arr2 = @[@"invite_wpc",@"manager_wpc"];
    for (int i = 0; i < 2; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentMode = UIViewContentModeScaleToFill;
        btn.frame = CGRectMake(UISCREENWIDTH/2*i, 0, UISCREENWIDTH/2-0.5, 49);
        [btn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 310 +i;
        if (i == 0) {
            [btn setImage:[UIImage imageNamed:arr1[i]] forState:UIControlStateNormal];

        } else {
            if (_hasApply) {
                [btn setImage:[UIImage imageNamed:arr2[i]] forState:UIControlStateNormal];
            } else {
                [btn setImage:[UIImage imageNamed:arr1[i]] forState:UIControlStateNormal];
            }
        }
        [view addSubview:btn];
    }
}

//此方法在数据请求完毕后调用
- (void)createFirstView {
    
    [self createCollction];
    _firstView = [[UIView alloc] init];
    [self createCollction];
    [_firstView addSubview:_headCollection];
    
    //title
    UILabel *titleLab = [[UILabel alloc] init];
    NSString *str = [LVTools mToString:_detailModel.matchName];
    CGFloat nameLabWidth = [LVTools sizeWithStr:str With:17 With2:20];
    titleLab.frame = CGRectMake(10, _headCollection.bottom+20, nameLabWidth, 20);
    titleLab.text = str;
    [_firstView addSubview:titleLab];
    
    UIImageView *stateImg = [[UIImageView alloc] initWithFrame:CGRectMake(titleLab.right, _headCollection.bottom+15, 65, 25)];
    NSString *matchStatus = [LVTools mToString:_detailModel.matchStatusCode];
    if ([matchStatus isEqualToString:@"0"]) {
        [stateImg setImage:[UIImage imageNamed:@"BisaiBegin"]];
    } else if ([matchStatus isEqualToString:@"1"]) {
        [stateImg setImage:[UIImage imageNamed:@"BisaiEnd"]];
    } else {
        [stateImg setImage:[UIImage imageNamed:@"Bisaiing"]];
    }
    [_firstView addSubview:stateImg];

    NSArray *contentArr = [[NSArray alloc] initWithObjects:[LVTools mToString: _detailModel.chief],[LVTools mToString:_detailModel.hosted],[LVTools mToString:_detailModel.registrationFee],[LVTools mToString:_detailModel.cityMeaning],[LVTools mToString:_detailModel.startDate],[LVTools mToString:_detailModel.signUpDate],[LVTools mToString:_detailModel.phone], nil];
    NSArray *preimageArray = @[@"zhuban_sport_wpc",@"chengban_sport_wpc",@"feiyong_sport_wpc",@"chengshi_sport_wpc",@"begin_sport_wpc",@"end_sport_wpc",@"phone_sport_wpc"];
    for (int i = 0; i < _keysArray.count; i ++) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, titleLab.bottom+14+30*i, 16, 16)];
        img.layer.cornerRadius = 8;
        img.image = [UIImage imageNamed:preimageArray[i]];
        img.layer.masksToBounds = YES;
        [_firstView addSubview:img];
        
        CGFloat width1 = [LVTools sizeWithStr:_keysArray[i] With:14 With2:16];
        UILabel *prelab = [[UILabel alloc] initWithFrame:CGRectMake(img.right+5, img.top, width1, 16)];
        prelab.text = _keysArray[i];
        prelab.font = [UIFont systemFontOfSize:14];
        [_firstView addSubview:prelab];
        
        CGFloat width2 = [LVTools sizeWithStr:contentArr[i] With:14 With2:16];
        UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(prelab.right, prelab.top, width2, 16)];
        contentLab.text = contentArr[i];
        contentLab.font = [UIFont systemFontOfSize:14];
        [_firstView addSubview:contentLab];
        if ([_keysArray[i] isEqualToString:@"费用:"]) {
            if ([contentArr[i] length] == 0) {
                NSString *str = @"无(报名费)";
                CGFloat detailwidth = [LVTools sizeWithStr:str With:14 With2:16];
                contentLab.width = detailwidth;
                contentLab.text = str;
            } else {
                NSString *str = [NSString stringWithFormat:@"%@元(报名费)",contentArr[i]];
                CGFloat detailwidth = [LVTools sizeWithStr:str With:14 With2:16];
                contentLab.width = detailwidth;
                contentLab.text = str;
            }
        }
        if ([_keysArray[i] isEqualToString:@"报名截止:"]) {
            UILabel *leftTime = [[UILabel alloc] initWithFrame:CGRectMake(contentLab.right, contentLab.top, 100, 16)];
            leftTime.font = [UIFont systemFontOfSize:14];
            leftTime.text = str;
            leftTime.backgroundColor = NavgationColor;
            leftTime.textColor = [UIColor whiteColor];
            [_firstView addSubview:leftTime];
            
            //计算报名截止时间差
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *appointdate = [formatter dateFromString:contentArr[i]];
            NSTimeInterval appoint = [appointdate timeIntervalSince1970];
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval now = [date timeIntervalSince1970];
            NSTimeInterval cha = now - appoint;
            if (cha < 0) {
                cha = -cha;
                _isTimeOut = NO;
                int day = cha/86400;
                int hour = (cha-day*86400)/3600;
                NSString *textstring = nil;
                if (day != 0 && hour != 0) {
                    textstring = [NSString stringWithFormat:@"还剩%d天%d小时",day,hour];
                } else if (day != 0 && hour == 0) {
                    textstring = [NSString stringWithFormat:@"还剩%d天",day];
                } else if (day == 0 && hour != 0) {
                    textstring = [NSString stringWithFormat:@"还剩%d小时",hour];
                } else {
                    leftTime.hidden = YES;
                }
                CGFloat restwidth = [LVTools sizeWithStr:textstring With:13 With2:15];
                leftTime.text = textstring;
                leftTime.width = restwidth+4;
            } else {//报名已截止
                leftTime.hidden = YES;
                _isTimeOut = YES;
            }
        }
        if ([_keysArray[i] isEqualToString:@"联系电话:"]) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:@"callPhone"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(contentLab.right, contentLab.top, 16, 16);
            [btn addTarget:self action:@selector(phoneClick) forControlEvents:UIControlEventTouchUpInside];
            [_firstView addSubview:btn];
        }
        if (i == _keysArray.count-1) {
            _firstView.frame = CGRectMake(0, 0, UISCREENWIDTH, prelab.bottom+5);
        }
    }
}
- (void)createSecondView {
    _secondView = [[UIView alloc] init];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, UISCREENWIDTH-10, 340*propotion)];
    img.userInteractionEnabled = YES;
    if(_matchPicArray.count!=0){
    [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,_matchPicArray[0][@"path"]]] placeholderImage:nil];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagescanner)];
    [img addGestureRecognizer:tap];
    [_secondView addSubview:img];
    
    UILabel *countLab = [[UILabel alloc] initWithFrame:CGRectMake(img.width-50, img.height-25, 45, 20)];
    NSString *countStr = [NSString stringWithFormat:@"1/%lu",(unsigned long)_matchPicArray.count];
    countLab.text = countStr;
    countLab.textAlignment = NSTextAlignmentRight;
    countLab.textColor = [UIColor grayColor];
    countLab.font = Content_lbfont;
    [img addSubview:countLab];
    
    //分享几个
    _carryView = [[UIView alloc] initWithFrame:CGRectMake(-0.5, img.bottom+5, UISCREENWIDTH+1, 74*propotion)];
    _carryView.layer.borderWidth = 0.5;
    _carryView.layer.borderColor = [RGBACOLOR(222, 222, 222, 1) CGColor];
    [_secondView addSubview:_carryView];
    NSArray *arr = @[@"share_wpc",@"comment_wpc",@"praise_wpc"];
    for (int i = 0 ; i < arr.count; i ++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*(BOUNDS.size.width/3.0)+15, 9.5, 15*3.3636, 15)];
        btn.center = CGPointMake(UISCREENWIDTH/3*i+UISCREENWIDTH/6, 17);
        btn.tag = 300 +i;
        [btn addTarget:self action:@selector(optionOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:arr[i]] forState:UIControlStateNormal];
        if (i == 2) {
            [btn setBackgroundImage:[UIImage imageNamed:@"hasPraised_wpc"] forState:UIControlStateSelected];
        } else {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(UISCREENWIDTH/3*(i+1), 5, 0.5, _carryView.height-10)];
            lineView.backgroundColor = RGBACOLOR(222, 222, 222, 1);
            [_carryView addSubview:lineView];
        }
        [_carryView addSubview:btn];
    }
    _dianzanScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _carryView.bottom, UISCREENWIDTH, 120*propotion)];
    _dianzanScrollview.contentSize = CGSizeMake(UISCREENWIDTH, 120*propotion);
    _dianzanScrollview.showsHorizontalScrollIndicator = NO;
    [_secondView addSubview:_dianzanScrollview];
    [self setZanImagesWithArray:_praiseArray];
    _secondView.frame = CGRectMake(0, _firstView.bottom, UISCREENWIDTH, _dianzanScrollview.bottom);
}

- (void)createCollction {
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.itemSize = CGSizeMake(UISCREENWIDTH/6, 110*propotion);
    _headCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 110*propotion) collectionViewLayout:flowlayout];
    [_headCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:headCollectID];
    _headCollection.dataSource = self;
    _headCollection.backgroundColor = RGBACOLOR(239, 239, 239, 1);
    _headCollection.delegate = self;
}

- (void)initialDatasource {

    _liuyanArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setObject:self.MatchModel.id forKey:@"id"];
    NSString *str = [kUserDefault objectForKey:kUserLogin];
    if ([str isEqualToString:@"1"]) {
        [dic setObject:[LVTools mToString:[kUserDefault objectForKey:kUserId]] forKey:@"uid"];
    }
    [self showHudInView:self.view hint:LoadingWord];
    request = [DataService requestWeixinAPI:getMatchDetail parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        self.wholeInfoDic = [NSMutableDictionary dictionaryWithDictionary:result];//返回的总数据
        NSLog(@"---------------------%@",self.wholeInfoDic);
        [self hideHud];
        if ([[_wholeInfoDic objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"]) {
            _detailModel = [[GetMatchListModel alloc] init];
            [_detailModel setValuesForKeysWithDictionary:self.wholeInfoDic[@"match"]];//赛事详情的基本信息
            self.matchPicArray = [NSArray arrayWithArray:self.wholeInfoDic[@"matchPicList"]];//图片数组信息
            //整理评论和回复，按评论id大小排序
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < [self.wholeInfoDic[@"msgList"] count]; i ++) {
                [tempArray addObject:[LVTools mToString:[self.wholeInfoDic[@"msgList"] objectAtIndex:i][@"id"]]];
            }
            for (int i = 0; i < [self.wholeInfoDic[@"replyMsgList"] count]; i ++) {
                [tempArray addObject:[LVTools mToString:[self.wholeInfoDic[@"replyMsgList"] objectAtIndex:i][@"id"]]];
            }
            NSMutableArray *totalArray = [NSMutableArray array];
            [totalArray addObjectsFromArray:self.wholeInfoDic[@"msgList"]];
            [totalArray addObjectsFromArray:self.wholeInfoDic[@"replyMsgList"]];
            if ([tempArray count] > 0) {
                [LVTools sortArrayWithArray:tempArray andAscend:NO];
                for (int i = 0; i < tempArray.count; i ++) {
                    for (int j = 0; j < totalArray.count; j ++) {
                        if ([[LVTools mToString:[totalArray objectAtIndex:j][@"id"]] isEqualToString:tempArray[i]]) {
                            [_liuyanArray addObject:totalArray[j]];
                        }
                    }
                }
            }
            _praiseArray = [[NSMutableArray alloc] initWithArray:self.wholeInfoDic[@"praiseList"]];//点赞的信息
            if ([_wholeInfoDic[@"isSignup"] isEqualToString:@"SF_0002"]) {
                _hasApply = NO;
            } else {
                _hasApply = YES;
                self.matchSignUpInfo = self.wholeInfoDic[@"signupInfo"];
            }
            if ([_detailModel.isVerify isEqualToString:@"SF_0002"]) {
                _needVerify = NO;
            } else {
                _needVerify = YES;
            }
            if ([[LVTools mToString:self.MatchModel.registrationFee] length] == 0) {
                _needPay = NO;
            } else {
                _needPay = YES;
            }
            _aboutMeNumString = [LVTools mToString:_wholeInfoDic[@"aboutMeNum"]];
            [self initialInterface];
            for (NSDictionary *dic in _praiseArray) {
                NSString *userId =[LVTools mToString:[dic objectForKey:@"userId"]];
                NSString * uid = [LVTools mToString:[kUserDefault objectForKey:kUserId]];
                if ([userId isEqualToString:uid]) {
                    UIButton *tempbtn = (UIButton *)[_carryView viewWithTag:302];
                    tempbtn.selected = YES;
                }
            }
        }
        else if([result[@"statusCode"] isEqualToString:@"error"]){
            [self showHint:@"该赛事已被删除"];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}

- (void)changePayStatuse {
    _hasPay = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAY_SUCCESS object:nil];
}



#pragma mark -- collection datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:headCollectID forIndexPath:indexPath];
    UILabel *lab = [[UILabel alloc] initWithFrame:cell.bounds];
    lab.backgroundColor = [UIColor clearColor];
    lab.text = _preArray[indexPath.row];
    lab.font = Btn_font;
    lab.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:lab];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(cell.width, 33*propotion, 0.5, 44*propotion)];
    lineView.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [cell.contentView addSubview:lineView];
    
    return cell;
}

#pragma mark -- collection delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //todo
    ZHSportInfoController *vc = [[ZHSportInfoController alloc] init];
    vc.idString = _detailModel.id;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_liuyanArray.count > 5) {
        return 5;
    } else {
        return _liuyanArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    WPCCommentCell *cell = (WPCCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID commentType:WPCSportCommentType];
    }
    
    [cell configTheplayContent:[_liuyanArray objectAtIndex:indexPath.row]];
    cell.headImgView.tag = indexPath.row +100;
    [cell.headImgView addTarget:self action:@selector(userInfoOnclick:) forControlEvents:UIControlEventTouchUpInside];
    cell.morActionBtn.tag = 4700+indexPath.row;
    [cell.morActionBtn addTarget:self action:@selector(morActionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //评论里的图片tag为400+i
    if ([[_liuyanArray objectAtIndex:indexPath.row][@"commentShowList"] count] > 0) {
        for (int i = 0; i < [[_liuyanArray objectAtIndex:indexPath.row][@"commentShowList"] count]; i++) {
            WPCImageView *image = (WPCImageView *)[cell.contentView viewWithTag:400+i];
            image.row = indexPath.row;
            image.userInteractionEnabled = YES;
            UITapGestureRecognizer *commentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImagesFromComment:)];
            [image addGestureRecognizer:commentImgTap];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scanImagesFromComment:(UITapGestureRecognizer *)tap {
    WPCImageView *view = (WPCImageView *)tap.view;
    NSMutableArray *imagearr = [NSMutableArray array];
    for (int i = 0; i < [[_liuyanArray objectAtIndex:view.row][@"commentShowList"] count]; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,[[_liuyanArray objectAtIndex:view.row][@"commentShowList"][i] valueForKey:@"path"]];
        [imagearr addObject:str];
    }
    
    ImgShowViewController *vc = [[ImgShowViewController alloc] initWithSourceData:imagearr withIndex:tap.view.tag-400 hasUseUrl:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_aboutMeNumString isEqualToString:@"0"]) {
        return 40;
    } else {
        return 75;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 30)];
    view1.backgroundColor = [UIColor colorWithRed:0.945f green:0.945f blue:0.945f alpha:1.00f];
    
    [view addSubview:view1];
    
    UILabel *commentCountLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    /** 风格 **/
    commentCountLb.font = [UIFont systemFontOfSize:13.0];
    commentCountLb.textColor = [UIColor grayColor];
    commentCountLb.text =[NSString stringWithFormat: @"   共%lu条评论",(unsigned long)(_liuyanArray.count)];
    [view1 addSubview:commentCountLb];
    
    //点击事件使tableview列表进行收缩或展开
    UIImageView *lab = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-35, 5, 20, 20)];
    lab.image = [UIImage imageNamed:@"arrow"];
    lab.userInteractionEnabled = YES;
    [view1 addSubview:lab];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerlabClick)];
    [lab addGestureRecognizer:tap];
    
    if ([_aboutMeNumString intValue] != 0) {
        NSString *str = [NSString stringWithFormat:@"%@条关于我的评论",_aboutMeNumString];
        [self.aboutMeBtn setTitle:str forState:UIControlStateNormal];
        CGFloat width = [LVTools sizeWithStr:str With:13 With2:13];
        UIView *redView = [[UIView alloc] init];
        redView.frame = CGRectMake(UISCREENWIDTH/2+width/2-2, 7, 6, 6);
        redView.backgroundColor = [UIColor redColor];
        redView.layer.cornerRadius = 3;
        redView.layer.masksToBounds = YES;
        [self.aboutMeBtn addSubview:redView];
        [view addSubview:self.aboutMeBtn];
        view.frame = CGRectMake(0, 0, UISCREENWIDTH, 75);
    } else {
        self.aboutMeBtn.frame = CGRectZero;
        [view addSubview:self.aboutMeBtn];
        view.frame = CGRectMake(0, 0, UISCREENWIDTH, 40);
    }
    return view;
}

- (UIButton *)aboutMeBtn {
    if (!_aboutMeBtn) {
        _aboutMeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _aboutMeBtn.frame = CGRectMake(5, 40, UISCREENWIDTH-10, 25);
        _aboutMeBtn.backgroundColor = RGBACOLOR(74, 159, 212, 1);
        _aboutMeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_aboutMeBtn addTarget:self action:@selector(changeTheTableView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _aboutMeBtn;
}

- (void)clearUpCommentNum {
    [_aboutMeBtn setTitle:@"暂无关于我的评论" forState:UIControlStateNormal];
}

- (void)changeTheTableView
{
    //点击进行刷新tableview，呈现关于自己的评论
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        WPCCommentVC *vc= [[WPCCommentVC alloc] init];
        vc.title = @"关于我的评论";
        vc.fromStyle = StyleResultMatch;
        vc.isMe = YES;
        vc.idString = _detailModel.id;
        vc.chuanBlock = ^(NSArray *arr) {
            if (![_liuyanArray isEqual:arr]) {
                [_liuyanArray removeAllObjects];
                [_liuyanArray addObjectsFromArray:arr];
                [_tableview reloadData];
            }
            for (UIView *view in self.aboutMeBtn.subviews) {
                [view removeFromSuperview];
            }
            _aboutMeNumString = @"0";
            [_tableview reloadData];
        };
        vc.arr = [NSMutableArray arrayWithArray:_liuyanArray];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self jumpToLoginVC];
    }
}

- (void)headerlabClick
{
    WPCCommentVC *vc= [[WPCCommentVC alloc] init];
    vc.title = @"全部评论";
    vc.fromStyle = StyleResultMatch;
    vc.isMe = NO;
    vc.chuanBlock = ^(NSArray *arr) {
        if (![_liuyanArray isEqual:arr]) {
            [_liuyanArray removeAllObjects];
            [_liuyanArray addObjectsFromArray:arr];
            [_tableview reloadData];
        }
    };
    vc.idString = _detailModel.id;
    vc.arr = [NSMutableArray arrayWithArray:_liuyanArray];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [_liuyanArray objectAtIndex:indexPath.row];
    NSString *tempStr;
    if ([[LVTools mToString:[dic objectForKey:@"parentId"]] isEqualToString:@""]) {
        tempStr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
    }
    else{
        tempStr = [NSString stringWithFormat:@"@%@:%@",[dic objectForKey:@"parentName"],[dic objectForKey:@"message"]];
    }
    CGFloat height = [LVTools sizeContent:tempStr With:14 With2:(UISCREENWIDTH-60-50)];
    if ([dic[@"commentShowList"] count] > 0) {
        height += 50;
    }
    return height + 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)talkBtnClick:(UITextView *)textViewGet
{
    if ([LVTools stringContainsEmoji:textViewGet.text]) {
        [self showHint:@"后台暂不支持表情符号"];
        return;
    }
    _contentstring = [NSString stringWithFormat:@"%@",textViewGet.text];
    if (_contentstring.length > 0) {
        _optionStr = optionReply;
        [self insertRequest];
    } else {
        //提示内容不能为空
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 20)];
        label.center = CGPointMake(UISCREENWIDTH/2, UISCREENHEIGHT/2-100);
        label.layer.cornerRadius = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"内容不能为空";
        [self.view addSubview:label];
        label.backgroundColor = [UIColor lightGrayColor];
        label.alpha = 0.8;
        [UIView animateWithDuration:0.8 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }
}

#pragma mark -- action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 601) {
        if (buttonIndex == 0) {
            //回复
            _optionStr = optionReply;
            _partnerId = [NSString stringWithFormat:@"%@",_liuyanArray[_deleteIndex][@"id"]];
            _partnerName = _liuyanArray[_deleteIndex][@"userName"];
            [[HcCustomKeyboard customKeyboard] textViewShowView:self customKeyboardDelegate:self andState:YES];
        } else if (buttonIndex == 1) {
            //删除
            NSMutableDictionary *dic = [LVTools getTokenApp];
            [dic setValue:_liuyanArray[_deleteIndex][@"id"] forKey:@"id"];
            [DataService requestWeixinAPI:delMatchInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                NSLog(@"----------------%@",result);
                [_liuyanArray removeObjectAtIndex:_deleteIndex];
                [_tableview reloadData];
            }];
        }
    } else {
        //回复
        if (buttonIndex == 0) {
            _optionStr = optionReply;
            _partnerId = [NSString stringWithFormat:@"%@",_liuyanArray[_deleteIndex][@"id"]];
            _partnerName = _liuyanArray[_deleteIndex][@"userName"];
            [[HcCustomKeyboard customKeyboard] textViewShowView:self customKeyboardDelegate:self andState:YES];
        }
    }
}

#pragma mark -- private method
//拨打电话
- (void)phoneClick {
    [WCAlertView showAlertWithTitle:nil message:[LVTools mToString:_detailModel.phone] customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            [LVTools callPhoneToNumber:[LVTools mToString:_detailModel.phone] InView:self.view];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
}

- (void)optionOnClick:(UIButton *)btn {
    //是否登陆
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        if (btn.tag ==302 ) {
            //赞
            _optionStr = optionZan;
            [self zanOnclick:btn];
        }
        else if(btn.tag == 301){
            //评论
            //zxf modifed
            ZHCommentController *ComentVC = [[ZHCommentController alloc] init];
            ComentVC.fromStyle = StyleResultComment;
            ComentVC.title = @"写评论";
            ComentVC.count = 3;
            ComentVC.fromStyle = StyleResultMatch;
            ComentVC.idstring = _detailModel.id;
            ComentVC.chuanComment = ^(NSDictionary *dic) {
                [_liuyanArray insertObject:dic atIndex:0];
                [_tableview reloadData];
            };
            [self.navigationController pushViewController:ComentVC animated:YES];
        }
        else{
            //分享
            [self sharOnClick];
        }
    } else {
        //跳转登陆界面
        [self jumpToLoginVC];
    }
}

- (void)zanOnclick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    _optionStr=optionZan;
    if (btn.selected) {//已选中，此时是取消
        for (NSDictionary *dic in _praiseArray) {
            //todo
            NSString *userId =[LVTools mToString:[dic objectForKey:@"userId"]];
            NSString * uid = [LVTools mToString:[kUserDefault objectForKey:kUserId]];
            if ([userId isEqualToString:uid]) {
                NSLog(@"userid ==== %@",userId);
                NSLog(@"uid ==== %@",uid);
                NSLog(@"%@",dic[@"id"]);
                [self cancelPraiseOrDeleteMsg:[LVTools mToString:dic[@"id"]] isCancelPraise:YES];
            }
        }
    } else {
        [self insertRequest];
    }
}

- (void)cancelPraiseOrDeleteMsg:(NSString *)stringid isCancelPraise:(BOOL)cancelordelete {
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:stringid forKey:@"id"];
    
    [DataService requestWeixinAPI:delMatchInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            [self showHint:@"操作成功"];
            if (cancelordelete == YES) {
                UIButton *tempbtn = (UIButton *)[_carryView viewWithTag:302];
                tempbtn.selected = NO;
                _hasRedHeart = NO;
                for (int i = 0; i < _praiseArray.count; i ++) {
                    if ([[LVTools mToString:[_praiseArray[i] objectForKey:@"id"]] isEqualToString:stringid]) {
                        [_praiseArray removeObjectAtIndex:i];
                    }
                }
                [self setZanImagesWithArray:_praiseArray];
            } else {
                [_liuyanArray removeObjectAtIndex:_deleteIndex];
                [_tableview reloadData];
            }
        } else {
            [self showHint:@"操作失败，请重试"];
        }
    }];
}

- (void)insertRequest {
    //赞和回复    操作
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:_detailModel.id forKey:@"matchId"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setObject:_optionStr forKey:@"type"];//点赞
    if (![_optionStr isEqualToString:optionZan]) {
        [dic setObject:_contentstring forKey:@"message"];
    }
    [dic setValue:@[] forKey:@"ids"];
    [dic setObject:[NSString stringWithFormat:@"%@", [NSDate  date]]  forKey:@"interactTime"];//评论时间
    if ([_optionStr isEqualToString:optionReply]) {
        [dic setObject:_partnerId forKey:@"parentId"];//回复的评论的id，回复留言时填充
    }
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:addMatchInteract parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"resultdic ======= %@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
        {
            NSMutableDictionary *objectdict = [[NSMutableDictionary alloc] initWithDictionary:result[@"list"]];
            NSLog(@"result === %@",result);
            if ([_optionStr isEqualToString:optionZan]) {
                
                [objectdict setValue:[kUserDefault objectForKey:KUserIcon] forKey:@"iconPath"];
                [objectdict setObject:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
                [objectdict setObject:[kUserDefault objectForKey:kUserName] forKey:@"userName"];
                UIButton *btn = (UIButton *)[_carryView viewWithTag:302];
                btn.selected = !btn.selected;
                [self showHint:@"点赞成功!"];
                _hasRedHeart = YES;
                [_praiseArray insertObject:objectdict atIndex:0];
                [self animationCurve];
            }
            else{
                [self showHint:@"回复成功"];
                [objectdict setValue:[kUserDefault valueForKey:KUserIcon] forKey:@"iconPath"];
                [objectdict setValue:_partnerName forKey:@"parentName"];
                [objectdict setObject:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]*1000] forKey:@"interactTime"];
                [objectdict setValue:[kUserDefault valueForKey:kUserName] forKey:@"userName"];
                [_liuyanArray insertObject:objectdict atIndex:0];
                [_tableview reloadData];
            }
        }
        else{
            [self showHint:@"操作失败,请重试!"];
        }
    }];
}

- (void)animationCurve
{
    
    UIImageView *redheart = [[UIImageView alloc] initWithFrame:CGRectMake(80*propotion*0.6, 80*propotion*0.7, 80*propotion*0.3, 80*propotion*0.3)];
    redheart.image = [UIImage imageNamed:@"Redheart"];
    redheart.tag = 997;
    redheart.frame = CGRectMake(UISCREENWIDTH/6*5, -25, 80*propotion*0.3, 80*propotion*0.3);
    [_carryView addSubview:redheart];
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, UISCREENWIDTH/6*5, -25);
    CGPathAddQuadCurveToPoint(path, NULL, 150, -70, 10+80*0.8*propotion, 20*propotion+80*0.85*propotion+74*propotion);
    bounceAnimation.path = path;
    [bounceAnimation setAutoreverses:YES];
    bounceAnimation.duration = 1;
    [redheart.layer addAnimation:bounceAnimation forKey:@"move"];
    CFRelease(path);
    if (_praiseArray.count > 1) {
        [self setZanImgAnimationWithArr:_praiseArray];
    } else {
        [self performSelector:@selector(selfZanAnimation) withObject:self afterDelay:0.28f];
        [self performSelector:@selector(changeTheScroll) withObject:self afterDelay:1.0f];
    }
    

}

- (void)setZanImgAnimationWithArr:(NSArray *)arr {
    [UIView animateWithDuration:1 animations:^{
        for (int i = 0; i < _praiseArray.count-1; i ++) {
            UIButton *btn = (UIButton *)[_dianzanScrollview viewWithTag:1300+i];
            btn.frame = CGRectMake(10+105*propotion*(i+1), 20*propotion, 80*propotion, 80*propotion);
        }
        [self performSelector:@selector(selfZanAnimation) withObject:self afterDelay:0.28f];
    } completion:^(BOOL finished) {
        [self setZanImagesWithArray:_praiseArray];
    }];
}

- (void)selfZanAnimation {
    UIImageView *selfZan = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 2, 2)];
    selfZan.center = CGPointMake(10+40*propotion,60*propotion);
    selfZan.layer.cornerRadius = 1;
    selfZan.layer.masksToBounds = YES;
    [selfZan sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[kUserDefault valueForKey:KUserIcon]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    [_dianzanScrollview addSubview:selfZan];
    
    CGAffineTransform transform = CGAffineTransformScale(selfZan.transform, 40*propotion, 40*propotion);
    [UIView animateWithDuration:0.72f animations:^{
        selfZan.transform = transform;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)changeTheScroll
{
    [self setZanImagesWithArray:_praiseArray];
}

- (void)setZanImagesWithArray:(NSMutableArray*)array{

    for (UIView *view in _dianzanScrollview.subviews) {
        [view removeFromSuperview];
    }
    
    
    _dianzanScrollview.contentSize = CGSizeMake(105*propotion*[array count]+10, _dianzanScrollview.height);
    for (NSInteger i= 0; i<[array count]; i++) {
        NSDictionary *dic =[array objectAtIndex:i];
        UIButton *imageV = [[UIButton alloc] initWithFrame:CGRectMake(10+105*propotion*i, 20*propotion, 80*propotion, 80*propotion)];
        imageV.layer.masksToBounds = YES;
        imageV.layer.cornerRadius = 40*propotion;
        imageV.tag = 1300+i;
        [imageV sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[dic objectForKey:@"iconPath"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        [imageV addTarget:self action:@selector(userInfoOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [_dianzanScrollview addSubview:imageV];
        
    }
    UIImageView *img = (UIImageView *)[_carryView viewWithTag:997];
    [img removeFromSuperview];
    img = nil;
    if (_hasRedHeart) {
        UIImageView *redheart = [[UIImageView alloc] init];
        redheart.frame = CGRectMake(10+80*propotion*0.65, 80*propotion*0.7+20*propotion, 80*propotion*0.3, 80*propotion*0.3);
        redheart.image = [UIImage imageNamed:@"Redheart"];
        [_dianzanScrollview addSubview:redheart];
    }
}

- (void)jumpToLoginVC{
    LoginHomeZhViewController *loginVC = [[LoginHomeZhViewController alloc] init];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
}

- (void)sharOnClick {
    if([[LVTools mToString:self.wholeInfoDic[@"matchName"]] length]!= 0){
    [LVShareManager shareText:[NSString stringWithFormat:@"快来下载约战123,参加比赛－%@,猛戳下载%@",self.wholeInfoDic[@"matchName"],kDownLoadUrl] Targert:self];
    }
    else{
        [LVShareManager shareText:kShareText Targert:self];
    }
}
- (void)morActionBtnClick:(UIButton *)sender
{
    //先判断是否登陆
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        //删除按钮
        _deleteIndex = sender.tag - 4700;
        _deleteIndex = sender.tag - 4700;
        if ([_liuyanArray[_deleteIndex][@"userId"] intValue] == [[LVTools mToString:[kUserDefault objectForKey:kUserId]] intValue]) {
            //表明是这个人发的，有删除评论
            UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"回复" otherButtonTitles:@"删除", nil];
            actionsheet.tag = 601;
            [actionsheet showInView:self.view];
        } else {
            UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"回复" otherButtonTitles:nil, nil];
            actionsheet.tag = 602;
            [actionsheet showInView:self.view];
        }
    } else { 
        [self jumpToLoginVC];
    }
}

- (void)userInfoOnclick:(UIButton*)btn{
    //./symbolicatecrash temp..yxijkemu.crash yuezhan123.app.dSYM > yuezhan123_symbol.crash
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        NSDictionary *dic = nil;
        if (btn.tag >= 1300) {//点赞头像
            dic = _praiseArray[btn.tag-1300];
        } else {//评论区头像
            dic = _liuyanArray[btn.tag-100];
        }
        NSString *useId =[LVTools mToString:[dic objectForKey:@"userId"]];
        NSString *selfid = [LVTools mToString:[kUserDefault objectForKey:kUserId]];
        if (![useId isEqualToString:selfid]) {
            WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
            vc.uid = useId;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            //进入自己的个人中心心
            WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
            vc.basicVC = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [self jumpToLoginVC];
    }
}

- (void)bottomBtnClick:(UIButton *)sender
{
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        if (sender.tag == 310) {
            NSLog(@"邀请好友方法");
            ZHInviteFriendController *inviteVC= [[ZHInviteFriendController alloc] init];
            inviteVC.applyId = @"22";
            inviteVC.nameStr = self.MatchModel.matchName;
            inviteVC.type = @"2";
            inviteVC.chuanBlock = ^(NSArray *arr){
                [self showHint:@"邀请成功"];
            };
            [self.navigationController pushViewController:inviteVC animated:YES];
        } else {
            if (_hasApply) {
                [self popManageView];
            } else {
                //我要报名
                //1.判断报名是否截止
                if (_isTimeOut) {
                    [self showHint:@"报名已截止，不能报名"];
                } else {
                    //判断报名人数是否已满
                    NSLog(@"%@%@",self.MatchModel.registrationNumber,self.MatchModel.maxUser);
                    if ([self.MatchModel.registrationNumber integerValue] < [self.MatchModel.maxUser integerValue]) {
                        [self popBaoMingView];
                    }
                    else{
                        [self showHint:@"报名人数已满,下次早点来哦"];
                    }
                }
            }
        }
    } else {
        [self jumpToLoginVC];
    }
}

- (void)popBaoMingView {
    NSArray *baomingArray = @[@[@"BMFS_0001",@"个人报名",@0],@[@"BMFS_0002",@"团队报名",@1]/*,@[@"BMFS_0003",@"下载报名表",@2]*/];
    NSArray *signUpStyle = [[LVTools mToString:_detailModel.signUpType] componentsSeparatedByString:@","];
    _baomingList = [NSMutableArray array];
    for (int i = 0; i < signUpStyle.count; i ++) {
        for (int j = 0; j < baomingArray.count; j ++) {
            if ([signUpStyle[i] isEqualToString:baomingArray[j][0]]) {
                [_baomingList addObject:baomingArray[j]];
            }
        }
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < _baomingList.count; i ++) {
        [arr addObject:_baomingList[i][1]];
    }
    CGPoint point = CGPointMake(UISCREENWIDTH*3/4, UISCREENHEIGHT-45);
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:arr images:nil andStyle:PopoverStyleDefault];
    pop.popStyle = PopoverStyleDefault;
    pop.selectRowAtIndex = ^(NSInteger index){
        self.isModify = NO;
        [self loadListWithIndex:index];
    };
    __block PopoverView *tempPop = pop;
    pop.dismissBlock = ^() {
        tempPop = nil;
    };
    [pop show];
}

- (void)popManageView {//分：审核支付，不审核不支付，审核不支付，不审核支付.主流分支还是审核进行判断(如果用户已经支付，则不能操作)
    
    if (![self.wholeInfoDic[@"order"] isKindOfClass:[NSNull class]] && [[LVTools mToString:self.wholeInfoDic[@"order"][@"status"]] isEqualToString:DDZT_0002]) {
        _hasPay = YES;
    }
    if (_hasPay == YES) {
        [self showHint:@"支付后不得修改"];
        return;
    }
    if (![self.wholeInfoDic[@"order"] isKindOfClass:[NSNull class]] && [[LVTools mToString:self.wholeInfoDic[@"order"][@"status"]] isEqualToString:DDZT_0003]) {
        [self showHint:@"您的报名已作废"];
        return;
    }
    if (_needVerify == NO) {
        NSArray *arr = @[@"修改报名",@"取消报名"];
        CGPoint point = CGPointMake(UISCREENWIDTH*3/4, UISCREENHEIGHT-45);
        PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:arr images:nil andStyle:PopoverStyleDefault];
        pop.selectRowAtIndex = ^(NSInteger index){
            if (index == 0) {
                self.isModify = YES;
                //修改报名
                if ([self.matchSignUpInfo[@"signupType"] isEqualToString:@"BMFS_0001"]) {
                    //个人报名
                    [self loadListWith:BaomingPersonal];
                } else if ([self.matchSignUpInfo[@"signupType"] isEqualToString:@"BMFS_0002"]) {
                    //团队报名
                    [self loadListWith:BaomingTeamal];
                } else {
                    
                }
            } else {
                //取消报名
                [WCAlertView showAlertWithTitle:nil message:@"确定要取消该报名吗" customizationBlock:^(WCAlertView *alertView) {
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    if (buttonIndex == 1) {
                        NSMutableDictionary *dic = [LVTools getTokenApp];
                        [dic setValue:self.matchSignUpInfo[@"id"] forKey:@"id"];
                        [DataService requestWeixinAPI:delMatchSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                            if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                                UIButton *btn = (UIButton *)[self.view viewWithTag:311];
                                [btn setImage:[UIImage imageNamed:@"baoming_wpc"] forState:UIControlStateNormal];
                                _hasApply = NO;
                            } else {
                                [self showHint:@"取消报名失败，请重试"];
                            }
                        }];
                    }
                } cancelButtonTitle:@"放弃" otherButtonTitles:@"确定", nil];
            }
        };
        __block PopoverView *tempPop = pop;
        pop.dismissBlock = ^() {
            tempPop = nil;
        };
        [pop show];
    }
    
    if (_needVerify == YES) {
        if ([[LVTools mToString:self.matchSignUpInfo[@"verifyStatus"]] isEqualToString:@"BMSH_0004"]) {
            NSArray *arr = @[@"修改报名",@"取消报名"];
            CGPoint point = CGPointMake(UISCREENWIDTH*3/4, UISCREENHEIGHT-45);
            PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:arr images:nil andStyle:PopoverStyleDefault];
            pop.selectRowAtIndex = ^(NSInteger index){
                if (index == 0) {
                    self.isModify = YES;
                    //修改报名
                    if ([self.matchSignUpInfo[@"signupType"] isEqualToString:@"BMFS_0001"]) {
                        //个人报名
                        [self loadListWith:BaomingPersonal];
                    } else if ([self.matchSignUpInfo[@"signupType"] isEqualToString:@"BMFS_0002"]) {
                        //团队报名
                        [self loadListWith:BaomingTeamal];
                    } else {
                        
                    }
                } else {
                    //取消报名
                    [WCAlertView showAlertWithTitle:nil message:@"确定要取消该报名吗" customizationBlock:^(WCAlertView *alertView) {
                    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 1) {
                            NSMutableDictionary *dic = [LVTools getTokenApp];
                            [dic setValue:self.matchSignUpInfo[@"id"] forKey:@"id"];
                            [DataService requestWeixinAPI:delMatchSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                                if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                                    UIButton *btn = (UIButton *)[self.view viewWithTag:311];
                                    [btn setImage:[UIImage imageNamed:@"baoming_wpc"] forState:UIControlStateNormal];
                                    _hasApply = NO;
                                } else {
                                    [self showHint:@"取消报名失败，请重试"];
                                }
                            }];
                        }
                    } cancelButtonTitle:@"放弃" otherButtonTitles:@"确定", nil];
                }
            };
            __block PopoverView *tempPop = pop;
            pop.dismissBlock = ^() {
                tempPop = nil;
            };
            [pop show];
        } else {
            [self showHint:@"报名审核开始后不得修改"];
        }
    }
}

- (void)loadListWithIndex:(NSInteger)index {
    NSNumber *number = _baomingList[index][2];
    [self loadlistwithnumber:number];
}

- (void)loadlistwithnumber:(NSNumber *)num {
    if ([num isEqual:@0]) {
        [self loadListWith:BaomingPersonal];
    } else if ([num isEqual:@1]) {
        [self loadListWith:BaomingTeamal];
    } else {
        [self loadListWith:BaomingInfo];
    }
}

#pragma mark [获取报名中用到的list]
- (void)loadListWith:(BaomingType)type{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:_detailModel.id forKey:@"id"];
    [dic setValue:[LVTools mToString:[kUserDefault objectForKey:kUserId]] forKey:@"uid"];
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:toSignUp parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"]) {
            //获取成功跳转报名页面
            NSMutableArray *sexArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in resultDic[@"genderList"]) {
                ZHItem *sModel = [[ZHItem alloc] init];
                [sModel setValuesForKeysWithDictionary:dict];
                [sexArray addObject:sModel];
            }
            NSMutableArray *cardArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in resultDic[@"cardTypeList"]) {
                ZHItem *sModel = [[ZHItem alloc] init];
                [sModel setValuesForKeysWithDictionary:dict];
                [cardArray addObject:sModel];
            }
            
            NSMutableArray *saizhiArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in resultDic[@"matchGroupList"]) {
                ZHItem *sModel = [[ZHItem alloc] init];
                [sModel setValuesForKeysWithDictionary:dict];
                [saizhiArray addObject:sModel];
            }
            GetMatchListModel *model = [[GetMatchListModel alloc] init];
            [model setValuesForKeysWithDictionary:resultDic[@"match"]];
            ZHAppointBaomingController *baomingVC = [[ZHAppointBaomingController alloc] init];
            baomingVC.baoMingtype = type;
            if (type == BaomingInfo) {
                baomingVC.title = @"下载报名表";
            }
            else if(type == BaomingPersonal){
                baomingVC.title = @"个人报名";
            }
            else{
                baomingVC.title = @"团队报名";
            }
            baomingVC.chuanBlock = ^(NSArray *arr){
                UIButton *btn = (UIButton *)[self.view viewWithTag:311];
                [btn setImage:[UIImage imageNamed:@"manager_wpc"] forState:UIControlStateNormal];
                self.matchSignUpInfo = arr[0];
                NSLog(@"sign ----- %@",self.matchSignUpInfo);
                _hasApply = YES;
            };
            baomingVC.matchModel =model;
            baomingVC.sexList = sexArray;
            baomingVC.cardList = cardArray;
            baomingVC.msaizhiList = saizhiArray;
            if (self.isModify) {
                baomingVC.signupInfo = self.matchSignUpInfo;
                baomingVC.isModify = self.isModify;
                baomingVC.title = @"修改报名";
            }
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:baomingVC animated:YES];
        }
        else{
            [self showHint:@"请重试"];
        }
    }];
}

- (void)imagescanner {
    //20张图片浏览
    NSMutableArray *pathArrays = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < _matchPicArray.count; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:_matchPicArray[i][@"path"]]];
        [pathArrays addObject:str];
    }
    ImgShowViewController *imgshowVC =[[ImgShowViewController alloc] initWithSourceData:pathArrays withIndex:0 hasUseUrl:YES];
    [self.navigationController pushViewController:imgshowVC animated:YES];
}

//去掉heaview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableview) {
        CGFloat sectionHeaderHeight = 75;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

@end
