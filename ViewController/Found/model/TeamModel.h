//
//  TeamModel.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/9.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamModel : NSObject
/*{
 area = "";
 areaMeaning = "\U671d\U9633\U533a";
 captainId = 1220;
 captainName = hongyan;
 city = "";
 cityMeaning = "\U5317\U4eac";
 club = "<null>";
 createtime = 1438761530000;
 createuser = hongyan;
 department = "<null>";
 distance = 0;
 hospital = "<null>";
 iconPath = "/upload/pic/team/show/20150805155850411.png";
 iconUrl = "20150805155850411.png";
 id = 1269;
 introduce = "";
 kind = "DWXZ_0002";
 latitude = "39.954225";
 lmodifytime = 1438761530000;
 lmodifyuser = hongyan;
 longitude = "116.426748";
 memberNumber = "<null>";
 often = "<null>";
 other = "<null>";
 phone = 1111111111;
 province = "";
 provinceMeaning = "\U5317\U4eac";
 slogan = 1111;
 sportsType = "YDLX_0004";
 status = "<null>";
 teamName = 1111;
 university = "";
 },
 {
 academic = "\U5728\U8fd9\U91cc";
 check = 0;
 club = "\U5728\U8fd9\U91cc";
 createTime = "<null>";
 creatorId = "<null>";
 creatorMobile = "<null>";
 department = "\U5728\U8fd9\U91cc";
 distance = 0;
 latitude = "39.961439";
 longitude = "116.439643";
 often = "";
 path = "/upload/pic/team/logo/cc92b8d8_1451963990064.png";
 schoolId = "<null>";
 signUp = 0;
 slogan = "\U4e0d\U9519\U4e0d\U9519";
 sportsType = "<null>";
 status = 0;
 teamFace = "<null>";
 teamId = "<null>";
 teamLevel = "<null>";
 teamName = "<null>";
 teamType = "<null>";
 thumbPath = "/upload/pic/team/logo/cc92b8d8_1451963990064_thumb.png";
 time = 0;
 }
*/
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *area;
@property (nonatomic,copy) NSString *areaMeaning;
@property (nonatomic,copy) NSString *creatorId;
@property (nonatomic,copy) NSString *creatorName;
@property (nonatomic,copy) NSString *matchStatus;
@property (nonatomic,copy) NSString *inTeam;
@property (nonatomic,copy) NSString *captainId;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,copy) NSString *captainName;
@property (nonatomic,copy) NSString *city;
@property (nonatomic,copy) NSString *cityMeaning;
@property (nonatomic,copy) NSString *createtime;
@property (nonatomic,copy) NSString *createuser;
@property (nonatomic,copy) NSString *iconPath;
@property (nonatomic,copy) NSString *iconUrl;
@property (nonatomic,copy) NSString *introduce;
@property (nonatomic,copy) NSString *kind;
@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;
@property (nonatomic,copy) NSString *lmodifytime;
@property (nonatomic,copy) NSString *lmodifyuser;
@property (nonatomic,copy) NSString *memberNumber;
@property (nonatomic,copy) NSString *often;
@property (nonatomic,copy) NSString *other;
@property (nonatomic,copy) NSString *creatorMobile;
@property (nonatomic,copy) NSString *province;
@property (nonatomic,copy) NSString *provinceMeaning;
@property (nonatomic,copy) NSString *slogan;
@property (nonatomic,copy) NSString *sportsType;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSString *teamName;
@property (nonatomic,copy) NSString *university;
@property (nonatomic,copy) NSString *club;//俱乐部
@property (nonatomic,copy) NSString *distance;//距离
@property (nonatomic,copy) NSString *department;//系
@property (nonatomic,copy) NSString *hospital;//学院
@property (nonatomic,copy) NSString *playing;
@property (nonatomic,copy) NSString *matching;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *academic;//学院
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *teamFace;
@property (nonatomic,copy) NSString *schoolId;
@property (nonatomic,copy) NSString *signUp;
@property (nonatomic,copy) NSString *thumbPath;
@property (nonatomic,copy) NSString *teamType;
@property (nonatomic,copy) NSString *teamId;
@property (nonatomic,copy) NSString *teamLevel;
@property (nonatomic,copy) NSString *time;
@property (nonatomic,copy) NSString *schoolName;
@property (nonatomic,copy) NSString *fansCount;
@property (nonatomic,assign) BOOL isSelected;

//academic = "\U5728\U8fd9\U91cc";
//check = 0;
//club = "\U5728\U8fd9\U91cc";
//createTime = 1451964006000;
//creatorId = 25;
//creatorMobile = 13146518485;
//department = "\U5728\U8fd9\U91cc";
//distance = "0.002561586948462197";
//latitude = "39.961477";
//longitude = "116.43969";
//often = "";
//path = "/upload/pic/team/logo/cc92b8d8_1451963990064.png";
//records =         (
//);
//schoolId = 1;
//signUp = 0;
//slogan = "\U4e0d\U9519\U4e0d\U9519";
//sportsType = 2;
//status = 0;
//teamFace = 127;
//teamId = 6;
//teamLevel = 0;
//teamName = "\U8db3\U7403\U5c0f\U5c06";
//teamType = "<null>";
//thumbPath = "/upload/pic/team/logo/cc92b8d8_1451963990064_thumb.png";
//time = 0;
//userPath =         (
//                    "<null>"
//                    );
@end
