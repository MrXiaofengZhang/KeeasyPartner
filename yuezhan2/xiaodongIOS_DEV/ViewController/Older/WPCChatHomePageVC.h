//
//  WPCChatHomePageVC.h
//  yuezhan123
//
//  Created by admin on 15/7/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"

@interface WPCChatHomePageVC : BaseViewController
- (void)refreshDataSource;

- (void)isConnect:(BOOL)isConnect;
- (void)networkChanged:(EMConnectionState)connectionState;
@end
