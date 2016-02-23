//
//  WPCTopView.h
//  yuezhan123
//
//  Created by admin on 15/6/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WPCTopViewDelegate <NSObject>

- (void)menuClickWithIndex:(NSInteger)index;

@end

@interface WPCTopView : UIView

@property (nonatomic, assign)NSInteger selectedIndex;
@property (nonatomic, assign)id <WPCTopViewDelegate> delegate;
@property (nonatomic, strong)NSDictionary *selectDic;
@property (nonatomic, strong)NSArray *countArray;
@property (nonatomic, assign)BOOL flagForCollection;
@property (nonatomic, assign)BOOL secondSelect;

@property (nonatomic, strong)NSMutableArray *layerArrays;

- (id)initWithFrame:(CGRect)frame andArray:(NSArray *)arr;

@end
