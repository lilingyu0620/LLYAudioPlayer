//
//  LLYAudioQueue.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/3.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYAudioQueue.h"
#import <AVFoundation/AVFoundation.h>

@implementation LLYAudioQueue{
    
    AudioStreamBasicDescription llyAudioDesc;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef audioQueueBuffer[Num_Buffers];
    bool inuse[Num_Buffers];//标记当前buffer是否正在被使用
    AudioStreamPacketDescription bufferDescs[Num_Descs];
    UInt32 bufferSize;//每个buffer的大小
    UInt32 currBufferIndex;//当前使用的buffer的索引
    UInt32 currBufferFillOffset;//当前buffer已填充的数据量
    UInt32 currBufferPacketCount;//当前是第几个packet
    
    NSLock *mLock;
    
    BOOL isStart;
    BOOL isSeeking;
}

- (instancetype)initWithAudioDesc:(AudioStreamBasicDescription)audioDesc{
    self = [super init];
    if (self) {
        llyAudioDesc = audioDesc;
        mLock = [[NSLock alloc]init];
        _seekTime = 0;
        isStart = NO;
        isSeeking = NO;
        _loadFinished = NO;
    }
    return self;
}

- (void)start{
    if (_audioProperty.status == LLYAudioStatus_Paused) {
        _audioProperty.status = LLYAudioStatus_Playing;
    }
    else{
        _audioProperty.status = LLYAudioStatus_Waiting;
    }
    
    [self p_audioStart];
}

- (void)pause{
    _audioProperty.status = LLYAudioStatus_Paused;
    
    [self p_audioPause];
}

- (void)stop{
    
    _audioProperty.status = LLYAudioStatus_Stop;
    
    [self p_audioStop];
    
    [self p_cleanUp];
}

- (void)seeked{
    @synchronized(self){
        isSeeking = NO;
        currBufferPacketCount = 0;
        currBufferFillOffset = 0;
        currBufferIndex = 0;
    }
}

- (void)enqueueBuffer:(NSData *)data packetNum:(UInt32)packetCount packetDescs:(AudioStreamPacketDescription *)inPacketDescs{
    if (!audioQueue) {
        [self p_createQueue];
    }
    
    if (inPacketDescs) {
        for (int i = 0; i < packetCount; i++) {
            if (isSeeking) {
                return;
            }
            
            if (_audioProperty.status == LLYAudioStatus_Stop) {
                return;
            }
            
            AudioStreamPacketDescription packetDesc = inPacketDescs[i];
            if (currBufferFillOffset + packetDesc.mDataByteSize >= bufferSize) {
//                NSLog(@"当前buffer_%u已经满了，送给audioqueue去播吧",(unsigned int)currBufferIndex);
                [self p_putBufferToQueue];
            }
            
//            NSLog(@"给当前buffer_%u填装数据中",(unsigned int)currBufferIndex);
            AudioQueueBufferRef outBufferRef = audioQueueBuffer[currBufferIndex];
            memcpy(outBufferRef->mAudioData + currBufferFillOffset, data.bytes + packetDesc.mStartOffset,packetDesc.mDataByteSize);
            outBufferRef->mAudioDataByteSize = currBufferFillOffset+packetDesc.mDataByteSize;
            
            bufferDescs[currBufferPacketCount] = packetDesc;
            bufferDescs[currBufferPacketCount].mStartOffset = currBufferFillOffset;
            currBufferFillOffset = currBufferFillOffset+packetDesc.mDataByteSize;
            currBufferPacketCount++;
        }
    }
    
}

- (double)currentTime{
    AudioTimeStamp audioTime;
    Boolean discontinuity;
    OSStatus error = AudioQueueGetCurrentTime(audioQueue, NULL, &audioTime, &discontinuity);
    if (error != noErr) {
        return 0;
    }
    else{
        return _seekTime + audioTime.mSampleTime/llyAudioDesc.mSampleRate;
    }
}

- (void)setSeekTime:(double)seekTime{
    _seekTime = seekTime;
    isSeeking = YES;
    isStart = NO;
    AudioQueueStop(audioQueue, true);
}

#pragma mark - private method

- (void)p_createQueue{
    if (!audioQueue) {
        
        [self printAudioStreamBasicDescription:llyAudioDesc];
        
        OSStatus error = AudioQueueNewOutput(&llyAudioDesc, LLYAudioQueueOutputCallback, (__bridge void *)self, NULL, NULL, 0, &audioQueue);
        if (error != noErr) {
            [_audioProperty error:LLYAudioError_AQ_InitFail];
            return;
        }
        
//        AudioQueueAddPropertyListener(audioQueue, kAudioQueueProperty_IsRunning, LLYAudioQueueIsRunningCallback, (__bridge  void *)(self));
        
        currBufferIndex = 0;
        currBufferFillOffset = 0;
        currBufferPacketCount = 0;
        if (_audioProperty.cookieSize > 0) {
            AudioQueueSetProperty(audioQueue, kAudioQueueProperty_MagicCookie, _audioProperty.magicData, _audioProperty.cookieSize);
        }
        [self p_initQueueBuffer];
    }
}

- (void)p_initQueueBuffer{
    
    if (_audioProperty.packetMaxSize == 0) {
        bufferSize = Size_DefaultBufferSize;
    }else{
        bufferSize = _audioProperty.packetMaxSize;
    }
    
    for (int i = 0; i < Num_Buffers; ++i) {
        OSStatus error = AudioQueueAllocateBuffer(audioQueue, bufferSize, &audioQueueBuffer[i]);
        if (error != noErr) {
            [self.audioProperty error:LLYAudioError_AQB_AllocFail];
            return;
        }
    }
}

- (void)p_audioStart{
    @synchronized(self){
        if (!isStart) {
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            
            OSStatus error = AudioQueueStart(audioQueue, NULL);
            if (error != noErr) {
                [_audioProperty error:LLYAudioError_AQ_StartFail];
                return;
            }
            
            isStart = YES;
            
            if (_audioProperty.status != LLYAudioStatus_Playing) {
                _audioProperty.status = LLYAudioStatus_Playing;
            }
        }
    }
}

- (void)p_audioPause{
    @synchronized(self)
    {
        if (isStart){
            OSStatus status= AudioQueuePause(audioQueue);
            if (status!=noErr)
            {
                [self.audioProperty error:LLYAudioError_AQ_PauseFail];
                return;
            }
            isStart = NO;
        }
    }
}

- (void)p_audioStop{
    @synchronized(self)
    {
        if (audioQueue) {
            
            isStart = NO;
            
            OSStatus status= AudioQueueStop(audioQueue, true);
            if (status!=noErr)
            {
                [self.audioProperty error:LLYAudioError_AQ_StopFail];
                return;
            }
        }
        
    }
}

- (void)p_cleanUp{
    if (audioQueue) {
//        AudioQueueRemovePropertyListener(audioQueue, kAudioQueueProperty_IsRunning, audioQueueIsRunningCallback, (__bridge void *)(self));
        for (NSInteger i = 0;i < Num_Buffers;i++) {
            AudioQueueFreeBuffer(audioQueue, audioQueueBuffer[i]);
        }
        AudioQueueDispose(audioQueue, true);
        audioQueue=NULL;
    }
    currBufferPacketCount=0;
    currBufferFillOffset=0;
    currBufferIndex=0;
}


- (void)p_putBufferToQueue{
    
    inuse[currBufferIndex] = YES;
    AudioQueueBufferRef outBufferRef = audioQueueBuffer[currBufferIndex];
    OSStatus error;
    if (currBufferPacketCount > 0) {
        error = AudioQueueEnqueueBuffer(audioQueue, outBufferRef, currBufferPacketCount, bufferDescs);
    }
    else{
        error = AudioQueueEnqueueBuffer(audioQueue, outBufferRef, 0, NULL);
    }
    
    if (error != noErr) {
        [_audioProperty error:LLYAudioError_AQB_EnqueueFail];
        return;
    }
    
//    if (_audioProperty.status != LLYAudioStatus_Playing) {
//        _audioProperty.status = LLYAudioStatus_Playing;
//    }
    
    if (!isStart && _audioProperty.status != LLYAudioStatus_Paused) {
        
        [self start];

    }
    
    currBufferIndex = ++currBufferIndex % Num_Buffers;
    currBufferPacketCount=0;
    currBufferFillOffset=0;
    
    while (inuse[currBufferIndex]);
}

- (void)p_audioQueueOutput:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer{
    for (int i = 0; i < Num_Buffers; i++) {
        if (inBuffer == audioQueueBuffer[i]) {
            [mLock lock];
            inuse[i] = NO;
//            NSLog(@"当前buffer_%d的数据已经播放完了 还给程序继续装数据去吧！！！！！！",i);
            [mLock unlock];
        }
    }
}

#pragma mark - callback

void LLYAudioQueueOutputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer){
    LLYAudioQueue *audioQueue=(__bridge LLYAudioQueue*)inUserData;
    [audioQueue p_audioQueueOutput:inAQ inBuffer:inBuffer];
}


- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("Sample Rate:         %10.0f\n",  asbd.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)asbd.mBytesPerPacket);
    printf("Frames per Packet:   %10d\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("Channels per Frame:  %10d\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)asbd.mBitsPerChannel);
    printf("\n");
}

@end
