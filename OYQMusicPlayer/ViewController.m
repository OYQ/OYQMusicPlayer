//
//  ViewController.m
//  播放器
//
//  Created by 欧阳铨 on 15/12/18.
//  Copyright © 2015年 欧阳铨. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>
/// 封面图片
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
/// 播放进度
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/// 播放进度的文字
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
/// 播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playMusic;

/// 自动更新播放进度的文字的定时器
@property (strong, nonatomic) NSTimer *timer;
/// 音乐播放器
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化播放器
    [self initPlayer];
    //更新播放进度的文字
    [self changeTime];
    //初始化动画
    [self initAnimatiom];
    //先不要让动画播放
    [self pauseLayer:self.coverImageView.layer];
    
}

/**
 *  初始化播放器
 */
- (void)initPlayer{
    // 音乐播放器
    NSBundle *bundle = [NSBundle mainBundle];
    NSString * path = [bundle pathForResource:@"music" ofType:@"mp3"];
    NSURL *musicURL = [NSURL fileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    //设置初始的声音值
    self.player.volume = 2;
    self.player.delegate = self;
}

/**
 *  更新播放时间的label
 */
- (void)changeTime
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

/**
 *  暂停layer上面的动画
 *
 *  @param layer 需要暂停的layer
 */
- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

/**
 *  继续layer上面的动画
 *
 *  @param layer 需要继续的layer
 */
- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

/**
 *  创建动画
 */
- (void)initAnimatiom{
    //创建一个绕z轴选择的动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //旋转一周
    animation.toValue = @(2*M_PI);
    animation.repeatCount = MAXFLOAT;
    animation.duration = 50.f;
    [self.coverImageView.layer addAnimation:animation forKey:@"rotationAnimation"];
    
}

#pragma mark - Action方法
- (IBAction)sliderView:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.player.volume = slider.value;
}
- (IBAction)playbutton:(id)sender {
    if (self.player.isPlaying) {
        //暂停播放器
        [self.player pause];
        //更换播放button上面的图片
        [self.playMusic setImage:[UIImage imageNamed:@"bfzn_playMusic"] forState:UIControlStateNormal];
        //取消定时器
        if ([self.timer isValid]) {
            [self.timer invalidate];
            self.timer = nil;
        }
        //暂停封面图片的旋转
        CAAnimation * anim = [self.coverImageView.layer animationForKey:@"rotationAnimation"];
        if (anim) {
            //暂停动画
            [self pauseLayer:self.coverImageView.layer];
        }
        
    }else{
        //开始播放器
        [self.player play];
        //更换播放button上面的图片
        [self.playMusic setImage:[UIImage imageNamed:@"bfzn_pauseMusic"] forState:UIControlStateNormal];
        //开始定时器
        if (self.timer == nil) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
        }
        //继续封面图片的旋转(动画可能在播放结束的时候被移除)
        CAAnimation * anim = [self.coverImageView.layer animationForKey:@"rotationAnimation"];
        if (anim == nil) {
            [self initAnimatiom];
        }else{
            [self resumeLayer:self.coverImageView.layer];
        }
        
        
    }
}

# pragma mark - 代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    //更换播放button上面的图片
    [self.playMusic setImage:[UIImage imageNamed:@"bfzn_playMusic"] forState:UIControlStateNormal];
    //取消定时器
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    //停止封面图片的旋转
    CAAnimation * anim = [self.coverImageView.layer animationForKey:@"rotationAnimation"];
    if (anim) {
        //暂停动画
        [self.coverImageView.layer removeAllAnimations];
    }
    [self changeTime];
}

@end
