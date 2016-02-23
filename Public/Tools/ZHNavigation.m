//
//  ZHNavigation.m
//  yuezhan123
//
//  Created by zhoujin on 15/4/8.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHNavigation.h"
#define MKKEY @"qGrc6jMYNRi7I6PluB82kT2m"
@implementation ZHNavigation

CLLocationCoordinate2D origionLoaction;
- (id)initWithBkDelegate:(id)target
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)showNavigationWithOriginLocation:(CLLocationCoordinate2D ) originlocation WithDestinationLocation:(CLLocationCoordinate2D) destinationlocation WithOriginTilte:(NSString *)orgintitle WithDestinationTitle:(NSString *)destinationtitle
{
    
    
    //初始化调启导航时的参数管理类
    BMKNaviPara* para = [[BMKNaviPara alloc]init];
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map"]])
    {
        //指定导航类型
        para.naviType = BMK_NAVI_TYPE_NATIVE;
        //指定返回自定义scheme
        para.appScheme = @"SCHOOLSPORT://schoolsport.yuezhan123.com";
    
    }
    else
    {
      
        //指定导航类型
        para.naviType = BMK_NAVI_TYPE_WEB;
        //初始化起点节点
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        //指定起点经纬度
        CLLocationCoordinate2D coor1;
        coor1.latitude = originlocation.latitude;
        coor1.longitude = originlocation.longitude;
        start.pt = coor1;
        //指定起点名称
        start.name = orgintitle;
        //指定起点
        para.startPoint = start;
        para.appName = [NSString stringWithFormat:@"%@", @"testAppName"];
    }
   
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    //指定终点经纬度
    CLLocationCoordinate2D coor2;
    coor2.latitude = destinationlocation.latitude;
    coor2.longitude = destinationlocation.longitude;
    end.pt = coor2;
    //指定终点名称
    end.name = destinationtitle;
    //指定终点
    para.endPoint = end;
    
  
    
    //调启百度地图客户端导航
    [BMKNavigation openBaiduMapNavigation:para];
    
    
    
}
@end
