//
//  ImgShowViewController.m
//  Project-Movie
//
//  Created by Minr on 14-11-14.
//  Copyright (c) 2014年 Minr. All rights reserved.
//

#import "ImgShowViewController.h"
#import "MRImgShowView.h"

@interface ImgShowViewController ()

@property (nonatomic, strong)UIImage *currentImg;

@end

@implementation ImgShowViewController

- (id)initWithSourceData:(NSMutableArray *)data withIndex:(NSInteger)index hasUseUrl:(BOOL)useUrl{
    
    self = [super init];
    if (self) {
        [self init];
        self.useUrl = useUrl;
        _data = [data retain];
        _index = index;
    }
    return self;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)dealloc{
    
    [_data release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"图片列表";
    // 隐藏导航栏
    self.navigationController.navigationBarHidden = YES;

    self.automaticallyAdjustsScrollViewInsets = NO;

    
    [self creatImgShow];
}

- (void)saveAction
{
    MRImgShowView *imgShowView = (MRImgShowView *)[self.view viewWithTag:500];
    if (self.useUrl == YES) {
        NSLog(@"%@",_data[imgShowView.curIndex]);
        NSURL *url = [NSURL URLWithString:_data[imgShowView.curIndex]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        _currentImg = [UIImage imageWithData:data];
    } else {
        _currentImg = (UIImage *)_data[imgShowView.curIndex];
    }
    [LVTools saveImageToPhotos:_currentImg WithTarget:self AndMothod:@selector(image:didFinishSavingWithError:contextInfo:)];
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    
    NSString *msg = nil ;
    
    if(error != NULL){
        
        msg = @"保存图片失败" ;
        
    }else{
        
        msg = @"保存图片成功" ;
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                          
                                                    message:msg
                          
                                                   delegate:self
                          
                                          cancelButtonTitle:@"确定"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
}
// 初始化视图
- (void)creatImgShow{
    
    MRImgShowView *imgShowView = [[[MRImgShowView alloc]
                                  initWithFrame:self.view.frame
                                    withSourceData:_data
                                    withIndex:_index
                                  andvc:self
                                  hasUseUrl:self.useUrl] autorelease];
    imgShowView.tag = 500;
    // 解决谦让
    [imgShowView requireDoubleGestureRecognizer:[[self.view gestureRecognizers] lastObject]];
    
    [self.view addSubview:imgShowView];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = CGRectMake(10, 30, 36, 24);
    [self.view addSubview:btn1];
    [self.view bringSubviewToFront:btn1];

    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (_isSelf) {
        //删除
        [btn2 setTitle:@"删除" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        //保存
        [btn2 setTitle:@"保存" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    btn2.frame = CGRectMake(UISCREENWIDTH-50, 32, 40, 20);
    [self.view addSubview:btn2];
    [self.view bringSubviewToFront:btn2];
}

- (void)deleteAction
{
    [WCAlertView showAlertWithTitle:nil message:@"确定删除此图片么？" customizationBlock:^(WCAlertView *alertView) {
        //todo wpc
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
            MRImgShowView *imgShowView = (MRImgShowView *)[self.view viewWithTag:500];
            //向服务器提交删除图片的数据，删除成功对详情页也进行处理，然后返回
            NSDictionary *dic = [LVTools getTokenApp];
            [dic setValue:[_detailArray objectAtIndex:imgShowView.curIndex][@"id"] forKey:@"id"];
            [DataService requestWeixinAPI:deletePlayShow parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                NSLog(@"===========%@",result);
                if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                    NSLog(@"imgShowView%@",imgShowView);
                    self.chuanImg(imgShowView.curIndex);
                    [self.navigationController popViewControllerAnimated:YES];
                    self.navigationController.navigationBarHidden = NO;
                }
            }];
        }
    } cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
}

#pragma mark -NavAction
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
}
@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
