//
//  ZHAgreementViewController.m
//  yuezhan123
//
//  Created by zhoujin on 15/4/16.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHAgreementViewController.h"

@interface ZHAgreementViewController ()
{
   
    UIWebView *_webView;
}
@end

@implementation ZHAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    [self makeUI];
    // Do any additional setup after loading the view.
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)makeUI
{
    _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0,0, UISCREENWIDTH, UISCREENHEIGHT-64.0)];
    _webView.dataDetectorTypes = UIDataDetectorTypeAll;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlstring]]];
  
    [self.view addSubview:_webView];
    
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
