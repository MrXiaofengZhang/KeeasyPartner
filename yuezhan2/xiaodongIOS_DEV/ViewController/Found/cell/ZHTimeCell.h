//
//  ZHTimeCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ZHTimeCellDelegate<NSObject>
@optional
- (void)mcollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface ZHTimeCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>{
    UIView *whiteBg;
    UIView *lineTop;
}
@property (nonatomic,strong) UIButton *headImg;//头像
@property (nonatomic,strong) UILabel *nameLb;//昵称
@property (nonatomic,strong) UILabel *contentLb;//文字
@property (nonatomic,strong) UICollectionView *imgCollection;//图片集合
@property (nonatomic,strong) UILabel *timeLb;//时间
@property (nonatomic,strong) UIButton *removeBtn;//删除
@property (nonatomic,strong) UILabel *visitCount;//浏览
@property (nonatomic,strong) UIButton *commentBtn;//评论
@property (nonatomic,strong) UIButton *zanBtn;//赞

@property (nonatomic,strong) NSArray *imgArray;//图片集合
@property (nonatomic,assign) id<ZHTimeCellDelegate> delegate;
- (void)reDrawViews;
@end
