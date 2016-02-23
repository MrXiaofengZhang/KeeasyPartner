//
//  NearByTableViewCell.h
//  yuezhan123
//
//  Created by LV on 15/3/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHGenderView.h"
@class NearByModel;


@interface NearByTableViewCell : UITableViewCell

@property (nonatomic, copy)void (^addFirend)(BOOL isLogin,NSString *uid,NSString * userName);;

@property (nonatomic, copy)void (^chatFirend)(NSString * uid,NSString * userName);

@property (nonatomic, strong)UIButton *headerBtn;
//@property (nonatomic, strong)UILabel * agerLabel;
@property (nonatomic, strong)UILabel * nameLabel;
@property (nonatomic, strong)UILabel * habitLabel;
//@property (nonatomic, strong)UIImageView * genderImg;
@property (nonatomic, strong)UILabel * locationLabel;
@property (nonatomic, strong)UILabel * timeagoLabel;
@property (nonatomic, strong)UIButton * addFriedBtn;
@property (nonatomic, strong)NSArray * plistArray;
@property (nonatomic, strong)ZHGenderView *genderView;
@property (nonatomic,strong) NSArray *sportArray;//爱好
@property (nonatomic, assign)BOOL isFriend;
- (void)configModel:(NearByModel *)model;

@end
