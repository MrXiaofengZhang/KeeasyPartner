//
//  WPCCustomKeyboard.h
//  yuezhan123
//
//  Created by admin on 15/7/2.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WPCCustomKeyboardDelegate <NSObject>

@required
-(void)talkBtnClick:(UITextView *)textViewGet;

@end

@interface WPCCustomKeyboard : NSObject<UITextViewDelegate>

@property (nonatomic,assign) id<WPCCustomKeyboardDelegate>mDelegate;
@property (nonatomic,strong)UIView *mBackView;
@property (nonatomic,strong)UIView *mTopHideView;
@property (nonatomic,strong)UITextView * mTextView;
@property (nonatomic,strong)UIView *mHiddeView;
@property (nonatomic,strong)UIViewController *mViewController;
@property (nonatomic,strong)UIView *mSecondaryBackView;
@property (nonatomic,strong)UIButton *mTalkBtn;
@property (nonatomic) BOOL isTop;//用来判断评论按钮的位置

+(WPCCustomKeyboard *)customKeyboard;

-(void)textViewShowView:(UIViewController *)viewController customKeyboardDelegate:(id)delegate;

@end
