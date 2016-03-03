//
//  CoShuXing.h
//  CoAddressListDemo
//
//  Created by Co_Lee on 14-7-11.
//  Copyright (c) 2014年 ___ShenKeYi___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoShuXing : NSObject 

@property NSInteger sectionNumber;

@property NSInteger recordID;

@property (nonatomic,strong) NSNumber *localID;

@property(nonatomic,strong)NSString *name;

@property(nonatomic,strong)NSString *email;

@property(nonatomic,strong)NSMutableArray *tel;

@property (nonatomic,strong)NSString *headImg;

@property (nonatomic,strong)NSString *birthday;

@property (nonatomic,strong)NSString *work;





@end
