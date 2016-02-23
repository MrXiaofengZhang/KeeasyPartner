//
//  WPCSportsTypeChooseVC.h
//  yuezhan123
//
//  Created by admin on 15/6/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"

@interface WPCSportsTypeChooseVC : BaseViewController <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong)NSArray *dataSource;
@property (nonatomic, strong)UICollectionView *collect;
@property (nonatomic, assign)BOOL multipleChoose;
@property (nonatomic, strong)NSMutableArray *chooseArray;
@property (nonatomic, strong)NSMutableArray *chooseCodeArr;
@property (nonatomic, copy) void (^sportCode)(NSArray *arr);
@property (nonatomic,assign) BOOL ishoppy;
@property (nonatomic,strong) NSMutableDictionary *infoDic;
@end
