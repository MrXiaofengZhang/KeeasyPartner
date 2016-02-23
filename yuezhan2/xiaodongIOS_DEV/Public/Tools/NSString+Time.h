//
//  NSString+Time.h
//  haochang
//
//  Created by Administrator on 14-5-4.
//  Copyright (c) 2014年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Time)

// 如:type 0:返回 20130828153322  type 1:返回 2013-08-28 15:33:22  2:返回 2013-08-28  3:返回 2013年8月28日 15时33分22秒 4:返回2013年8月28日
+(NSString *)getNowDateForall:(int)type;
//与当前时间做比较  返回(几个月前,几周前,几天前,几小时前,几分钟前,几秒前)
+ (NSString *)intervalFromLastDate: (NSDate *) date;
//根据当前时间生成文件名称   格式为(20138291746985071.mp3)    suffix 代表文件后缀名
+ (NSString *)getNowDateFileName:(NSString *)suffix;
//根据字符串生成时间
+ (NSDate *) getDateFormat:(NSString *)str Format:(NSString *)format;
//根据时间生成字符串
+ (NSString *)getStringFormat:(NSDate *)date Format:(NSString *)format;
//时间字符串转时间字符串 2010-10-27 10:22:15 转化为 2010-10-27 10:22
+ (NSString *)stringFormatYearAndMonthAndDayInterval:(NSString*)str;

//时间戳时间  2013:12:11 11:11:11
+ (NSString *)stringIntervalSince1970:(double)interval;

+ (NSString *)stringFormatIntervalSince1970:(double)interval;
//根据时间戳格式化月日   10月27日
+ (NSString *)stringFormatMonthAndDayIntervalSince1970:(double)interval;
//根据时间戳格式化月日   9月1日
+ (NSString *)stringFormatMonthAndDayIntervalSince:(double)interval;
//根据时间戳格式化年月日   2014年10月27日
+ (NSString *)stringFormatYearAndMonthAndDayIntervalSince1970:(double)interval;

//获取当前格式化时间  2013:12:11 11:11:11
+ (NSString *)getNowDateFormatter;
//获取当前时间  2013105221034
+ (NSString *)getNowDate;
+(double)getNowDateTimeInterval;

//随机数字字符串
+(NSString*)stringRandomNumberForm:(NSUInteger)from to:(NSUInteger)to;

//根据秒 获取几分钟
+ (NSString *)getDateFromSecond:(int)second;

//根据时间获取秒数  例如:(01:30)==90s
+ (float) getDSceond:(NSString *)strTime;

//输出格式为：2010-10-27 10:22:13
+ (NSString *)getTimeStringWithFormmatter;

+ (NSString *)getCreateTime:(NSString*)str;

+ (NSString *)intervalSinceNow:(NSString *)theDate;

//当前时间戳
+(NSString*)stringTimeIntervalSince1970;

@end
