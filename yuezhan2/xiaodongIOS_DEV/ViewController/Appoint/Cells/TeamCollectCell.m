//
//  TeamCollectCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/20.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "TeamCollectCell.h"
#import "TeamModel.h"
@implementation TeamCollectCell
- (id)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        [self customView];
    }
    return self;
}
- (void)customView{
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.levelBtn];
    [self.contentView addSubview:self.nickNameLb];

}
- (void)configTeamDict:(TeamModel *)dic{
    //    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:[dic objectForKey:@"iconPath"]]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    //    self.nickNameLb.text = [LVTools mToString:[dic objectForKey:@"username"]];
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[LVTools mToString:dic.path]]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
    self.nickNameLb.text = [LVTools mToString:dic.teamName];
    NSInteger teamLevel = [dic.teamLevel integerValue];
    if (teamLevel == 0) {
        [self.levelBtn setBackgroundImage:[UIImage imageNamed:@"lv_3"]forState:UIControlStateNormal];
        [self.levelBtn setTitle:@"1" forState:UIControlStateNormal];
    }
    else{
        if (teamLevel>0&&teamLevel<100) {
            [self.levelBtn setBackgroundImage:[UIImage imageNamed:@"lv_2"]forState:UIControlStateNormal];
            [self.levelBtn setTitle:[NSString stringWithFormat:@"%d",(int)teamLevel] forState:UIControlStateNormal];
        }
        else if(teamLevel>99&&teamLevel<1000){
            [self.levelBtn setBackgroundImage:[UIImage imageNamed:@"lv_2"]forState:UIControlStateNormal];
            [self.levelBtn setTitle:@"99+" forState:UIControlStateNormal];
        }
        else{
            [self.levelBtn setBackgroundImage:[UIImage imageNamed:@"lv_1"]forState:UIControlStateNormal];
            [self.levelBtn setTitle:@"" forState:UIControlStateNormal];
        }
    }
    
}
#pragma mark Getter
- (UIImageView*)headImageView{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _headImageView.image = [UIImage imageNamed:@"SelfUserHeadDefault"];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.layer.cornerRadius = 3.0;
        
        [_headImageView addSubview:self.ownerBtn];
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
- (UIButton*)ownerBtn{
    if (_ownerBtn == nil) {
        _ownerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        [_ownerBtn setBackgroundImage:[UIImage imageNamed:@"owner"] forState:UIControlStateNormal];
    }
    return _ownerBtn;
}
- (UIButton*)levelBtn{
    if (_levelBtn == nil) {
        _levelBtn = [[UIButton alloc] initWithFrame:CGRectMake(_headImageView.right-15.0f, _headImageView.bottom-15.0f, 20.0f, 20.0f)];
        _levelBtn.contentMode = UIViewContentModeScaleAspectFit;
        _levelBtn.titleLabel.textColor = [UIColor whiteColor];
        _levelBtn.titleLabel.font = [UIFont systemFontOfSize:9];
    }
    return _levelBtn;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
