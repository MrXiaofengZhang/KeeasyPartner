//
//  ZHSportInfoController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/7.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHSportInfoController.h"
#import "TypeView.h"
#import "GetMatchListModel.h"
#define ItemCount 6
#define topViewHeight 55.0f

@interface ZHSportInfoController ()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView *contentWebView;
@property (nonatomic,strong) TypeView *typeView;
@end

@implementation ZHSportInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    [self makeUI];
    [self loadData];
}

- (void)loadData {
    NSDictionary *dic = [LVTools getTokenApp];
    [dic setValue:self.idString forKey:@"id"];
    if ([self.title isEqualToString:@"报名须知"]) {
        [dic setValue:@"notice" forKey:@"param"];
    }
    else if ([self.title isEqualToString:@"赛事规则"]){
        [dic setValue:@"rule" forKey:@"param"];
    }
    else{
        //赛程
        [dic setValue:@"schedule" forKey:@"param"];
    }
    
    [self showHudInView:self.view hint:@"页面加载中"];
    [DataService requestWeixinAPI:getMatchInfo parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"resuilt ======       %@",result);
        [self hideHud];
        if ([result[@"status"] boolValue]) {
            
            if ([self.title isEqualToString:@"报名须知"]) {
                [self changeInfomationWithContentStr:result[@"data"][@"notice"]];
            }
            else if ([self.title isEqualToString:@"赛事规则"]){
                [self changeInfomationWithContentStr:result[@"data"][@"rule"]];
            }
            else{
                //赛程
                [self changeInfomationWithContentStr:result[@"data"][@"schedule"]];
            }

            
        } else {
            [self showHint:@"数据加载失败"];
        }
    }];
}
- (void)makeUI{
    TypeView *topView = [[TypeView alloc] initWithFrame:CGRectMake(-1, -1, BOUNDS.size.width+2, topViewHeight) Type:_matchInfo.type AndTitle:_matchInfo.name];
    [self.view addSubview:topView];
    [self.view addSubview:self.contentWebView];
}

- (void)changeInfomationWithContentStr:(NSString*)content {
    self.contentWebView.hidden = NO;
    [self.contentWebView loadHTMLString:[content stringByReplacingOccurrencesOfString:@"http://localhost/yuezhan" withString:preUrl] baseURL:nil];
}
#pragma mark getter
- (UIWebView*)contentWebView{
    if (_contentWebView == nil) {
        _contentWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, topViewHeight, BOUNDS.size.width, BOUNDS.size.height-64-topViewHeight)];
        _contentWebView.backgroundColor = [UIColor whiteColor];
        _contentWebView.scalesPageToFit = YES;
        _contentWebView.scrollView.bounces = NO;
        _contentWebView.delegate = self;
    }
    return _contentWebView;
}
#pragma mark WebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //webview内容居中
    NSString *bodyStyleVertical = @"document.getElementsByTagName('body')[0].style.verticalAlign = 'middle';";
    //水平不居中
    if ([self.title isEqualToString:@"赛事赛程"]) {
        NSString *bodyStyleHorizontal = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
        [webView stringByEvaluatingJavaScriptFromString:bodyStyleHorizontal];
    }
    
    NSString *mapStyle = @"document.getElementById('mapid').style.margin = 'auto';";
    //字体大小
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '250%'";
    [webView stringByEvaluatingJavaScriptFromString:str];
    //字体大小和颜色
//    NSString *jsString = [[NSString alloc] initWithFormat:@"document.body.style.fontSize=%f;document.body.style.color=%@",fontSize,fontColor];
//    [webView stringByEvaluatingJavaScriptFromString:jsString];
    [webView stringByEvaluatingJavaScriptFromString:bodyStyleVertical];
    
    [webView stringByEvaluatingJavaScriptFromString:mapStyle];
//    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '250%'";
//    [webView stringByEvaluatingJavaScriptFromString:str];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
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
