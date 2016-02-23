//
//  EditViewController.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/1/6.
//  Copyright © 2016年 LV. All rights reserved.
//

#import "BaseViewController.h"

@interface EditViewController : BaseViewController
@property (nonatomic,strong) NSMutableDictionary *infoDic;
@property (nonatomic,strong) NSString *contentStr;
@property (nonatomic,assign) BOOL isEditSign;//是否编辑个性签名
@end
