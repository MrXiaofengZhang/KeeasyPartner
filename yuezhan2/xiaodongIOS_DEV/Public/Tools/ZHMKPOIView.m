//
//  ZHMKPOIView.m
//  yuezhan123
//
//  Created by zhoujin on 15/4/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHMKPOIView.h"
#import "ZHReverseCode.h"
@implementation ZHMKPOIView
{
    NSMutableArray *_dataArray;
    int index;
    ZHReverseCode *convertCode;
    BMKPointAnnotation* longPressItem;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mapView=[[BMKMapView alloc]initWithFrame:self.bounds];
        _mapView.delegate=self;
         [_mapView setZoomLevel:13];
        _mapView.isSelectedAnnotationViewFront = YES;
        _poisearch=[[BMKPoiSearch alloc]init];
        _poisearch.delegate=self;
        index=0;
        _dataArray =[[NSMutableArray alloc]init];
        [self addSubview:_mapView];
        //添加长按手势
        UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        lpress.minimumPressDuration = 0.3;//按0.5秒响应longPress方法
        lpress.allowableMovement = 10.0;
        //给MKMapView加上长按事件
        [_mapView addGestureRecognizer:lpress];//mapView是MKMapView的实例
    }
    return self;
}
-(void)poiSearchNearbyWithLatitude:(NSString *)latitude WithLongitude:(NSString  *)longitude WithRadius:(NSString *)radius
{
    if (self.nearby==nil) {
        self.nearby=[[BMKNearbySearchOption alloc]init];
       
    }
     self.nearby.pageIndex = 0;
    _nearby.pageCapacity=30;
    _nearby.keyword=self.SearchKey;
    _nearby.location=CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    _nearby.radius=1000000;
    BOOL flag=[_poisearch poiSearchNearBy:_nearby];
    
    if(flag)
    {
        // _nextPageButton.enabled = true;
        NSLog(@"附近周边检索发送成功");
    }
    else
    {
        //_nextPageButton.enabled = false;
        NSLog(@"附近周边内检索发送失败");
    }
}
#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    index++;
   
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置从天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0,2, annotationView.bounds.size.width, annotationView.bounds.size.height*0.5)];
        label.font=[UIFont systemFontOfSize:10];
        label.textColor=[UIColor whiteColor];
        label.tag=100;
        label.textAlignment=NSTextAlignmentCenter;
        [annotationView addSubview:label];
    }
    UILabel *label=(UILabel *)[annotationView viewWithTag:100];
    label.text=[NSString stringWithFormat:@"%d",index];
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"didAddAnnotationViews");
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    //清除数据
    [_mapView removeAnnotations:array];
    //重置index
    index=0;
    if (error == BMK_SEARCH_NO_ERROR) {
        [_dataArray removeAllObjects];
        for (int i = 0; i < result.poiInfoList.count; i++) {
          
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            item.subtitle = poi.address;
            NSDictionary *dic=@{@"title":poi.name,@"longitude":[NSString stringWithFormat:@"%lf",poi.pt.longitude],@"latitude":[NSString stringWithFormat:@"%lf",poi.pt.latitude],@"address":poi.address};
            [_dataArray addObject:dic];
            [_mapView addAnnotation:item];
            //以中间的为标准
            if(i == 0)
            {
                //将第15个点的坐标移到屏幕中央
                //_mapView.centerCoordinate = poi.pt;
                [_mapView setCenterCoordinate:poi.pt animated:YES];
               [_mapView setZoomLevel:13];
            }
            
        }
        self.chuanBlock(_dataArray,nil);
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"检索地址有岐义");
    } else if(error == BMK_SEARCH_RESULT_NOT_FOUND){
        // 各种情况的判断。。。
        self.chuanBlock(_dataArray,@"没有找到检索结果");
    }
    else{
    
        if(error == BMK_SEARCH_NOT_SUPPORT_BUS_2CITY){
            self.chuanBlock(_dataArray,@"不支持跨城市公交");
        }
        if(error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
            self.chuanBlock(_dataArray,@"检索词有岐义");
        }
        if(error == BMK_SEARCH_ST_EN_TOO_NEAR){
            self.chuanBlock(_dataArray,@"起终点太近");
        }
        if(error == BMK_SEARCH_NOT_SUPPORT_BUS){
            self.chuanBlock(_dataArray,@"该城市不支持公交搜索");
        }
    }
}
/**
 *  长按响应事件
 */
- (void)longPress:(UIGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){  //这个状态判断很重要
        //坐标转换
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        //这里的touchMapCoordinate.latitude和touchMapCoordinate.longitude就是你要的经纬度，
        NSLog(@"%f",touchMapCoordinate.latitude);
        NSLog(@"%f",touchMapCoordinate.longitude);
        if (convertCode==nil) {
            convertCode = [[ZHReverseCode alloc] init];
        }
        [convertCode shareReverseCodeWithLongitude:[NSString stringWithFormat:@"%f", touchMapCoordinate.longitude] WithLatitude:[NSString stringWithFormat:@"%f",touchMapCoordinate.latitude] With:^(NSString *string) {
            //选中的地址
            NSLog(@"选择的所在地%@",string);
            if (longPressItem == nil) {
                longPressItem = [[BMKPointAnnotation alloc]init];
            }
            longPressItem.coordinate = touchMapCoordinate;
            longPressItem.title = string;
            [self.mapView selectAnnotation:longPressItem animated:YES];//标题和子标题自动显示
            [self.mapView addAnnotation: longPressItem ];//把大头针加到地图上
        }];
//        [convertCode shareReverseCodeWithLongitude:@"116.439613" WithLatitude:@"39.961425" With:^(NSString *string) {
//            NSLog(@"当前位置:%@",string);
//        }];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
