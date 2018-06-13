//
//  LLYAudioQueue.h
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/3.
//  Copyright © 2018年 lly. All rights reserved.
//
//  AudioQueue封装类
//

#import <Foundation/Foundation.h>
#import "LLYAudioProperty.h"

@protocol LLYAudioQueueDelegate <NSObject>

- (void)setEncoderCookie;

@end

@interface LLYAudioQueue : NSObject

@property (nonatomic, assign) double currentTime;
@property (nonatomic, assign) double seekTime;
@property (nonatomic, assign) BOOL loadFinished;
@property (nonatomic, strong) LLYAudioProperty *audioProperty;
@property (nonatomic, weak) id <LLYAudioQueueDelegate> delegate;
@property (nonatomic, assign) NSInteger audioVersion;

- (instancetype)initWithAudioDesc:(AudioStreamBasicDescription)audioDesc;

- (void)start;

- (void)pause;

- (void)stop;

- (void)seeked;

- (void)enqueueBuffer:(NSData *)data packetNum:(UInt32)packetCount packetDescs:(AudioStreamPacketDescription *)inPacketDescs;

@end
