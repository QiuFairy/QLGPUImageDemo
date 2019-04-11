//
//  GPUImageMovieViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/11.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "GPUImageMovieViewController.h"

#import <GPUImage.h>
#import <Photos/Photos.h>

@interface GPUImageMovieViewController ()<GPUImageMovieDelegate>{
    GPUImageMovie *_movie;
    GPUImageView *_imageView;       // 展示图像内容

    AVPlayer *_player;              // 用来播放视频声音的
}

@end

@implementation GPUImageMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    _imageView.center = self.view.center;
    [self.view addSubview:_imageView];

    [self movieUsage];
}

- (void)movieUsage{
    // GPUImageMovie 使用方法，GPUImageMovie 读取的视频显示在view上是没有声音的，需要添加AVPlayer对象播放声音
    NSURL *movieUrl = [[NSBundle mainBundle] URLForResource:@"ceshilive" withExtension:@"mp4"];
    
    // 获取视频的尺寸
//    AVAsset *fileas = [AVAsset assetWithURL:movieUrl];
//    CGSize movieSize = fileas.naturalSize;
    
    AVURLAsset  *asset = [AVURLAsset assetWithURL:movieUrl];
    NSArray *array = asset.tracks;
    CGSize movieSize = CGSizeZero;
    for(AVAssetTrack  *track in array){
        if([track.mediaType isEqualToString:AVMediaTypeVideo]){
            movieSize = track.naturalSize;
        }
    }
    // 适配视图的大小
    _imageView.frame = [self frameWithAspectRatio:movieSize.width / movieSize.height];
    
    //没有声音使用此方法
//    _movie = [[GPUImageMovie alloc] initWithURL:movieUrl];
    
    //part 2 播放声音使用此种方法
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:movieUrl];
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    _movie = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    // 按视频真实帧率播放
    _movie.playAtActualSpeed = YES;
    // 重复播放
    _movie.shouldRepeat = YES;
    // 是否在控制台输出当前帧时间
    _movie.runBenchmark = YES;
    _movie.delegate = self;
    
    [_movie addTarget:_imageView];
    
    // 开始处理视频
    [_movie startProcessing];
    
    //part 2
    // play 放在 startProcessing 之后
    [_player play];
}

// 监控 GPUImageMovie 播放完成状态，如果 shouldRepeat 设为 YES 则不会走这里
- (void)didCompletePlayingMovie{
    NSLog(@"视频播放完成");
}

// 根据画面的宽高比，适配展示画面的视图
- (CGRect)frameWithAspectRatio:(CGFloat)ratio{
    
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.width;
    if (ratio > 1) {
        h = w / ratio;
    }
    else{
        w = h * ratio;
    }
    CGRect frame = CGRectMake(self.view.center.x - w / 2.0, self.view.center.y - h / 2.0, w, h);
    
    return frame;
}
@end
