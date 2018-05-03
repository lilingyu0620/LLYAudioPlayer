//
//  LLYAudioStream.h
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/3.
//  Copyright © 2018年 lly. All rights reserved.
//
//  音频数据处理类
//

#import <Foundation/Foundation.h>
#import "LLYAudioProperty.h"

@protocol LLYAudioStreamDelegate <NSObject>

- (void)audioStream_readyToProducePackets;
- (void)audioStream_packets:(NSData *)data packetNum:(UInt32)packetCount packetDesc:(AudioStreamPacketDescription *)inPacketDesc;

@end

@interface LLYAudioStream : NSObject

@property (nonatomic, assign) AudioStreamBasicDescription audioDesc;
@property (nonatomic, assign) double duration;
@property (nonatomic, weak) id<LLYAudioStreamDelegate> delegate;
@property (nonatomic, strong) LLYAudioProperty *audioProperty;
@property (nonatomic, assign) UInt64 seekByteOffset;
@property (nonatomic, assign) double seekTime;
@property (nonatomic, assign) NSInteger audioVersion;

//- (instancetype)initWithFileType:(AudioFileTypeID)fileTypeID;

- (void)audioStreamParseBytes:(NSData *)data flags:(UInt32)flags;

- (void)getSeekToOffset:(double)seekToTime;

- (void)close;

@end
