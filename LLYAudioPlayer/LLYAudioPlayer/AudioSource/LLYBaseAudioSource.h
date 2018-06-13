//
//  LLYBaseAudioSource.h
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/2.
//  Copyright © 2018年 lly. All rights reserved.
//
//  音频数据源基类
//

#import <Foundation/Foundation.h>
#import "LLYAudioProperty.h"

@class LLYBaseAudioSource;

@protocol LLYAudioSourceDelegate <NSObject>

- (void)audioSource_fileType:(LLYBaseAudioSource *)curAudioSource fileType:(AudioFileTypeID)fileType;
- (void)audioSource_dataArrived:(LLYBaseAudioSource *)curAudioSource data:(NSData *)data contine:(BOOL)isContine;
- (void)audioSource_finished:(LLYBaseAudioSource *)curAudioSource error:(NSError *)error;
- (void)audioSource_shouldExit:(LLYBaseAudioSource*)currAudioData;


@end

@interface LLYBaseAudioSource : NSObject

@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, weak) id<LLYAudioSourceDelegate> delegate;
@property (nonatomic, assign) int audioVersion;
@property (nonatomic, strong) LLYAudioProperty *audioProperty;

- (void)start;
- (void)cancel;
- (void)seekToOffset:(UInt64)offset;
- (AudioFileTypeID)fileTypeWithFileExtension:(NSString *)fileExtension;
- (void)audioSourceError:(NSString *)errorDomain userInfo:(NSDictionary *)userInfo;


@end
