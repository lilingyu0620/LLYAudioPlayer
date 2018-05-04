//
//  LLYNetAudioSource.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/4.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYNetAudioSource.h"

@interface LLYNetAudioSource ()<NSURLSessionDataDelegate>{
    BOOL isContine;
    UInt64 fileSize;
    UInt64 seekOffset;
    UInt64 currDataSize;
}

@property (nonatomic, strong) NSURLSession *audioSession;
@property (nonatomic, strong) NSURLSessionTask *audioTask;
@property (nonatomic, strong) NSMutableURLRequest *audioRequest;

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

    [self performSelectorInBackground:@selector(requestStart) withObject:nil];

}

- (void)requestStart{
    
    if (!self.audioTask) {
        self.audioRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
        if (seekOffset) {
            [self.audioRequest setValue:[NSString stringWithFormat:@"bytes=%llu-",seekOffset] forHTTPHeaderField:@"Range"];
        }
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.audioSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue new]];
        self.audioTask = [self.audioSession dataTaskWithRequest:self.audioRequest];
        [self.audioTask resume];
        
        NSLog(@"requestStart current thread %@",[NSThread currentThread]);
    }
}

- (void)cancel{
    if (self.audioTask) {
        [self.audioTask cancel];
        self.audioTask = nil;
        self.audioSession = nil;
        self.audioRequest = nil;
    }
}

- (void)seekToOffset:(UInt64)offset{
    isContine = NO;
    if (self.audioTask) {
        [self.audioTask cancel];
        self.audioTask = nil;
        self.audioSession = nil;
        self.audioRequest = nil;
    }
    
    seekOffset = offset;

    [self performSelectorInBackground:@selector(requestStart) withObject:nil];
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    NSLog(@"didReceiveResponse current thread %@",[NSThread currentThread]);

    fileSize = seekOffset + response.expectedContentLength;
    seekOffset = 0;
    self.audioProperty.fileSize = fileSize;
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    NSLog(@"didReceiveData current thread %@",[NSThread currentThread]);

    if (self.delegate) {
        if (currDataSize == 0) {
            isContine = NO;
        }
        [self.delegate audioSource_dataArrived:self data:data contine:isContine];
        currDataSize = currDataSize + data.length;
        if (!isContine) {
            isContine = YES;
        }
    }
}


@end
