//
//  TeamCollectCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/20.
//  Copyright © 2016年 LV. All rights reserved.
//

@class TeamModel;
@interface TeamCollectCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *nickNameLb;
@property (nonatomic,strong) UIButton *ownerBtn;
@property (nonatomic,strong) UIButton *levelBtn;
- (void)configTeamDict:(TeamModel *)dic;
@end
