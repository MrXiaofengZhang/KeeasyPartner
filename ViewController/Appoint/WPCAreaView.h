//
//  WPCAreaView.h
//  yuezhan123
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, AreaType) {
    TypeAppoint = 0,
    TypeVenue,
};


@protocol WpcAreaDelegate <NSObject>
@optional
//每个cell点击代理
- (void)collectionCellClickAtIndex:(NSInteger)index;
//更换按钮点击代理
- (void)changeBtnClick;

@end

@interface WPCAreaView : UIView <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, assign)id <WpcAreaDelegate> delegate;
@property (nonatomic, strong)UICollectionView *areaCollection;
@property (nonatomic, strong)UILabel *currentCityLab;
@property (nonatomic, strong)NSArray *dataSource;
@property (nonatomic, strong)UIView *whiteView;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UIViewController *viewVC;
@property (nonatomic, assign)BOOL open;
@property (nonatomic, assign)AreaType areaType;

- (id)initWithFrame:(CGRect)frame dataSource:(NSArray *)arr city:(NSString *)aCity viewController:(UIViewController *)vc;
- (id)initWithFrame:(CGRect)frame dataSource:(NSArray *)arr city:(NSString *)aCity;
- (void)desappearTheCustomView;
- (void)disappearImmediately;
//点击城市视图出现
- (void)appearTheCustomView;
- (void)changeDatasource:(NSArray *)arr;

/*
 约战首页，还有3个地方点击要处理
 点击上方搜索框时。如果area视图存在，要理解把他移除
 点击tabbar其他几个按钮时，同上
 点击发起约战按钮时，同上
 */

@end
