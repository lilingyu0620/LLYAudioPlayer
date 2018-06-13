//
//  LLYAudioPlayerDefine.h
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/2.
//  Copyright © 2018年 lly. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef LLYAudioPlayerDefine_h
#define LLYAudioPlayerDefine_h

#define Num_Buffers 3 //缓冲区数量
#define Num_Descs 512 //复用的包描述数量
#define Size_DefaultBufferSize 2048 //默认缓冲区大小

#define Dur_RecordBuffer 0.5 //录音每次时间
#define Size_RecordBufferSize 2048 //录音缓冲区默认大小


//音频播放状态
typedef NS_ENUM(NSUInteger, LLYAudioStatus) {
    LLYAudioStatus_Init = 0,
    LLYAudioStatus_Waiting,
    LLYAudioStatus_Playing,
    LLYAudioStatus_Paused,
    LLYAudioStatus_Stop,
};

//AS:AudioSource; AQ:AudioQueue; AQB:AudioQueue Buffer;
//AQR:AQB:AudioQueue Record; AFS:AudioFileStream; AF:AudioFile
typedef NS_ENUM(NSUInteger, LLYAudioError) {
    LLYAudioError_noErr = 0,
    LLYAudioError_AS_Nil,
    LLYAudioError_AQ_InitFail,
    LLYAudioError_AQB_AllocFail,
    LLYAudioError_AQ_StartFail,
    LLYAudioError_AQ_PauseFail,
    LLYAudioError_AQ_StopFail,
    LLYAudioError_AQB_EnqueueFail,
    LLYAudioError_AQR_StartFail,
    LLYAudioError_AQR_InitFail,
    LLYAudioError_AQR_EnqueueBufferFail,
    LLYAudioError_AFS_OpenFail,
    LLYAudioError_AFS_ParseFail,
    LLYAudioError_AF_CreateFail,
    LLYAudioError_AF_PacketWriteFail,
    LLYAudioError_AS_CustomError
};

typedef NS_ENUM(NSUInteger, LLYFormatID) {
    LLYFormatID_PCM = 'lpcm',
    LLYFormatID_AAC = 'aac ',
    LLYFormatID_AMR = 'samr',
};

#endif /* LLYAudioPlayerDefine_h */
