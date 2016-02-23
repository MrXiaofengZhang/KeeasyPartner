//
//  ZHShuoModel.h
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/1.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>
//{
//    go = "<null>";
//    id = 1;
//    info = "<null>";
//    messagesAgreenum = 0;
//    messagesCommentnum = 0;
//    time = "<null>";
//    type = 1;
//    uid = 22;
//}
@interface ZHShuoModel : NSObject
@property (nonatomic,strong) NSString *go;
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *info;
@property (nonatomic,strong) NSString *messagesAgreenum;
@property (nonatomic,strong) NSString *messagesCommentnum;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSArray *timeMachineList;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *isAgree;
@property (nonatomic,strong) NSString *infoIcon;
@property (nonatomic,assign) DynamicType dynamicType;
@end
