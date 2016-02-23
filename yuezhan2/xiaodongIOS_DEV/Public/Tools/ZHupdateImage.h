//
//  ZHupdateImage.h
//  yuezhan123
//
//  Created by zhoujin on 15/4/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completion)(NSDictionary *data );
@interface ZHupdateImage : NSObject
-(void)requestWithURL:(NSString *)url WithParams:(NSDictionary *)param WithType:(NSString *)type WithData:(NSData *)data With:(completionHandle)block;
-(void)requestWithURL:(NSString *)url WithParams:(NSDictionary *)param WithType:(NSString *)type WithDataArray:(NSArray *)dataArray With:(completionHandle)block;
@end
