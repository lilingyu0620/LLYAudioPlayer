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
    UInt64 currOffset;//当前读取了多少音频数据
    NSTimer *fileTimer;
    BOOL isContine;//是否接着前一帧的数据播放seek的时候需要用到，默认为yes
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
        currOffset = 0;
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
    
//    [self loadData];
    
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];

}

- (void)cancel{
    exit = YES;
}

- (void)seekToOffset:(UInt64)offset{
    isContine = NO;
    newOffset = offset;
}

- (void)loadData{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.urlStr]){
        NSError *error;
        NSDictionary *fileAttDic = [[NSFileManager defaultManager] attributesOfItemAtPath:self.urlStr error:&error];
        fileSize = [[fileAttDic objectForKey:NSFileSize] longValue];
        if (fileSize > 0) {
            self.audioProperty.fileSize = fileSize;
            filehandle = [NSFileHandle fileHandleForReadingAtPath:self.urlStr];
            currOffset = 0;
            if (!fileTimer) {
                fileTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(fileTimer_intval) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] run];
            }
        }
        else{
            [self audioSourceError:@"file read error" userInfo:nil];
        }
    }
    else{
        [self audioSourceError:@"file not exists" userInfo:nil];
    }
}

- (void)fileTimer_intval{
    
    if (exit) {
        [filehandle closeFile];
        filehandle=nil;
        
        if (self.delegate) {
            [self.delegate audioSource_shouldExit:self];
        }
        
        CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);//必须停止，要不线程一直不会被释放
        return;
    }
    
    if (!filehandle) {
        return;
    }
    
    if (newOffset > 0) {
        currOffset = newOffset;
    }
    
    UInt64 currReadLength = readLength;
    if (currOffset + readLength > fileSize) {
        currReadLength = fileSize - currOffset;
    }
    
    if (currOffset == 0) {
        isContine = NO;
    }
    
    if (newOffset > 0){
        [filehandle seekToFileOffset:newOffset];
        
        newOffset = 0;
    }
    
    audioFileData = [filehandle readDataOfLength:currReadLength];
    if (audioFileData && self.delegate) {
        [self.delegate audioSource_dataArrived:self data:audioFileData contine:isContine];
    }
    
    currOffset += readLength;

    if (currOffset >= fileSize) {
        if (fileTimer) {
            [fileTimer invalidate];
            fileTimer=nil;
        }
    }
    
    if (!isContine) {
        isContine = YES;
    }
    
    if (!fileTimer) {
        if (self.delegate) {
            [self.delegate audioSource_finished:self error:nil];
            [filehandle closeFile];
            filehandle=nil;
        }
    }

}

@end
