//
//  ZHInviteFriendController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@interface ZHInviteFriendController : BaseViewController
@property (nonatomic,strong) NSString *applyId;
@property (nonatomic,strong) UIImage *appImg;
@property (nonatomic,strong) NSString *userName;

@property (nonatomic,strong) NSString *type;//邀请类型0约战 1战队 2比赛 3邀请替补(比赛) 空表示建群
@property (nonatomic,strong) NSString *idStr;//邀请项目id
@property (nonatomic,strong) NSString *nameStr;//邀请项目名字
@property (nonatomic,assign) NSInteger floorCount;//人数下限
@property (nonatomic,assign) NSInteger topCount;
@property (nonatomic,strong) UILabel *teamNameLb;
@property (nonatomic,strong) UILabel *countLb;
@property (nonatomic,strong) NSString *matchType;
@property (nonatomic,assign) NSInteger limit;
- (instancetype)initWithBlockSelectedUsernames:(NSArray*)userNames;
@end
