//
//  ZHGenderView.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/5/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHGenderView : UIView
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *lab;
/**
 XB_0001 男 XB_0002女
 */
- (id)initWithFrame:(CGRect)frame WithGender:(NSString*)gender AndAge:(NSString*)age;
- (void)setGender:(NSString*)gender;
- (void)setAge:(NSString*)age;
@end
