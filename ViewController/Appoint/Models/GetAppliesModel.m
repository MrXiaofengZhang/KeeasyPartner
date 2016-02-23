//
//  GetAppliesModel.m
//  yuezhan123
//
//  Created by LV on 15/3/24.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "GetAppliesModel.h"

@implementation GetAppliesModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"GetAppliesModel未定义的key：%@",key);
}

//@property (nonatomic, strong)NSString * applyCount;
//@property (nonatomic, strong)NSString * applyLimit;
//@property (nonatomic, strong)NSString * area;
//@property (nonatomic, strong)NSString * areaMeaning;
//@property (nonatomic, strong)NSString * birthday;
//@property (nonatomic, strong)NSString * city;
//@property (nonatomic, strong)NSString * cityMeaning;
//@property (nonatomic, strong)NSString * color;
//@property (nonatomic, strong)NSString * distance;
//@property (nonatomic, strong)NSString * gender;
//@property (nonatomic, strong)NSString * id;
//@property (nonatomic, strong)NSString * introduce;
//@property (nonatomic, strong)NSString * latitude;
//@property (nonatomic, strong)NSString * longitude;
//@property (nonatomic, strong)NSString * loveSports;
//@property (nonatomic, strong)NSString * mobile;
//@property (nonatomic, strong)NSString * msgCount;
//@property (nonatomic, strong)NSString * path;
//@property (nonatomic, strong)NSString * playTime;
//@property (nonatomic, strong)NSString * playType;
//@property (nonatomic, strong)NSString * praiseCount;
//@property (nonatomic, strong)NSString * province;
//@property (nonatomic, strong)NSString * provinceMeaning;
//@property (nonatomic, strong)NSString * remarksFee;
//@property (nonatomic, strong)NSString * remarksTime;
//@property (nonatomic, strong)NSString * remarksType;
//@property (nonatomic, strong)NSString * results;
//@property (nonatomic, strong)NSString * sportsType;
//@property (nonatomic, strong)NSString * sportsTypeMeaning;
//@property (nonatomic, strong)NSString * title;
//@property (nonatomic, strong)NSString * uid;
//@property (nonatomic, strong)NSString * url;
//@property (nonatomic, strong)NSString * userAccount;
//@property (nonatomic, strong)NSString * userLogoPath;
//@property (nonatomic, strong)NSString * username;
//@property (nonatomic ,strong)NSString * usernameY;
//@property (nonatomic, strong)NSString * venuesName;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_applyCount forKey:@"applyCount"];
    [aCoder encodeObject:_applyLimit forKey:@"applyLimit"];
    [aCoder encodeObject:_area forKey:@"area"];
    [aCoder encodeObject:_areaMeaning forKey:@"areaMeaning"];
    [aCoder encodeObject:_birthday forKey:@"birthday"];
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_cityMeaning forKey:@"cityMeaning"];
    [aCoder encodeObject:_color forKey:@"color"];
    [aCoder encodeObject:_distance forKey:@"distance"];
    [aCoder encodeObject:_gender forKey:@"gender"];
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_introduce forKey:@"introduce"];
    [aCoder encodeObject:_longitude forKey:@"longitude"];
    [aCoder encodeObject:_latitude forKey:@"latitude"];
    [aCoder encodeObject:_loveSports forKey:@"loveSports"];
    [aCoder encodeObject:_mobile forKey:@"mobile"];
    [aCoder encodeObject:_msgCount forKey:@"msgCount"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeObject:_playTime forKey:@"playTime"];
    [aCoder encodeObject:_playType forKey:@"playType"];
    [aCoder encodeObject:_praiseCount forKey:@"praiseCount"];
    [aCoder encodeObject:_province forKey:@"province"];
    [aCoder encodeObject:_provinceMeaning forKey:@"provinceMeaning"];
    [aCoder encodeObject:_remarksFee forKey:@"remarksFee"];
    [aCoder encodeObject:_remarksTime forKey:@"remarksTime"];
    [aCoder encodeObject:_remarksType forKey:@"remarksType"];
    [aCoder encodeObject:_results forKey:@"results"];
    [aCoder encodeObject:_sportsType forKey:@"sportsType"];
    [aCoder encodeObject:_sportsTypeMeaning forKey:@"sportsTypeMeaning"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_userAccount forKey:@"userAccount"];
    [aCoder encodeObject:_userLogoPath forKey:@"userLogoPath"];
    [aCoder encodeObject:_username forKey:@"username"];
    [aCoder encodeObject:_usernameY forKey:@"usernameY"];
    [aCoder encodeObject:_venuesName forKey:@"venuesName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark -- nscoping
- (id)copyWithZone:(NSZone *)zone {
    GetAppliesModel *copy = [[[self class] allocWithZone:zone] init];
    
    
    
    
    
    return copy;
}

@end
