//
//  LLYFileManager.h
//  LLYAudioPlayer
//
//  Created by lly on 2018/6/13.
//  Copyright © 2018年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLYFileManager : NSObject

//网络地址转本地地址
+ (NSString *)pathWithUrl:(NSString *)fileUrl;
//将数据保存到本地目录下
+ (BOOL)saveFileWithPath:(NSString *)path fileObject:(id)fileObject;
//判断当前url对应的文件是否已经缓存
+ (BOOL)isFileExit:(NSString *)url;
//获取文件大小
+ (unsigned long long)fileSizeWithFilePath:(NSString *)filePath;

@end
