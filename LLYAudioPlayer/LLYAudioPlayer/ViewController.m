//
//  ViewController.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/5/2.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"
#import "LLYAudioPlayer.h"

@interface ViewController ()<LLYAudioPlayerDelegate>

@property (nonatomic, strong) LLYAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *audioSlider;

@property (nonatomic, strong) NSTimer *audioTimer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.statusLabel.text = @"停止";
    self.currentTimeLabel.text = @"00:00";
    self.durationLabel.text = @"00:00";
    self.audioSlider.value = 0;
    
}

-(void)timer_Interval{

    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@",[self ocn_timeFormattedSeconds:self.audioPlayer.currentTime]];
    self.durationLabel.text = [NSString stringWithFormat:@"%@",[self ocn_timeFormattedSeconds:self.audioPlayer.duration]];
    self.audioSlider.maximumValue = self.audioPlayer.duration;
    self.audioSlider.minimumValue = 0;
    self.audioSlider.value = self.audioPlayer.currentTime;
}


- (IBAction)playLocalAudioSource:(id)sender {
    
    if ([self.audioTimer isValid]) {
        [self.audioTimer invalidate];
        self.audioTimer = nil;
    }
    
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timer_Interval) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.audioTimer forMode:NSRunLoopCommonModes];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"平凡之路" ofType:@"mp3"];
    self.audioPlayer = [[LLYAudioPlayer alloc] init];
    self.audioPlayer.delegate = self;
    [self.audioPlayer playWithUrl:path];

//    //需要放到子线程
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//    });
}

- (IBAction)playNetAudioSource:(id)sender {
}

- (IBAction)stop:(id)sender {
}

- (IBAction)seekComplete:(id)sender {
    NSLog(@"seekkkkk");
    
    [self.audioPlayer seekToTime:self.audioSlider.value];

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
