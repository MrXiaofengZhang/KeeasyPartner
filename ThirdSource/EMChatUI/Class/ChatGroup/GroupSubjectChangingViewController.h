//
//  GroupSubjectChangingViewController.h
//  ChatDemo-UI2.0
//
//  Created by Neil on 15-2-25.
//  Copyright (c) 2014年 Neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EMGroup.h"

@interface GroupSubjectChangingViewController : UIViewController
@property (nonatomic,copy) void(^backBlock)(NSString *title);
- (instancetype)initWithGroup:(EMGroup *)group;

@end
