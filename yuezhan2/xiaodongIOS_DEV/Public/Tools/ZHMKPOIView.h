//
//  ZHMKPOIView.h
//  yuezhan123
//
//  Created by zhoujin on 15/4/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
/*
 _poiView=[[ZHMKPOIView alloc]initWithFrame:CGRectMake(0, 180, UISCREENWIDTH, 300)];
 [self.view addSubview:_poiView];
 _poiview.CityName=@"北京" 必须把市去掉
 _poiview.SearchKey=@"场地";
 
 poiView.chuanBlock=^(NSArray * arr)
 {
 for (NSDictionary *dic in arr) {
 NSLog(@"dic=%@",dic);
 }
 };
 [_poiView onClickNextPage];//获得第一页的数据
 
*/
@interface ZHMKPOIView : UIView <BMKMapViewDelegate,BMKPoiSearchDelegate>

- (id)initWithFrame:(CGRect)frame;
//附近周边检索
-(void)poiSearchNearbyWithLatitude:(NSString *)latitude WithLongitude:(NSString  *)longitude WithRadius:(NSString *)radius;
@property(nonatomic,strong) BMKMapView*mapView;
@property(nonatomic,strong) BMKPoiSearch*poisearch;
@property(nonatomic,strong) BMKNearbySearchOption *nearby;
@property(nonatomic,strong)NSString *CityName;
@property(nonatomic,strong)NSString *SearchKey;
@property(nonatomic,strong)void(^chuanBlock)(NSArray *arr,NSString *errorInfo);
@end
