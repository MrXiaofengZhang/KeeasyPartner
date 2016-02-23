//
//  WPCMenberListVC.h
//  yuezhan123
//
//  Created by admin on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@class TeamModel;
@interface WPCMenberListVC : BaseViewController

@property (nonatomic, assign)MemberType detailType;
@property (nonatomic, strong)NSMutableArray *datasource;
@property (nonatomic,strong)TeamModel *teamModel;
@property (nonatomic, assign)BOOL isTeamLeader;
@end
