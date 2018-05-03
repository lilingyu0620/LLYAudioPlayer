//
//  LLYAudioPlayer.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/3.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYAudioPlayer.h"
#import "LLYBaseAudioSource.h"
#import "LLYLocalAudioSource.h"
#import "LLYAudioQueue.h"
#import "LLYAudioStream.h"

@interface LLYAudioPlayer ()<LLYAudioSourceDelegate,LLYAudioStreamDelegate,LLYAudioPropertyDelegate>

@property (nonatomic, strong) LLYBaseAudioSource *audioSource;
@property (nonatomic, strong) LLYAudioQueue *audioQueue;
@property (nonatomic, strong) LLYAudioStream *audioStream;
@property (nonatomic, strong) LLYAudioProperty *audioProperty;

@end

@implementation LLYAudioPlayer

- (instancetype)init{
    self = [super init];
    if (self) {
        self.audioProperty = [[LLYAudioProperty alloc]init];
        self.audioProperty.delegate = self;
    }
    return self;
}

- (void)playWithUrl:(NSString*)urlStr{
    
    LLYBaseAudioSource *audioSource;
    if([urlStr.lowercaseString hasPrefix:@"http"]){
        
    }else{
        audioSource=[[LLYLocalAudioSource alloc] init];
    }
    audioSource.urlStr = urlStr;
    
    [self playWithAudioSource:audioSource];
}

- (void)play{
    if (_audioQueue) {
        [_audioQueue start];
    }
}

- (void)pause{
    if (_audioQueue) {
        [_audioQueue pause];
    }
}

- (void)stop{
    if (_audioQueue) {
        [_audioQueue stop];
        _audioQueue.audioProperty = nil;
        self.audioQueue = nil;
        self.audioProperty = nil;
    }
    else{
        _audioProperty.status = LLYAudioStatus_Stop;
    }
    if (_audioSource) {
        [_audioSource cancel];
        self.audioSource.audioProperty = nil;
        self.audioSource = nil;
    }
    if (_audioStream) {
        _audioStream.delegate = nil;
        _audioStream.audioProperty = nil;
        [_audioStream close];
        self.audioStream = nil;
    }
}

-(void)seekToTime:(double)seekToTime{
    if (!_audioStream) {
        return;
    }
    if (!_audioQueue) {
        return;
    }
    [_audioStream getSeekToOffset:seekToTime];
    _audioQueue.seekTime = self.audioStream.seekTime;
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.audioSource seekToOffset:weakSelf.audioStream.seekByteOffset];
    });
}

-(double)duration{
    if (!_audioStream) {
        return 0;
    }
    return _audioStream.duration;
}

-(double)currentTime{
    if (!_audioQueue) {
        return 0;
    }
    return _audioQueue.currentTime;
}

-(LLYAudioStatus)status{
    return _audioProperty.status;
}

#pragma mark - private method

- (void)playWithAudioSource:(LLYBaseAudioSource *)audioSource{
    if (_audioProperty) {
        [_audioProperty clean];
    }
    if (self.audioQueue) {
        [_audioQueue stop];
        self.audioQueue = nil;
    }
    if (audioSource) {
        [audioSource cancel];
        audioSource.audioProperty = nil;
        self.audioSource = nil;
    }
    if (_audioStream) {
        _audioStream.delegate = nil;
        _audioStream.audioProperty = nil;
        [_audioStream close];
        self.audioStream = nil;
    }
    if(!audioSource){
        ///播放错误
        [self.audioProperty error:LLYAudioError_AS_Nil];
        return;
    }
    
    self.audioSource = audioSource;
//    self.audioSource.audioVersion = ++audioVersion;
    self.audioSource.audioProperty = self.audioProperty;
    self.audioSource.delegate = self;
    [self.audioSource start];
    _audioProperty.status = LLYAudioStatus_Waiting;
}


#pragma mark - LLYAudioSourceDelegate

- (void)audioSource_fileType:(LLYBaseAudioSource *)curAudioSource fileType:(AudioFileTypeID)fileType{
    if (curAudioSource != self.audioSource) {
        return;
    }
    
    if (!self.audioStream) {
        self.audioStream = [[LLYAudioStream alloc]init];
        self.audioStream.audioProperty = self.audioProperty;
        self.audioStream.delegate = self;
    }
}
- (void)audioSource_dataArrived:(LLYBaseAudioSource *)curAudioSource data:(NSData *)data contine:(BOOL)isContine{
    if (curAudioSource != self.audioSource) {
        return;
    }
    
    UInt32 flags=0;
    if (!isContine) {
        flags = kAudioFileStreamParseFlag_Discontinuity;
        [self.audioQueue seeked];
    }
    [self.audioStream audioStreamParseBytes:data flags:flags];
}
- (void)audioSource_finished:(LLYBaseAudioSource *)curAudioSource error:(NSError *)error{
    if (curAudioSource != self.audioSource) {
        return;
    }
    if (_audioQueue) {
        _audioQueue.loadFinished=YES;
    }
}
- (void)audioSource_shouldExit:(LLYBaseAudioSource*)currAudioData{
    
}


#pragma mark - LLYAudioStreamDelegate

- (void)audioStream_readyToProducePackets{
    if (!self.audioQueue) {
        self.audioQueue=[[LLYAudioQueue alloc] initWithAudioDesc:self.audioStream.audioDesc];
        _audioQueue.audioProperty = self.audioProperty;
//        _audioQueue.audioVersion=self.audioData.audioVersion;
    }
}
- (void)audioStream_packets:(NSData *)data packetNum:(UInt32)packetCount packetDesc:(AudioStreamPacketDescription *)inPacketDesc{
    [self.audioQueue enqueueBuffer:data packetNum:packetCount packetDescs:inPacketDesc];
}

#pragma mark - LLYAudioPropertyDelegate

- (void)audioProrperty_error:(NSError *)error{
    
    
}
- (void)audioProperty_statusChanged:(LLYAudioStatus)audioStatus{
    if (self.delegate) {
        [self.delegate audioPlayer_statusChanged:_audioProperty.status error:_audioProperty.error];
        if (_audioProperty.error) {
            _audioProperty.error = nil;
        }
    }
}

@end
