//
//  LVTools.m
//  yuezhan123
//
//  Created by LV on 15/3/25.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVTools.h"
#import <sys/types.h>
#import "JSONKit.h"
#import <CoreLocation/CoreLocation.h>
#import "ZHGenderView.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "RSADataSigner.h"
#import "MD5DataSigner.h"

#import <AdSupport/ASIdentifierManager.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "payRequsestHandler.h"
#import "WXApi.h"
#import "LoginLoginZhViewController.h"


#pragma mark MAC
@interface LVTools ()

@end

@implementation LVTools


#pragma  mark --获取plist文件中运动类型
+ (NSArray *)sportStylePlist{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:path];
    NSClassFromString(@"NSObject");
    return array;
}

+ (NSArray *)getAllSportsList {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < array.count; i ++) {
        if ([array[i][@"sport1"] length] > 0) {
            [arr addObject:array[i]];
        }
    }
    return arr;
}

+ (void)getIphoneInfo{
    
//    NSString * deviceStr = [[UIDevice currentDevice] name];
    NSString * modelStr = [[UIDevice currentDevice] model];
    NSString * versionStr = [[UIDevice currentDevice] systemVersion];
    NSString * width = [NSString stringWithFormat:@"%f",CGRectGetWidth(BOUNDS)];
    NSString * height = [NSString stringWithFormat:@"%f",CGRectGetHeight(BOUNDS)];
    
    NSString * userId =[LVTools mToString: [kUserDefault objectForKey:kUserId]];
    if (!userId||[userId isEqualToString:@""]) {
        userId = @"0";
    }
    NSString *idfa = nil;
    if (iOS7) {
        idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    else{
        idfa = [LVTools macaddress];
    }
    NSDictionary * dict = @{@"baseInfo":@{@"packageName":@"",//包名
                                          @"device":@"ios",  //设备
                                          @"model":modelStr, //手机型号
                                          @"vendor":@"Apple",     //手机厂商
                                          @"user_id":userId, //用户ID，未登录为0
                                          @"imei":idfa,       //手机串号
                                          @"product":kAppID,    //
                                          @"version":versionStr,//版本号
                                          @"channel":@"App Store",
                                          @"imageWidth":width, //屏幕的宽度
                                          @"imageHeight":height,//屏幕的高度
                                          @"ip":@""},        //用户ip，客户端不需要赋值
                            };  //order:0:asc 1:desc
    [DataService requestWeixinAPI:getToken parsms:@{@"param":[self configDicToDES:dict]} method:@"post" completion:^(id result) {
        if ([LVTools mToString:result[@"error"]].length>0) {
            NSLog(@"token获取失败");
        }
        else{
        NSLog(@"获取的token----%@",(NSDictionary *)result[@"token"]);
        [kUserDefault setObject:result[@"token"] forKey:kToken];
        [kUserDefault synchronize];
        }
    }];
}

+ (NSString *)configDicToDES:(NSDictionary *)dict{
    NSString * string = [dict JSONString];
//    NSError *parseError = nil;
//    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
//    NSString * string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSLog(@"jsonstr ==== %@",string);
   NSString *resultstring = [LVTools mToString:[Utility encryptUseDES:string]];
    
    return resultstring;
}
+ (NSString *) macaddress
{
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
    
}
/**
 *  设备ip
 */
+ (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                else{
                    //非wifi
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}
+ (NSMutableDictionary *)getTokenApp{
    NSString * modelStr = [[UIDevice currentDevice] model];
    NSString * versionStr = [[UIDevice currentDevice] systemVersion];
    NSString * width = [NSString stringWithFormat:@"%f",CGRectGetWidth(BOUNDS)];
    NSString * height = [NSString stringWithFormat:@"%f",CGRectGetHeight(BOUNDS)];
    
    NSString * userId =[LVTools mToString: [kUserDefault objectForKey:kUserId]];
    if (!userId||[userId isEqualToString:@""]) {
        userId = @"0";
    }
    NSString *idfa = nil;
    if (iOS7) {
        idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    else{
        idfa = [LVTools macaddress];
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"baseInfo":@{@"packageName":@"",//包名
                                                                                               @"device":@"ios",  //设备
                                                                                               @"model":modelStr, //手机型号
                                                                                               @"vendor":@"Apple",     //手机厂商
                                                                                               @"user_id":userId, //用户ID，未登录为0
                                                                                               @"imei":idfa,       //手机串号
                                                                                               @"product":kAppID,    //
                                                                                               @"version":versionStr,//版本号
                                                                                               @"channel":@"App Store",
                                                                                               @"imageWidth":width, //屏幕的宽度
                                                                                               @"imageHeight":height,//屏幕的高度
                                                                                               @"ip":[LVTools deviceIPAdress]}       //用户ip，客户端不需要赋值
                                                                                 }];
    
    
    return dict;
}

+ (NSString *)time:(NSString *)timeBegin{
    NSString * nowStr = [NSString getNowDateFormatter];
    NSString *str=nil;
    NSLog(@"++++++++++%@",nowStr);
    NSLog(@"________%@",timeBegin);
    if ([nowStr compare:timeBegin] == NSOrderedDescending) {
        str = @"1";
        //过期
    }else{
        str=@"0";
        //没过期
    }
    return str;
}
+ (NSDate*)mconvertDate:(NSDate*)date
{
    //好像是从ios4.1开始[NSDate date];获取的是GMT时间，这个时间和北京时间相差8个小时，以下代码可以解决这个
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMT];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}
+ (CGFloat)sizeFrom:(CGSize)imgSize With:(CGFloat)CellWidth{
    CGFloat height;
    height = imgSize.height*CellWidth/imgSize.width;
    return height;
}

+ (CGFloat)sizeContent:(NSString *)contentLabel With:(CGFloat)fontText With2:(CGFloat)SizeWidth
{
    NSDictionary * dict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontText]};
    CGRect frame = [contentLabel boundingRectWithSize:CGSizeMake(SizeWidth, SIZE_T_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return frame.size.height + 5;
}

+ (CGFloat)sizeWithStr:(NSString *)str With:(int)fontText With2:(CGFloat)sizeHeight
{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontText]};
    CGRect frame = [str boundingRectWithSize:CGSizeMake(10000, sizeHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return frame.size.width + 5;
}

/**
 服务器获取的数据转换为字符型
 */
+(NSString *)mToString:(id)obj
{
    if (obj == nil) {
        return @"";
    }
    if (obj == [NSNull null]) {
        return @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    return [NSString stringWithFormat:@"%@",obj];
}

/**
 * 注册信息上面的提示条目
 */
/**
比较是否超过当前时间yes超过了no等于或没超过
 */
+(BOOL)mTimeFromDate:(NSDate*)someDate{
//    NSDate * now = [[NSDate alloc] init];
//    NSString * str ;
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    unsigned int unitFlags = NSCalendarUnitDay;
//    NSDateComponents *comps = [gregorian components:unitFlags fromDate:someDate  toDate:now  options:0];
//    NSInteger days =  [comps second]/86400;
//    NSInteger hours = ([comps second] - days*86400)/3600;
//    NSInteger mins  = (([comps second] -days*86400)-hours*3600)/60;
//    NSInteger secds = ((([comps second] -days*86400)-hours*3600)-mins*60);
//    str = [NSString stringWithFormat:@"%ld天%ld时%ld分%ld秒",(long)[comps day],(long)hours,(long)mins,(long)secds];
    return YES;
}
/**
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
+(NSString *) compareCurrentTime:(NSDate*) compareDate
//
{

    
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    
    return  result;
}
//验证邮箱是否合法
+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//验证手机号合法性
+(BOOL)isValidateMobile:(NSString *) mobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0-9]))\\d{8}$";
    //^1+[3578]+\d{9}
    //“^((d{3,4})|d{3,4}-)?d{7,8}$”
    //^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$
    //^[1]([3][0-9]{1}|59|58|88|89)[0-9]{8}$
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    // NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}
//验证密码合法性
+(BOOL)isValidatePassWord:(NSString*) password {
    NSString *emailRegex = @"^[A-Za-z0-9]+$";
    NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [pwdTest evaluateWithObject:password];
}
/**
 *  验证手机号
 *
 *  @param identityCard 身份证
 *
 *  @return 是否符合
 */
+ (BOOL)isValidateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
//拨打电话
+(void)callPhoneToNumber:(NSString*)number InView:(UIView*)view{
//    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",number];
//    UIWebView * callWebview = [[UIWebView alloc] init];
//    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//    [view addSubview:callWebview];
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
/**
 银联支付 借口
 
 */
+(BOOL)mstartPay:(NSString*)tn mode:(NSString*)mode viewController:(UIViewController*)viewController delegate:(id<UPPayPluginDelegate>)delegate{
 return   [UPPayPlugin startPay:tn mode:mode viewController:viewController delegate:delegate];
}
/**
 微信支付接口
 参数为后台返回的订单信息
 */
+ (void)mSendWXPay:(NSDictionary*)dict{

    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = (UInt32)([[dict objectForKey:@"timestamp"] longLongValue]);
    req.package             = @"Sign=WXPay";
    req.sign                = [dict objectForKey:@"sign"];
    //日志输出
    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    [WXApi sendReq:req];
}


+ (void)sendPayWithDic:(NSDictionary *)dic
{
    payRequsestHandler *reg = [payRequsestHandler alloc];
    [reg init:APP_ID mch_id:MCH_ID];
    [reg setKey:PARTNER_ID];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setObject:[LVTools mToString:dic[@"appid"]] forKey:@"appid"];
    [mutableDic setObject:[LVTools mToString:dic[@"noncestr"]] forKey:@"noncestr"];
    [mutableDic setObject:[LVTools mToString:dic[@"package"]] forKey:@"package"];
    [mutableDic setObject:[LVTools mToString:dic[@"partnerid"]] forKey:@"partnerid"];
    [mutableDic setObject:[LVTools mToString:dic[@"timestamp"]] forKey:@"timestamp"];
    [mutableDic setObject:[LVTools mToString:dic[@"prepayid"]] forKey:@"prepayid"];
    NSString *sign = [reg createMd5Sign:mutableDic];
    PayReq *req = [[PayReq alloc] init];
    req.openID              = [dic objectForKey:@"appid"];
    req.partnerId           = [dic objectForKey:@"partnerid"];
    req.prepayId            = [dic objectForKey:@"prepayid"];
    req.nonceStr            = [dic objectForKey:@"noncestr"];
    req.timeStamp           = (UInt32)([[dic objectForKey:@"timestamp"] longLongValue]);
    req.package             = @"Sign=WXPay";
    req.sign                = sign;

    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    [WXApi sendReq:req];
}

/**
 支付宝支付
 */
+(void)mPay:(NSString *)oid ProductName:(NSString *)name ProductPrice:(NSString *)price serviceSign:(NSString *)signstr callback:(completionHandle)block{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088411558063771";
    NSString *seller = @"yizhichaoyue@126.com";
//    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMXM625PfnpxeDomERGPIRiJmwzFbZsQTZtYZP0zPjgsXizwa+5ypCo+KyXD8PGdsG/4m2lKYF4qLyLMIKgKu2tExXHkAgtGfRkKaTz5ik8THvl9TK7FFRcx7Xfs7QrMi/ZCOaRnlONn9Kom93Tq62uaay+lKxbT7ToxWt3FjsORAgMBAAECgYEAxT7As0LwZBeNBad6M+Ff5oEqLcUetJfAXB38rwWPkSKlUvj5GFIX5MwT6NgJCFfwXugxygBSMvSsBm46TnhNRTq7OJv4uZRjg9Bwkd9af4iQNM1KKGppnTh70Wlq1goheGK3qR0rDNYlp7lOcz1ffR/nLnbEhRT3qteZeiJMLnECQQD487L+1CNCQWU0f/sq/TKX+/4s/gWcYT1PyZCaim2uxHFBak65tA93N3FqeAeNziYDfIZKZ0CKOmmV0Oefp2wVAkEAy2Z+4zst9B0VvvJ1EkYm3oBFovDFVkZmAjXKNldRldHR2Y46Tnt4eymuZaUqy7SZRFtTqo/lTvLRjPI177pMjQJACRYb+mETyF9Kqlfhevgy2IlCBbJf0g1ah4b72CglSLOyzohqxyxjRB6p7RDkdbCIgqgQ3rZWDLWFFQrC6Xja4QJALvBUT/QUQsWDgzFIuxLdXXOUnmmZ4LMWT2RCag/0j/J/zwj3g60SvLl9uY9INQJUbGX3BOF4NaPrn+81a0E+8QJAbsfsXNibqLfhmDsCtGoIyyR0ElXJaujLYRJ4UsxNtB5ndtoacYrGr9f/OgzhO4sE8tLe3o0iMTZj45pJ1biF4A==";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
//    if ([partner length] == 0 ||
//        [seller length] == 0 ||
//        [privateKey length] == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"缺少partner或者seller或者私钥。"
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = oid; //订单ID（由商家自行制定）
    order.productName = name; //商品标题
    order.productDescription = name; //商品描述
    order.amount =price; //商品价格
    order.notifyURL = @"http://www.yuezhan123.com/yuezhan/app/order/notifyUrl";
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"SCHOOLSPORT";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
//    id<DataSigner> signer = CreateRSADataSigner(privateKey);
//    NSString *signedString = [signer signString:orderSpec];
    NSString *signedString = signstr;//这里需要后台返回
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        NSLog(@"LLLL ==== %@",orderString);
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:block];
    }
}
/**
 计算两点距离
 */
+(NSString*)caculateDistanceFromLat:(NSString*)lat andLng:(NSString*)lng{
    //位置信息收否有效
    if ([[LVTools mToString:[kUserDefault objectForKey:kLocationLat]] isEqualToString:@""] ||[[LVTools mToString:[kUserDefault objectForKey:kLocationlng]] isEqualToString:@""]||[[LVTools mToString:lat] isEqualToString:@""]||[[LVTools mToString:lng] isEqualToString:@""])  {
        return @"定位失败";
    }
    //苹果自带
    CLLocation *orig=[[CLLocation alloc] initWithLatitude:[[kUserDefault objectForKey:kLocationLat] doubleValue]  longitude:[[kUserDefault objectForKey:kLocationlng] doubleValue]];
    CLLocation* dist=[[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
    NSLog(@"%@%@",[kUserDefault objectForKey:kLocationLat], [kUserDefault objectForKey:kLocationlng]);
    CLLocationDistance meters=[orig distanceFromLocation:dist];
    if (meters<=1000) {
        return [NSString stringWithFormat:@"%.fm",meters];
    }
    return [NSString stringWithFormat:@"%.1fkm",meters/1000.0f];
}
#pragma mark - calculate distance  根据2个经纬度计算距离

#define PI 3.1415926
+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}
/**
 获取一个本地缓存对象
 */
+(id)mGetLocalDataByKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return  [userDefault objectForKey:key] ;
}
/**
 缓存对象到本地
 */
+(void)mSetLocalData:(id)theData Key:(NSString *)key
{
    if (key && theData) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:theData forKey:key];
        [userDefault synchronize];
    }else{
        [WCAlertView showAlertWithTitle:nil message:[NSString stringWithFormat:@"本地化缓存数据错误!key:%@,value:%@",key,theData] customizationBlock:nil completionBlock:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    }
    
}
+(UIImage *)buttonImageFromColor:(UIColor *)color withFrame:(CGRect)frame{
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
/**
 保存图片到本地
 */
+(void)saveImageToPhotos:(UIImage*)savedImage WithTarget:(id)target AndMothod:(SEL)mothod
{
    UIImageWriteToSavedPhotosAlbum(savedImage, target, mothod, NULL);
}
/**
  浮点型
 */
+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

/**
 判断是否为浮点形
 */
+ (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
/**
 判断是否包含emoji编码
 */
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

+ (UIView *)headerViewWithbackgroudcolor:(UIImage *)image
                                 backBtn:(UIImage *)image1
                              settingBtn:(UIImage *)image2
                                beginTag:(int)tag
                                 islogin:(NSString *)login isHide:(BOOL)hide
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 220)];
    view.userInteractionEnabled = YES;
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.image = image;
    if (image1) {
        //导航返回按钮
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 setImage:image1 forState:UIControlStateNormal];
        btn1.frame = CGRectMake(10, 30, 36, 24);
        btn1.tag = tag + 1;
        [view addSubview:btn1];
    }
    if (image2) {
        //设置按钮
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn2 setImage:image2 forState:UIControlStateNormal];
        btn2.frame = CGRectMake(UISCREENWIDTH-30-10, 20+7, 30, 30);
        btn2.tag = tag + 2;
        [view addSubview:btn2];
    }
    //创建中间头像
    UIButton *headImg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    headImg.tag = tag + 3;
    headImg.center = CGPointMake(UISCREENWIDTH/2, 90);
    headImg.layer.cornerRadius = 35;
    headImg.layer.masksToBounds = YES;
    
    [view addSubview:headImg];
    
    //创建名称标签
    UIButton *nameLab = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 14)];
    nameLab.center = CGPointMake(UISCREENWIDTH/2, headImg.bottom + 12);
    nameLab.tag = tag + 4;
    nameLab.backgroundColor = [UIColor clearColor];
    [nameLab.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [nameLab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:nameLab];
    
    if (![login isEqualToString:@"1"]) {
        //没登陆处理
        [headImg setBackgroundImage:[UIImage imageNamed:@"plhor_2"] forState:UIControlStateNormal];
        [nameLab setTitle:@"点击登录" forState:UIControlStateNormal];
    }
    //创建签名标签
    UILabel *signLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(nameLab.frame)+25, UISCREENWIDTH-40, 30)];
    signLab.backgroundColor = [UIColor clearColor];
    signLab.tag = tag + 5;
    signLab.textAlignment = NSTextAlignmentCenter;
    signLab.numberOfLines = 2;
    signLab.text = @"这个家伙很懒,什么也没写";
    signLab.textColor = [UIColor whiteColor];
    signLab.font = [UIFont systemFontOfSize:13];
    if (UISCREENWIDTH == 414) {
        signLab.frame = CGRectMake(20, CGRectGetMaxY(nameLab.frame)+25, UISCREENWIDTH-40, 30);
        signLab.font = [UIFont systemFontOfSize:15];
    }
    [view addSubview:signLab];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, signLab.bottom, BOUNDS.size.width, 20)];
    lable.textColor = [UIColor whiteColor];
    lable.font = Content_lbfont;
    lable.hidden = hide;
    lable.tag = tag + 6;
    lable.text = @"关注  29   ｜   粉丝  267";
    lable.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lable];
    return view;
}

+ (void)createTheSortsLab:(NSDictionary *)dic inView:(UIView *)tempView
{
    NSString *habitStr = [LVTools mToString:dic[@"loveSports"]];
//    NSString *genderStr = [LVTools mToString:dic[@"genderName"]];
    NSArray *arr = [habitStr componentsSeparatedByString:@","];
    CGFloat width;
    if (habitStr.length == 0) {
        width = 40;
    } else {
        width = 40+(arr.count>6?6:arr.count)*25;
    }
    //add之前先remove
    if ([tempView viewWithTag:111]) {
        [[tempView viewWithTag:111] removeFromSuperview];
    }
    UIView *habitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
    habitView.center = CGPointMake(UISCREENWIDTH/2, 161);
    habitView.tag = 111;
    [tempView addSubview:habitView];
    NSLog(@"dic ==== %@",dic);
    //计算年龄
    NSString *age = @"0";
    NSString *birthday = [LVTools mToString:dic[@"birthday"]];
    if(birthday.length==0){
        age = @"0";
    }
    else{
        age = [LVTools fromDateToAge:[NSDate dateWithTimeIntervalSince1970:[dic[@"birthday"] floatValue]/1000]];
    }
    ZHGenderView *ageAndGenderView = [[ZHGenderView alloc] initWithFrame:CGRectMake(2, 2, 30, 15) WithGender:[LVTools mToString:dic[@"gender"]] AndAge:age];
    [habitView addSubview:ageAndGenderView];
    //性别年龄爱好都填写了的
    if (habitStr.length != 0) {
        for (int i = 0; i < (arr.count>6?6:arr.count); i ++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40+25*i, 0, 20, 20)];
            imageView.image =[UIImage imageNamed:arr[i]];
            [habitView addSubview:imageView];
        }
    }
}
/**
 //带颜色的文字
 */
+ (NSMutableAttributedString *)attributedStringFromText:(NSString *)string range:(NSRange)range andColor:(UIColor *)color
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    return str;
}

/**
 发送加好友消息
 */
+(NSMutableAttributedString *)mString:(NSString *)text bString:(NSString *)bStr color:(UIColor *)color
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange redBegin = [text rangeOfString:bStr];
    [str addAttribute:NSForegroundColorAttributeName value:color_black_dan range:NSMakeRange(0, text.length)];
    [str addAttribute:NSForegroundColorAttributeName value:color_red_dan range:NSMakeRange(redBegin.location,text.length - redBegin.location)];
    [str addAttribute:NSFontAttributeName value:Btn_font range:NSMakeRange(0, text.length)];
    return str;
}

/**
 创建自定义的导航栏位置视图
 */
+ (UIView *)selfNavigationWithColor:(UIColor *)color leftBtn:(UIButton *)btn1 rightBtn:(UIButton *)btn2 titleLabel:(UILabel *)titleLab
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, 64)];
    view.backgroundColor = color;
    
    if (btn1) {
        btn1.frame = CGRectMake(10, 30, 36, 24);
        [view addSubview:btn1];
    }
    if (btn2) {
        btn2.frame = CGRectMake(UISCREENWIDTH-40-10, 20+7, 40, 30);
        [view addSubview:btn2];
    }
    if (titleLab) {
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.textColor = [UIColor whiteColor];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.frame = CGRectMake(0, 0, 150, 20);
        titleLab.center = CGPointMake(UISCREENWIDTH/2, 43);
        [view addSubview:titleLab];
    }
    return view;
}
/**
 *  读取运动类型
 */
+ (NSArray*)readPlist{
    //运动
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:path];
}
/**
 *  获得比赛类型
 */
+ (NSArray*)getMatchTypes{
    NSMutableArray *resultArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    NSArray *allTypes = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dic in allTypes) {
        if ([dic[@"sport2"] hasPrefix:@"BSLX"]) {
            [resultArr addObject:dic];
        }
    }
     return resultArr;
}
/**
 *  把运动代码转化为运动名字
 *
 *  @param sportcode 运动代码
 *
 *  @return 运动名字
 */
+ (NSString*)convertSportFromCode:(NSString*)sportcode{
    for (NSDictionary *dic in [LVTools readPlist]) {
        if ([dic[@"sport2"] isEqualToString:sportcode]) {
            return dic[@"name"];
        }
    }
    return nil;
}
+ (NSArray *)sortArrayWithArray:(NSMutableArray *)arr andAscend:(BOOL)ascend {
    for (int i = 0 ; i < arr.count-1; i ++) {
        for (int j = i + 1; j < arr.count; j ++) {
            long result = [arr[i] compare:arr[j] options:NSNumericSearch];
            if (ascend == YES) {//升序
                if (result == 1 || result == 0) {
                    [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            } else {//降序
                if (result == -1) {
                    [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
    }
    return arr;
}
/**
 *  高斯模糊化
 */
+ (UIImage*)convertGaussImage:(UIImage*)img{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [[CIImage alloc] initWithImage:img];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:@10.0f forKey: @"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage = [context createCGImage: result fromRect:[result extent]];
    UIImage * blurImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}
+ (NSString*)deleteSpace:(NSString *)string{
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return  [[NSString alloc]initWithString:[string stringByTrimmingCharactersInSet:whiteSpace]];
}
+ (NSString*)fromDateToAge:(NSDate*)date{
    NSDate *myDate = date;
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSYearCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:myDate toDate:nowDate options:0];
    NSInteger year = [comps year];
    return [NSString stringWithFormat:@"%d",(int)year];
}
+ (void)turnLoginWithVC:(UIViewController*)Vc{
    NSString *islogin = [kUserDefault objectForKey:kUserLogin];
    if (![islogin isEqualToString:@"1"]) {
        LoginLoginZhViewController *loginVC = [[LoginLoginZhViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [Vc.navigationController presentViewController:loginNav animated:YES completion:nil];
        
    }
}
@end
