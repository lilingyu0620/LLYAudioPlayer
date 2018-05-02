//
//  LLYAudioProperty.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/2.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYAudioProperty.h"

@implementation LLYAudioProperty{
    NSDictionary *errorDic;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _status = LLYAudioStatus_Init;
        _fileSize = 0;
        _packetMaxSize = 0;
        errorDic=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LLYAudioError" ofType:@"plist"]];
    }
    return self;
}

- (void)error:(LLYAudioError)errorType{
    
    if (!errorDic&&![errorDic objectForKey:[NSString stringWithFormat:@"%d",errorType]]) {
        self.error = [NSError errorWithDomain:@"no desc" code:errorType userInfo:nil];
    }else{
        self.error = [NSError errorWithDomain:[errorDic objectForKey:[NSString stringWithFormat:@"%d",errorType]] code:errorType userInfo:nil];
    }
}
- (NSString *)errorDomain:(LLYAudioError)errorType{
    if (!errorDic&&![errorDic objectForKey:[NSString stringWithFormat:@"%d",errorType]]) {
        return @"";
    }else{
        return [errorDic objectForKey:[NSString stringWithFormat:@"%d",errorType]];
    }
}
- (void)clean{
    self.fileSize = 0;
    self.packetMaxSize = 0;
    self.magicData = NULL;
    self.cookieSize = 0;
    self.status = LLYAudioStatus_Init;
    self.error = nil;
}

- (void)setStatus:(LLYAudioStatus)status{
    if (status != _status) {
        _status = status;
        if (self.delegate) {
            [self.delegate audioProperty_statusChanged:_status];
        }
    }
}

- (void)setError:(NSError *)error{
    _error = error;
    if (_error && self.delegate) {
        [self.delegate audioProrperty_error:_error];
    }
}



@end
