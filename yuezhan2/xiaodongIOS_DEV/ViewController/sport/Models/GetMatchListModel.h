//
//  GetMatchListModel.h
//  yuezhan123
//
//  Created by LV on 15/3/24.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetMatchListModel : NSObject
/*
 commentNum = 0;
 endTime = 1451404800000;
 id = 5;
 matchShow = "/upload/pic/match/show/ea5c7d0e_1450834171349.jpg";
 matchStatus = 1;
 name = "\U8861\U6c34\U5b66\U9662\U8db3\U7403\U8d5b";
 praiseNum = 0;
 registrationdeadline = 1450886400000;
 share = 1;
 signUpStatus = 1;
 singUpNum = 0;
 startTime = 1451145600000;
 type = 2;
 */
@property (nonatomic, strong)NSString *commentNum;
@property (nonatomic, strong)NSString *endtime;
@property (nonatomic, strong)NSString *matchShow;
//@property (nonatomic, strong)NSString *matchStatus;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *praiseNum;//
@property (nonatomic, strong)NSString *registrationdeadline;//报名截止时间
@property (nonatomic, strong)NSString *share;//
@property (nonatomic, strong)NSString *signUpStatus;//
@property (nonatomic, strong)NSString *singUpNum;//报名人数
@property (nonatomic, strong)NSString *starttime;//
@property (nonatomic, strong)NSString *type;//赛事类型
@property (nonatomic, strong)NSString *createtime;
@property (nonatomic, strong)NSString *createuser;
@property (nonatomic, strong)NSString *entryfee;
@property (nonatomic, strong)NSString *linkman;
//@property (nonatomic, strong)NSString *notice;
//@property (nonatomic, strong)NSString *phone;
@property (nonatomic, strong)NSString *rule;
@property (nonatomic, strong)NSString *schedule;
@property (nonatomic, strong)NSString *schoolId;
@property (nonatomic, strong)NSString *showId;
@property (nonatomic, strong)NSString *site;
@property (nonatomic, strong)NSString *sponsor;
@property (nonatomic, strong)NSString *userlimit;



@property (nonatomic, strong)NSString * area;
@property (nonatomic, strong)NSString * areaMeaning;
@property (nonatomic, strong)NSString * cashPledge;//押金
@property (nonatomic, strong)NSString * chief;
@property (nonatomic, strong)NSString * city;
@property (nonatomic, strong)NSString * cityMeaning;
@property (nonatomic, strong)NSString * contact;
@property (nonatomic, strong)NSString * customPath;
@property (nonatomic, strong)NSString * customUrl;
@property (nonatomic, strong)NSString * endDate;
@property (nonatomic, strong)NSString * hosted;
@property (nonatomic, strong)NSString * id;
@property (nonatomic, strong)NSString * introduction;
@property (nonatomic, strong)NSString * isHot;
@property (nonatomic, strong)NSString * isHotName;
@property (nonatomic, strong)NSString * isValidate;
@property (nonatomic, strong)NSString * isVerify;
@property (nonatomic, strong)NSString * matchLogo;
@property (nonatomic, strong)NSString * matchName;
@property (nonatomic, strong)NSString * matchPath;
@property (nonatomic, strong)NSString * matchStatus;
@property (nonatomic, strong)NSString * matchStatusCode;
@property (nonatomic, strong)NSString * maxUser;
@property (nonatomic, strong)NSString * needSignUpForm;
@property (nonatomic, strong)NSString * notice;
@property (nonatomic, strong)NSString * phone;
@property (nonatomic, strong)NSString * place;
@property (nonatomic, strong)NSString * processPath;
@property (nonatomic, strong)NSString * processUrl;
@property (nonatomic, strong)NSString * province;
@property (nonatomic, strong)NSString * provinceMeaning;
@property (nonatomic, strong)NSString * registrationFee;
@property (nonatomic, strong)NSString * rules;
@property (nonatomic, strong)NSString * sportsType;
@property (nonatomic, strong)NSString * sportsTypeMeaning;
@property (nonatomic, strong)NSString * startDate;
@property (nonatomic, strong)NSString * signupNum;
@property (nonatomic, strong)NSString * matchYear;
@property (nonatomic, strong)NSString * page;
@property (nonatomic, strong)NSString * rows;
@property (nonatomic, strong)NSString * matchPeople;//赛制
@property (nonatomic, strong)NSString * matchDetailLogo;
@property (nonatomic, strong)NSString * registrationNumber;//报名数
@property (nonatomic, strong)NSString * matchType;//赛事类别
@property (nonatomic, strong)NSString * matchTypeName;
@property (nonatomic, strong)NSString * signUpType;
@property (nonatomic, strong)NSString * matchDetailPath;
@property (nonatomic, strong)NSString * matchIndexLogo;
@property (nonatomic, strong)NSString * matchIndexPath;
@property (nonatomic, strong)NSString * matchPeopleMeaning;
@property (nonatomic, strong)NSString * result;
@property (nonatomic, strong)NSString * score;
@property (nonatomic, strong)NSString * signUpDate;
@property (nonatomic, strong)NSString * signUpName;
@property (nonatomic, strong)NSString * signUpPath;
@property (nonatomic, strong)NSString * signUpExt;
@property (nonatomic, strong)NSString * payTime;
@property (nonatomic, strong)NSString * verifyTime;
@property (nonatomic, strong)NSString * signUpId;

@end
