//
//  ImgShowViewController.h
//
//  图片展示控件
//
//  Created by Minr on 14-11-14.
//  Copyright (c) 2014年 Minr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface ImgShowViewController :BaseViewController

@property(nonatomic ,assign)NSInteger index;
@property(nonatomic ,retain)NSMutableArray *data;
@property(nonatomic, assign)BOOL isSelf;
@property(nonatomic, retain)NSMutableArray *detailArray;
@property(nonatomic, copy)void(^chuanImg)(NSInteger index);
@property(nonatomic, assign)BOOL useUrl;

- (id)initWithSourceData:(NSMutableArray *)data withIndex:(NSInteger)index hasUseUrl:(BOOL)useUrl;

@end


// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
