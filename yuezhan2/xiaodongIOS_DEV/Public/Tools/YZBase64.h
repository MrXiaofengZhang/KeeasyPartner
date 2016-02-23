//
//  Base64.h
//  yuezhan123
//
//  Created by LV on 15/4/2.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>

static const char encodingBaseTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@interface YZBase64 : NSObject

+(int)char2Int:(char)c;
+(NSData *)decode:(NSString *)data;
+(NSString *)encode:(NSData *)data;

@end
