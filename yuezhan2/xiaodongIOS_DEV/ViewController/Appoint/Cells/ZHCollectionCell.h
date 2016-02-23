//
//  ZHCollectionCell.h
//  Yuezhan123
//
//  Created by zhangxiaofeng on 15/3/20.
//  Copyright (c) 2015年 zhangxiaofeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NearByModel;
#import "TeamModel.h"
@interface ZHCollectionCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *nickNameLb;
@property (nonatomic,strong) UIImageView *rankImg;
- (void)configYingzhanDic:(NSDictionary*)dic;//迎战
- (void)configFriendModel:(NearByModel*)model;//好友
- (void)configTeamDict:(TeamModel *)dic;//战队或群组

@end
