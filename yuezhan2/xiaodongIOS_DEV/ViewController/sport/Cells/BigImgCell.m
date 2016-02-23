//
//  BigImgCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/14.
//  Copyright © 2015年 LV. All rights reserved.
//

#import "BigImgCell.h"

@implementation BigImgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.sportImg = [[UIImageView alloc] initWithFrame:CGRectMake(mygap, mygap, BOUNDS.size.width-2*mygap, 268.0/728.0*(BOUNDS.size.width-2*mygap))];
        //self.sportImg.layer.borderColor = [UIColor colorWithRed:0.808 green:0.804 blue:0.804 alpha:1.00].CGColor;
        //self.sportImg.layer.borderWidth = 0.7;
        //UIView *line = [UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size, <#CGFloat height#>)
        [self.contentView addSubview:self.sportImg];
        self.contentView.backgroundColor = [UIColor colorWithRed:0.808 green:0.804 blue:0.804 alpha:1.00];
        self.line = [[UIImageView alloc] initWithFrame:CGRectMake(55.0, BOUNDS.size.width*(58.0/750.0)+2, BOUNDS.size.width*(711.0/750.0)-45.0, 0.5)];
        self.line.image = [UIImage imageNamed:@"xuxian"];
        [self.contentView addSubview:self.line];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
