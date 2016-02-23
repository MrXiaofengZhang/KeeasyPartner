//
//  NSString+Time.m
//  haochang
//
//  Created by Administrator on 14-5-4.
//  Copyright (c) 2014年 Administrator. All rights reserved.
//

#import "NSString+Time.h"

#define SECONDS_PER_DAY (24*60*60)
#define SECONDS_PER_MONTH (30*24*60*60)
#define SECONDS_PER_YEAR (365*24*60*60)

@implementation NSString (Time)

+ (NSString *)getNowDateForall:(int)type
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit | NSDayCalendarUnit  |
    NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger seconds=[cps second];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    if(type == 0){
        return  [NSString stringWithFormat:@"%lu%lu%lu%2lu%02lu%02lu",(unsigned long)year,(unsigned long)month,(unsigned long)day,(unsigned long)hour,(unsigned long)minute,(unsigned long)seconds];
    }
    if (type==1)
    {
        return [NSString stringWithFormat:@"%lu-%lu-%lu %02lu:%02lu:%02lu",(unsigned long)year,(unsigned long)month,(unsigned long)day,(unsigned long)hour,(unsigned long)minute,(unsigned long)seconds];
    }
    if (type==2)
    {
        return [NSString stringWithFormat:@"%lu-%lu-%lu",(unsigned long)year,(unsigned long)month,(unsigned long)day];
        
    }
    if (type==3)
    {
        return [NSString stringWithFormat:@"%lu年%lu月%lu日 %2lu时:%2lu分:%2lu秒",(unsigned long)year,(unsigned long)month,(unsigned long)day,(unsigned long)hour,(unsigned long)minute,(unsigned long)seconds];
    }
    if (type==4)
    {
        return [NSString stringWithFormat:@"%lu年%lu月%lu日 ",(unsigned long)year,(unsigned long)month,(unsigned long)day];
    }
    if (type==5)
    {
        return [NSString stringWithFormat:@"%lu-%lu-%lu %02lu:%02lu",(unsigned long)year,(unsigned long)month,(unsigned long)day,(unsigned long)hour,(unsigned long)minute];
    }
    return nil;
}

+ (NSString *)intervalFromLastDate: (NSDate *) date;
{
    //两个时间的时间差
    int TimeDifference=fabs([date timeIntervalSinceDate:[NSDate date]]);
    if (TimeDifference/(60*60*24*30)>0) {
        return [NSString stringWithFormat:@"%d个月前",TimeDifference/(60*60*24*30)>0];
    }
    if (TimeDifference/(60*60*24*7)>0) {
        return [NSString stringWithFormat:@"%d周前",TimeDifference/(60*60*24*7)];
    }
    if (TimeDifference/(60*60*24)>0) {
        return [NSString stringWithFormat:@"%d天前",TimeDifference/(60*60*24)];
    }
    if (TimeDifference/(60*60)>0) {
        return [NSString stringWithFormat:@"%d小时前",TimeDifference/(60*60)];
    }
    if (TimeDifference/60>0) {
        return [NSString stringWithFormat:@"%d分钟前",TimeDifference/60];
    }
    if (TimeDifference%60>0) {
        return [NSString stringWithFormat:@"%d秒前",TimeDifference%60];
    }
    return nil;
}

+ (NSString *)getNowDateFileName:(NSString *)suffix
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit | NSDayCalendarUnit  |
    NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    return [NSString stringWithFormat:@"%lu%lu%lu%lu%lu%d.%@",(unsigned long)year,(unsigned long)month,(unsigned long)day,(unsigned long)hour,(unsigned long)minute,arc4random()%8888888,suffix];
}

//根据字符串生成时间
+ (NSDate *) getDateFormat:(NSString *)str Format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];

    if (str.length!=format.length) {

        return nil;
    }
    NSDate *tempdate=[NSDate dateWithTimeInterval:8*60*60 sinceDate:[formatter dateFromString:str]];
    if ([[tempdate.description substringFromIndex:tempdate.description.length-17] isEqualToString:@"596:-31:-23 +0000"]) {

        return nil;
    }
    return [NSDate dateWithTimeInterval:8*60*60 sinceDate:[formatter dateFromString:str]];
}

//根据时间生成字符串
+ (NSString *)getStringFormat:(NSDate *)date Format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}


+ (NSString *)getDateFromSecond:(int)second
{
    if (second>600&&second%60>=10) {
        return [NSString stringWithFormat:@"%d:%d",second/60,second%60];
    }else if (second>600&&second%60<10){
        return [NSString stringWithFormat:@"%d:0%d",second/60,second%60];
    }else if (second<600&&second%60>=10){
        return [NSString stringWithFormat:@"0%d:%d",second/60,second%60];
    }else if (second<600&&second%60<10){
        return [NSString stringWithFormat:@"0%d:0%d",second/60,second%60];
    }
    else if (second<60&&second%60>=10){
        return [NSString stringWithFormat:@"00:%d",second%60];
    }else{
        return [NSString stringWithFormat:@"00:0%d",second%60];
    }
}

+(NSString *)getNowDateFormatter
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit | NSDayCalendarUnit  |
    NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger seconds=[cps second];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    return [NSString stringWithFormat:@"%lu-%02lu-%02lu %02lu:%02lu:%02lu",(unsigned long)year,(unsigned long)month,(unsigned long)day,(unsigned long)hour,(unsigned long)minute,(unsigned long)seconds];
}

+(NSString *)getNowDate
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit | NSDayCalendarUnit  |
    NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger seconds=[cps second];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    return [NSString stringWithFormat:@"%lu%lu%lu%lu%lu%lu",(unsigned long)year,(unsigned long)month,(unsigned long)day,(unsigned long)hour,(unsigned long)minute,(unsigned long)seconds];
}

+(double)getNowDateTimeInterval
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval =[dat timeIntervalSince1970];
    NSString    *time   = [[NSString stringWithFormat:@"%lf",timeInterval] componentsSeparatedByString:@"."][0];
    
    return [time doubleValue];
}

+(NSString*)stringTimeIntervalSince1970
{
    NSTimeInterval timeInterval =[[[NSDate alloc] init] timeIntervalSince1970];
    NSString    *time   = [NSString stringWithFormat:@"%lf",timeInterval];
    
    return [time stringByReplacingOccurrencesOfString:@"." withString:@""];
}

+(NSString*)stringRandomNumberForm:(NSUInteger)from to:(NSUInteger)to
{
    NSUInteger number = from + (arc4random() % (to - from + 1));

    return [NSString stringWithFormat:@"%lu",(unsigned long)number];
}

+ (float) getDSceond:(NSString *)strTime
{
    NSArray *ay=[strTime componentsSeparatedByString:@":"];
    return  [ay[0]intValue]*60+[ay[1]intValue];
}

+ (NSString *)getTimeStringWithFormmatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//输出格式为：2010-10-27 10:22:13
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return  currentDateStr;
}

+ (NSString *)getCreateTime:(NSString*)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd "];//输出格式为：2010-10-27
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:str.longLongValue]];
    return  currentDateStr;
}

+ (NSString *)stringFormatYearAndMonthAndDayInterval:(NSString*)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate* date    = [dateFormatter dateFromString:str];

    if (date == nil) return str;
    
    double interval = (long)[date timeIntervalSince1970];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];//输出格式为：2010-10-27 10:22
    
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    
    return  currentDateStr;
}

+ (NSString *)stringFormatYearAndMonthAndDayIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//输出格式为：2010-10-27
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//输出格式为：2010-10-27 10:22:13
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringFormatIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];//输出格式为：2010-10-27 10:22
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringFormatMonthAndDayIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日"];//输出格式为：10月27日
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}
+ (NSString *)stringFormatMonthAndDayIntervalSince:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M月d日"];//输出格式为：9月2日  不是 09月02日
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}
//时间戳转换
+ (NSString *)intervalSinceNow:(NSString *)theDate
{
    //如果是以北京时间为准的，就用北京时间转换。如果是以GMT时间为准的，就不用转换了，看服务器
    //    转换成 北京时间
    NSTimeInterval late;
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];//系统时区
    NSDate *dateNow = [NSDate date];//获取GMT时间，和北京时间不同
    //    NSInteger interval = [zone secondsFromGMTForDate:dateNow];//以秒为单位返回GMT(格林威治)时区与系统时区时间的时差。
    //    NSDate *localeDate = [[NSDate date]dateByAddingTimeInterval:interval];//增加时间间隔生成新的NSDate对象
    NSTimeInterval now = [dateNow timeIntervalSince1970];
    //    NSLog(@"%@",localeDate);
    
    if ([theDate rangeOfString:@"-"].location != NSNotFound)
    {
        //把theDate格式转换为时间戳格式-转换成北京时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *laDate = [formatter dateFromString:theDate];//string型转换为NSDate型（GMT时间）
        NSTimeZone *zone1 = [NSTimeZone systemTimeZone];//系统时区
        NSInteger inter = [zone1 secondsFromGMTForDate:laDate];//以秒为单位返回GMT(格林威治)时区与系统时区时间的时差。
        NSDate *lateDate = [laDate dateByAddingTimeInterval:inter];//增加时间间隔生成新的NSDate对象
        //        NSLog(@"%@",lateDate);
        late = [lateDate timeIntervalSince1970] ;
    }
    else
    {
        //如果是直接的时间戳格式
        late = [theDate doubleValue];
    }
    
    NSString *timeString = @"";
    NSTimeInterval cha = now - late;
    if (cha/3600<1)
    {
        if (cha/60<1)
        {
            timeString = [NSString stringWithFormat:@"%d分钟前",1];
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f",cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
            timeString = [NSString stringWithFormat:@"%@分钟前",timeString];
        }
    }
    if (cha/3600>=1 && cha/3600<24)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@小时前",timeString];
    }
    if (cha/SECONDS_PER_DAY>=1 && cha/SECONDS_PER_DAY <30)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/SECONDS_PER_DAY];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@天前",timeString];
    }
    if (cha/SECONDS_PER_DAY>=30 && cha/SECONDS_PER_DAY <365)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/SECONDS_PER_MONTH];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@个月前",timeString];
    }
    if(cha/SECONDS_PER_DAY>=365)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/SECONDS_PER_YEAR];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@年前",timeString];
    }
    return timeString;
}

@end
