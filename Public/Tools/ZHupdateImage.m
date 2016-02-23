//
//  ZHupdateImage.m
//  yuezhan123
//
//  Created by zhoujin on 15/4/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHupdateImage.h"
#import "AppDelegate.h"

@implementation ZHupdateImage

-(void)requestWithURL:(NSString *)url WithParams:(NSDictionary*)param WithType:(NSString *)type WithData:(NSData *)data With:(completionHandle)block
{
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    NSMutableString *body = [[NSMutableString alloc] init];
    NSArray *keyArray=[param allKeys];
    for (int i=0; i<param.count; i++) {
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data;name=\"%@\"\r\n\r\n",[keyArray objectAtIndex:i] ];
        if ([[keyArray objectAtIndex:i]isEqualToString:@"param"]) {
            [body appendFormat:@"%@\r\n",[LVTools configDicToDES:[param objectForKey:[keyArray objectAtIndex:i]]]];
        }
        else
        {
         [body appendFormat:@"%@\r\n", [param objectForKey:[keyArray objectAtIndex:i]]];
        }
    }
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData;
    //将body字符串转化为UTF8格式的二进制
    myRequestData=[NSMutableData data];
    
    //上传文件
    [body appendFormat:@"%@\r\n",MPboundary];
    [body appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",@"image.png"];
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [myRequestData appendData:data];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",VHAKKWEIXIN_URL,url]]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    //    [request setTimeoutInterval:[DataStore getHttpTimeout]];
    [request setHTTPMethod:@"POST"];
    //设置HTTPHeader中Content-Type的值
    NSString *cttype=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:cttype forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:myRequestData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
       
        if (response==nil)
        {
            NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
            [dic setValue:@"失败" forKey:@"statusCodeInfo"];
            if (block)
            block(dic);
            return ;
            
        }
        NSError *error = nil;
        id jsonData=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
            [dic setValue:@"失败" forKey:@"statusCodeInfo"];
            if (block)
                block(dic);
            return ;
        }
        else{
        if ([jsonData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic=(NSDictionary *)jsonData;
            if (block)
            block(dic);
        }
        else{
            NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
            [dic setValue:@"失败" forKey:@"statusCodeInfo"];
            if (block)
            block(dic);
            return ;
        }
        }
    }];
}


-(void)requestWithURL:(NSString *)url WithParams:(NSDictionary *)param WithType:(NSString *)type WithDataArray:(NSArray *)dataArray With:(completionHandle)block {
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    NSMutableString *body = [[NSMutableString alloc] init];
    NSArray *keyArray=[param allKeys];
    NSLog(@"keyarray === %@",keyArray);
    for (int i=0; i<param.count; i++) {
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data;name=\"%@\"\r\n\r\n",[keyArray objectAtIndex:i] ];
        if ([[keyArray objectAtIndex:i]isEqualToString:@"param"]) {
            [body appendFormat:@"%@\r\n",[LVTools configDicToDES:[param objectForKey:[keyArray objectAtIndex:i]]]];
        }
        else
        {
            [body appendFormat:@"%@\r\n", [param objectForKey:[keyArray objectAtIndex:i]]];
        }
    }
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData;
    //将body字符串转化为UTF8格式的二进制
    myRequestData=[NSMutableData data];
    
    //上传文件
    [body appendFormat:@"%@\r\n",MPboundary];
    [body appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",@"image.png"];
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"----%@",body);
    NSLog(@"++++%@",myRequestData);
    for (int i = 0; i < dataArray.count; i ++) {
        UIImage *img = dataArray[i];
        NSData *tempData = UIImageJPEGRepresentation(img, kCompressqulitaty);
        if (tempData == nil) {
            tempData = UIImagePNGRepresentation(img);
        }
        [myRequestData appendData:tempData];
    }
    
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",VHAKKWEIXIN_URL,url]]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    //    [request setTimeoutInterval:[DataStore getHttpTimeout]];
    [request setHTTPMethod:@"POST"];
    //设置HTTPHeader中Content-Type的值
    NSString *cttype=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:cttype forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:myRequestData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        if (response==nil)
        {
            NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
            [dic setValue:@"失败" forKey:@"statusCodeInfo"];
            if (block)
                block(dic);
            return ;
            
        }
        NSError *error = nil;
        id jsonData=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"jsondata ==== %@",jsonData);
        if (error) {
            NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
            [dic setValue:@"失败" forKey:@"statusCodeInfo"];
            if (block)
                block(dic);
            return ;
        }
        else{
            if ([jsonData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic=(NSDictionary *)jsonData;
                if (block)
                    block(dic);
            }
            else{
                NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
                [dic setValue:@"失败" forKey:@"statusCodeInfo"];
                if (block)
                    block(dic);
                return ;
            }
        }
    }];
}

@end
