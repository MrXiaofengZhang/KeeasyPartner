//
//  DataService.h
//  vhall1
//
//  Created by vhallrd01 on 13-12-30.
//  Copyright (c) 2013年 vhallrd01. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^completionHandle)(id result);
@class ASIHTTPRequest;

@interface DataService : NSObject
//请求数据工具方法
+ (id)requestData:(NSString *)jsonName;

+ (ASIHTTPRequest *)requestVhallService:(NSString *)op withJsonDict:(NSDictionary *)jsonDict withCallbackBlock:(completionHandle)block;
+ (ASIHTTPRequest *)requestKeeasyAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method completion:(completionHandle)block;
+ (ASIHTTPRequest *)requestWeixinAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method  withData:(NSData *)data completion:(completionHandle)block;
+ (ASIHTTPRequest *)requestWeixinAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method completion:(completionHandle)block;

+ (ASIHTTPRequest *)requestPPTForGetFMethod:(NSString *)url parsms:(NSDictionary *)params withBlock:(completionHandle)block;
//发送聊天
+ (ASIHTTPRequest *)requestSendchatAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method completion:(completionHandle)block;



@end
