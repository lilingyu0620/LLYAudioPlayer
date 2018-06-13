//
//  LLYPlayerViewController.m
//  LLYAudioPlayer
//
//  Created by lly on 2018/6/13.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYPlayerViewController.h"
#import "LLYAudioPlayer.h"


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
    [self.audioPlayer playWithUrl:self.playUrl];
    
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
