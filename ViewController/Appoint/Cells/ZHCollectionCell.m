//
//  ZHCollectionCell.m
//  Yuezhan123
//
//  Created by zhangxiaofeng on 15/3/20.
//  Copyright (c) 2015年 zhangxiaofeng. All rights reserved.
//

#import "ZHCollectionCell.h"
#import "NearByModel.h"
@implementation ZHCollectionCell
- (id)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        [self customView];
    }
    return self;
}
- (void)customView{
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.nickNameLb];
    _rankImg = [[UIImageView alloc] initWithFrame:CGRectMake(_headImageView.right-15.0f, _headImageView.bottom-15.0f, 20.0f, 20.0f)];
    _rankImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_rankImg];

}
- (void)configTeamDict:(TeamModel *)dic{
//    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"iconPath"]]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
//    self.nickNameLb.text = [LVTools mToString:[dic objectForKey:@"username"]];
    if ([LVTools mToString:dic.path].length>0) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic.path]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    }
    else{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic.teamFace]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    }
    self.nickNameLb.text = [LVTools mToString:dic.teamName];
    
    if (!dic.isSelected==NO) {
        _rankImg.image = [UIImage imageNamed:@"selected"];
    }
    else{
        _rankImg.image = [UIImage imageNamed:@"select"];
    }
}
- (void)configYingzhanDic:(NSDictionary *)dic{
    
    if ([[LVTools mToString:dic[@"teamName"]] length] > 0) {//团队迎战
        self.nickNameLb.text = [LVTools mToString:[dic objectForKey:@"teamName"]];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"teamPath"]]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    } else {//个人应战
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"iconPath"]]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
        self.nickNameLb.text = [LVTools mToString:[dic objectForKey:@"username"]];
    }
}

- (void)configFriendModel:(NearByModel *)model{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:model.iconPath]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    self.nickNameLb.text = [LVTools mToString:model.userName];
}
#pragma mark Getter
- (UIImageView*)headImageView{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _headImageView.image = [UIImage imageNamed:@"SelfUserHeadDefault"];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        _headImageView.layer.cornerRadius = 30.0;
        
        ;    }
    return _headImageView;
}
- (UILabel*)nickNameLb{
    if (_nickNameLb == nil) {
        _nickNameLb = [[UILabel alloc] initWithFrame:CGRectMake(0, _headImageView.bottom, 60, 20)];
        _nickNameLb.font = [UIFont systemFontOfSize:12.0];
        _nickNameLb.textAlignment = NSTextAlignmentCenter;
        _nickNameLb.text = @"";
    }
    return _nickNameLb;
}
@end
