//
//  WPCMyOwnVC.h
//  yuezhan123
//
//  Created by admin on 15/5/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendListModel.h"

@interface WPCMyOwnVC : BaseViewController

@property (nonatomic, strong) FriendListModel *model;
@property (nonatomic, assign) BOOL basicVC;

@end
