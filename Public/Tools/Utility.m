//
//  Utility.m
//  yuezhan123
//
//  Created by LV on 15/4/2.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "Utility.h"

@implementation Utility

const Byte iv[] = {1,2,3,4,5,6,7,8};

#define  DESKEY @"#!1y5z*3"

+(NSString *) encryptUseDES:(NSString *)plainText
{
    NSString *ciphertext = nil;
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[8192];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [DESKEY UTF8String], kCCKeySizeDES,
                                          iv,
                                          [textData bytes], dataLength,
                                          buffer, 8192,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [YZBase64 encode:data];
    }
    else if (cryptStatus == kCCParamError) NSLog(@"PARAM ERROR");
    else if (cryptStatus == kCCBufferTooSmall) NSLog(@"BUFFER TOO SMALL");
    else if (cryptStatus == kCCMemoryFailure) NSLog(@"MEMORY FAILURE");
    else if (cryptStatus == kCCAlignmentError) NSLog(@"ALIGNMENT");
    else if (cryptStatus == kCCDecodeError) NSLog(@"DECODE ERROR");
    else if (cryptStatus == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");
    
    return ciphertext;
}

+(NSString *) parseByte2HexString:(Byte *) bytes
{
    NSMutableString *hexStr = [[[NSMutableString alloc]init] autorelease];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    NSLog(@"bytes 的16进制数为:%@",hexStr);
    return hexStr;
}

+(NSString *) parseByteArray2HexString:(Byte[]) bytes
{
    NSMutableString *hexStr = [[[NSMutableString alloc]init] autorelease];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    NSLog(@"bytes 的16进制数为:%@",hexStr);
    return hexStr;
}


+(NSString *)decryptUseDES:(NSString *)cipherText
{
    NSData *cipherdata = [YZBase64 decode:cipherText];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [DESKEY UTF8String], kCCKeySizeDES,
                                          iv,
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, 1024,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        NSString *plaintext = [[[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding] autorelease];
        return plaintext;
    } else {
        return nil;
    }
}

@end