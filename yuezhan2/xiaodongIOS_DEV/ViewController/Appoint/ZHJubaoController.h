//
//  ZHJubaoController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"

@interface ZHJubaoController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *touSuReasonArr;

@property (nonatomic, strong) NSMutableArray *selectReasonArr;

@property (nonatomic, strong) UITableView *touSuTableView;
@property (nonatomic, strong) UITextView *ContentView;
@property (nonatomic, strong) NSString *reportId;
@property (nonatomic, strong) NSString *commenentId;
@end
