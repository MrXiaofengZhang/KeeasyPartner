//
//  SportResultController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/20.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@class GetMatchListModel;
@interface SportResultController : BaseViewController
@property (nonatomic,strong) GetMatchListModel *matchInfo;
@property (nonatomic,strong) NSDictionary *matchShow;
@property (nonatomic,strong) NSString *matchId;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSDictionary *record;
@end
