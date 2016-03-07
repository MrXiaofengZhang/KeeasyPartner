//
//  Global.h
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//



#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


#define CHATVIEWBACKGROUNDCOLOR [UIColor colorWithRed:0.936 green:0.932 blue:0.907 alpha:1]


#define BOUNDS [UIScreen mainScreen].bounds

#define iOS7 [[[UIDevice currentDevice]systemVersion]floatValue]>=7.0


#define garyLineColor [UIColor colorWithRed:72/255.0 green:72/255.0 blue:72/255.0 alpha:1]//系统字体灰色
//color
#define OlderItem_Color [UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.00f]

#define INDEX_BG_COLOR [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.00f]//首页背静颜色
#define INDEX_IMG_BG_COLOR [UIColor colorWithRed:207/255.0f green:24/255.0f blue:29/255.0f alpha:1.00f]//图片的颜色（红色）
#define NavgationColor [UIColor colorWithRed:0.302f green:0.631f blue:0.855f alpha:1.00f]//系统颜色
#define BackGray_dan [UIColor colorWithRed:0.933f green:0.933f blue:0.933f alpha:1.00f]//背景灰
#define BackBlue_dan [UIColor colorWithRed:0.561f green:0.788f blue:0.929f alpha:1.00f]//搜索输入背景淡蓝
#define color_red_dan [UIColor colorWithRed:0.988 green:0.239 blue:0.224 alpha:1.00]
#define UIColorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define color_black_dan UIColorFromRGB(158.0f, 158.0f, 158.0f)
#define SystemBlue [UIColor colorWithRed:0.086f green:0.494f blue:0.984f alpha:1.00f]
//tag
#define INDEX_BTN_TAG 1300
#define Sport_Select_Item_Tag  1345
#define YueZhan_Sift_Btn_Tag   1711

#define LISTFILEPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DataList.plist"]//用来存取城市地区信息的
#define CITYLISTFILEPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Cities.json"]//用来存取城市地区信息的
#define CITYSCHOOLLISTFILEPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CitySchools.json"]//用来存取城市大学地区信息的
#define SCHOOLSLISTFILEPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Schools.json"]//用来存取大学地区信息的

//height
#define dayInterval 86400
#define  mygap 5.0
#define HeightOfCell 44.0
#define  INDEXWIDTH (CGRectGetWidth(BOUNDS)-(mygap*3))/2
//底部按钮高度也是tabbar的高度
#define kBottombtn_height 49.0
//ZH 配置文件
#define UISCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define UISCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define propotion UISCREENWIDTH/750
#define LEFTX UISCREENWIDTH/18

//校动token
#define kToken @"xdtoken"
#if DEBUG
#define VHAKKWEIXIN_URL @"http://192.168.1.109/xiaodong"//少丰

#else
#define VHAKKWEIXIN_URL @"http://123.57.212.220:9000/xiaodong"//正式
#endif


//#define VHAKKWEIXIN_URL @"http://192.168.1.111/xiaodong"//彭飞
//#define VHAKKWEIXIN_URL @"http://111.13.56.45:8080/xiaodong"//测试



#define preUrl VHAKKWEIXIN_URL//内网

//app下载链接
#define kDownLoadUrl @"http://a.app.qq.com/o/simple.jsp?pkgname=com.yizhi.xiaodongandroid"
//app协议链接
#define kProtocolUrl @"/xdsm.html"
//分享文字
#define kShareText [NSString stringWithFormat:@"约战123,等你来战!点击下载%@",kDownLoadUrl]
//ZH 教练筛选
#define JLDJ_0001 @"JLDJ_0001"
#define JLDJ_0002 @"JLDJ_0002"
#define JLDJ_0003 @"JLDJ_0003"

#define JLPL_0001 @"JLPL_0001"
#define JLPL_0002 @"JLPL_0002"

#define JLSEX_MAN @"XB_0001"
#define JLSEX_WOMEN @"XB_0002"

//#define DDZT_0000 @"DDZT_0000" //订单状态
//#define DDZT_0001 @"DDZT_0001" //未支付
//#define DDZT_0002 @"DDZT_0002" //已支付
//#define DDZT_0003 @"DDZT_0003" //作废

#define SexList @[@"",JLSEX_MAN,JLSEX_WOMEN]
#define LevelList @[@"",JLDJ_0001,JLDJ_0002,JLDJ_0003]
#define CoachTypeList @[@"",JLPL_0001,JLPL_0002]

////类型 HDLX_0001=点赞,HDLX_0002=留言，HDLX_0003=回复

#define optionZan @"HDLX_0001"
#define optionLiuyan @"HDLX_0002"
#define optionReply @"HDLX_0003"

//String orderType;//类型 DDLX_0001=定场馆, DDLX_0002=团体赛事报名费,DDLX_0003=个人赛事报名费
#define orderTypeVenue @"DDLX_0001"
#define orderTypeTeam @"DDLX_0002"
#define orderTypePerson @"DDLX_0003"

//BMFS_0001=个人报名，BMFS_0002=团体报名，BMFS_0003=EXCEL表报名
#define singleMark @"BMFS_0001"
#define teamMark @"BMFS_0002"
#define loadMark @"BMFS_0003"

//预约
#define kYuyueDic [NSDictionary dictionaryWithObjectsAndKeys:@"是否需要预约",@"YY_0000",@"需要预约",@"YY_0001",@"免预约",@"YY_0002", nil]
//身份证护照
#define IDCard @"ZJLX_0001"
#define Passport @"ZJLX_0002"



//支付宝支付参数

//银联支付模式
//"00":代表接入生产环境（正式版本需要）；
//@"01"：代表接入开发测试环境
#define UPayMode @"00"
//赛制
#define saizhiList @[@"SSZB_0011",@"SSZB_0012",@"SSZB_0013"]
//是否
#define kYes @"SF_0001"
#define kNo @"SF_0002"
//队伍类型
#define StudentType @"DWXZ_0001"
#define AdultType @"DWXZ_0002"
//轮播图时间间隔
#define timeMid 2.0
//图片压缩参数
#define kCompressqulitaty 0.5f
//好友单元格高度
#define kFriendCellHeight 85.0
//字体设置
#define Title_font [UIFont systemFontOfSize:17.0]
#define Btn_font  [UIFont systemFontOfSize:15.0]
#define Content_lbfont [UIFont systemFontOfSize:13.0]
#define Content_lbColor [UIColor lightGrayColor]
//通知
#define NotificationChatView @"chatView"
#define NotificationRefreshMessageCount @"refreshMessageCount"
#define NotificationRefreshAppoint @"refreshAppoint"//个人信息更改时,刷新约战首页
#define NotificationRefreshOldList @"refreshFriendList"//刷新好友列表
#define NotificationNewApply @"newfriendApply"//好友申请通知

#define LaunchFirst @"LaunchFirst"
#define CityCacheTime @"CityCacheTime"
#define SchoolCacheTime @"SchoolCacheTime"
#define PhoneListCount @"PhoneListCount"
#define ARROW_CHANGE_DIRECTION_NOTIFICATION @"arrow_change_direction_notification"//改变首页地点那个方向箭头
#define SPORT_TYPE_CHANGE_NOTIFICATION @"sportTypeChangeNotification"//首页运动类型那个collection消失时的通知
#define LOCATION_UPDATE_NOTIFICATION @"location_update_notification"//首页默认城市通知
#define CHANGE_TEXTCOLOR_NOTIFICATION @"change_textcolor_notification"
#define LOGINSTATECHANGE_NOTIFICATION @"loginstatechange_notification"//登录状态改变通知
#define LOCALNEWESTMESSAGE @"messageNewId"
#define DOWNLOAD_COMPLETE_NOTIFICATION @"download_complete_notification"//下载报名表成功的通知
#define DOWNLOAD_FAILED_NOTIFICATION @"download_failed_notification"//下载报名表失败的通知
#define WXPAY_BACK_NOTIFICATION @"wxpay_back_notification"//微信支付完成后appdelegate发出的通知
#define RECEIVEREMOTENOTIFICATION @"receivenotification"//收到推送
#define PAY_SUCCESS @"pay_success"

//朋友本地缓存路径
#define LoadingWord @"请稍后..."
#define ErrorWord @"貌似你的网络不太给力"
#define EmptyList @"无更多数据"
#define NotNetWork @"请检查是否启用网络功能\n步骤:设置>通用>无线局域网/蜂窝移动网络"
#define kDragBack YES
//友盟分享appkey
#define kUMAppkey  @"56493ed3e0f55a4ddf000c92"   //友盟iPhone 唯一Appkey
//app信息
#define kAppID @"1055535538"
typedef enum{
    StyleResultImg            = 0,//约战上传赛果图
    StyleResultInfo,              //约战上传赛果结果
    StyleResultComment,           //约战评论,也用来与下面赛事，时光机，场馆区别的标记
    StyelResultVenueComment,      //场馆评论
    StyelResultTimeMachine,       //时光机评论
    StyleResultMatch,              //赛事评论
    StyleResultTeam               //上传战队晒图
}CommentFromStyle;

typedef enum{
    MenberInviteFriendType = 0,//邀请好友cell
    MenberTeamType,            //站队成员cell
    MenberNearByType           //附近的人cell
}MemberType;


//订单状态
typedef enum OrderStatus{
    OrderStatusNone = 0,//默认
    OrderStatusNopay,//未付款
    OrderStatusNouse,//未使用
    OrderStatusNocomment,//未评论
    OrderStatusComment
}OrderStatus;

#define DDZT_0001 @"DDZT_0001"//未支付
#define DDZT_0002 @"DDZT_0002"//未消费
#define DDZT_0003 @"DDZT_0003"//作废
#define DDZT_0004 @"DDZT_0004"//申请退款中，退款单
#define DDZT_0005 @"DDZT_0005"//带评价
#define DDZT_0006 @"DDZT_0006"//已评价
#define DDZT_0007 @"DDZT_0007"//退款成功

typedef enum BaomingType {
    BaomingPersonal = 0,//个人报名
    BaomingTeamal = 1,//团队报名
    BaomingInfo = 2//报名表
    
}BaomingType;


typedef enum DynamicType{
    DynamicTypeString = 0,//只发表了一句话
    DynamicTypeActivity,//只有一条动态，如加入了什么战队
    DynamicTypeImgAndWord,//张图片和文字
}DynamicType;
#ifndef yuezhan123_Global_h
#define yuezhan123_Global_h



#endif
