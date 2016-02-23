//
//  Utility.h
//  yuezhan123
//
//  Created by LV on 15/4/2.
//  Copyright (c) 2015年 LV. All rights reserved.
//

/*
    AES加密
 */

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "YZBase64.h"



@interface Utility : NSObject

+(NSString *) encryptUseDES:(NSString *)plainText;
+(NSString *) decryptUseDES:(NSString *)cipherText;

@end

