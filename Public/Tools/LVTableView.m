//
//  LVTableView.m
//  yuezhan123
//
//  Created by LV on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVTableView.h"

@implementation LVTableView


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style WithTarget:(id)idSelf WithTag:(NSInteger)tagId{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        self.tag = tagId;
        self.delegate = idSelf;
        self.dataSource = idSelf;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = YES;
    }
    return self;
}

@end
