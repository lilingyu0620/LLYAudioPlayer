//
//  LLYEncryption.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/6/13.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYEncryption.h"
#import <CommonCrypto/CommonDigest.h>

//秘钥
static NSString *encryptionKey = @"nha735n197nxn(N′568GGS%d~~9naei';45vhhafdjkv]32rpks;lg,];:vjo(&**&^)";

@implementation LLYEncryption

+ (NSString *)md5EncryptWithString:(NSString *)string{
    return [LLYEncryption md5:[NSString stringWithFormat:@"%@%@", encryptionKey, string]];
}

+ (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}
@end
