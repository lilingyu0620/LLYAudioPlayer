//
//  LLYNetAudioSource.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/4.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYNetAudioSource.h"
#import "LLYHttpSessionManager.h"
#import "LLYFileManager.h"

@interface LLYNetAudioSource (){
    BOOL isContine;
    UInt64 fileSize;
    UInt64 seekOffset;
    UInt64 currDataSize;
}

@property (nonatomic, strong) NSURLSessionTask *audioTask;

@end

@implementation LLYNetAudioSource

- (instancetype)init{
    self = [super init];
    if (self) {
        fileSize = 0;
        isContine = YES;
        seekOffset = 0;
        currDataSize = 0;
    }
    return self;
}


- (void)start{
    
    if (self.delegate) {
        [self.delegate audioSource_fileType:self fileType:[self fileTypeWithFileExtension:self.urlStr.pathExtension]];
    }
    NSLog(@"start current thread %@",[NSThread currentThread]);
    
    [LLYHttpSessionManager shareInstance].didReceiveResponseBlock = ^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response) {
        NSLog(@"dataTask = %lu",(unsigned long)dataTask.taskIdentifier);
        
        fileSize = seekOffset + response.expectedContentLength;
        seekOffset = 0;
        self.audioProperty.fileSize = fileSize;
        
    };
    
    [LLYHttpSessionManager shareInstance].didReceiveDataBlock = ^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
//        NSLog(@"dataTask = %lu,data = %@",(unsigned long)dataTask.taskIdentifier,data);
        if (self.delegate && self.audioTask.taskIdentifier == dataTask.taskIdentifier) {
            if (currDataSize == 0) {
                isContine = NO;
            }
            [self.delegate audioSource_dataArrived:self data:data contine:isContine];
            
            currDataSize = currDataSize + data.length;
            if (!isContine) {
                isContine = YES;
            }
        }
    };
    
    [self requestStart];
}

- (void)requestStart{
    
    if (!self.audioTask) {
        
        if (seekOffset) {
            [[LLYHttpSessionManager shareInstance] setValue:[NSString stringWithFormat:@"bytes=%llu-",seekOffset] forHTTPHeaderField:@"Range"];
        }
        
        self.audioTask = [[LLYHttpSessionManager shareInstance] requestAUDIOWithMethod:LLYHttpMethod_GET urlString:self.urlStr parameters:nil progress:^(NSProgress * _Nullable downloadProgress) {
            NSLog(@"totalunit = %lld,completeunit = %lld",downloadProgress.totalUnitCount,downloadProgress.completedUnitCount);
        } success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {

            NSString *path = [LLYFileManager pathWithUrl:self.urlStr];
            [LLYFileManager saveFileWithPath:path fileObject:responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
            
        }];
        
        NSLog(@"requestStart current thread %@",[NSThread currentThread]);
    }
}

- (void)cancel{
    if (self.audioTask) {
        [self.audioTask cancel];
        self.audioTask = nil;
    }
}

- (void)seekToOffset:(UInt64)offset{
    isContine = NO;
    if (self.audioTask) {
        [self.audioTask cancel];
        self.audioTask = nil;
    }
    
    seekOffset = offset;

    [self requestStart];
}

@end
