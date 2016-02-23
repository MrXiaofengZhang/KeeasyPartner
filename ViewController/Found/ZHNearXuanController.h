//
//  ZHNearXuanController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
typedef enum ShaixuanType{
    ShaixuanTypeNone =0,
    ShaixuanTypePerson ,
    ShaixuanTypeTeam
}ShaixuanType;
@interface ZHNearXuanController : BaseViewController
@property (nonatomic,assign) ShaixuanType shaixuanType;
@end
