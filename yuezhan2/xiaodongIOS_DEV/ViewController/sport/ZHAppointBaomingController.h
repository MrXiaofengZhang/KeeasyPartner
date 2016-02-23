//
//  ZHAppointBaomingController.h
//  Yuezhan123
//
//  Created by zhangxiaofeng on 15/3/24.
//  Copyright (c) 2015年 zhangxiaofeng. All rights reserved.
//

#import "BaseViewController.h"
#import "GetMatchListModel.h"
@interface ZHAppointBaomingController : BaseViewController
@property (nonatomic,assign) BaomingType baoMingtype;
@property (nonatomic,strong) GetMatchListModel *matchModel;
@property (nonatomic,strong) NSMutableArray *sexList;
@property (nonatomic,strong) NSMutableArray *cardList;
@property (nonatomic,strong) NSMutableArray *msaizhiList;

@property (nonatomic,strong) NSMutableDictionary *signupInfo;
@property (nonatomic,assign) BOOL isModify;

@end
