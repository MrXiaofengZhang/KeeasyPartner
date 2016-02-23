//
//  SelfInforAddrZhViewController.h
//  yuezhan123
//
//  Created by zhoujin on 15/3/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "BaseViewController.h"
#import "AreaModel.h"
@interface SelfInforAddrZhViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)AreaModel *model;
@property(nonatomic,strong)NSMutableArray *areaArray;
@property(nonatomic,strong)NSString *regionid;
@property(nonatomic,strong)NSString *province;
@property(nonatomic,strong)NSString *provinceMeaning;
@property(nonatomic,strong)NSString *city;
@property(nonatomic,strong)NSString *cityMeaning;
@property(nonatomic,strong)NSString *area;
@property(nonatomic,strong)NSString *areaMeaning;
@end
