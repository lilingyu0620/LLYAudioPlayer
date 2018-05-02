//
//  LLYAudioProperty.h
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/2.
//  Copyright © 2018年 lly. All rights reserved.
//
//  音频属性类
//

#import <Foundation/Foundation.h>

@protocol LLYAudioPropertyDelegate <NSObject>

- (void)audioProrperty_error:(NSError *)error;
- (void)audioProperty_statusChanged:(LLYAudioStatus)audioStatus;

@end

@interface LLYAudioProperty : NSObject

@property (nonatomic, assign) UInt64 fileSize;
@property (nonatomic, assign) UInt32 packetMaxSize;
@property (nonatomic, assign) void * magicData;
@property (nonatomic, assign) UInt32 cookieSize;
@property (nonatomic, assign) LLYAudioStatus status;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, weak) id <LLYAudioPropertyDelegate> delegate;
@property (nonatomic, assign) AudioStreamBasicDescription audioDesc;

- (void)error:(LLYAudioError)errorType;
- (NSString *)errorDomain:(LLYAudioError)errorType;
- (void)clean;

@end
