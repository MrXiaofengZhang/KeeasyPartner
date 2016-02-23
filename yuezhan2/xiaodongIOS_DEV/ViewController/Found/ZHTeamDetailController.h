//
//  ZHTeamDetailController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@class TeamModel;
@class FriendListModel;
@interface ZHTeamDetailController : BaseViewController
@property (nonatomic,strong) TeamModel *teamModel;
@property (nonatomic,strong) FriendListModel *leaderModel;
@property (nonatomic,strong) NSString *teamId;

@end
