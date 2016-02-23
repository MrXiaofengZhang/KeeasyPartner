//
//  ZHReverseCode.m
//  yuezhan123
//
//  Created by zhoujin on 15/4/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHReverseCode.h"
#import "BMapKit.h"
@implementation ZHReverseCode
{
    BMKGeoCodeSearch *_geocodesearch;
}
- (id)init{
    if (self =[super init]) {
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _geocodesearch.delegate=self;
        
    }
    return self;
}
-(void)shareReverseCodeWithLongitude:(NSString *)longitude WithLatitude:(NSString *)latitude With:(codeReverseBlock)block
{
    CLLocationCoordinate2D pt = CLLocationCoordinate2DMake(0.0f, 0.0f);
    if (longitude!=nil&&latitude!=nil) {
        pt.longitude=[longitude floatValue];
        pt.latitude=[latitude floatValue];
    }
    self.codeReverse=block;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
    
}
-(void)shareForwardCodeWithCityName:(NSString *)cityname AndAddress:(NSString *)address With:(codeForwardBlock)block
{
    BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    self.codeForward=block;
    NSLog(@"###%@",cityname);
    NSLog(@"###%@",address);
    geocodeSearchOption.city= cityname;
    geocodeSearchOption.address =address;
    BOOL flag = [_geocodesearch geoCode:geocodeSearchOption];
    if(flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
    }
    
    
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
//        NSString* titleStr;
//        NSString* showmeg;
//        titleStr = @"正向地理编码";
//        showmeg = [NSString stringWithFormat:@"经度:%f,纬度:%f",item.coordinate.latitude,item.coordinate.longitude];
        
        NSDictionary *dic=@{@"longitude":[NSString stringWithFormat:@"%lf", item.coordinate.longitude],@"latitude":[NSString stringWithFormat:@"%lf", item.coordinate.latitude]};
        self.codeForward(dic);
        
    }
}
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
//        NSString* titleStr;
//        NSString* showmeg;
//        titleStr = @"反向地理编码";
//        showmeg = [NSString stringWithFormat:@"%@",item.title];
        self.codeReverse(item.title);
        //        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        //        [myAlertView show];
    }
}
@end
