//
//  SelfRespectZhViewController.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/20.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "SelfRespectZhViewController.h"
#import "SDImageCache.h"
#define CELLHEIGHT UISCREENHEIGHT/2/5
@interface SelfRespectZhViewController ()

@end

@implementation SelfRespectZhViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    self.view.backgroundColor=[UIColor whiteColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appImg"]];
    imageView.frame=CGRectMake(UISCREENWIDTH/4*3/2, UISCREENWIDTH/5, UISCREENWIDTH/4, UISCREENWIDTH/4);
    [self.view addSubview:imageView];
    
    UILabel *appNameLb = [[UILabel alloc] initWithFrame:CGRectMake((BOUNDS.size.width-100)/2.0, UISCREENWIDTH/5+UISCREENWIDTH/4, 100, 30)];
    appNameLb.text = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"]];
    appNameLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:appNameLb];
    UILabel *versionLabel=[[UILabel alloc]initWithFrame:CGRectMake(UISCREENWIDTH/4*3/2, appNameLb.bottom, UISCREENWIDTH/4, UISCREENWIDTH/4/2)];
    versionLabel.textAlignment=NSTextAlignmentCenter;
  
    versionLabel.text=[NSString stringWithFormat:@"v%@",[[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleShortVersionString"]];
    versionLabel.font = Content_lbfont;
    [self.view addSubview:versionLabel];
    UILabel *textLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, versionLabel.frame.origin.y+versionLabel.frame.size.height, UISCREENWIDTH, versionLabel.frame.size.height)];
    textLabel.text=@"学生专属的校园赛事平台";
    textLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:textLabel];
    //官网
    UILabel *indexUrl = [[UILabel alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height-80-64, BOUNDS.size.width, 20)];
    indexUrl.font = Content_lbfont;
    indexUrl.textColor = [UIColor lightGrayColor];
    NSString *str = @"访问www.yuezhan123.com了解更多";
    NSRange range = [str rangeOfString:@"www.yuezhan123.com"];
    indexUrl.attributedText = [LVTools attributedStringFromText:str range:range andColor:NavgationColor];
    indexUrl.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:indexUrl];
    
    
    UILabel *copyRightLb = [[UILabel alloc] initWithFrame:CGRectMake(0, BOUNDS.size.height-60-64, BOUNDS.size.width, 40)];
    copyRightLb.font = [UIFont systemFontOfSize:10.0];
    copyRightLb.textColor = [UIColor lightGrayColor];
    copyRightLb.text = @"Copyright©2014 Beijing YZCY Sports Culture. All Rights Reserved";
    copyRightLb.textAlignment = NSTextAlignmentCenter;
    copyRightLb.numberOfLines = 0;
    [self.view addSubview:copyRightLb];
    
    // Do any additional setup after loading the view.
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
