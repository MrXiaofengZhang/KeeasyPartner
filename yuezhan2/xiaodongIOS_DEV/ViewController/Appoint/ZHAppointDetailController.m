//
//  ZHAppointDetailController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHAppointDetailController.h"
#import "ZHCollectionCell.h"
#import "GetAppliesModel.h"
#import "ZHInviteFriendController.h"
#import "LoginHomeZhViewController.h"
#import "ChatViewController.h"
#import "AppDelegate.h"
#import "LVShareManager.h"
#import "NearByModel.h"
#import "ZHAppointBuildController.h"
#import "RCDraggableButton.h"
#import "HcCustomKeyboard.h"
#import "WPCFriednMsgVC.h"
#import "WPCMyOwnVC.h"
#import "ZHCommentController.h"
#import "ZHYingzhanController.h"
#import "WPCCommentCell.h"
#import "WPCCommentVC.h"
#import "PopoverView.h"
#import "ImgShowViewController.h"
#import "ZHTeamDetailController.h"
#import "WPCImageView.h"
#import "ZHNavigation.h"

#define BottomBtn_height 20.0f
#define TextViewleft 30.0f
#define TextViewTop 140.0f
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ZHAppointDetailController ()<HcCustomKeyboardDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,ZHRefreshDelegate,UINavigationControllerDelegate,CommentClearUpDelegate>{
    UIWindow *mainWindow;
    NSMutableString *friendstr;
    AppDelegate *ap;
    NSMutableArray *testArray;
    UIView *sectionHeadview;
}
@property (nonatomic,strong) NSString *optionStr;
@property (nonatomic,strong) NSString *partnerId;
@property (nonatomic,strong) NSString *partnerName;
@property (nonatomic, strong)RCDraggableButton * postMatch;
@property (nonatomic, copy)NSString *contentstring;
@property (nonatomic, assign)BOOL isSelf;
@property (nonatomic, strong) UIImageView *colorImage;
@property (nonatomic, assign)BOOL hasResultImg;//判断是否有赛果图片
@property (nonatomic, assign)BOOL hasResult;//判断是否有赛果
@property (nonatomic, assign)NSInteger resultImgCount;
@property (nonatomic, assign)CGFloat resultHeight;
@property (nonatomic, strong)UITextView *resultTextView;
@property (assign)CGRect rect;
@property (nonatomic, strong)UILabel *placeHolderlabel;
@property (nonatomic, strong)UILabel *rstLabel;
@property (nonatomic, strong)UIView *carryView;
@property (nonatomic, strong)UIView *headView;
@property (nonatomic, strong)UIActionSheet *action;
@property (nonatomic, strong)UIButton *deleteimg;
@property (nonatomic, strong)NSMutableArray *resultImgArray;
@property (nonatomic, strong)UIButton *deleteBtn;
@property (nonatomic, assign)NSInteger selectindex;
@property (nonatomic, assign)NSInteger deleteIndex;
@property (nonatomic, strong)NSDictionary *builddic;
@property (nonatomic, assign)NSInteger imgCount;
@property (nonatomic, assign)BOOL hasRedHeart;
@property (nonatomic, strong)NSArray *arryResult;
@property (nonatomic, assign)BOOL isFriend;
@property (nonatomic, assign)BOOL isTimeOut;
@property (nonatomic, strong)NSString *deleteOrCancelID;
@property (nonatomic, strong)NSDictionary *detailDic;
@property (nonatomic, strong)UIButton *aboutMeBtn;
@property (nonatomic, strong)NSMutableArray *playShowList;
@property (nonatomic, strong)NSString *aboutMeNumString;

@end

@implementation ZHAppointDetailController

- (void)viewDidLoad{
    [super viewDidLoad];
    _resultHeight = 0;
    
    //模拟有赛果图片，有赛果数据
    
    _hasRedHeart = NO;
    //详情界面需要先判断是不是本人，
    if ([[LVTools mToString:[kUserDefault objectForKey:kUserId]] isEqualToString:[LVTools mToString:self.model.uid]]) {
        _isSelf = YES;
    } else {
        _isSelf = NO;
    }
    if ([[LVTools mToString:_model.title] length] > 0) {
        self.title = [LVTools mToString:_model.title];
    } else {
        self.title = @"约战详情";
    }
    
    [self navgationBarLeftReturn];
    ap = (AppDelegate*)[UIApplication sharedApplication].delegate;
    mainWindow=ap.window;
    _optionStr = optionZan;
    liuyanArray = [[NSMutableArray alloc] initWithCapacity:0];
    zanArray = [[NSMutableArray alloc] initWithCapacity:0];
    yingzhangArray = [[NSMutableArray alloc] initWithCapacity:0];
    _playShowList = [[NSMutableArray alloc] initWithCapacity:0];
    [self loadDefaultData];
    
}
- (void)sharOnClick{
    if([[LVTools mToString:[kUserDefault objectForKey:kUserLogin]] isEqualToString:@"1"]){
    [LVShareManager shareText:[NSString stringWithFormat:@"来参加我发起的约战－%@,点击查看详情%@",[LVTools mToString:_model.title],kDownLoadUrl] Targert:self];
    }
    else{
        LoginHomeZhViewController *loginVC = [[LoginHomeZhViewController alloc] init];
        [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
    }
}

- (void)locationOnClick{
    //    Amappilot *amappilot = [[Amappilot alloc] init];
    if ( [[LVTools mToString:_builddic[@"latitude"]] isEqualToString:@""]||[[LVTools mToString:_builddic[@"longitude"]] isEqualToString:@""]) {
        [self showHint:@"抱歉,还没有相关数据,详情请致电"];
        return;
    }
    else{
        //    [amappilot firstNaviLat:self.vennueModel.latitude WithLng:self.vennueModel.longitude WithTargr:self];
        //[amappilot firstNaviLat:@"116.3" WithLng:@"39.9" WithTargr:self];
        ZHNavigation *_zhnavigation;
        _zhnavigation=[[ZHNavigation alloc]initWithBkDelegate:self];
        CLLocationCoordinate2D OriginLocation,DestinationLocation;
        OriginLocation.latitude=[[kUserDefault objectForKey:kLocationLat] floatValue];
        
        OriginLocation.longitude=[[kUserDefault objectForKey:kLocationlng] floatValue];
        NSLog(@"latitude=%f", OriginLocation.latitude);
        NSLog(@"longitude=%f", OriginLocation.longitude);
        DestinationLocation.latitude=[_builddic[@"latitude"] floatValue];
        DestinationLocation.longitude=[_builddic[@"longitude"] floatValue];
        
        [_zhnavigation showNavigationWithOriginLocation:OriginLocation WithDestinationLocation:DestinationLocation WithOriginTilte:nil WithDestinationTitle:nil];
    }
}


//发起约战按钮
- (void)viewWillAppear:(BOOL)animated{
    //发起约战
    [super viewWillAppear:animated];
//    for (UIView *view in self.view.subviews) {
//        [view removeFromSuperview];
//    }
//    [self loadDefaultData];
    [self postMatch];
    if (!_postMatch.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:_postMatch];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.postMatch removeFromSuperview];
}

- (void)cancelPraiseOrDeleteMsg:(NSString *)stringid isCancelPraise:(BOOL)cancelordelete {
    NSMutableDictionary *dic = [LVTools getTokenApp];
    [dic setValue:stringid forKey:@"id"];
    
    [DataService requestWeixinAPI:delInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            [self showHint:@"操作成功"];
            if (cancelordelete == YES) {
                UIButton *tempbtn = (UIButton *)[_secondView viewWithTag:202];
                tempbtn.selected = NO;
                _hasRedHeart = NO;
                for (int i = 0; i < zanArray.count; i ++) {
                    if ([[LVTools mToString:[zanArray[i] objectForKey:@"id"]] isEqualToString:stringid]) {
                        [zanArray removeObjectAtIndex:i];
                    }
                }
                [self setZanImagesWithArray:zanArray];
            } else {
                [liuyanArray removeObjectAtIndex:_deleteIndex];
                [_mTableView reloadData];
            }
        } else {
            [self showHint:@"操作失败，请重试"];
        }
    }];
}

- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark --越战按钮
- (RCDraggableButton *)postMatch{
    if (!_postMatch) {
        _postMatch = [[RCDraggableButton alloc] initInKeyWindowWithFrame:CGRectMake(10, CGRectGetHeight(BOUNDS)-140, 72, 72) WithMatch:NO];
        __weak typeof(self) weakSelf =self;
        _postMatch.layer.borderWidth = 0;
        
        [_postMatch setTapBlock:^(RCDraggableButton *_postMatch) {
            if([[LVTools mToString:[kUserDefault objectForKey:kUserId]] isEqualToString:@""]){
                [weakSelf showHint:@"登录后才能发起约战"];
                return ;
            }
            if ([[weakSelf.navigationController.viewControllers lastObject] isKindOfClass:[ZHAppointBuildController class]]) {
                
            }
            else{
                ZHAppointBuildController *buildVC = [[ZHAppointBuildController alloc] init];
                buildVC.title = @"发起约战";
                buildVC.hidesBottomBarWhenPushed = YES;
                [weakSelf.postMatch removeFromSuperview];
                [weakSelf.navigationController pushViewController:buildVC animated:YES];
            }
        }];
        [_postMatch setLongPressBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow ===  LongPress!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setDoubleTapBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow ===  DoubleTap!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setDraggingBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === Dragging!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setDragDoneBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === DragDone!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setAutoDockingBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === AutoDocking!!! ===");
            //More todo here.
            
        }];
        
        [_postMatch setAutoDockingDoneBlock:^(RCDraggableButton *avatar) {
            NSLog(@"\n\tAvatar in keyWindow === AutoDockingDone!!! ===");
            //More todo here.
            
        }];
        
    }
    return _postMatch;
}

- (void)postMatchOnClick{
    ZHAppointBuildController *buildVC = [[ZHAppointBuildController alloc] init];
    buildVC.title = @"发起约战";
    buildVC.hidesBottomBarWhenPushed = YES;
    [self.postMatch removeFromSuperview];
    [self.navigationController pushViewController:buildVC animated:YES];
}

- (void)createUI{
    
    [self.view addSubview:self.mTableView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _mTableView.bottom, BOUNDS.size.width, 0.4)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, _mTableView.bottom, UISCREENWIDTH, 45)];
    tempView.backgroundColor = RGBACOLOR(245, 245, 245, 1);
    [self.view addSubview:tempView];
    tempView.layer.borderWidth = 0.5;
    tempView.layer.borderColor = [RGBACOLOR(205, 205, 205, 1) CGColor];
    UIView *gapLine = [[UIView alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2-0.25, 5, 0.5, 35)];
    gapLine.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    [tempView addSubview:gapLine];
    
    //新版中，最下面的两个按钮
    NSArray *arr1 = @[@"invite_wpc",@"yingzhan_wpc"];
    NSArray *arr2 = @[@"invite_wpc",@"manager_wpc"];
    for (int i = 0; i < 2; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentMode = UIViewContentModeScaleToFill;
        btn.frame = CGRectMake(UISCREENWIDTH/2*i, 0, UISCREENWIDTH/2-0.5, 45);
        [btn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 300 +i;
        if (i == 0) {
            [btn setImage:[UIImage imageNamed:arr1[i]] forState:UIControlStateNormal];
        } else if (i == 1) {
            if (_isSelf) {
                [btn setImage:[UIImage imageNamed:arr2[i]] forState:UIControlStateNormal];
            } else {
                [btn setImage:[UIImage imageNamed:arr1[i]] forState:UIControlStateNormal];
            }
        }
        [tempView addSubview:btn];
    }
}

- (void)bottomBtnClick:(UIButton *)sender
{
    //先判断是否登陆了
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
        if (sender.tag == 300) {
            NSLog(@"邀请好友方法");
            ZHInviteFriendController *inviteVC= [[ZHInviteFriendController alloc] init];
            inviteVC.applyId =_model.id;
            inviteVC.nameStr = self.model.title;
            inviteVC.type = @"0";
            inviteVC.chuanBlock = ^(NSArray *arr){
                
                if (friendstr == nil) {
                    friendstr = [[NSMutableString alloc] init];
                }
                [friendstr setString:@""];
                for (NearByModel *model in arr) {
                    [friendstr appendFormat:@"%@,",model.uid];
                }
            };
            [self.navigationController pushViewController:inviteVC animated:YES];
        } else {
            if (_isSelf) {
                //管理菜单
                CGPoint point = CGPointMake(UISCREENWIDTH*3/4, UISCREENHEIGHT-45);
                NSArray *arr = @[@"修改",@"删除约战"];
                PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:arr images:nil andStyle:PopoverStyleDefault];
                pop.popStyle = PopoverStyleDefault;
                __weak typeof(self) weakSelf =self;
                pop.selectRowAtIndex = ^(NSInteger index){
                    if (index == 0) {
                        //修改,推到发起约占界面
                        NSString *timeOut = [LVTools time:_builddic[@"playTime"]];
                        //判断该约战是否过去，过期就提示
                        if ([timeOut isEqualToString:@"1"]) {
                            [self showHint:@"该约战已过期，不能修改"];
                        } else {
                            ZHAppointBuildController *vc = [[ZHAppointBuildController alloc] init];
                            vc.title = @"修改约战";
                            vc.chuanBlock = ^(NSArray *arr) {
                                for (UIView *view in self.view.subviews) {
                                    [view removeFromSuperview];
                                }
                                [self loadDefaultData];
                                
                            };
                            vc.idString = [LVTools mToString:weakSelf.builddic[@"id"]];
                            vc.datasource = [NSMutableDictionary dictionaryWithDictionary:_builddic];
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                    } else {
                        //删除约战
                        [WCAlertView showAlertWithTitle:nil message:@"确定删除该约战吗？" customizationBlock:^(WCAlertView *alertView) {
                            NSLog(@"1");
                        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                            if (buttonIndex == 1) {
                                //向服务器提交删除约战的数据。同时返回首页
                                NSMutableDictionary *dic = [LVTools getTokenApp];
                                [dic setObject:[LVTools mToString:_builddic[@"id"]] forKey:@"id"];
                                NSLog(@"dic ==== %@",dic);
                                [self showHudInView:self.view hint:@"正在删除"];
                                [DataService requestWeixinAPI:deletePlayApply parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"post" completion:^(id result) {
                                    NSLog(@"result ==== %@",result);
                                    [self hideHud];
                                    if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                                        [self showHint:@"删除成功"];
                                        [self.navigationController popViewControllerAnimated:YES];
                                    } else {
                                        [self showHint:@"删除失败"];
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
                sender.selected = !sender.selected;
                if ([[LVTools time:_builddic[@"playTime"]] isEqualToString:@"1"]) {
                    [self showHint:@"该约战已过期，不能应战"];
                } else {
                    if ([sender.currentImage isEqual:[UIImage imageNamed:@"cancel_wpc"]]) {
                        //取消迎战
                        NSDictionary *dic = [LVTools getTokenApp];
                        for (int i = 0; i < yingzhangArray.count; i ++) {
                            if ([[LVTools mToString:yingzhangArray[i][@"uid"]] isEqualToString:[LVTools mToString:[kUserDefault valueForKey:kUserId]]]) {
                                [dic setValue:yingzhangArray[i][@"id"] forKey:@"id"];
                                [DataService requestWeixinAPI:deletePlayReply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                                    if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                                        [sender setImage:[UIImage imageNamed:@"yingzhan_wpc"] forState:UIControlStateNormal];
                                        [yingzhangArray removeObjectAtIndex:i];
                                        _countYzLb.text = [NSString stringWithFormat:@"  已应战%ld",(unsigned long)[yingzhangArray count]];
                                        //重新计算高度
                                        if ([yingzhangArray count]==1) {
                                            _joinedCollectionView.top = _countYzLb.bottom;
                                            _joinedCollectionView.height = 80;
                                            self.mTableView.tableFooterView.height = 120;
                                            [self.mTableView.tableFooterView viewWithTag:900].height = 120;
                                            CGSize size =_mTableView.contentSize;
                                            size.height = size.height+60;
                                            _mTableView.contentSize = size;
                                        }
                                        else if([yingzhangArray count] == 5){
                                            _joinedCollectionView.height = 80*2;
                                            self.mTableView.tableFooterView.height = 200;
                                            [self.mTableView.tableFooterView viewWithTag:900].height = 200;
                                            CGSize size =_mTableView.contentSize;
                                            size.height = size.height+60;
                                            _mTableView.contentSize = size;
                                        }
                                        [_joinedCollectionView reloadData];
                                    } else {
                                        [self showHint:@"取消应战失败，请重试"];
                                    }
                                }];
                            }
                        }
                    } else {
                        ZHYingzhanController *yingzhanVC = [[ZHYingzhanController alloc] init];
                        yingzhanVC.idString = _builddic[@"id"];
                        yingzhanVC.chuanBlock = ^(NSArray *arr) {
                            [yingzhangArray insertObject:arr[0] atIndex:0];
                            _countYzLb.text = [NSString stringWithFormat:@"  已应战%ld",(unsigned long)[yingzhangArray count]];
                            //重新计算高度
                            if ([yingzhangArray count]==1) {
                                _joinedCollectionView.top = _countYzLb.bottom;
                                _joinedCollectionView.height = 80;
                                self.mTableView.tableFooterView.height = 120;
                                [self.mTableView.tableFooterView viewWithTag:900].height = 120;
                                CGSize size =_mTableView.contentSize;
                                size.height = size.height+60;
                                _mTableView.contentSize = size;
                            }
                            else if([yingzhangArray count] == 5){
                                _joinedCollectionView.height = 80*2;
                                self.mTableView.tableFooterView.height = 200;
                                [self.mTableView.tableFooterView viewWithTag:900].height = 200;
                                CGSize size =_mTableView.contentSize;
                                size.height = size.height+60;
                                _mTableView.contentSize = size;
                            }
                            [_joinedCollectionView reloadData];
                            [sender setImage:[UIImage imageNamed:@"cancel_wpc"] forState:UIControlStateNormal];
                        };
                        [self.navigationController pushViewController:yingzhanVC animated:YES];
                    }
                }
            }
        }
    }
    else {
        [self jumpToLoginVC];
    }
}

- (void)animationCurve
{
    UIImageView *redheart = [[UIImageView alloc] initWithFrame:CGRectMake(22, 27, 11, 11)];
    redheart.image = [UIImage imageNamed:@"Redheart"];
    redheart.tag = 997;
    redheart.frame = CGRectMake(UISCREENWIDTH/6*5, -25, 11, 11);
    [_carryView addSubview:redheart];
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, UISCREENWIDTH/6*5, -25);
    CGPathAddQuadCurveToPoint(path, NULL, 150, -60, 34, 77);
    bounceAnimation.path = path;
    [bounceAnimation setAutoreverses:YES];
    bounceAnimation.duration = 1;
    [redheart.layer addAnimation:bounceAnimation forKey:@"move"];
    CFRelease(path);
    if (zanArray.count > 1) {
        [self setZanImgAnimationWithArr:zanArray];
    } else {
        [self performSelector:@selector(selfZanAnimation) withObject:self afterDelay:0.28f];
        [self performSelector:@selector(changeTheScroll) withObject:self afterDelay:1.0f];
    }
}

- (void)setZanImgAnimationWithArr:(NSArray *)arr {
    [UIView animateWithDuration:1 animations:^{
        for (int i = 0; i < zanArray.count-1; i ++) {
            UIButton *btn = (UIButton *)[_dianzanScrollview viewWithTag:1300+i];
            btn.frame = CGRectMake(7+50*(i+1), 0, 36, 36);
        }
        [self performSelector:@selector(selfZanAnimation) withObject:self afterDelay:0.28f];
    } completion:^(BOOL finished) {
        [self setZanImagesWithArray:zanArray];
    }];
}

- (void)selfZanAnimation {
    UIImageView *selfZan = [[UIImageView alloc] initWithFrame:CGRectMake(7, 0, 2, 2)];
    selfZan.center = CGPointMake(23, 18);
    selfZan.layer.cornerRadius = 1;
    selfZan.layer.masksToBounds = YES;
    [selfZan sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[kUserDefault valueForKey:KUserIcon]]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    [_dianzanScrollview addSubview:selfZan];

    CGAffineTransform transform = CGAffineTransformScale(selfZan.transform, 18, 18);
    [UIView animateWithDuration:0.72f animations:^{
        selfZan.transform = transform;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)changeTheScroll
{
    [self setZanImagesWithArray:zanArray];
}

#pragma mark -- 【评论，点赞，恢复越战(insert)】
- (void)insertRequest{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:self.model.id forKey:@"playId"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
    [dic setObject:_optionStr forKey:@"type"];//点赞
    if (![_optionStr isEqualToString:optionZan]) {
        [dic setObject:_contentstring forKey:@"message"];
    }
    NSLog(@"-----%@",_partnerId);
    [dic setObject:[NSString stringWithFormat:@"%@", [NSDate  date]]  forKey:@"interactTime"];//评论时间
    if ([_optionStr isEqualToString:optionReply]) {
        [dic setObject:_partnerId forKey:@"parentId"];//回复的评论的id，回复留言时填充
    }
    
    NSLog(@"dic ===== %@",dic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:addInteract parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
        {
            NSMutableDictionary *objectdict = [[NSMutableDictionary alloc] initWithDictionary:result[@"list"]];
            if ([_optionStr isEqualToString:optionZan]) {
                
                [objectdict setValue:[kUserDefault objectForKey:KUserIcon] forKey:@"iconPath"];
                [objectdict setObject:[kUserDefault objectForKey:kUserId] forKey:@"userId"];
                [objectdict setObject:[kUserDefault objectForKey:kUserName] forKey:@"userName"];
                UIButton *btn = (UIButton *)[_carryView viewWithTag:202];
                btn.selected = !btn.selected;
                [self showHint:@"点赞成功!"];
                _hasRedHeart = YES;
                [zanArray insertObject:objectdict atIndex:0];
                [self animationCurve];
            }
            else{
                [self showHint:@"回复成功"];
                [objectdict setValue:[kUserDefault valueForKey:KUserIcon] forKey:@"iconPath"];
                [objectdict setValue:_partnerName forKey:@"parentName"];
                [objectdict setObject:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]*1000] forKey:@"interactTime"];
                [objectdict setValue:[kUserDefault valueForKey:kUserName] forKey:@"userName"];
                [liuyanArray insertObject:objectdict atIndex:0];
                [_mTableView reloadData];
                UILabel *commentCountLb = (UILabel*)[sectionHeadview viewWithTag:999];
                commentCountLb.text =[NSString stringWithFormat: @"   共%lu条评论",(unsigned long)(liuyanArray.count)];
            }
        }
        else{
            [self showHint:@"操作失败,请重试!"];
        }
    }];
}

- (void)clearUpCommentNum {
    [self.aboutMeBtn setTitle:@"暂无关于我的评论" forState:UIControlStateNormal];
}

#pragma mark --初始化请求数据
- (void)loadDefaultData{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:self.model.id forKey:@"id"];
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
        [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    }
    [self showHudInView:self.view hint:LoadingWord];
    NSLog(@"%@",dic);
    [DataService requestWeixinAPI:getApplyDetail parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"dic ------------- %@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"]) {
            _detailDic = [NSDictionary dictionaryWithDictionary:resultDic];
            _aboutMeNumString = [LVTools mToString:_detailDic[@"aboutMeNum"]];
//            if ([[LVTools mToString:_detailDic[@"aboutMeNum"]] intValue] != 0) {
//                NSString *str = [NSString stringWithFormat:@"%@条关于我的评论",_detailDic[@"aboutMeNum"]];
//                [self.aboutMeBtn setTitle:str forState:UIControlStateNormal];
//                CGFloat width = [LVTools sizeWithStr:str With:13 With2:13];
//                UIView *redView = [[UIView alloc] init];
//                redView.frame = CGRectMake(UISCREENWIDTH/2+width/2-2, 7, 6, 6);
//                redView.backgroundColor = [UIColor redColor];
//                redView.layer.cornerRadius = 3;
//                redView.layer.masksToBounds = YES;
//                [self.aboutMeBtn addSubview:redView];
//            } else {
//                self.aboutMeBtn.frame = CGRectZero;
//                sectionHeadview.frame = CGRectMake(0, 0, UISCREENWIDTH, 50);
////                [self.aboutMeBtn setTitle:@"暂无关于我的评论" forState:UIControlStateNormal];
//            }
            _arryResult = [[NSArray alloc] initWithArray:resultDic[@"playShowList"]];
            if ([resultDic[@"isFriend"] intValue] == 1) {
                //是好友
                _isFriend = YES;
            } else {
                _isFriend = NO;
            }
            _builddic = [NSDictionary dictionaryWithDictionary:resultDic[@"playApply"]];
            [self.model setValuesForKeysWithDictionary:resultDic[@"playApply"]];
            //整理评论和回复，按评论id大小排序
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < [result[@"msgList"] count]; i ++) {
                [tempArray addObject:[LVTools mToString:[result[@"msgList"] objectAtIndex:i][@"id"]]];
            }
            for (int i = 0; i < [result[@"replyMsgList"] count]; i ++) {
                [tempArray addObject:[LVTools mToString:[result[@"replyMsgList"] objectAtIndex:i][@"id"]]];
            }
            [liuyanArray removeAllObjects];
            [zanArray removeAllObjects];
            [yingzhangArray removeAllObjects];
            [_playShowList removeAllObjects];
            NSMutableArray *totalArray = [NSMutableArray array];
            [totalArray addObjectsFromArray:result[@"msgList"]];
            [totalArray addObjectsFromArray:result[@"replyMsgList"]];
            if ([tempArray count] > 0) {
                [LVTools sortArrayWithArray:tempArray andAscend:NO];
                for (int i = 0; i < tempArray.count; i ++) {
                    for (int j = 0; j < totalArray.count; j ++) {
                        if ([[LVTools mToString:[totalArray objectAtIndex:j][@"id"]] isEqualToString:tempArray[i]]) {
                            [liuyanArray addObject:totalArray[j]];
                        }
                    }
                }
            }
            
            [zanArray addObjectsFromArray:resultDic[@"praiseList"]];
            [yingzhangArray addObjectsFromArray:resultDic[@"playReplyList"]];
            [_playShowList addObjectsFromArray:_detailDic[@"playShowList"]];
            
            //ui operator
            [self createUI];
            [self firstViewAddSubViews];
            for (NSDictionary *dic in resultDic[@"praiseList"]) {
                NSString *userId =[LVTools mToString:[dic objectForKey:@"userId"]];
                NSString * uid = [LVTools mToString:[kUserDefault objectForKey:kUserId]];
                if ([userId isEqualToString:uid]) {
                    UIButton *tempbtn = (UIButton *)[_secondView viewWithTag:202];
                    tempbtn.selected = YES;
                }
            }
            _countYzLb.text =[NSString stringWithFormat:@"  已应战%ld",(long)yingzhangArray.count];
            [self setZanImagesWithArray:zanArray];
            [self.mTableView reloadData];
            [self.joinedCollectionView reloadData];
            NSString *isreply =[LVTools mToString: resultDic[@"isReply"]];
            if ([isreply isEqualToString:@"1"]) {
                UIButton *btn = (UIButton *)[self.view viewWithTag:301];
                [btn setImage:[UIImage imageNamed:@"cancel_wpc"] forState:UIControlStateNormal];
            }
            //主线程ui操作
//            __async_main__, ^{
                if ([[LVTools mToString:resultDic[@"playApply"][@"color"]] length] != 0) {
                    _colorImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"color_%@",[LVTools mToString:resultDic[@"playApply"][@"color"]]]];
                }
                //创建用户爱好
                NSString *tempStr = [LVTools mToString:resultDic[@"playApply"][@"loveSports"]];
                NSArray *tempArr = [tempStr componentsSeparatedByString:@","];
                NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
                NSArray *arr = [NSArray arrayWithContentsOfFile:path];
                for (int i = 0; i < tempArr.count; i ++) {
                    for (int j = 0; j < arr.count; j ++) {
                        if ([[LVTools mToString:tempArr[i]] isEqualToString:arr[j][@"sport2"]]) {
                            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(_genderView.right+5+i*17, _genderView.top, 15, 15)];
                            img.image = [UIImage imageNamed:[LVTools mToString:arr[j][@"name"]]];
                            [_zeroView addSubview:img];
                        }
                    }
                }
                //年龄
                NSDate *date = [NSDate date];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSString *timestring = [formatter stringFromDate:date];
                NSString *birthday = [LVTools mToString:resultDic[@"playApply"][@"birthday"]];
                if (birthday.length > 0) {
                    NSString *str1 =[timestring substringToIndex:4];
                    NSString *str2 = [birthday substringToIndex:4];
                    [_genderView setAge:[NSString stringWithFormat:@"%d",[str1 intValue] - [str2 intValue]]];
                } else {
                    [_genderView setAge:@"25"];
                }
                //性别
                NSString *genderstr = [LVTools mToString:resultDic[@"playApply"][@"gender"]];
                if (genderstr.length > 0) {
                    [_genderView setGender:genderstr];
                } else {
                    [_genderView setGender:@"XB_0001"];//默认性别
                }
//            });
        }
        else if([result[@"statusCode"] isEqualToString:@"error"]){
            [self showHint:@"该约战已被发起人删除"];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}



//WPC改
#pragma mark [加好友]
- (void)insertAddFriendRequest{
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:self.model.uid forKey:@"fuid"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setValue:@"1" forKey:@"status"];
    [dic setValue:self.model.userAccount forKey:@"fusername"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"username"];
    [dic setValue:[LVTools mToString:[kUserDefault valueForKey:KUserMobile]] forKey:@"mobile"];
    [dic setValue:self.model.sportsType forKey:@"sportsType"];
    
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:addFrirend parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
        {
            [self showHint:@"加好友成功!"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshOldList object:nil];
            self.isFriend = YES;
        }
        else{
            NSLog(@"请求失败");
            [self showHint:ErrorWord];
        }
    }];
    
}
#pragma mark [应战]
- (void)insertAppointRequest{
    
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:self.model.id forKey:@"applyId"];
    [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
    [dic setValue:[kUserDefault objectForKey:kUserName] forKey:@"username"];
    [dic setValue:[LVTools mToString:[kUserDefault valueForKey:KUserMobile]] forKey:@"mobile"];
    [dic setValue:self.model.sportsType forKey:@"sportsType"];
    
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:addPlayReply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary * resultDic = (NSDictionary *)result;
        NSLog(@"%@",resultDic);
        [self hideHud];
        if ([resultDic[@"statusCode"] isEqualToString:@"success"])
        {
            [self showHint:@"应战成功!"];
            NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithCapacity:0];
            [dict setObject:@"" forKey:@"applyId"];
            [dict setObject:[LVTools mToString:[kUserDefault objectForKey:KUserIcon]] forKey:@"iconPath"];
            [dict setObject:@"" forKey:@"id"];
            [dict setObject:@"" forKey:@"mobile"];
            [dict setObject:@"" forKey:@"replyTime"];
            [dict setObject:@"" forKey:@"sportsType"];
            [dict setObject:[LVTools mToString:[kUserDefault objectForKey:kUserId]] forKey:@"uid"];
            [dict setObject:[LVTools mToString:[kUserDefault objectForKey:kUserName]] forKey:@"username"];
            
            [yingzhangArray addObject:dict];
            
            _countYzLb.text = [NSString stringWithFormat:@"  已应战%ld",(unsigned long)[yingzhangArray count]];
            //重新计算高度
            if ([yingzhangArray count]==1) {
                _joinedCollectionView.top = _countYzLb.bottom;
                _joinedCollectionView.height = 80;
                self.mTableView.tableFooterView.height = 120;
                [self.mTableView.tableFooterView viewWithTag:900].height = 120;
                CGSize size =_mTableView.contentSize;
                size.height = size.height+60;
                _mTableView.contentSize = size;
            }
            else if([yingzhangArray count] == 5){
                _joinedCollectionView.height = 80*2;
                self.mTableView.tableFooterView.height = 200;
                [self.mTableView.tableFooterView viewWithTag:900].height = 200;
                CGSize size =_mTableView.contentSize;
                size.height = size.height+60;
                _mTableView.contentSize = size;
            }
            [_joinedCollectionView reloadData];
        }
        else{
            NSLog(@"请求失败");
            [self showHint:ErrorWord];
        }
    }];
}
- (void)setZanImagesWithArray:(NSMutableArray*)array{
    _countLb.text = [NSString stringWithFormat:@"%lu",(unsigned long)[array count]];
    for (UIView *view in _dianzanScrollview.subviews) {
        [view removeFromSuperview];
    }

    
    _dianzanScrollview.contentSize = CGSizeMake(50*[array count]+10, _dianzanScrollview.height);
    for (NSInteger i= 0; i<[array count]; i++) {
        NSDictionary *dic =[array objectAtIndex:i];
        UIButton *imageV = [[UIButton alloc] initWithFrame:CGRectMake(7+50*i, 0, 36, 36)];
        imageV.layer.masksToBounds = YES;
        imageV.layer.cornerRadius = 18;
        imageV.tag = 1300+i;
        [imageV sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"iconPath"]]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        [imageV addTarget:self action:@selector(userInfoOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [_dianzanScrollview addSubview:imageV];
    }
    UIImageView *img = (UIImageView *)[_carryView viewWithTag:997];
    [img removeFromSuperview];
    img = nil;
    if (_hasRedHeart) {
        UIImageView *redheart = [[UIImageView alloc] init];
        redheart.frame = CGRectMake(29, 27, 10, 10);
        redheart.image = [UIImage imageNamed:@"Redheart"];
        [_dianzanScrollview addSubview:redheart];
    }
}

#pragma mark Getter
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth , kScreenHeight-64-45) style:UITableViewStylePlain];
        _mTableView.showsVerticalScrollIndicator = NO;
        _headView = [[UIView alloc] init];
        _headView.backgroundColor = [UIColor whiteColor];
        
        [_headView addSubview:self.zeroView];
        [_headView addSubview:self.firstView];
        [_headView addSubview:self.secondView];
        
        _headView.frame = CGRectMake(0, 0, kScreenWidth,_secondView.bottom);
        
        _mTableView.tableHeaderView = _headView;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        backView.tag = 901;
        UIView *footView= [[UIView alloc]initWithFrame:CGRectMake(5, 0, BOUNDS.size.width-2*5, 30+80*2)];
        footView.tag = 900;
        [footView addSubview:self.countYzLb];
        [footView addSubview:self.joinedCollectionView];
        footView.height = self.joinedCollectionView.bottom;
        [backView addSubview:footView];
        backView.frame = CGRectMake(0, 0, BOUNDS.size.width, footView.height);
        _mTableView.tableFooterView = backView;
        _mTableView.delegate =self;
        _mTableView.dataSource = self;
    }
    
    return _mTableView;
}
- (UIView*)zeroView{
    if (_zeroView == nil) {
        //头像
        _zeroView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 80)];
        _zeroView.backgroundColor = [UIColor whiteColor];
        [_zeroView addSubview:self.headImage];
        //用户名
        //自适应
        UILabel *lb =[[UILabel alloc] initWithFrame:CGRectMake(_headImage.right+10, 5, 80, 20)];
        lb.textAlignment = NSTextAlignmentLeft;
        lb.font = Btn_font;
        lb.text =[LVTools mToString: self.model.username];
        [lb sizeToFit];
        [_zeroView addSubview:lb];
        //球队战衣颜色
        _colorImage= [[UIImageView alloc] initWithFrame:CGRectMake(lb.right+5, lb.top, 20, 20)];
        [_zeroView addSubview:_colorImage];
        //性别
        _genderView = [[ZHGenderView alloc] initWithFrame:CGRectMake(lb.left, _colorImage.bottom, 30, 15) WithGender:@"XB_001" AndAge:@"25"];
        
        [_zeroView addSubview:_genderView];
        
        //聊天
        [_zeroView addSubview:self.talkBtn];
        _talkBtn.frame = CGRectMake(lb.left, _genderView.bottom+5, 102, 27);
        UIView *lineview = [[UIView alloc] initWithFrame:CGRectMake(0, 79.5, UISCREENWIDTH, 0.5)];
        lineview.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        [_zeroView addSubview:lineview];
    }
    return _zeroView;
}

- (UIButton *)callBtn {
    if (!_callBtn) {
        _callBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        [_callBtn setBackgroundImage:[UIImage imageNamed:@"callPhone"] forState:UIControlStateNormal];
        [_callBtn addTarget:self action:@selector(callOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callBtn;
}

- (void)firstViewAddSubViews {
    for (UIView *view in _firstView.subviews) {
        [view removeFromSuperview];
    }
    NSArray *titleArray = [[NSArray alloc] initWithObjects:@"约战宣言:  ",@"城       市:  ",@"详细地址:  ",@"开始时间:  ",@"联系方式:  ",@"人数限制:  ",@"费       用:  ",@"时       长:  ",@"规       则:  ", nil];
    NSArray *contentArray = [[NSArray alloc] initWithObjects:[LVTools mToString:_builddic[@"introduce"]],[LVTools mToString:_builddic[@"cityMeaning"]],[LVTools mToString:_builddic[@"venuesName"]],[LVTools mToString:_builddic[@"playTime"]],[LVTools mToString:_builddic[@"mobile"]],[LVTools mToString:_builddic[@"applyLimit"]],[LVTools mToString:_builddic[@"remarksFee"]],[LVTools mToString:_builddic[@"remarksTime"]],[LVTools mToString:_builddic[@"remarksType"]], nil];
    for(NSInteger i=0;i<[titleArray count];i++){
        if (i == 0) {
            CGFloat width1 = [LVTools sizeWithStr:@"约战宣言:  " With:13 With2:20.5];
            UILabel *prefixLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, width1, 20.5)];
            prefixLab.font = Content_lbfont;
            prefixLab.text = titleArray[0];
            [_firstView addSubview:prefixLab];
            
            CGFloat height1 = [LVTools sizeContent:contentArray[0] With:13 With2:UISCREENWIDTH-width1-20];
            NSLog(@"height1 == %f",height1);
            UILabel *firstContentLab = [[UILabel alloc] initWithFrame:CGRectMake(prefixLab.right, 10, UISCREENWIDTH-width1-20, height1)];
            firstContentLab.text = contentArray[0];
            firstContentLab.numberOfLines = -1;
            firstContentLab.font = Content_lbfont;
            [_firstView addSubview:firstContentLab];
            
        } else {
            CGFloat width1 = [LVTools sizeWithStr:@"约战宣言:  " With:13 With2:15];
            CGFloat height1 = [LVTools sizeContent:contentArray[0] With:13 With2:UISCREENWIDTH-width1-20];
            
            UILabel *contenLb = [[UILabel alloc] initWithFrame:CGRectMake(10, height1+4.5+10+25*(i-1), kScreenWidth-100-10, 20.5)];
            if (i==3) {
                contenLb.width =kScreenWidth-100-10-5-30;//打电话
            }
            [_firstView addSubview:contenLb];
            contenLb.font = Content_lbfont;
            contenLb.text = [NSString stringWithFormat:@"%@%@",[titleArray objectAtIndex:i],[contentArray objectAtIndex:i]];
            if(i == 4  && [[LVTools mToString:_builddic[@"mobile"]] length] > 0){
                contenLb.width = 150;
                [_firstView addSubview:self.callBtn];
                _callBtn.frame = CGRectMake(contenLb.right, contenLb.top+1.5, 16, 18);
            }
            if (i == 2) {
                CGFloat width = [LVTools sizeWithStr:[NSString stringWithFormat:@"%@%@",[titleArray objectAtIndex:i],[contentArray objectAtIndex:i]] With:13 With2:15];
                if (width >= UISCREENWIDTH-40) {
                    width = UISCREENWIDTH - 40;
                }
                contenLb.width = width;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(contenLb.right, contenLb.top+1.5, 16, 18);
                [btn setBackgroundImage:[UIImage imageNamed:@"mapSelect_wpc"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(mapclick) forControlEvents:UIControlEventTouchUpInside];
                [_firstView addSubview:btn];
            }
            if (i == 3) {
                NSString *str = [[contentArray objectAtIndex:i] substringToIndex:16];
                CGFloat width = [LVTools sizeWithStr:[NSString stringWithFormat:@"%@%@",[titleArray objectAtIndex:i],str] With:13 With2:15];
                contenLb.text = [NSString stringWithFormat:@"%@%@",[titleArray objectAtIndex:i],str];
                contenLb.width = width;
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *appointdate = [formatter dateFromString:[contentArray objectAtIndex:i]];
                NSTimeInterval appoint = [appointdate timeIntervalSince1970];
                
                UILabel *restTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(contenLb.right, contenLb.top, 100, 20.5)];
                restTimeLab.backgroundColor = RGBACOLOR(77,161,218,1);
                restTimeLab.layer.cornerRadius = 2;
                restTimeLab.layer.masksToBounds = YES;
                restTimeLab.font = [UIFont systemFontOfSize:13];
                restTimeLab.textAlignment = NSTextAlignmentCenter;
                restTimeLab.textColor = [UIColor whiteColor];
                [_firstView addSubview:restTimeLab];
                //计算约战开始时间差
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
                        restTimeLab.hidden = YES;
                    }
                    CGFloat restwidth = [LVTools sizeWithStr:textstring With:13 With2:20.5];
                    restTimeLab.text = textstring;
                    restTimeLab.width = restwidth+4;
                } else {//约占已过期
                    restTimeLab.hidden = YES;
                    _isTimeOut = YES;
                }
            }
            if (i == 8) {
                _firstView.frame = CGRectMake(0, _zeroView.bottom+0.5, UISCREENWIDTH, contenLb.bottom);
                _secondView.frame = CGRectMake(0, _firstView.bottom+0.5, kScreenWidth, _carryView.bottom+5);
                _headView.frame = CGRectMake(0, 0, kScreenWidth,_secondView.bottom);
                _mTableView.tableHeaderView = _headView;
            }
        }
    }
    if ([[LVTools mToString:self.model.uid] isEqualToString:[LVTools mToString: [kUserDefault objectForKey:kUserId]]]) {
        _talkBtn.hidden = YES;
    }
}

- (UIView*)firstView{
    if (_firstView == nil) {
        _firstView = [[UIView alloc] initWithFrame:CGRectMake(0, _zeroView.bottom+0.5, kScreenWidth, 230)];
        _firstView.backgroundColor = [UIColor whiteColor];
        
    }
    
    return _firstView;
}

#pragma mark -- 详细地址后面的地图点击事件
- (void)mapclick
{
    [self locationOnClick];
}

- (void)callOnClick:(id)sender{
    //拨打电话
//    [LVTools callPhoneToNumber:_model.mobile InView:self.view];
    [WCAlertView showAlertWithTitle:nil message:[LVTools mToString:_builddic[@"mobile"]] customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            [LVTools callPhoneToNumber:[LVTools mToString:_builddic[@"mobile"]] InView:self.view];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
}

- (void)headimgclick
{
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        if (_isSelf == NO) {
            WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
            vc.uid = self.model.uid;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            //查看自己资料
            WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
            vc.basicVC = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [self jumpToLoginVC];
    }
}

//约战图片
- (UIImageView*)headImage{
    if (_headImage == nil) {
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60,60)];
        _headImage.userInteractionEnabled = YES;
        [_headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:_model.userLogoPath]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headimgclick)];
        [_headImage addGestureRecognizer:tap];
    }
    return _headImage;
}
- (UIButton*)talkBtn{
    if (_talkBtn == nil) {
        _talkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_talkBtn setFrame:CGRectZero];
        [_talkBtn setBackgroundImage:[UIImage imageNamed:@"Btn_talk"] forState:UIControlStateNormal];
        [_talkBtn addTarget:self action:@selector(talkOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _talkBtn;
}

- (void)zanOnclick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    _optionStr=optionZan;
    if (btn.selected) {//已选中，此时是取消
        for (NSDictionary *dic in zanArray) {
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
- (void)replyOnclickInselect:(NSInteger)index{
    
    NSString * isLogin = [LVTools mToString:[kUserDefault objectForKey:kUserLogin]];
    if ([isLogin isEqualToString:@"1"]) {
        NSDictionary *dic =[liuyanArray objectAtIndex:index];
        _optionStr = optionReply;
        _partnerId = [LVTools mToString:[dic objectForKey:@"id"]];
        _partnerName = [LVTools mToString:[dic objectForKey:@"userName"]];
        NSLog(@"点击回复了%@",_partnerId);
        self.grayView.hidden = NO;
        self.backView.hidden = NO;
    }
    else{
        [self jumpToLoginVC];
    }
}

- (void)replyOnclick:(UIButton*)sender{
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
        if (sender.tag == 201) {
            _optionStr = optionLiuyan;
            _partnerId = nil;
            [self newCommentForm];
        } else {
            _optionStr = optionReply;
            _partnerId = [NSString stringWithFormat:@"%ld",(long)sender.tag];
            _partnerName = sender.titleLabel.text;
            [self newCommentForm];
        }
    }
    else{
        [self jumpToLoginVC];
    }
}


//2.0版本的留言评论形式
- (void)newCommentForm
{
    [[HcCustomKeyboard customKeyboard] textViewShowView:self customKeyboardDelegate:self andState:YES];
}

#pragma mark -- HcCustomKeyboardDelegate
-(void)talkBtnClick:(UITextView *)textViewGet
{
    if ([LVTools stringContainsEmoji:textViewGet.text]) {
        [self showHint:@"暂不支持表情符号"];
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


- (void)jumpToLoginVC{
    LoginHomeZhViewController *loginVC = [[LoginHomeZhViewController alloc] init];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
}
- (void)talkOnClick:(id)sender{
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
        //先判断是否为好友
        if (_isFriend) {
            NSString * uid = [NSString stringWithFormat:@"%@",[LVTools mToString:self.model.uid]];
            ChatViewController * vc = [[ChatViewController alloc] initWithChatter:uid isGroup:NO WithIcon:self.model.userLogoPath];
            vc.title = self.model.username;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            //添加好友
             [WCAlertView showAlertWithTitle:nil message:@"添加好友即可聊天" customizationBlock:^(WCAlertView *alertView) {
                
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                if (buttonIndex == 0) {
                    //添加好友接口
                    [self insertAddFriendRequest];
                }
            } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        }
    }
    else{
        [self jumpToLoginVC];
    }
}

- (void)optionOnClick:(UIButton*)btn{
    //先判断是否登陆
    NSString * isLogin = [kUserDefault objectForKey:kUserLogin];
    if ([isLogin isEqualToString:@"1"]) {
        if (btn.tag ==202 ) {
            //赞
            [self zanOnclick:btn];
        }
        else if(btn.tag == 201){
            //评论
            _optionStr = optionLiuyan;
            //zxf modifed
            ZHCommentController *ComentVC = [[ZHCommentController alloc] init];
            ComentVC.fromStyle = StyleResultComment;
            ComentVC.idstring = [LVTools mToString:_builddic[@"id"]];
            ComentVC.title = @"写评论";
            ComentVC.count = 3;
            ComentVC.chuanComment = ^(NSDictionary *dic) {
                [liuyanArray insertObject:dic atIndex:0];
                [_mTableView reloadData];
                UILabel *commentCountLb = (UILabel*)[sectionHeadview viewWithTag:999];
                commentCountLb.text =[NSString stringWithFormat: @"   共%lu条评论",(unsigned long)(liuyanArray.count)];
                //todo
            };
            [self.navigationController pushViewController:ComentVC animated:YES];
        }
        else{
            //分享
            [self sharOnClick];
        }
    }
    else{
        [self jumpToLoginVC];
    }
}

- (UIView*)secondView{
    if (_secondView == nil) {
        _secondView = [[UIView alloc] init];
        _secondView.backgroundColor = [UIColor whiteColor];
        [self createImgForMacth];
        //赞,评论,分享
        _carryView = [[UIView alloc] initWithFrame:CGRectMake(0, _resultHeight+5, UISCREENWIDTH, 85)];
        _carryView.backgroundColor = [UIColor whiteColor];
        [_secondView addSubview:_carryView];
        UIView *lineTop = [[UIView alloc] initWithFrame:CGRectMake(2, 0, BOUNDS.size.width-4, 0.5)];
        lineTop.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        [_carryView addSubview:lineTop];
        NSArray *imgArray = @[@"share_wpc",@"comment_wpc",@"praise_wpc"];
        for (NSInteger i=0; i<3; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*(BOUNDS.size.width/3.0)+15, lineTop.bottom+9.5, 15*3.3636, 15)];
            btn.center = CGPointMake(UISCREENWIDTH/3*i+UISCREENWIDTH/6, 17);
            [btn setBackgroundImage:[UIImage imageNamed:imgArray[i]] forState:UIControlStateNormal];
            btn.tag = 200+i;
            [btn addTarget:self action:@selector(optionOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_carryView addSubview:btn];
            if (i!=0) {
                UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(UISCREENWIDTH/3*i, 5, 0.5, 24)];
                verticalLine.backgroundColor = RGBACOLOR(222, 222, 222, 1);
                [_carryView addSubview:verticalLine];
                if (i == 2) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"hasPraised_wpc"] forState:UIControlStateSelected];
                }
            }
        }
        UIView *lineBottom = [[UIView alloc] initWithFrame:CGRectMake(2, 34, BOUNDS.size.width-4, 0.5)];
        lineBottom.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        [_carryView addSubview:lineBottom];
        [_carryView addSubview:self.dianzanScrollview];
        _carryView.frame = CGRectMake(0, _resultHeight+5, UISCREENWIDTH, self.dianzanScrollview.bottom);
        _secondView.frame = CGRectMake(0, _firstView.bottom+0.5, kScreenWidth, _carryView.bottom+5);
    }
    return _secondView;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 601) {
        if (buttonIndex == 0) {
            //回复
            _optionStr = optionReply;
            _partnerId = [NSString stringWithFormat:@"%@",liuyanArray[_deleteIndex][@"id"]];
            _partnerName = liuyanArray[_deleteIndex][@"userName"];
            [self newCommentForm];
        } else if (buttonIndex == 1) {
            //删除
            [self cancelPraiseOrDeleteMsg:[LVTools mToString:liuyanArray[_deleteIndex][@"id"]] isCancelPraise:NO];
        }
    } else {
        //回复
        if (buttonIndex == 0) {
            _optionStr = optionReply;
            _partnerId = [NSString stringWithFormat:@"%@",liuyanArray[_deleteIndex][@"id"]];
            _partnerName = liuyanArray[_deleteIndex][@"userName"];
            [self newCommentForm];
        }
    }
}

////约战发起人进行赛果修改
- (void)editSportResult:(UIButton *)sender
{
    ZHCommentController *vc = [[ZHCommentController alloc] init];
    vc.fromStyle = StyleResultInfo;
    vc.delegate = self;
    vc.title = @"编辑战果";
    vc.idstring = [LVTools mToString:_builddic[@"id"]];
    NSLog(@"%@",vc.idstring);
    vc.str = _resultTextView.text;
    if (_resultImgArray.count > 5) {
        vc.count = 0;
    } else {
        vc.count = 6 - _resultImgArray.count;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setResultImg{
    UIScrollView *scroll = (UIScrollView *)[_secondView viewWithTag:4400];
    for (UIView *view in scroll.subviews) {
        [view removeFromSuperview];
    }
    for (NSInteger i=0; i<_resultImgArray.count; i++) {
        UIButton *imageV  =(UIButton*)[scroll viewWithTag:4500+i];
        if (imageV==nil) {
            imageV = [[UIButton alloc] initWithFrame:CGRectMake(5+75*i, 5, 60, 60)];
            if (UISCREENWIDTH == 320) {
                imageV.frame = CGRectMake(5+63*i, 10, 50, 50);
            } else if (UISCREENWIDTH == 375) {
                imageV.frame = CGRectMake(5+75*i, 5, 60, 60);
            } else {
                imageV.frame = CGRectMake(12+80*i, 5, 60, 60);
            }
            imageV.tag = 4500+i;
            [imageV addTarget:self action:@selector(imgOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [scroll addSubview:imageV];
        }
        if (i==_resultImgArray.count-1) {
            [imageV setBackgroundImage:[_resultImgArray objectAtIndex:i] forState:UIControlStateNormal];
        }
        else{
//            [imageV sd_setBackgroundImageWithURL:[NSURL URLWithString:[_resultImgArray objectAtIndex:i]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            [imageV sd_setImageWithURL:[NSURL URLWithString:[_resultImgArray objectAtIndex:i]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
            imageV.imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageV.imageView.clipsToBounds = YES;
        }
    }
}

- (void)imgOnClick:(UIButton*)btn{
    if (btn.tag-4500 == _resultImgArray.count-1) {
        ZHCommentController *vc = [[ZHCommentController alloc] init];
        vc.title = @"上传图片";
        vc.idstring = [LVTools mToString:_builddic[@"id"]];
        vc.fromStyle = StyleResultImg;
        if (_resultImgArray.count > 5) {
            vc.count = 0;
        } else {
            vc.count = 6 - _resultImgArray.count;
        }
        vc.chuanBlock = ^ (NSArray *arr) {
            for (int i = 0 ; i < arr.count; i ++) {
                NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,arr[i][@"path"]];
                [_resultImgArray insertObject:str atIndex:0];
                [testArray insertObject:str atIndex:0];
                [_playShowList insertObject:arr[i] atIndex:0];
                NSLog(@"_result === %@",_resultImgArray);
            }
            [self setResultImg];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        //图片
        ImgShowViewController *imgShow = [[ImgShowViewController alloc] initWithSourceData:testArray withIndex:btn.tag-4500 hasUseUrl:YES];
        imgShow.data = testArray;
        imgShow.isSelf = _isSelf;
        imgShow.detailArray = _playShowList;
        imgShow.chuanImg = ^(NSInteger index) {
            [_resultImgArray removeObjectAtIndex:index];
            [testArray removeObjectAtIndex:index];
            [_playShowList removeObjectAtIndex:index];
            [self setResultImg];
        };
        [self.navigationController pushViewController:imgShow animated:YES];
    }
}

//创建约战图片,用于secondview中.此时的所有数据均是模拟的
- (void)createImgForMacth
{
    if ([[LVTools mToString:_builddic[@"results"]] length] > 0) {
        _hasResult = YES;
    } else {
        _hasResult = NO;
    }
    if ([_arryResult count] > 0) {
        _hasResultImg = YES;
    } else {
        _hasResultImg = NO;
    }
    
    //模拟数组个数
    testArray = [[NSMutableArray alloc] initWithCapacity:0];
    _resultImgArray = [NSMutableArray array];
    for (int i = 0; i < _arryResult.count; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,_arryResult[i][@"path"]];
        [_resultImgArray addObject:str];
        [testArray addObject:str];
        
    }
    [_resultImgArray addObject:[UIImage imageNamed:@"addImg_wpc"]];
    
    
    if (_isSelf) {
        //赛果图片系列
        
        //赛果图片系列
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, BOUNDS.size.width-10, 70)];
        scroll.tag = 4400;
        scroll.contentSize = CGSizeMake(80*((_resultImgArray.count>5)?5:_resultImgArray.count), scroll.height);
        [_secondView addSubview:scroll];

        UIView *grayline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 0.5)];
        grayline.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        [_secondView addSubview:grayline];
        [self setResultImg];
        
        _resultHeight +=70;
        
        //赛果视图
        _rstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 40, 18)];
        _rstLabel.font = [UIFont systemFontOfSize:13];
        _rstLabel.tag = 5699;
        _rstLabel.text = @"战果：";
        [_secondView addSubview:_rstLabel];
        
        if (!_resultTextView) {
            _resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, _rstLabel.top-8, UISCREENWIDTH-80, 25)];
            _resultTextView.font = [UIFont systemFontOfSize:13];
            _resultTextView.userInteractionEnabled = NO;
            _resultTextView.layer.borderWidth = 0;
            _resultTextView.delegate = self;
            [_secondView addSubview:_resultTextView];
        }
        
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(_resultTextView.right-10, _resultTextView.top+5, 14, 18);
        editBtn.tag = 5701;
        editBtn.selected = NO;
        [editBtn setBackgroundImage:[UIImage imageNamed:@"editResult_wpc"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(editSportResult:) forControlEvents:UIControlEventTouchUpInside];
        [_secondView addSubview:editBtn];
        
        if (_hasResult) {
            //模拟赛果数据
            NSString *resultString = [LVTools mToString:_builddic[@"results"]];
            CGFloat height = [LVTools sizeContent:resultString With:13 With2:UISCREENWIDTH-50-80];
            _resultTextView.frame = CGRectMake(50, _rstLabel.top-8, UISCREENWIDTH-80, height+3);
            _resultTextView.text = resultString;
            
            _resultHeight += height;
            
        } else {
            _resultTextView.text = @"暂无战果，请上传";
            _resultTextView.frame = CGRectMake(50, _rstLabel.top-8, UISCREENWIDTH-80, 25);
            _resultHeight += 25;
        }
    } else {
        if (_hasResultImg) {
            UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, BOUNDS.size.width-5*2, 70)];
            scroll.contentSize = CGSizeMake(80*testArray.count, scroll.height);
            for (int i = 0; i < testArray.count; i ++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(5+75*i, 10, 60, 60);
//                [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:testArray[i]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
//
//                btn.contentMode = UIViewContentModeScaleAspectFill;
//                btn.clipsToBounds = YES;
                
                
                [btn sd_setImageWithURL:[NSURL URLWithString:[_resultImgArray objectAtIndex:i]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"applies_plo"]];
                btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                btn.imageView.clipsToBounds = YES;
                
                btn.tag = 950+i;
                [btn addTarget:self action:@selector(scanAllImages:) forControlEvents:UIControlEventTouchUpInside];
                [scroll addSubview:btn];
            }
            [_secondView addSubview:scroll];
            _resultHeight += 70;
            UIView *grayline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 0.5)];
            grayline.backgroundColor = RGBACOLOR(222, 222, 222, 1);
            [_secondView addSubview:grayline];
        } else {
            
        }
        if (_hasResult) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, _resultHeight+5, 40, 18)];
            label.font = [UIFont systemFontOfSize:13];
            label.text = @"战果：";
            [_secondView addSubview:label];
            
            //模拟赛果数据
            NSString *resultString = [LVTools mToString:_builddic[@"results"]];
            CGFloat height = [LVTools sizeContent:resultString With:13 With2:UISCREENWIDTH-50-80];
            UITextView *resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, label.top-5, UISCREENWIDTH-80, height+3)];
            resultTextView.delegate = self;
            resultTextView.font = [UIFont systemFontOfSize:13];
            resultTextView.userInteractionEnabled = NO;
            resultTextView.layer.borderWidth = 0;
            resultTextView.text = resultString;
            [_secondView addSubview:resultTextView];
            _resultHeight += height;
        }
    }
}

#pragma mark -- 赛果图片点击方法
- (void)scanAllImages:(UIButton *)sender
{
    ImgShowViewController *imgShow = [[ImgShowViewController alloc] initWithSourceData:testArray withIndex:sender.tag-950 hasUseUrl:YES];
    imgShow.data = testArray;
    imgShow.isSelf = _isSelf;
    [self.navigationController pushViewController:imgShow animated:YES];
}

#pragma mark -- 赛果编写后的代理方法
- (void)sendMsg:(NSString *)msg
{
    CGFloat height = [LVTools sizeContent:msg With:13 With2:UISCREENWIDTH-80];
    _resultTextView.frame = CGRectMake(50, _rstLabel.top-5, UISCREENWIDTH-80, height+3);
    _resultTextView.text = msg;
    _resultHeight += height;
    _carryView.frame = CGRectMake(0, _resultTextView.bottom+5, UISCREENWIDTH, 85);
    _secondView.frame = CGRectMake(0, _firstView.bottom+3, kScreenWidth, _carryView.bottom+5);
    _headView.frame = CGRectMake(0, 0, kScreenWidth,_secondView.bottom);
    _mTableView.tableHeaderView = _headView;
}

- (UIScrollView*)dianzanScrollview{
    if (_dianzanScrollview == nil) {
        _dianzanScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 40)];
        _dianzanScrollview.backgroundColor = [UIColor whiteColor];
        _dianzanScrollview.showsHorizontalScrollIndicator = NO;
    }
    return _dianzanScrollview;
}
- (UILabel*)countYzLb{
    if (_countYzLb == nil) {
        _countYzLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width-2*5, 30)];

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width-10, 0.5)];
        lineView.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        [_countYzLb addSubview:lineView];
    }
    return _countYzLb;
}
- (UICollectionView*)joinedCollectionView{
    if (_joinedCollectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(60, 80);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 0;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _joinedCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, _countYzLb.bottom+5, kScreenWidth-2*5-2*5, 80*2) collectionViewLayout:flowLayout];
        if ([yingzhangArray count]==0) {
            _joinedCollectionView.frame = CGRectMake(5, _countYzLb.bottom, kScreenWidth-2*5-2*5, 0);
        }
        if ([yingzhangArray count]>0&&[yingzhangArray count]<5) {
            _joinedCollectionView.height = 80;
        }
        
        _joinedCollectionView.dataSource = self;
        _joinedCollectionView.delegate = self;
        _joinedCollectionView.backgroundColor = [UIColor whiteColor];
        [_joinedCollectionView registerClass:[ZHCollectionCell class] forCellWithReuseIdentifier:@"ZHCollectionCell"];
        NSLog(@"%@",[kUserDefault objectForKey:KxgToken]);
    }
    return _joinedCollectionView;
}
- (UILabel*)alerttitleLb{
    if (_alerttitleLb == nil) {
        _alerttitleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-2*TextViewleft, 30)];
        _alerttitleLb.backgroundColor = [UIColor colorWithRed:0.800f green:0.110f blue:0.149f alpha:1.00f];
        _alerttitleLb.text = @"留 言";
        _alerttitleLb.textColor = [UIColor whiteColor];
        _alerttitleLb.textAlignment = NSTextAlignmentCenter;
    }
    return _alerttitleLb;
}

#pragma mark UICollectViewDatasourse
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [yingzhangArray count];
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ZHCollectionCell";
    ZHCollectionCell * cell = (ZHCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell configYingzhanDic:[yingzhangArray objectAtIndex:indexPath.row]];
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
#pragma mark UICollectViewdelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了");
    //应战用户个人信息
    [self yzuserInfo:indexPath.row];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma mark UITableViewDatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (liuyanArray.count <= 5) {
        return liuyanArray.count;
    } else {
        return 5;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idet = @"commentCell";
    WPCCommentCell *cell = (WPCCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[WPCCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idet commentType:WPCAppointCommentType];
    }
    for (UIView *view in cell.contentView.subviews) {
        view.clipsToBounds = YES;
    }
    [cell configTheplayContent:[liuyanArray objectAtIndex:indexPath.row]];
    cell.headImgView.tag = indexPath.row +100;
    [cell.headImgView addTarget:self action:@selector(userInfoOnclick:) forControlEvents:UIControlEventTouchUpInside];
    cell.morActionBtn.tag = 4700+indexPath.row;
    [cell.morActionBtn addTarget:self action:@selector(morActionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //评论里的图片tag为400+i
    if ([[liuyanArray objectAtIndex:indexPath.row][@"commentShowList"] count] > 0) {
        for (int i = 0; i < [[liuyanArray objectAtIndex:indexPath.row][@"commentShowList"] count]; i++) {
            WPCImageView *image = (WPCImageView *)[cell.contentView viewWithTag:400+i];
            image.row = indexPath.row;
            image.userInteractionEnabled = YES;
            UITapGestureRecognizer *commentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImagesFromComment:)];
            [image addGestureRecognizer:commentImgTap];
        }
    }
    return cell;
}

- (void)scanImagesFromComment:(UITapGestureRecognizer *)sender {
    //ImgShowViewController
    WPCImageView *view = (WPCImageView *)sender.view;
    NSMutableArray *imagearr = [NSMutableArray array];
    for (int i = 0; i < [[liuyanArray objectAtIndex:view.row][@"commentShowList"] count]; i ++) {
        NSString *str = [NSString stringWithFormat:@"%@%@",preUrl,[[liuyanArray objectAtIndex:view.row][@"commentShowList"][i] valueForKey:@"path"]];
        [imagearr addObject:str];
    }
    
    ImgShowViewController *vc = [[ImgShowViewController alloc] initWithSourceData:imagearr withIndex:sender.view.tag-400 hasUseUrl:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)morActionBtnClick:(UIButton *)sender
{
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        //删除按钮
        _deleteIndex = sender.tag - 4700;
        if ([liuyanArray[_deleteIndex][@"userId"] intValue] == [[LVTools mToString:[kUserDefault objectForKey:kUserId]] intValue]) {
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


#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([_aboutMeNumString intValue] == 0) {
        return 40;
    } else {
        return 75;
    }
}

//去掉heaview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _mTableView) {
        CGFloat sectionHeaderHeight = 100;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (sectionHeadview==nil) {
        sectionHeadview = [[UIView alloc] init];
        sectionHeadview.backgroundColor = [UIColor whiteColor];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        view1.backgroundColor = [UIColor colorWithRed:0.945f green:0.945f blue:0.945f alpha:1.00f];
        
        [sectionHeadview addSubview:view1];
        
        UILabel *commentCountLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        /** 风格 **/
        commentCountLb.font = [UIFont systemFontOfSize:13.0];
        commentCountLb.textColor = [UIColor grayColor];
        commentCountLb.text =[NSString stringWithFormat: @"   共%lu条评论",(unsigned long)(liuyanArray.count)];
        commentCountLb.userInteractionEnabled = YES;
            commentCountLb.tag = 999;
        UITapGestureRecognizer *allComtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerlabClick)];
        [commentCountLb addGestureRecognizer:allComtap];
        [view1 addSubview:commentCountLb];
        
        //点击事件使tableview列表进行收缩或展开
        UIImageView *lab = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREENWIDTH-35, 5, 20, 20)];
        lab.image = [UIImage imageNamed:@"arrow"];
        lab.userInteractionEnabled = YES;
        [view1 addSubview:lab];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerlabClick)];
        [lab addGestureRecognizer:tap];
            
        if ([_aboutMeNumString intValue] != 0) {
            NSString *str = [NSString stringWithFormat:@"%@条关于我的评论",_detailDic[@"aboutMeNum"]];
            [self.aboutMeBtn setTitle:str forState:UIControlStateNormal];
            CGFloat width = [LVTools sizeWithStr:str With:13 With2:13];
            UIView *redView = [[UIView alloc] init];
            redView.frame = CGRectMake(UISCREENWIDTH/2+width/2-2, 7, 6, 6);
            redView.backgroundColor = [UIColor redColor];
            redView.layer.cornerRadius = 3;
            redView.layer.masksToBounds = YES;
            [self.aboutMeBtn addSubview:redView];
            [sectionHeadview addSubview:self.aboutMeBtn];
            sectionHeadview.frame = CGRectMake(0, 0, UISCREENWIDTH, 75);
        } else {
            self.aboutMeBtn.frame = CGRectZero;
            [sectionHeadview addSubview:self.aboutMeBtn];
            sectionHeadview.frame = CGRectMake(0, 0, UISCREENWIDTH, 40);
        }
    }
    return sectionHeadview;
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


- (void)changeTheTableView
{
    //点击进行刷新tableview，呈现关于自己的评论
    WPCCommentVC *vc= [[WPCCommentVC alloc] init];
    vc.title = @"关于我的评论";
    vc.fromStyle = StyleResultComment;
    vc.isMe = YES;
    vc.chuanBlock = ^(NSArray *arr) {
        if (![liuyanArray isEqual:arr]) {
            [liuyanArray removeAllObjects];
            [liuyanArray addObjectsFromArray:arr];
            [_mTableView reloadData];
        }
        sectionHeadview = nil;
        _aboutMeNumString = @"0";
        for (UIView *view in self.aboutMeBtn.subviews) {
            [view removeFromSuperview];
        }
        [_mTableView reloadData];
    };
    vc.idString = [LVTools mToString:_builddic[@"id"]];
    vc.arr = [NSMutableArray arrayWithArray:liuyanArray];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerlabClick
{
    WPCCommentVC *vc= [[WPCCommentVC alloc] init];
    vc.title = @"全部评论";
    vc.fromStyle = StyleResultComment;
    vc.idString = [LVTools mToString:_builddic[@"id"]];
    vc.isMe = NO;
    vc.chuanBlock = ^(NSArray *arr) {
        if (![liuyanArray isEqual:arr]) {
            [liuyanArray removeAllObjects];
            [liuyanArray addObjectsFromArray:arr];
            [_mTableView reloadData];
        }
    };
    vc.arr = [NSMutableArray arrayWithArray:liuyanArray];
    [self.navigationController pushViewController:vc animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [liuyanArray objectAtIndex:indexPath.row];
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
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"点击了");
    [self replyOnclickInselect:indexPath.row];
}

#pragma mark [个人信息]
- (void)userInfoOnclick:(UIButton*)btn{
    //./symbolicatecrash temp..yxijkemu.crash yuezhan123.app.dSYM > yuezhan123_symbol.crash
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        NSDictionary *info=nil;
        if ([btn.superview isEqual:_dianzanScrollview]) {
            info = [zanArray objectAtIndex:btn.tag-1300];
        }
        else{
            info=[liuyanArray objectAtIndex:btn.tag-100];
        }
        NSString *useId =[LVTools mToString: [info objectForKey:@"userId"]];
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
- (void)yzuserInfo:(NSInteger)index
{
    if ([[kUserDefault valueForKey:kUserLogin] isEqualToString:@"1"]) {
        //是不是自己
        NSDictionary *info=nil;
        info=[yingzhangArray objectAtIndex:index];
        //是不是战队的模式
        if ([[LVTools mToString:info[@"teamName"]] length] == 0) {
            //是个人
            NSString *useId =[LVTools mToString: [info objectForKey:@"uid"]];
            NSString *selfid = [LVTools mToString:[kUserDefault objectForKey:kUserId]];
            if ([useId isEqualToString:selfid]) {
                WPCMyOwnVC *vc = [[WPCMyOwnVC alloc] init];
                vc.basicVC = NO;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                WPCFriednMsgVC *vc = [[WPCFriednMsgVC alloc] init];
                vc.uid = useId;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            //是团队
            ZHTeamDetailController *vc = [[ZHTeamDetailController alloc] init];
            vc.teamId = info[@"teamId"];
            vc.chuanBlock = ^(NSArray *arr){
                
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [self jumpToLoginVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
