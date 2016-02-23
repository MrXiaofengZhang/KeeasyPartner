//
//  ZHNavgationSearchBar.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/26.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHNavgationSearchBar.h"

@implementation ZHNavgationSearchBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame=CGRectMake(0, 0, UISCREENWIDTH, 64);
        _searchTextField=[[UITextField alloc]initWithFrame:CGRectMake(UISCREENWIDTH/9.0-5   , 5, UISCREENWIDTH/9.0*7,30)];
        _searchTextField.layer.cornerRadius=15;
        _searchTextField.backgroundColor = BackBlue_dan;
        _searchTextField.textColor = [UIColor whiteColor];
        _searchTextField.font=[UIFont systemFontOfSize:14];
        _searchTextField.borderStyle=UITextBorderStyleNone;
        _searchTextField.leftViewMode = UITextFieldViewModeAlways;
        _searchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mygap, 0)];
        _searchTextField.keyboardType=UIKeyboardTypeWebSearch;
        //iOS7下光标不显示
        if(iOS7){
            [_searchTextField setTintColor:[UIColor blueColor]];
        }
        [self addSubview:_searchTextField];
        _searchView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [_searchView addTarget:self action:@selector(SearchViewbuttonclick:) forControlEvents:UIControlEventTouchUpInside];
        _searchView.backgroundColor=[UIColor lightGrayColor];
        _searchView.alpha=0.5;

        //透明按钮
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearBtn.frame = CGRectMake(UISCREENWIDTH-38, 10, 24, 24);
        [_clearBtn addTarget:self action:@selector(clearclick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)clearclick
{
    [self.delegate searchClickEvent];
}

-(void)SearchViewbuttonclick:(UIButton *)button
{
   
    [_searchTextField resignFirstResponder];
    [_searchView removeFromSuperview];
    [_clearBtn removeFromSuperview];
    [self removeFromSuperview];
    [self.delegate assignSelfToBeNil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
