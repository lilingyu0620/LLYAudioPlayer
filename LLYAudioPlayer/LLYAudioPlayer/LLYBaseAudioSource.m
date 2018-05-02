//
//  LLYBaseAudioSource.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/2.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYBaseAudioSource.h"

@implementation LLYBaseAudioSource

- (AudioFileTypeID)fileTypeWithFileExtension:(NSString *)fileExtension{
    
    AudioFileTypeID fileTypeHint = kAudioFileAAC_ADTSType;
    if ([fileExtension isEqual:@"mp3"])
    {
        fileTypeHint = kAudioFileMP3Type;
    }
    else if ([fileExtension isEqual:@"wav"])
    {
        fileTypeHint = kAudioFileWAVEType;
    }
    else if ([fileExtension isEqual:@"aifc"])
    {
        fileTypeHint = kAudioFileAIFCType;
    }
    else if ([fileExtension isEqual:@"aiff"])
    {
        fileTypeHint = kAudioFileAIFFType;
    }
    else if ([fileExtension isEqual:@"m4a"])
    {
        fileTypeHint = kAudioFileM4AType;
    }
    else if ([fileExtension isEqual:@"mp4"])
    {
        fileTypeHint = kAudioFileMPEG4Type;
    }
    else if ([fileExtension isEqual:@"caf"])
    {
        fileTypeHint = kAudioFileCAFType;
    }
    else if ([fileExtension isEqual:@"aac"])
    {
        fileTypeHint = kAudioFileAAC_ADTSType;
    }
    return fileTypeHint;
    
}
- (void)audioSourceError:(NSString *)errorDomain userInfo:(NSDictionary *)userInfo{
    self.audioProperty.error = [NSError errorWithDomain:errorDomain code:LLYAudioError_AS_CustomError userInfo:userInfo];
}



@end
