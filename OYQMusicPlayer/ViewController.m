//
//  ViewController.m
//  播放器
//
//  Created by 欧阳铨 on 15/12/18.
//  Copyright © 2015年 欧阳铨. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
/// 声音调节
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
/// 封面后面的黑色图片
@property (weak, nonatomic) IBOutlet UIView *backView;
/// 封面图片
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
/// 播放进度
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/// 播放进度的文字
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
/// 上一首的按钮
@property (weak, nonatomic) IBOutlet UIButton *lastMusic;
/// 播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playMusic;
/// 下一首的按钮
@property (weak, nonatomic) IBOutlet UIButton *nextMusic;


/// 当前是否正在播放音乐的标志
@property (nonatomic, assign, getter=isPlay) BOOL playingMusic;
/// 自动更新播放进度的文字的定时器
@property (strong, nonatomic) NSTimer *timer;
/// 音乐播放器
@property (strong, nonatomic) AVAudioPlayer *player;
/// 更新歌曲时间
-(void)changeTime;
/// 改变声音大小
-(void)changeVoice;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playingMusic = NO;
    
    //设置声音调节的范围
    [self.sliderView addTarget:self action:@selector(changeVoice) forControlEvents:UIControlEventValueChanged];
    self.sliderView.minimumValue = 1;
    self.sliderView.maximumValue = 10;
    
    //封面后面的黑色图片的圆角
    self.backView.layer.cornerRadius = self.backView.bounds.size.width/2;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    
    //设置封面图片为圆角
    self.coverImageView.layer.cornerRadius = self.coverImageView.bounds.size.width/2;
    self.coverImageView.layer.masksToBounds = YES;
    
    //设置初始的播放进度
    self.progressView.progress = 0;
    
    // 上一首的按钮
    [self.lastMusic setBackgroundImage:[UIImage imageNamed:@"bfzn_lastMusic"] forState:UIControlStateNormal];
    
    // 播放按钮
    [self.playMusic setBackgroundImage:[UIImage imageNamed:@"bfzn_playMusic"] forState:UIControlStateNormal];
    [self.playMusic addTarget:self action:@selector(playMusicBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 下一首的按钮
    [self.nextMusic setBackgroundImage:[UIImage imageNamed:@"bfzn_nextMusic"] forState:UIControlStateNormal];
    
    
    // 音乐播放器
    NSBundle *bundle = [NSBundle mainBundle];
    NSString * path = [bundle pathForResource:@"music" ofType:@"mp3"];
    NSURL *musicURL = [NSURL fileURLWithPath:path];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
    
    //更新播放进度的文字
    [self changeTime];
    
}

//更新时间
-(void)changeTime
{
    //获取音频的总时间
    NSTimeInterval totalTimer = self.player.duration;
    //获取音频的当前时间
    NSTimeInterval currentTime = self.player.currentTime;
    //根据时间比设置进度条的进度
    self.progressView.progress = (currentTime/totalTimer);
    
    //把秒转换成分钟
    int currentM = currentTime/60;
    int currentS = (int)currentTime%60;
    
    int totalM = totalTimer/60;
    int totalS = (int)totalTimer%60;
    
    //把时间显示在lable上
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentM, currentS, totalM, totalS];
    self.progressLabel.text = timeString;
}
//

//改变声音
-(void)changeVoice
{
    self.player.volume = self.sliderView.value;
    
}

//播放按钮的点击方法
-(void)playMusicBtnClick
{
    if (self.isPlay) {
        [self.playMusic setBackgroundImage:[UIImage imageNamed:@"bfzn_playMusic"] forState:UIControlStateNormal];
        self.playingMusic = NO;
        [self.player pause];
        if ([self.timer isValid]) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }else{
        [self.playMusic setBackgroundImage:[UIImage imageNamed:@"bfzn_pauseMusic"] forState:UIControlStateNormal];
        self.playingMusic = YES;
        [self.player play];
        if (self.timer == nil) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
        }
    }
}
@end
