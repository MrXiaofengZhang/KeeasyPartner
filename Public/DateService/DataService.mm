//
//  DataService.m
//  vhall1
//
//  Created by vhallrd01 on 13-12-30.
//  Copyright (c) 2013年 vhallrd01. All rights reserved.
//

#import "DataService.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "MBProgressHUD+Add.h"
#import "Global.h"

#define kTimeOut 10
/*
 json解析的框架:
 
 JSONKit   性能好
 SBJSON
 TouchJSON
 NSJSONSerialization  ios5.0新增的类，性能最好
 */

//#define VHAKKWEIXIN_URL @"http://123.57.212.220/yuezhan"//外网
//#define VHAKKWEIXIN_URL @"http://192.168.101.100/yuezhan"//周星测试网




#define VHAKKPPT_URL @"http://webinar.vhall.com/docshower.php"
#define INDUSTRYIMGURL(x) [NSString stringWithFormat:@"http://192.168.2.124:8080/resources/images/public/industry/IN_%@.png",x]

@implementation DataService

+ (id)requestData:(NSString *)jsonName {
    
    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonName ofType:nil];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:jsonName];
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    float version = [systemVersion floatValue];
    
    id jsonObj = nil;
    
    if (version >= 5.0) {
        
        //NSJSONSerialization 5.0之后ios新添加解析json的工具类
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
    } else {
        NSString *jsonData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        //jsonkit解析json字符串
        jsonObj = [jsonData objectFromJSONString];
    }
    
    return jsonObj;
}
//带用户id的参数
+ (ASIHTTPRequest *)requestKeeasyAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method completion:(completionHandle)block{
    NSString *shopId=[[NSUserDefaults standardUserDefaults] objectForKey:kToken];
    if (!shopId) {
        shopId=@"";
    }
    NSMutableDictionary *newParsms=[NSMutableDictionary dictionaryWithDictionary:params];
    [newParsms setObject:shopId forKey:@"shopid"];
       ASIHTTPRequest *request= [self requestWeixinAPI:subURL parsms:newParsms method:method completion:block];
    return request;
}
+ (ASIHTTPRequest *)requestWeixinAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method  withData:(NSData *)data completion:(completionHandle)block
{
    NSString *urlstring = [NSString stringWithFormat:@"%@/%@",VHAKKWEIXIN_URL,subURL];
    
    ASIHTTPRequest *request = [self request:urlstring parsms:params method:method withData:data  completion:block];
    //拼接此借口完整的URL 带参数
    if (params != Nil) {
        
        NSMutableString *parsmsstring = [[NSMutableString alloc] init];
        NSArray *allkeys = [params allKeys];
        for (int i = 0; i < params.count; i++) {
            NSString *key = [allkeys objectAtIndex:i];
            NSString *value = [params objectForKey:key];
            [parsmsstring appendFormat:@"%@=%@",key,value];
            if (i < params.count) {
                [parsmsstring appendFormat:@"&"];
            }
        }
        //api.douban.com?start=0&count=30
        urlstring = [NSString stringWithFormat:@"%@?%@",urlstring,parsmsstring];
        
    }
    NSLog(@"请求的完整url----%@",urlstring);
    return request;

    
}
+ (ASIHTTPRequest *)requestWeixinAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method completion:(completionHandle)block
{
    //拼接此接口的不带参数URL
    NSString *urlstring = [NSString stringWithFormat:@"%@/%@",VHAKKWEIXIN_URL,subURL];
    NSLog(@"urlstring----------%@",urlstring);
    ASIHTTPRequest *request = [self request:urlstring parsms:params method:method completion:block];
    //拼接此借口完整的URL 带参数
    if (params != Nil) {
        
        NSMutableString *parsmsstring = [[NSMutableString alloc] init];
        NSArray *allkeys = [params allKeys];
        for (int i = 0; i < params.count; i++) {
            NSString *key = [allkeys objectAtIndex:i];
            NSString *value = [params objectForKey:key];
            [parsmsstring appendFormat:@"%@=%@",key,value];
            if (i < params.count) {
                [parsmsstring appendFormat:@"&"];
            }
        }
        //api.douban.com?start=0&count=30
        urlstring = [NSString stringWithFormat:@"%@?%@",urlstring,parsmsstring];
    }
    return request;
    
}
////////////////////////////////
+ (ASIHTTPRequest *)requestVhallGetPPT:(NSString *)PPTURL parsms:(NSDictionary *)params completion:(completionHandle)block
{
    ASIHTTPRequest *request = [self request:PPTURL parsms:params method:@"GET" completion:block];
    return request;
}


+ (ASIHTTPRequest *) requestVhallService:(NSString *)op withJsonDict:(NSDictionary *)jsonDict withCallbackBlock:(completionHandle)block
{
    ASIHTTPRequest *request = nil;
    NSString *ukey = [[NSUserDefaults standardUserDefaults] objectForKey:kToken];
    if(ukey == nil){
        ukey = @"";
    }
    //NSString *ukey = @"SHR5TkdnWHNIdHlyRzJDc0hnaE1IeEdMSDIzckh4N3JIeFdzRzJ1UEhnWVNHMkdPSTJkTUcyV09JWD09";
    NSDictionary *params = nil;
    if (jsonDict == nil) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                 ukey,@"ukey",
                 op,@"op", nil];
    }else{
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = nil;
        if(jsonData == nil){
            NSLog(@" Serialization Error <%@>",error);
            return request;
        }else{
            jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
         params = [NSDictionary dictionaryWithObjectsAndKeys:
                                ukey,@"ukey",
                                op,@"op",
                                jsonString,@"data", nil];
    }
    NSLog(@"Send <%@> Request Params <%@>",op,params);
    request = [self request:VHAKKWEIXIN_URL parsms:params method:@"POST" completion:block];
    return request;
}

+ (ASIHTTPRequest *)request:(NSString *)urlstring parsms:(NSDictionary *)params method:(NSString *)method withData:(NSData *)data completion:(completionHandle)block
{
    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"%@",ad.AppisNetAvailable?@"YES":@"NO");
    
    if (!ad.AppisNetAvailable)
    {
        //显示提示信息
        UIView *view = [[UIApplication sharedApplication].delegate window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.userInteractionEnabled = NO;
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NotNetWork;
        hud.labelFont = [UIFont systemFontOfSize:15.0];
        hud.margin = 10.f;
        hud.yOffset = IS_IPHONE_5?200.f:150.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }
    
    //忽略大小写比较
    NSComparisonResult result = [method caseInsensitiveCompare:@"GET"];
    
    if (result == NSOrderedSame) {//GET请求
        if (params != Nil) {
            
            NSMutableString *parsmsstring = [[NSMutableString alloc] init];
            NSArray *allkeys = [params allKeys];
            for (int i = 0; i < params.count; i++) {
                NSString *key = [allkeys objectAtIndex:i];
                NSString *value = [params objectForKey:key];
                [parsmsstring appendFormat:@"%@=%@",key,value];
                if (i < params.count) {
                    [parsmsstring appendFormat:@"&"];
                }
            }
            //api.douban.com?start=0&count=30
            urlstring = [NSString stringWithFormat:@"%@?%@",urlstring,parsmsstring];
            //            NSLog(@"get请求的完整url----%@",urlstring);
        }
    }
    
    __block ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    __weak ASIFormDataRequest * weakrequest=request;
    [request setRequestMethod:method];
    [request setTimeOutSeconds:kTimeOut];
    
    result = [method caseInsensitiveCompare:@"POST"];
    if (result == NSOrderedSame) {//POST请求
        NSArray *allkeys = [params allKeys];
        for (NSString *key in allkeys) {
            NSString *value = [params objectForKey:key];
            [request addPostValue:value forKey:key];
        }
    }
    
    [request setCompletionBlock:^{
        id result = nil;
        NSInteger code = [weakrequest responseStatusCode];
        if (code == 200) {
            NSData *data = weakrequest.responseData;
            NSError *error = NULL;
            result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                NSLog(@"NSJSONSerialization Error %@",result);
            }
        }else{
            result = @{@"error":@"网络异常,请稍后重试!"};
        }
        if (block)
        block(result);
    }];
    
    [request setFailedBlock:^{
        NSDictionary *result = nil;
        NSError *error = weakrequest.error;
        if(error){
            NSInteger code = [error code];
            switch (code) {
                case ASIRequestTimedOutErrorType:
                    
                    break;
                    //                case ASIRequestCancelledErrorType:
                    //                    用户取消操作不用处理
                    //                    break;
                default:
                    
                    break;
            }
            result = @{/*@"errorcode":[NSString stringWithFormat:@"%d",code],*/
                       @"error":@"链接超时,请稍后重试!"};
        }else{
            result = @{/*@"errorcode":[NSString stringWithFormat:@"%d",999],*/
                       @"error":@"网络异常,请稍后重试!"};
        }
        if (block)
        block(result);
    }];
   
    
    [request startAsynchronous];
    
    return request;
    
}
+ (ASIHTTPRequest *)request:(NSString *)urlstring parsms:(NSDictionary *)params method:(NSString *)method completion:(completionHandle)block
{
    //判断当前是否有网络
//    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    
//    NSLog(@"%@",ad.isNetAvailable?@"YES":@"NO");
//    
//    if (!ad.isNetAvailable)
//    {
//        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查是否启用网络功能\n步骤:设置>通用>无线局域网/蜂窝移动网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [aler show];
//    }
    
    //忽略大小写比较
    NSComparisonResult result = [method caseInsensitiveCompare:@"GET"];
    
    if (result == NSOrderedSame) {//GET请求
        if (params != Nil) {
            
            NSMutableString *parsmsstring = [[NSMutableString alloc] init];
            NSArray *allkeys = [params allKeys];
            for (int i = 0; i < params.count; i++) {
                NSString *key = [allkeys objectAtIndex:i];
                NSString *value = [params objectForKey:key];
                [parsmsstring appendFormat:@"%@=%@",key,value];
                if (i < params.count) {
                    [parsmsstring appendFormat:@"&"];
                }
            }
            //api.douban.com?start=0&count=30
            urlstring = [NSString stringWithFormat:@"%@?%@",urlstring,parsmsstring];
//            NSLog(@"get请求的完整url----%@",urlstring);
        }
    }
    
    __block ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    if (TARGET_IPHONE_SIMULATOR) {
        
    
//    //获取全局变量
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    //设置缓存方式
//    [request setDownloadCache:appDelegate.myCache];
//    //设置缓存数据存储策略，这里采取的是如果无更新或无法联网就读取缓存数据
//    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    }
    __weak ASIFormDataRequest * weakrequest=request;
    [request setRequestMethod:method];
    [request setTimeOutSeconds:kTimeOut];
    
    result = [method caseInsensitiveCompare:@"POST"];
    if (result == NSOrderedSame) {//POST请求
        NSArray *allkeys = [params allKeys];
        for (NSString *key in allkeys) {
            NSString *value = [params objectForKey:key];
            [request addPostValue:value forKey:key];
        }
    }
    
    [request setCompletionBlock:^{
        id result = nil;
        NSInteger code = [weakrequest responseStatusCode];
        NSLog(@"http code %ld",(long)code);
        if (code == 200) {
            NSData *data = weakrequest.responseData;
            NSError *error = NULL;
            result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                NSLog(@"NSJSONSerialization Error %@",result);
            }
        }
        else if(code == 417){
            [kUserDefault setObject:@"" forKey:kToken];
            [kUserDefault synchronize];
            [LVTools getIphoneInfo];
        }
            else{
            result = @{@"error":@"网络异常,请稍后重试!"};
        }
        if (block)
            block(result);
    }];
    
    [request setFailedBlock:^{
        NSDictionary *result = nil;
        NSError *error = weakrequest.error;
        if(error){
            NSInteger code = [error code];
            NSLog(@"asi http code %ld",(long)code);
            switch (code) {
                case ASIRequestTimedOutErrorType:
                    
                    break;
//                case ASIRequestCancelledErrorType:
//                    用户取消操作不用处理
//                    break;
                default:
                    
                    break;
            }
            result = @{/*@"errorcode":[NSString stringWithFormat:@"%d",code],*/
                       @"error":@"链接超时,请稍后重试!"};
        }else{
            result = @{/*@"errorcode":[NSString stringWithFormat:@"%d",999],*/
                       @"error":@"网络异常,请稍后重试!"};
        }
        if (block)
            block(result);
    }];
    
    [request startAsynchronous];
    
    return request;
}

+ (ASIHTTPRequest *)requestPPTForGetFMethod:(NSString *)url parsms:(NSDictionary *)params withBlock:(completionHandle)block
{
    
    if (params != Nil) {
        
        NSMutableString *parsmsstring = [[NSMutableString alloc] init];
        NSArray *allkeys = [params allKeys];
        for (int i = 0; i < params.count; i++) {
            NSString *key = [allkeys objectAtIndex:i];
            NSString *value = [params objectForKey:key];
            [parsmsstring appendFormat:@"%@=%@",key,value];
            if (i < params.count) {
                [parsmsstring appendFormat:@"&"];
            }
            
            //api.douban.com?start=0&count=30
            url = [NSString stringWithFormat:@"%@?%@",url,parsmsstring];
        }
    }
  __block  ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    __weak ASIFormDataRequest *weakrequest=request;
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:kTimeOut];
    
    [request setCompletionBlock:^{
        
        NSData *data = weakrequest.responseData;
        
        UIImage *img = [[UIImage alloc]initWithData:data];
        if (block)
            block(img);
    }];
    
    [request setFailedBlock:^{
        NSLog(@"%@",weakrequest.error);
    }];
    
    [request startAsynchronous];
    
    return request;
}

//发送聊天
+ (ASIHTTPRequest *)requestSendchatAPI:(NSString *)subURL parsms:(NSDictionary *)params method:(NSString *)method completion:(completionHandle)block
{
    //拼接此接口的完整URL
    NSString *urlstring = [NSString stringWithFormat:@"%@/%@",VHAKKWEIXIN_URL,subURL];
    
    __block ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    __weak ASIFormDataRequest *weakrequest = request;
    [request setRequestMethod:method];
    [request setTimeOutSeconds:kTimeOut];

        NSArray *allkeys = [params allKeys];
        for (NSString *key in allkeys) {
            NSString *value = [params objectForKey:key];
            [request addPostValue:value forKey:key];
        }
    
    [request setCompletionBlock:^{
        NSData *data = weakrequest.responseData;
        if (block)
        block(data);
    }];

    [request setFailedBlock:^{
        NSLog(@"%@",weakrequest.error);
    }];
    
    [request startAsynchronous];
    
    return request;
}
/**
 取消 当前所有请求
 */

@end
