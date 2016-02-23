//
//  WPCFriendMsgTableViewCell.h
//  yuezhan123
//
//  Created by admin on 15/5/14.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TeamModel;
@interface WPCFriendMsgTableViewCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    NSArray *_prefixArr;
}

@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, assign) BOOL isMsged;
@property (nonatomic, strong) UIImageView *msgView;
@property (nonatomic, strong) UICollectionView *teamCollection;
@property (nonatomic, strong) NSMutableArray *dataArray;//战队或群组信息
@property (nonatomic, strong)NSDictionary *infoDic;//个人信息字典
@property (nonatomic, assign) BOOL isUnfolded;//是否展开
@property (nonatomic, assign) BOOL isSelect;//是否可选
@property (nonatomic, copy) void(^selectBlock)(UICollectionView *view,NSIndexPath *index);
@property (nonatomic, copy) void(^leaderBlock)(TeamModel *model);
@property (nonatomic, copy) void(^levelBlock)(TeamModel *model);
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andType:(NSInteger)type;
@end
