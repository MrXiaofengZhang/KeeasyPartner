//
//  ReplyCell.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/12/14.
//  Copyright © 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReplyCell : UITableViewCell
@property (nonatomic,strong) UILabel *contentLb;
- (void)configDic:(NSDictionary*)dic;
@end
