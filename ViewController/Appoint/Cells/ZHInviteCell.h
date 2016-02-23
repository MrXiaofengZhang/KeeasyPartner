//
//  ZHInviteCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/13.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"


@class NearByModel;
@class ZHGenderView;
@interface ZHInviteCell : SWTableViewCell
@property (nonatomic,strong) UIImageView *headimg;//头像
@property (nonatomic,strong) UILabel *nameLb;//用户名
@property (nonatomic,strong) UILabel *timeLb;//时间
@property (nonatomic,strong) UILabel *jobLb;//职业
@property (nonatomic,strong) ZHGenderView *genderImg;//相别及年龄
@property (nonatomic,strong) NSArray *sportArray;//爱好
@property (nonatomic,strong) UILabel *hobbyLb;//签名
@property (nonatomic,strong) UIButton *selectedBtn;//选中按钮
@property (nonatomic,strong) NSArray *plistArray;
@property (nonatomic,strong) UILabel *distanceLb;//距离
@property (nonatomic,assign) MemberType menberType;//几个界面cell的区分
@property (nonatomic,strong) UIImageView *statusLab;//附近的人里面的队长，队员等区分标志
@property (nonatomic,strong) UIButton *applyStatus;//申请状态
@property (nonatomic,strong) UILabel *newfans;//新粉丝
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier menbertype:(MemberType)type;
- (void)configModel:(NearByModel*)model;
@end
