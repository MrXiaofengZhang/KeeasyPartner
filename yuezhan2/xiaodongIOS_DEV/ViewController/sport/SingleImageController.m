//
//  SingleImageController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/11/18.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "SingleImageController.h"
#import "ZHJubaoController.h"
#import "ZHCommentController.h"
#import "LoginLoginZhViewController.h"
#import "WPCTeamHpVC.h"
@interface SingleImageController (){
    UIScrollView *scrollView;
    UIImageView *img;
}

@end

@implementation SingleImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navgationBarLeftReturn];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0)];
    [self.view addSubview:scrollView];
    if(self.canApply){
        scrollView.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64.0-44.0);
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, scrollView.bottom, BOUNDS.size.width, 44.0)];
//        if (self.canApply) {
//            [btn setBackgroundColor:SystemBlue];
//        }
//        else{
//            [btn setBackgroundColor:[UIColor lightGrayColor]];
//        }
        [btn setBackgroundColor:SystemBlue];
        [btn setTitle:@"申请成为明星球队" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(applyOnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    [scrollView addSubview:self.imageView];
    scrollView.contentSize = CGSizeMake(BOUNDS.size.width, _imageView.height);
}
- (void)applyOnClick{
    if ([[kUserDefault objectForKey:kUserLogin] isEqualToString:@"1"]) {
        WPCTeamHpVC *vc = [[WPCTeamHpVC alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.title = @"选择球队";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
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
