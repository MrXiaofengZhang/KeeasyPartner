//
//  WPCComfirmVenueVC.h
//  VenueTest
//
//  Created by admin on 15/6/25.
//  Copyright (c) 2015年 zhoujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ZHTaocanModel.h"
#import "ZHVenueModel.h"
@interface WPCComfirmVenueVC : BaseViewController
@property (nonatomic,strong) ZHTaocanModel *taocanModel;
@property (nonatomic,strong) ZHVenueModel *vennueModel;
@property (nonatomic,strong) NSMutableArray *selectObject;
@property (nonatomic, strong)NSMutableDictionary *infoDic;
@property (nonatomic, copy)NSString *ordertype;//(@"1代表的是场馆预定界面过来的";@"2"代表的是团购界面立即抢购过来的)
@property (nonatomic,assign) CGFloat costNum;
@property (nonatomic, assign)NSInteger selectedWeekday;

@end
