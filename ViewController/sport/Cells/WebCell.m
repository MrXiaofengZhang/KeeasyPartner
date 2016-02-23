//
//  WebCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/5.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "WebCell.h"

@implementation WebCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 2, BOUNDS.size.width, 44.0)];
        self.webView.scalesPageToFit = YES;
        self.webView.scrollView.bounces = NO;
        [self.contentView addSubview:self.webView];
        self.contentView.backgroundColor = [UIColor colorWithRed:0.808 green:0.804 blue:0.804 alpha:1.00];
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
