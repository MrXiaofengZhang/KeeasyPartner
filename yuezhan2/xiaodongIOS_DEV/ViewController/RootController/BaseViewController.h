//
//  BaseViewController.h
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@protocol ZHRefreshDelegate<NSObject>
@optional
- (void)refreshData;
- (void)sendMsg:(NSString*)msg;
@end
@interface BaseViewController : UIViewController{
    ASIHTTPRequest *request;//每个页面的get请求。
}
@property (nonatomic,weak) id<ZHRefreshDelegate> delegate;
@property (nonatomic,strong)void(^chuanBlock)(NSArray *arr);
@property(nonatomic,strong)void(^detailAreaBlock)(NSArray *arr1,NSArray *arr2);
@property(nonatomic,strong) UIButton *scroTopBtn;
- (void)DismissView;
- (void)PopView;

- (void)navgationBarLeftReturn;
- (void)navgationbarRrightImg:(NSString *)imgStr WithAction:(SEL)method WithTarget:(id)taget;
- (void)setNoNavigationBarline:(BOOL)isNoLine;
@end
