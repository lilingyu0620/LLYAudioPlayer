//
//  LLYFileManager.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/6/13.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYFileManager.h"
#import "LLYEncryption.h"

@implementation LLYFileManager

+ (NSString *)libraryPath{
    NSArray *fileArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [fileArray objectAtIndex:0];
}

+ (NSString *)downloadFileDoc{
    NSString *fileDoc = nil;
    NSString *libraryPath = [LLYFileManager libraryPath];
    fileDoc = [NSString stringWithFormat:@"%@/Download",libraryPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDoc]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDoc withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileDoc;
}

+ (NSString *)pathWithUrl:(NSString *)fileUrl{
    
    NSString *filePath = nil;
    NSString *md5Str = [LLYEncryption md5EncryptWithString:fileUrl];
    filePath = [NSString stringWithFormat:@"%@/%@.mp3",[LLYFileManager downloadFileDoc],md5Str];
    return filePath;
}

+ (BOOL)saveFileWithPath:(NSString *)path fileObject:(id)fileObject{
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    
    NSFileHandle *saveHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:path] error:&error];
    if (saveHandle == nil || error != noErr) {
        return NO;
    }
//    [saveHandle seekToEndOfFile];
    [saveHandle writeData:fileObject];
    [saveHandle closeFile];
    
    return YES;
}

+ (BOOL)isFileExit:(NSString *)url{
    
    NSString *filePaht = [LLYFileManager pathWithUrl:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePaht]) {
        return YES;
    }
    return NO;
}

+ (unsigned long long)fileSizeWithFilePath:(NSString *)filePath{
    
    return [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
}
@end
