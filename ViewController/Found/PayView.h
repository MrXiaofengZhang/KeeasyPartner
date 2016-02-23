//
//  PayView.h
//  yuezhan123
//
//  Created by admin on 15/9/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PayViewDelegate <NSObject>

@optional
- (void)cancelAction;
- (void)confirmAction:(NSInteger)index;

@end

@interface PayView : UIView <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *imgArray;
    NSArray *contentArray;
}
@property (nonatomic, strong)UIView *backGround;
@property (nonatomic, strong)UIView *mainView;
@property (nonatomic, strong)UIButton *confirmBtn;
@property (nonatomic, strong)UIButton *cancelBtn;
@property (nonatomic, assign)NSInteger selectIndex;
@property (nonatomic, strong)UITableView *table;
@property (nonatomic, assign)id <PayViewDelegate>delegate;

@end
