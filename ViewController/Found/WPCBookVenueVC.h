//
//  WPCBookVenueVC.h
//  VenueTest
//
//  Created by admin on 15/6/24.
//  Copyright (c) 2015年 zhoujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ZHTaocanModel.h"
#import "ZHVenueModel.h"
@interface WPCBookVenueVC : BaseViewController
@property (nonatomic,strong) ZHTaocanModel *taocanModel;
@property (nonatomic,strong) ZHVenueModel *vennueModel;
@end
