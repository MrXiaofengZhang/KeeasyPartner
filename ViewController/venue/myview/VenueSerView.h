//
//  VenueSerView.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/25.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueSerView : UIView
@property (nonatomic,strong) UIImageView *leftImg;
@property (nonatomic,strong) UILabel *nameLb;
- (id)initWithFrame:(CGRect)frame Title:(NSString*)title AndImg:(NSString*)img;

@end
