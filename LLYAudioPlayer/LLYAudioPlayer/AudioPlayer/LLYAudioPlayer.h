//
//  LLYAudioPlayer.h
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/3.
//  Copyright © 2018年 lly. All rights reserved.
//
//  音频播放类
//
#import <Foundation/Foundation.h>

@protocol LLYAudioPlayerDelegate <NSObject>

- (void)audioPlayer_statusChanged:(LLYAudioStatus)playerStatus error:(NSError *)error;

@end

@interface LLYAudioPlayer : NSObject

@property (nonatomic, assign) double duration;
@property (nonatomic, assign) double currentTime;
@property (nonatomic, assign) LLYAudioStatus status;
@property (nonatomic, weak) id <LLYAudioPlayerDelegate> delegate;

- (void)playWithUrl:(NSString *)urlStr;

- (void)play;
- (void)pause;
- (void)stop;

- (void)seekToTime:(double)seekToTime;

@end
