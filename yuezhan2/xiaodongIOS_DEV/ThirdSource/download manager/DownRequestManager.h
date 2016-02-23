//
//  DownRequestManager.h
//  yuezhan123
//
//  Created by admin on 15/8/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"

@interface DownRequestManager : NSObject

@property (nonatomic, strong)AFDownloadRequestOperation *operation;
@property (nonatomic, strong)NSOperationQueue *oprationQueue;

+ (id)sharedDownRequestManager;
- (void)createOneOperationWithFileName:(NSString *)fileName andFormat:(NSString *)foramt andPath:(NSString *)path;
- (void)cancelOneOperationWithFileName:(NSString *)fileName;

@end
