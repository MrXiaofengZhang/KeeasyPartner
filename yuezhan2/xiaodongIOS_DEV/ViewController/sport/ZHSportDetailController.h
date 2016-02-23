//
//  ZHSportDetailController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/16.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@class GetMatchListModel;
@interface ZHSportDetailController : BaseViewController
@property (nonatomic,strong) GetMatchListModel *matchInfo;
@property (nonatomic,assign) BOOL isMyMatch;
@end
