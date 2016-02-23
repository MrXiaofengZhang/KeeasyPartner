//
//  SelfInformationModel.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/27.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "SelfInformationModel.h"

@implementation SelfInformationModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqual:@"id"]) {
        [self setValue:value forKey:@"ID"];
    }
}
@end
