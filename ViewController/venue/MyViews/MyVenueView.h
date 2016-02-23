//
//  MyVenueView.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//场馆顶部视图

#import <UIKit/UIKit.h>

@interface MyVenueView : UIView
@property (nonatomic,strong) UIImageView *mImgView;//图片
@property (nonatomic,strong) UILabel *imgCountLb;//图片个数
@property (nonatomic,strong) UILabel *titleLb;//场馆名
@property (nonatomic,strong) UILabel *FirstLb;//区域
@property (nonatomic,strong) UILabel *SecondLb;//价格
@property (nonatomic,strong) UILabel *ThirdLb;//评分
@property (nonatomic,strong) UIImageView *distanceImg;
@property (nonatomic,strong) UILabel *distanceLb;//距离
@property (nonatomic,strong) UIView *serviceiew;//服务；
@property (nonatomic,strong) UILabel *tipsLab;
@property (nonatomic,strong) NSDictionary *infoDic;
- (id)initWithTitle:(NSString*)title AndFirstContent:(NSString*)FContent AndSecContent:(NSString*)SContent AndThirdContent:(NSString*)TContent andBaseInfo:(NSDictionary *)info;
- (void)setScoreWith:(NSString*)score;
@end
