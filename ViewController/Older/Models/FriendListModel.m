//
//  FriendListModel.m
//  yuezhan123
//
//  Created by LV on 15/4/2.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "FriendListModel.h"

@implementation FriendListModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"FriendListModel中没有定义的key:%@",key);
}

@end
