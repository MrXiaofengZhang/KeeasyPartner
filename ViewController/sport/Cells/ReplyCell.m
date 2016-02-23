//
//  ReplyCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/14.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "ReplyCell.h"

@implementation ReplyCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentLb = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0, BOUNDS.size.width-55.0-mygap*2, 30.0)];
        self.contentLb.font = [UIFont systemFontOfSize:11.0];
        self.contentLb.numberOfLines = 0;
        [self.contentView addSubview:self.contentLb];
    }
    return self;
}
- (void)configDic:(NSDictionary*)dic{
    NSString *time = [NSString getCreateTime:[NSString stringWithFormat:@"%lld", [dic[@"createtime"] longLongValue]/1000]];
    NSString *contentstr = [NSString stringWithFormat:@"%@:%@ %@",dic[@"userName"],dic[@"message"],time];
    if ([LVTools mToString:dic[@"parentId"]].length>0) {
        contentstr = [NSString stringWithFormat:@"%@:回复%@ %@ %@",dic[@"userName"],dic[@"lastName"],dic[@"message"],time];
    }
    NSRange range1 = [contentstr rangeOfString:[NSString stringWithFormat:@"%@:",dic[@"userName"]]];
    NSRange range2 = [contentstr rangeOfString:time];
    NSMutableAttributedString *resultStr = [LVTools attributedStringFromText:contentstr range:range1 andColor:SystemBlue];
    [resultStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range2];
    self.contentLb.attributedText = resultStr;
    self.contentLb.textAlignment = NSTextAlignmentLeft;
    self.contentLb.height = [LVTools sizeContent:contentstr With:11.0 With2:BOUNDS.size.width-55.0-mygap*2];
}
- (void)awakeFromNib {
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
