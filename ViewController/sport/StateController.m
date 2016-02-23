//
//  StateController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/8.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "StateController.h"

@interface StateController ()
@property (nonatomic,strong) UIWebView *ContentView;
@end

@implementation StateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"免责声明";
    [self navgationBarLeftReturn];
    self.ContentView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0-50.0)];
    [self.ContentView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"state" ofType:@"html"]]]];
    [self.view addSubview:self.ContentView];
    
    UIButton *agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(BOUNDS.size.width*0.2, self.ContentView.bottom+10, BOUNDS.size.width*0.2, 30.0)];
    [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
    [agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [agreeBtn setBackgroundColor:SystemBlue];
    agreeBtn.layer.cornerRadius = mygap;
    [agreeBtn addTarget:self action:@selector(agreeclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreeBtn];
    
    UIButton *rejecBtn = [[UIButton alloc] initWithFrame:CGRectMake(agreeBtn.right+BOUNDS.size.width*0.2, self.ContentView.bottom+10, BOUNDS.size.width*0.2, 30.0)];
    [rejecBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    [rejecBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rejecBtn setBackgroundColor:[UIColor grayColor]];
    rejecBtn.layer.cornerRadius = mygap;
    [rejecBtn addTarget:self action:@selector(rejectclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rejecBtn];
}
- (void)agreeclick{
    self.chuanBlock(nil);
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rejectclick{
    [self.navigationController popViewControllerAnimated:YES];
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
