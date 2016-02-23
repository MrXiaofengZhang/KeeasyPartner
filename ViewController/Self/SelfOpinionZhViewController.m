//
//  SelfOpinionZhViewController.m
//  yuezhan123
//
//  Created by admin on 15/4/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "SelfOpinionZhViewController.h"

@interface SelfOpinionZhViewController ()
{
    UITextView *_textView;
    UIButton *_button;

}
@end

@implementation SelfOpinionZhViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navgationBarLeftReturn];
    [self makeUI];
    // Do any additional setup after loading the view.
}
-(void)makeUI
{
    _textView=[[UITextView alloc]initWithFrame:CGRectMake(LEFTX, 20, UISCREENWIDTH-LEFTX*2, 150)];
    _textView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    _textView.layer.cornerRadius=5;
    _textView.layer.borderWidth = 0.5;

    [self.view addSubview:_textView];
    _button=[[UIButton alloc]initWithFrame:CGRectMake(LEFTX, 150+20+50, UISCREENWIDTH-LEFTX*2, 50)];
    [_button setTitle:@"提交" forState:UIControlStateNormal];
    _button.backgroundColor=INDEX_IMG_BG_COLOR;
    _button.layer.cornerRadius=5;
    [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
}
-(void)buttonClick
{
    [_textView resignFirstResponder];
    if (_textView.text.length<=18) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示！" message:@"不得少于18个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    }else
    {
        [self showHudInView:self.view hint:@"提交中..."];
        NSTimer *time=[NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(commit) userInfo:nil repeats:NO];
        [time fire];
    }
    
}
-(void)commit
{
    [self hideHud];
    [self showHint:@"意见反馈成功！"];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textView resignFirstResponder];


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
