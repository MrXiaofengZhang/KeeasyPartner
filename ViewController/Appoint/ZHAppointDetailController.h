//
//  ZHAppointDetailController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/3/23.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
#import "ZHGenderView.h"

@class GetAppliesModel;
@interface ZHAppointDetailController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    NSMutableArray *liuyanArray;
    NSMutableArray *zanArray;
    NSMutableArray *yingzhangArray;
}
//约战详情
@property (nonatomic,strong) UITableView *mTableView;
//顶部视图
@property (nonatomic,strong) UIView *zeroView;//
@property (nonatomic,strong) UIView *firstView;
@property (nonatomic,strong) UIView *secondView;
//用户头像
@property (nonatomic,strong) UIImageView *headImage;
@property (nonatomic,strong) UIButton *talkBtn;
//@property (nonatomic,strong) UIButton *zanBtn;
//@property (nonatomic,strong) UIButton *liuyanBtn;
@property (nonatomic,strong) UIButton *shareBtn;
@property (nonatomic,strong) UIButton *callBtn;//打电话按钮
@property (nonatomic,strong) ZHGenderView *genderView;

@property (nonatomic,strong) UIScrollView *appointImgsScro;//约战图
//赛果
@property (nonatomic,strong) UITextView *xuanyanView;
@property (nonatomic,strong) UIScrollView *dianzanScrollview;//点赞人头像
//底部视图
@property (nonatomic,strong) UILabel *countYzLb;
@property (nonatomic,strong) UICollectionView *joinedCollectionView;
//点赞个数
@property (nonatomic,strong) UILabel *countLb;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UILabel *alerttitleLb;
//@property (nonatomic,strong) UITextView *contentTextV;
@property (nonatomic,strong) UIView *grayView;
//传参
@property (nonatomic,strong) GetAppliesModel *model;
@end
