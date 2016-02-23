//
//  WPCSportDetailVC.h
//  yuezhan123
//
//  Created by admin on 15/7/7.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@class GetMatchListModel;
@interface WPCSportDetailVC : BaseViewController
@property (nonatomic,strong) GetMatchListModel *MatchModel;
@property (nonatomic,strong) UIImage *sportImg;
@property (nonatomic,strong) NSMutableDictionary *matchSignUpInfo;//报完名之后

@end
