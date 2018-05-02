//
//  LLYLocalAudioSource.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/2.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYLocalAudioSource.h"

@implementation LLYLocalAudioSource{
    NSFileHandle *filehandle;
    NSInteger readLength;
    UInt64 fileSize;
    UInt64 currOffset;
    NSTimer *fileTimer;
    BOOL isContine;
    UInt64 newOffset;
    BOOL exit;
    NSData *audioFileData;//每次读取到的文件数据
}

- (instancetype)init{
    self = [super init];
    if (self) {
        readLength = 2048;
        isContine = YES;
        newOffset = 0;
        exit = NO;
    }
    return self;
}

- (void)start{
    if (!self.urlStr) {
        return;
    }
    
    if (self.delegate) {
        [self.delegate audioSource_fileType:self fileType:[self fileTypeWithFileExtension:self.urlStr.pathExtension]];
    }
    
    exit = NO;
    
    [self loadData];
}

- (void)cancel{
    exit = YES;
}

- (void)loadData{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.urlStr]){
        NSError *error;
        NSDictionary *fileAttDic = [[NSFileManager defaultManager] attributesOfItemAtPath:self.urlStr error:&error];
        fileSize = [[fileAttDic objectForKey:NSFileSize] longValue];
        if (fileSize > 0) {
            self.audioProperty.fileSize = fileSize;
            do {
                if (exit) {
                    [filehandle closeFile];
                    filehandle=nil;
                    
                    if (self.delegate) {
                        [self.delegate audioSource_shouldExit:self];
                    }
                    return;
                }
                
                audioFileData = [filehandle readDataOfLength:readLength];
                if (audioFileData && self.delegate) {
                    [self.delegate audioSource_dataArrived:self data:audioFileData contine:YES];
                }
            } while (audioFileData != nil && audioFileData.length > 0);
            
            [filehandle closeFile];
        }
        else{
            [self audioSourceError:@"file read error" userInfo:nil];
        }
    }
    else{
        [self audioSourceError:@"file not exists" userInfo:nil];
    }
}


@end
