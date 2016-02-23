//
//  BaseViewController.m
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"

#import "MobClick.h"
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hideKeyBoard];
}
- (void)hideKeyBoard{
    [self.view endEditing:YES];
}
//友盟页面统计
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [MobClick beginLogPageView:[[self class] description]];
   
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[[self class] description]];
    //当页面消失时取消请求
    if (request) {
       // [request clearDelegatesAndCancel];
    }
}
- (void)setNoNavigationBarline:(BOOL)isNoLine{
    if (isNoLine ==YES) {
    //去掉分割线
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.5 alpha:1];
    [self.navigationController.navigationBar setBackgroundImage:[LVTools buttonImageFromColor:NavgationColor withFrame:CGRectMake(0, 0, BOUNDS.size.width, 64.0)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    else{
        self.navigationController.navigationBar.barTintColor = NavgationColor;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (UIButton*)scroTopBtn{
    if (_scroTopBtn == nil) {
        _scroTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scroTopBtn setFrame:CGRectMake(BOUNDS.size.width-60, BOUNDS.size.height-100, 40, 40)];
        _scroTopBtn.hidden = YES;
        [_scroTopBtn setImage:[UIImage imageNamed:@"yuezhan_goup"] forState:UIControlStateNormal];
        [_scroTopBtn addTarget:self action:@selector(scroTopClick) forControlEvents:UIControlEventTouchUpInside];
        return _scroTopBtn;
    }
    return _scroTopBtn;
}
- (void)scroTopClick{
    NSLog(@"滚动到底部");
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    //[self openBackGesture];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


//导航栏右侧按钮  图标+功能
- (void)navgationbarRrightImg:(NSString *)imgStr WithAction:(SEL)method WithTarget:(id)taget{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imgStr] style:UIBarButtonItemStyleDone target:taget action:method];
}
//导航栏左侧按钮，pop回到上一个界面
- (void)navgationBarLeftReturn{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PopView)];
}

- (void)DismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)openBackGesture
{
    if (self.navigationController) {
        if (iOS7) {
            self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
            if ([self isRootVC]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            } else {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
        }
    }
}
-(BOOL)isRootVC
{
    NSInteger vcAllCount = [self.navigationController.viewControllers count];
    
    if(vcAllCount > 1){
        UIViewController *rootVC = self.navigationController.viewControllers[0];
        return  self == rootVC;
    }else{
        return YES;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
