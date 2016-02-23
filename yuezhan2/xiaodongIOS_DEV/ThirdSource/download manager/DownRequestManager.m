//
//  DownRequestManager.m
//  yuezhan123
//
//  Created by admin on 15/8/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "DownRequestManager.h"

static DownRequestManager *downRequestManager = nil;

@implementation DownRequestManager

+ (id)sharedDownRequestManager
{
    if (downRequestManager == nil) {
        downRequestManager = [[DownRequestManager alloc] init];
    }
    return downRequestManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _oprationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)createOneOperationWithFileName:(NSString *)fileName andFormat:(NSString *)foramt andPath:(NSString *)path {
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject] stringByAppendingFormat:@"/%@.%@",fileName,foramt];
    NSLog(@"---------------%@",filePath);
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",preUrl,path];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:36000];
    _operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
    __weak typeof(self) weakSelf = self;
    NSLog(@"%@",urlStr);
    NSDictionary *dic = @{@"detailFile":path,@"sandBoxPath":filePath};//此通知信息用来判断是不是同一个赛事的相关
    [_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_COMPLETE_NOTIFICATION object:weakSelf userInfo:dic];//成功通知
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_FAILED_NOTIFICATION object:weakSelf userInfo:dic];//失败通知
    }];
    [_operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {//下载的进度管理
        
    }];
    [self.oprationQueue addOperation:_operation];
}

- (void)cancelOneOperationWithFileName:(NSString *)fileName
{
    [_operation cancel];
    NSError *error = nil;
    [_operation cancelTempFileWithError:&error];
}

@end
