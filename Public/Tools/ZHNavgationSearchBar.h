//
//  ZHNavgationSearchBar.h
//  yuezhan123
//
//  Created by zhoujin on 15/3/26.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
//添加
/*
 -(void)searchBarShow
 {
 _search=[[ZHNavgationSearchBar alloc]init];
 [self.navigationController.navigationBar addSubview:_search];
 [self.view addSubview:_search.searchView];
 [_search.searchTextField becomeFirstResponder];
 _search.searchTextField.delegate=self;
 
 }
 */
//移除
/*
 -(BOOL)textFieldShouldReturn:(UITextField *)textField
 {
 [textField resignFirstResponder];
 [_search.searchView removeFromSuperview];
 [_search removeFromSuperview];
 
 
 return YES;
 }
*/
@protocol SearchClickDelegate <NSObject>

- (void)searchClickEvent;
- (void)assignSelfToBeNil;

@end


@interface ZHNavgationSearchBar : UIView
@property(nonatomic,strong)UITextField *searchTextField;
@property(nonatomic,strong)UIButton *searchView;
@property(nonatomic,strong)UIButton *clearBtn;
@property(nonatomic,assign)id <SearchClickDelegate> delegate;
@end
