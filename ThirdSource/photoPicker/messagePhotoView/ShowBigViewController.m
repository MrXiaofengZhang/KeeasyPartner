//
//  ShowBigViewController.m
//  testKeywordDemo
//
//  Created by mei on 14-8-18.
//  Copyright (c) 2014年 Bluewave. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "ShowBigViewController.h"
#define IOS7LATER  [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
@interface ShowBigViewController ()

@end

@implementation ShowBigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)selectedOnClick:(UIButton*)btn{
    btn.selected = !btn.selected;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedIndex = 0;
    //设置导航栏的rightButton
    _stausArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i=0; i<_arrayOK.count; i++) {
        [_stausArray addObject:@YES];
    }
    rightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightbtn.frame=CGRectMake(0, 0, 22, 22);
    [rightbtn setImage:[UIImage imageNamed:@"selecedCheck"] forState:UIControlStateNormal];
    [rightbtn setImage:[UIImage imageNamed:@"selecCheck"] forState:UIControlStateSelected];
    [rightbtn addTarget:self action:@selector(selectedOnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbtn];
    
     //设置导航栏的leftButton
    UIButton *leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftbtn.frame=CGRectMake(0, 0, 11, 20);
    
    [leftbtn setImage:[UIImage imageNamed:@"fanhui.png"] forState:UIControlStateNormal];
    [leftbtn addTarget:self action:@selector(dismiss)forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftbtn];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    //[[UINavigationBar appearance]setTintColor:SystemBlue];
   
    self.title = [NSString stringWithFormat:@"%ld/%ld",(long)(selectedIndex+1),(long)[_arrayOK count]];
    [self layOut];
    
}

-(void)layOut{
    self.view.backgroundColor = [UIColor blackColor];
            //arrayOK里存放选中的图片
   
    //CGFloat YHeight=([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)?(64.0f):(44.0f);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7LATER)
    {
          _scrollerview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50)];
         _btnOK = [[UIButton alloc]initWithFrame:CGRectMake(244,  _scrollerview.frame.size.height + 9, 61, 32)];
    }
#endif
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
    }
    else
    {
        _scrollerview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- 100)];
         _btnOK = [[UIButton alloc]initWithFrame:CGRectMake(244,  _scrollerview.frame.size.height + 11, 61, 32)];
    }
    
    
    //显示选中的图片的大图
  
    _scrollerview.backgroundColor = [UIColor clearColor];
    _scrollerview.pagingEnabled = YES;
    _scrollerview.showsHorizontalScrollIndicator = NO;
    _scrollerview.delegate = self;
    NSLog(@"self.arrayOK.count is %lu",(unsigned long)(self.arrayOK.count));
 
    for (int i=0; i<[self.arrayOK count]; i++) {
       ALAsset *asset=self.arrayOK[i];
        
        UIImageView *imgview=[[UIImageView alloc] initWithFrame:CGRectMake(i*_scrollerview.frame.size.width, 0, _scrollerview.frame.size.width, _scrollerview.frame.size.height)];
        imgview.contentMode=UIViewContentModeScaleAspectFit;
        imgview.clipsToBounds=YES;
        UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        [imgview setImage:tempImg];
        [_scrollerview addSubview:imgview];
    }
    
    _scrollerview.contentSize = CGSizeMake((self.arrayOK.count) * (self.view.frame.size.width),0);
    [self.view addSubview:_scrollerview];
    
    
    //点击按钮，回到主发布页面
   
    [_btnOK setBackgroundColor:NavgationColor];
    _btnOK.layer.masksToBounds = YES;
    _btnOK.layer.cornerRadius = 5.0;
    [_btnOK setTitle:[NSString stringWithFormat:@"完成(%lu)",(unsigned long)(self.arrayOK.count)] forState:UIControlStateNormal];
    _btnOK .titleLabel.font = [UIFont systemFontOfSize:10];
    [_btnOK addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnOK];
    
    
}
-(void)complete:(UIButton *)sender{
    NSLog(@"完成了,跳到主发布页面");
    for (NSInteger i=0; i<_arrayOK.count; i++) {
        if (![[_stausArray objectAtIndex:i] boolValue]) {
            [_arrayOK removeObjectAtIndex:i];
        }
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}


-(void)dismiss{

    [self.navigationController popViewControllerAnimated:YES];
    if([[[UIDevice currentDevice]systemVersion] doubleValue]>=7.0){
        
        self.navigationController.navigationBar.barTintColor = NavgationColor;
    }else{
        
        self.navigationController.navigationBar.tintColor = NavgationColor;
    }

}
#pragma mark UIscrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.title = [NSString stringWithFormat:@"%d/%d",(int)(scrollView.contentOffset.x/BOUNDS.size.width+1),(int)[_arrayOK count]];
    selectedIndex =scrollView.contentOffset.x/BOUNDS.size.width;
    rightbtn.selected = ![[_stausArray objectAtIndex:selectedIndex] boolValue];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
