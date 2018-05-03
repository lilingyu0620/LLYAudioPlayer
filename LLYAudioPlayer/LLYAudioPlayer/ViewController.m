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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"平凡之路" ofType:@"mp3"];
    self.audioPlayer = [[LLYAudioPlayer alloc] init];
    self.audioPlayer.delegate = self;
    [self.audioPlayer playWithUrl:path];

}


#pragma mark - LLYAudioPlayerDelegate
- (void)audioPlayer_statusChanged:(LLYAudioStatus)playerStatus error:(NSError *)error{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
