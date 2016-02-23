//
//  ZHShuoCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHShuoCell : UITableViewCell
@property (nonatomic,strong) UIButton *headImg;//头像
@property (nonatomic,strong) UILabel *nameLb;//和动作
@property (nonatomic,strong) UIView *mcontentView;//发表内容
@property (nonatomic,strong) UIImageView *mImageView;//图片
@property (nonatomic,strong) UILabel *contentLb;//文字
@property (nonatomic,strong) UILabel *timeLb;//时间
@property (nonatomic,strong) UIButton *removeBtn;//删除
@property (nonatomic,strong) UILabel *visitCount;//浏览
@property (nonatomic,strong) UIButton *commentBtn;//评论
@property (nonatomic,strong) UIButton *zanBtn;//赞
@end
