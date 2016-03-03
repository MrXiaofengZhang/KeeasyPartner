//
//  pinyin.h
//  ZiMuPaiXuDemo
//
//  Created by Co_Lee on 14-7-11.
//  Copyright (c) 2014年 ___ShenKeYi___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pinyin : NSObject


#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"

char pinyinFirstLetter(unsigned short hanzi);

@end
