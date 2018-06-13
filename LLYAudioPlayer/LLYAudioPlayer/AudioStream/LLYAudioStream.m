//
//  LLYAudioStream.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/3.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYAudioStream.h"

#define BitRateEstimationMaxPackets 5000
#define BitRateEstimationMinPackets 50

@implementation LLYAudioStream{
    AudioFileStreamID audioFileStreamID;
    NSInteger packetCount;//当前已读取了多少个packet
    NSInteger packetDataSize;//当前已读取的packet的总文件大小 （这两个变量用来计算平均码率）
    NSInteger bitRate;//码率
    NSInteger dataOffset;//获取音频数据在文件中的起始位置，因为音频数据前面会有头文件。
    double packetDuration;//每个packet的时长
    BOOL isSeeking;
    BOOL shouldExit;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        packetCount = 0;
        packetDataSize = 0;
        bitRate = 0;
        dataOffset = 0;
        packetDuration = 0;
        isSeeking = NO;
        
        OSStatus error = AudioFileStreamOpen((__bridge void *)self, PropertyListenCallback, PacketListenCallback, 0, &audioFileStreamID);
        if (error != noErr) {
            [self.audioProperty error:LLYAudioError_AFS_OpenFail];
        }
        
        shouldExit = NO;
    }
    return self;
}

- (void)audioStreamParseBytes:(NSData *)data flags:(UInt32)flags{
    if (audioFileStreamID) {
        OSStatus error = AudioFileStreamParseBytes(audioFileStreamID, (UInt32)data.length, data.bytes, flags);
        if (error != noErr) {
            [self.audioProperty error:LLYAudioError_AFS_ParseFail];
        }
    }
}

- (void)getSeekToOffset:(double)seekToTime{
    
    self.seekByteOffset = dataOffset +
    (seekToTime / self.duration) * (_audioProperty.fileSize - dataOffset);
    
    if (self.seekByteOffset > _audioProperty.fileSize - 2 * _audioProperty.packetMaxSize){
        self.seekByteOffset = _audioProperty.fileSize - 2 * _audioProperty.packetMaxSize;
    }
    self.seekTime = seekToTime;
    isSeeking=YES;
}

- (void)close{
    
    shouldExit = YES;
}

-(double)duration{
    double calculatedBitRate = [self calculatedBitRate];
    
    if (calculatedBitRate == 0 || _audioProperty.fileSize == 0)
    {
        return 0.0;
    }
    
    return (_audioProperty.fileSize-dataOffset) / (calculatedBitRate * 0.125);
}

- (double)calculatedBitRate
{
    if (packetDuration && packetCount > BitRateEstimationMinPackets)
    {
        double averagePacketByteSize = packetDataSize / packetCount;
        return 8.0 * averagePacketByteSize / packetDuration;
    }
    
    if (bitRate)
    {
        return (double)bitRate;
    }
    
    return 0;
}
#pragma mark - callback

void PropertyListenCallback(void *inClientData,
                            AudioFileStreamID inAudioFileStream,
                            AudioFileStreamPropertyID inPropertyID,
                            UInt32 *ioFlags){
    LLYAudioStream *audioStream=(__bridge LLYAudioStream *)inClientData;
    
    [audioStream propertyListener:inPropertyID];
}

void PacketListenCallback(void *inClientData,
                          UInt32 inNumberBytes,
                          UInt32 inNumberPackets,
                          const void *inInputData,
                          AudioStreamPacketDescription *inPacketDescriptions){
    LLYAudioStream *audioStream=(__bridge LLYAudioStream *)inClientData;

    [audioStream packets:inClientData bytesNum:inNumberBytes packetsNum:inNumberPackets inputData:inInputData packesDescs:inPacketDescriptions];
}

#pragma mark - callback function

- (void)propertyListener:(AudioFileStreamPropertyID)inPropertyID{
    
    OSStatus error = noErr;
    if (inPropertyID == kAudioFileStreamProperty_DataFormat) {
        UInt32 asbdSize = sizeof(_audioDesc);
        error = AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_DataFormat, &asbdSize, &_audioDesc);
        if (error != noErr) {
            return;
        }
        
        [self p_printAudioStreamBasicDescription:_audioDesc];
        
        if (_audioDesc.mSampleRate > 0) {
            packetDuration = _audioDesc.mFramesPerPacket/_audioDesc.mSampleRate;
        }
    }
    else if (inPropertyID == kAudioFileStreamProperty_PacketSizeUpperBound){
        if (_audioProperty.packetMaxSize == 0) {
            UInt32 sizeOfUInt32 = sizeof(UInt32);
            UInt32 packetMaxSize = 0;
            AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_PacketSizeUpperBound, &sizeOfUInt32, &packetMaxSize);
            _audioProperty.packetMaxSize = packetMaxSize;
        }
    }
    else if (inPropertyID == kAudioFileStreamProperty_MaximumPacketSize){
        if (_audioProperty.packetMaxSize==0) {
            UInt32 sizeOfUInt32 = sizeof(UInt32);
            UInt32 packetMaxSize=0;
            AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_MaximumPacketSize, &sizeOfUInt32, &packetMaxSize);
            _audioProperty.packetMaxSize=packetMaxSize;
        }
    }
    else if(inPropertyID == kAudioFileStreamProperty_DataOffset){
        UInt32 sizeOfUInt32 = sizeof(NSInteger);
        AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_DataOffset, &sizeOfUInt32, &dataOffset);
    }
    else if(inPropertyID == kAudioFileStreamProperty_BitRate){
        UInt32 sizeOfUInt32 = sizeof(NSInteger);
        AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_BitRate, &sizeOfUInt32, &bitRate);
    }
    else if(inPropertyID==kAudioFileStreamProperty_ReadyToProducePackets){
        if (self.delegate) {
            [self.delegate audioStream_readyToProducePackets];
        }

        UInt32 cookieSize;
        Boolean writable;
        error = AudioFileStreamGetPropertyInfo(audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
        if (error != noErr) {
            cookieSize = 0;
            _audioProperty.cookieSize = 0;
        }
        if (cookieSize > 0) {
            void *cookieData = calloc(1, cookieSize);
            error = AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
            if (error != noErr) {
                return;
            }
            
            _audioProperty.magicData = cookieData;
            _audioProperty.cookieSize = cookieSize;
            
            free(cookieData);
        }
    }
}

- (void)packets:(void *)inClientData bytesNum:(UInt32)inNumberBytes packetsNum:(UInt32)inNumberPackets inputData:(const void *)inInputData packesDescs:(AudioStreamPacketDescription *)inPacketDescriptions{
    
    packetCount += inNumberPackets;
    packetDataSize += inNumberBytes;
    
    if (self.delegate) {
        [self.delegate audioStream_packets:[NSData dataWithBytes:inInputData length:inNumberBytes] packetNum:inNumberPackets packetDesc:inPacketDescriptions];
    }
    
}

#pragma mark - private method

- (void)p_printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
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
