//
//  NearByModel.m
//  yuezhan123
//
//  Created by LV on 15/3/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "NearByModel.h"
#define kuidKey @"kuidKey"
#define kuserNameKey @"kuserNameKey"
#define kuserAccountKey @"kuserAccountKey"
#define kIconPathKey @"kIconPathKey"
//#define kShopNumberKey @"kShopNumberKey"
//#define kStateKey @"kStateKey"
//#define kCityKey @"kCityKey"
//#define kTimeKey @"kTimeKey"
@implementation NearByModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
//    NSLog(@"NearByModel中没有定义的key：%@",key);
}
#pragma mark [对象归档] NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:[LVTools mToString: _uid] forKey:kuidKey];
//    [aCoder encodeObject:[LVTools mToString: _userAccount] forKey:KUserAcount];
//    [aCoder encodeObject:[LVTools mToString:_userName] forKey:kUserName];
//    [aCoder encodeObject:[LVTools mToString:_iconPath] forKey:kIconPathKey];
    
    
    [aCoder encodeObject:[LVTools mToString: _userId] forKey:@"kuserId"];
    [aCoder encodeObject:[LVTools mToString: _mobile] forKey:@"kmobile"];
    [aCoder encodeObject:[LVTools mToString:_nickName] forKey:@"knickName"];
    [aCoder encodeObject:[LVTools mToString:_birthday] forKey:@"kbirthday"];
    [aCoder encodeObject:[LVTools mToString:_enrollment] forKey:@"kenrollment"];
    [aCoder encodeObject:[LVTools mToString:_gender] forKey:@"kgender"];
    [aCoder encodeObject:[LVTools mToString:_realName] forKey:@"krealName"];
    [aCoder encodeObject:[LVTools mToString:_schoolId] forKey:@"kschoolId"];
    [aCoder encodeObject:[LVTools mToString:_path] forKey:@"kpath"];
//    [aCoder encodeObject:_shopNumber forKey:kShopNumberKey];
//    [aCoder encodeObject:_partnerstate forKey:kStateKey];
//    [aCoder encodeObject:_workCity forKey:kCityKey];
//    [aCoder encodeObject:_jionTime forKey:kTimeKey];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
//        _uid = [aDecoder decodeObjectForKey:kuidKey];
//        _userAccount = [aDecoder decodeObjectForKey:KUserAcount];
//        _userName = [aDecoder decodeObjectForKey:kUserName];
//        _iconPath = [aDecoder decodeObjectForKey:kIconPathKey];
        
        _userId = [aDecoder decodeObjectForKey:@"kuserId"];
        _mobile = [aDecoder decodeObjectForKey:@"kmobile"];
        _nickName = [aDecoder decodeObjectForKey:@"knickName"];
        _birthday = [aDecoder decodeObjectForKey:@"kbirthday"];
        _enrollment = [aDecoder decodeObjectForKey:@"kenrollment"];
        _gender = [aDecoder decodeObjectForKey:@"kgender"];
        _realName = [aDecoder decodeObjectForKey:@"krealName"];
        _schoolId = [aDecoder decodeObjectForKey:@"kschoolId"];
        _path = [aDecoder decodeObjectForKey:@"kpath"];
//        _shopNumber = [aDecoder decodeObjectForKey:kShopNumberKey];
//        _partnerstate = [aDecoder decodeObjectForKey:kStateKey];
//        _workCity = [aDecoder decodeObjectForKey:kCityKey];
//        _jionTime = [aDecoder decodeObjectForKey:kTimeKey];
    }
    return self;
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone {
    NearByModel *copy = [[[self class] allocWithZone:zone] init];
//    copy.uid = [self.uid copyWithZone:zone];
//    copy.userAccount = [self.userAccount copyWithZone:zone];
//    copy.userName = [self.userName copyWithZone:zone];
//    copy.iconPath = [self.iconPath copyWithZone:zone];
    
    copy.userId = [self.userId copyWithZone:zone];
    copy.mobile = [self.mobile copyWithZone:zone];
    copy.nickName = [self.nickName copyWithZone:zone];
    copy.birthday = [self.birthday copyWithZone:zone];
    copy.enrollment = [self.enrollment copyWithZone:zone];
    copy.gender = [self.gender copyWithZone:zone];
    copy.realName = [self.realName copyWithZone:zone];
    copy.schoolId = [self.schoolId copyWithZone:zone];
    copy.path = [self.path copyWithZone:zone];
//    copy.shopNumber = [self.shopNumber copyWithZone:zone];
//    copy.partnerstate = [self.partnerstate copyWithZone:zone];
//    copy.workCity = [self.workCity copyWithZone:zone];
//    copy.jionTime = [self.jionTime copyWithZone:zone];
    return copy;
}

@end
