//
//  WPCCommentCell.h
//  yuezhan123
//
//  Created by admin on 15/6/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WPCCommentType) {
    WPCAppointCommentType = 0,//个人中心评论cell(没有楼，没按钮）
    WPCVenueCommentType,//带五星评分的cell（运动场馆）
    WPCSportCommentType,//比赛详情评论cell(楼 回复更多按钮)
};
@interface WPCCommentCell : UITableViewCell

@property (nonatomic, strong)UIButton *headImgView;//头像
@property (nonatomic, strong)UILabel *nickNameLb;
@property (nonatomic, strong)UIImageView *genderImg;
@property (nonatomic, strong)UILabel *contentLab;
@property (nonatomic, strong)UILabel *timeLab;
@property (nonatomic, strong)UIButton *morActionBtn;
@property (nonatomic, strong)UIButton *replyActionBtn;
@property (nonatomic, assign)WPCCommentType commentType;
@property (nonatomic, strong) UILabel *floorLb;
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) NSIndexPath *index;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier commentType:(WPCCommentType)type;

- (void)configTheCellContent:(NSDictionary *)dic;
- (void)configTheplayContent:(NSDictionary *)dic;

@end
