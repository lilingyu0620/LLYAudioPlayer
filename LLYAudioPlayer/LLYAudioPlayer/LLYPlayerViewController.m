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

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *audioSlider;

@property (nonatomic, strong) NSTimer *audioTimer;

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
    
    [self startTimer];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.audioPlayer stop];
    [self stopTimer];
}

- (void)startTimer{
    
    [self stopTimer];
    
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer_Interval) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.audioTimer forMode:NSRunLoopCommonModes];
    
}

- (void)stopTimer{
    
    if ([self.audioTimer isValid]) {
        [self.audioTimer invalidate];
        self.audioTimer = nil;
    }
}

-(void)timer_Interval{
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@",[self ocn_timeFormattedSeconds:self.audioPlayer.currentTime]];
    self.durationLabel.text = [NSString stringWithFormat:@"%@",[self ocn_timeFormattedSeconds:self.audioPlayer.duration]];
    self.audioSlider.maximumValue = self.audioPlayer.duration;
    self.audioSlider.minimumValue = 0;
    self.audioSlider.value = self.audioPlayer.currentTime;
}

- (IBAction)stop:(id)sender {
    
    [self.audioPlayer stop];
}
- (IBAction)goonPlay:(id)sender {
    
    [self.audioPlayer play];
}
- (IBAction)pauseBtnClicked:(id)sender {
    
    [self.audioPlayer pause];
}

- (IBAction)seekComplete:(id)sender {
    NSLog(@"seeked");
    [self startTimer];
    
    [self.audioPlayer seekToTime:self.audioSlider.value];
    
}
- (IBAction)seeking:(id)sender {
    
    NSLog(@"seekinggggggggggg");
    [self stopTimer];
}

- (NSString *)ocn_timeFormattedSeconds:(NSInteger)totolSeconds{
    NSInteger seconds = totolSeconds % 60;
    NSInteger minites = (totolSeconds / 60) % 60;
    NSInteger hours = totolSeconds / 3600;
    NSString *time = [NSString stringWithFormat:@"%02ld:%02ld",minites,seconds];
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02ld:%@",hours, time];
    }
    return time;
}

#pragma mark - LLYAudioPlayerDelegate
- (void)audioPlayer_statusChanged:(LLYAudioStatus)playerStatus error:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (playerStatus == LLYAudioStatus_Init) {
            self.statusLabel.text = @"初始化...";
        }
        else if (playerStatus == LLYAudioStatus_Waiting){
            self.statusLabel.text = @"等待中...";
        }
        else if (playerStatus == LLYAudioStatus_Playing){
            self.statusLabel.text = @"播放中...";
        }
        else if (playerStatus == LLYAudioStatus_Paused){
            self.statusLabel.text = @"暂停中...";
        }
        else{
            self.statusLabel.text = @"停止";
        }
    });
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
