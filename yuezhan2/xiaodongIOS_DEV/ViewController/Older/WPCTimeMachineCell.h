//
//  WPCTimeMachineCell.h
//  yuezhan123
//
//  Created by admin on 15/6/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHShuoModel;
@interface WPCTimeMachineCell : UITableViewCell
@property (nonatomic, strong)UILabel *timelab;//时间
@property (nonatomic, strong)UIImageView *typeImg;//类型
@property (nonatomic, strong)UIView *carryView;//载体
@property (nonatomic, strong)UIView *verticalLineView;//划线
@property (nonatomic, assign)DynamicType dynamicType;
@property (nonatomic, strong)UIView *imgScanView;//图片
@property (nonatomic, strong)UILabel *countLab;//图片个数
@property (nonatomic, strong)UILabel *contentlab;//文字
@property (nonatomic,strong) UIImageView *img;//其他动态图片
- (void)makeUIByDictionaryInfo:(ZHShuoModel *)dic andCellHeight:(CGFloat)height;

@end
