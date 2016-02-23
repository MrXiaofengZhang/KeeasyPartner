//
//  LVTools.h
//  yuezhan123
//
//  Created by LV on 15/3/25.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPPayPluginDelegate.h"
#import "UPPayPlugin.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
typedef void(^completionHandle)(id result);
@interface LVTools : NSObject


/**
 参数时间格式必须为2010-09-01
 */
+ (NSString *)time:(NSString *)timeBegin;
+ (NSDate*)mconvertDate:(NSDate*)date;
+ (CGFloat)sizeFrom:(CGSize)imgSize With:(CGFloat)CellWidth;

/**
 返回自适应固定宽度，高度动态的label
 */
+ (CGFloat)sizeContent:(NSString *)contentLabel With:(CGFloat)fontText With2:(CGFloat)SizeWidth;

/**
 返回自适应固定高度，宽度动态的label
 */
+ (CGFloat)sizeWithStr:(NSString *)str With:(int)fontText With2:(CGFloat)sizeHeight;

+ (void)getIphoneInfo;

+ (NSMutableDictionary *)getTokenApp;
+ (NSString *)configDicToDES:(NSDictionary *)dict;//加密字典参数

+ (NSArray *)sportStylePlist;
+ (NSArray *)getAllSportsList;
/**
 银联支付 借口
 */
+(BOOL)mstartPay:(NSString*)tn mode:(NSString*)mode viewController:(UIViewController*)viewController delegate:(id<UPPayPluginDelegate>)delegate;
/**
 微信支付接口
 参数为后台返回的订单信息
 */
+ (void)mSendWXPay:(NSDictionary*)dict;
+ (void)sendPayWithDic:(NSDictionary *)dic;
/**
 支付宝支付
 */
+(void)mPay:(NSString *)oid ProductName:(NSString *)name ProductPrice:(NSString *)price serviceSign:(NSString *)signstr callback:(completionHandle)block;
/**
 服务器获取的数据转换为字符型
 */
+(NSString *)mToString:(id)obj;
/**
 比较是否超过当前时间yes超过了no等于或没超过
 */
+(BOOL)mTimeFromDate:(NSDate*)someDate;
/**
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */

+(NSString *) compareCurrentTime:(NSDate*) compareDate;
//验证邮箱是否合法
+(BOOL)isValidateEmail:(NSString *)email;
//验证手机号合法性
+(BOOL)isValidateMobile:(NSString *) mobile;
//验证密码合法性
+(BOOL)isValidatePassWord:(NSString*) password;
/**
 *  验证手机号
 *
 *  @param identityCard 身份证
 *
 *  @return 是否符合
 */
+ (BOOL)isValidateIdentityCard: (NSString *)identityCard;
/**
 拨打电话
 */
+(void)callPhoneToNumber:(NSString*)number InView:(UIView*)view;
/**
 计算两点距离
 */
+(NSString*)caculateDistanceFromLat:(NSString*)lat andLng:(NSString*)lng;
/**
 获取一个本地缓存对象
 */
+(id)mGetLocalDataByKey:(NSString *)key;
/**
 缓存对象到本地
 */
+(void)mSetLocalData:(id)theData Key:(NSString *)key;
/**
 将颜色转化为纯色图片
 */
+ (UIImage *)buttonImageFromColor:(UIColor *)color withFrame:(CGRect)frame;
/**
 图片保存到本地
 */
+(void)saveImageToPhotos:(UIImage*)savedImage WithTarget:(id)target AndMothod:(SEL)mothod;
/**
 判断整型
 */
+ (BOOL)isPureInt:(NSString*)string;
/**
 判断浮点型
 */
+ (BOOL)isPureFloat:(NSString*)string;
/**
 判断是否包含emoji编码
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;
/**
 创建“我的”和个人资料里面的头部视图(不包括性别爱好那一排标签)
 */
+ (UIView *)headerViewWithbackgroudcolor:(UIImage *)image
                                 backBtn:(UIImage *)image1
                              settingBtn:(UIImage *)image2
                                beginTag:(int)tag
                                 islogin:(NSString *)login
                                  isHide:(BOOL)hide;
/**
 创建性别爱好那一排标签
 */
+ (void)createTheSortsLab:(NSDictionary *)dic inView:(UIView *)tempView;

/**
 创建自定义的导航栏位置视图
 */
+ (UIView *)selfNavigationWithColor:(UIColor *)color leftBtn:(UIButton *)btn1 rightBtn:(UIButton *)btn2 titleLabel:(UILabel *)titleLab;

/*
 返回富文本字体
 */
+ (NSMutableAttributedString *)attributedStringFromText:(NSString *)string range:(NSRange)range andColor:(UIColor *)color;
/**
 *  读取运动类型
 */
+ (NSArray*)readPlist;
/**
 *  获取比赛类型
 */
+ (NSArray*)getMatchTypes;
+ (NSString*)convertSportFromCode:(NSString*)sportcode;
/**
 *  字符串数组排序
 */
+ (NSArray *)sortArrayWithArray:(NSMutableArray *)arr andAscend:(BOOL)ascend;
/**
 *  高斯模糊化
 */
+ (UIImage*)convertGaussImage:(UIImage*)img;
/**
 * 去掉字符串两端的空格
 */
+ (NSString*)deleteSpace:(NSString*)string;
/**
 * 根据生日计算年龄
 */
+ (NSString*)fromDateToAge:(NSDate*)date;
/**
 * 去登陆
 */
+ (void)turnLoginWithVC:(UIViewController*)Vc;
@end
