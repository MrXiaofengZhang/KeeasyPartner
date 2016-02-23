//
//  ZHCommentController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"

@interface ZHCommentController : BaseViewController

@property (assign)NSInteger count;
@property (assign)CommentFromStyle fromStyle;
@property (nonatomic, copy)NSString *str;//约战编写赛果时，如果赛果有文字信息，就传这
@property (nonatomic, copy)NSString *idstring;
@property (nonatomic, copy) void (^chuanComment)(NSDictionary *dic);

@end
