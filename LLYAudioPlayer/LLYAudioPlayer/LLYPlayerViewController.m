//
//  LLYPlayerViewController.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/6/13.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYPlayerViewController.h"
#import "LLYAudioPlayer.h"
#import "LLYFileManager.h"
#import "LLYHttpSessionManager.h"


@interface LLYPlayerViewController ()<LLYAudioPlayerDelegate>

@property (nonatomic, copy) NSString * playUrl;
@property (nonatomic, strong) LLYAudioPlayer *audioPlayer;

@end

@implementation LLYPlayerViewController

- (void)dealloc{
    NSLog(@"%s dealloc",__func__);
}

- (instancetype)initWithUrl:(NSString *)playUrl{
    
    self = [super init];
    if (self) {
        
        self.playUrl = playUrl;
        self.title = playUrl;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.audioPlayer = [[LLYAudioPlayer alloc] init];
    self.audioPlayer.delegate = self;
    
    //先判断当前url是否已经缓存过
    if ([LLYFileManager isFileExit:self.playUrl]) {
        
        //判断一下文件是否下载完了
        [[LLYHttpSessionManager shareInstance] requestAUDIOWithMethod:LLYHttpMethod_HEAD urlString:self.playUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
            int64_t contentExceptLength = task.countOfBytesExpectedToReceive;
            unsigned long long fileSize = [LLYFileManager fileSizeWithFilePath:[LLYFileManager pathWithUrl:self.playUrl]];
            if (fileSize >= contentExceptLength) {
                //已下载完
                self.playUrl = [LLYFileManager pathWithUrl:self.playUrl];
                [self.audioPlayer playWithUrl:self.playUrl];
            }
            else{
                [self.audioPlayer playWithUrl:self.playUrl];
            }
            
        } failure:nil];
        
    }
    else{
        [self.audioPlayer playWithUrl:self.playUrl];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.audioPlayer stop];
}

#pragma mark - LLYAudioPlayerDelegate
- (void)audioPlayer_statusChanged:(LLYAudioStatus)playerStatus error:(NSError *)error{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
