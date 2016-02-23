//
//  ZHClickBigImageView.h
//  yuezhan123
//
//  Created by zhoujin on 15/4/17.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHClickBigImageView : UIView <NSURLConnectionDataDelegate>
@property (nonatomic,strong) UIImageView *imageView;
- (id)initWithUserHeadImg:(UIImage *)headImg;
@end
