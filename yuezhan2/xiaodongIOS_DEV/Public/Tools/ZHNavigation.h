//
//  ZHNavigation.h
//  yuezhan123
//
//  Created by zhoujin on 15/4/8.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

/* 
 
  ZHNavigation *_zhnavigation;
 _zhnavigation=[[ZHNavigation alloc]initWithBkDelegate:self];
 CLLocationCoordinate2D OriginLocation,DestinationLocation;
 OriginLocation.latitude=[[kUserDefault objectForKey:kLocationLat] floatValue];
 
 OriginLocation.longitude=[[kUserDefault objectForKey:kLocationlng] floatValue];
 NSLog(@"latitude=%f", OriginLocation.latitude);
 NSLog(@"longitude=%f", OriginLocation.longitude);
 DestinationLocation.latitude=39.90868;
 DestinationLocation.longitude=116.3956;
 
 [_zhnavigation showNavigationWithOriginLocation:OriginLocation WithDestinationLocation:DestinationLocation WithOriginTilte:nil WithDestinationTitle:nil];
*/



@interface ZHNavigation : NSObject<BMKLocationServiceDelegate>
@property(nonatomic,strong)BMKMapManager* mapManager;
- (id)initWithBkDelegate:(id)target;
-(void)showNavigationWithOriginLocation:(CLLocationCoordinate2D ) originlocation WithDestinationLocation:(CLLocationCoordinate2D) destinationlocation WithOriginTilte:(NSString *)orgintitle WithDestinationTitle:(NSString *)destinationtitle;
@end
