//
//  WPCTimeDetailVC.h
//  yuezhan123
//
//  Created by admin on 15/7/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class ZHShuoModel;
@interface WPCTimeDetailVC : BaseViewController
@property (nonatomic,strong) ZHShuoModel *shouModel;
@property (nonatomic,strong) NSIndexPath *index;
@property (nonatomic,strong) void (^deleteBlock)(NSIndexPath *index);
@end
