//
//  WPCCommentVC.h
//  yuezhan123
//
//  Created by admin on 15/6/15.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
@protocol CommentClearUpDelegate <NSObject>//如果是关于我的评论，用户成功进入本节目后，返回后关于我的评论个数清0

@optional

- (void)clearUpCommentNum;

@end


@interface WPCCommentVC : BaseViewController

@property (nonatomic, strong)NSMutableArray *arr;//回复／留言的数组
@property (nonatomic, assign)BOOL isMe;//是否是  关于我的
@property (nonatomic, assign)CommentFromStyle fromStyle;//前面的控制器类型，如约战，赛事，时光机等等
@property (nonatomic, strong)NSString *idString;//约战id，赛事id等等
@property (nonatomic, assign)id <CommentClearUpDelegate> clearDelegate;

@end
