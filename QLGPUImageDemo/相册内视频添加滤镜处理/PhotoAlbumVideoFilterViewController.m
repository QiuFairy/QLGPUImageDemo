//
//  PhotoAlbumVideoFilterViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "PhotoAlbumVideoFilterViewController.h"
#import <GPUImage.h>

#import "QLPhotoHelper.h"
@interface PhotoAlbumVideoFilterViewController ()

@property (nonatomic,strong) GPUImageMovie * movieFile;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> * filter;

@property (nonatomic,strong) UILabel * progressLabel;
@property (nonatomic,strong) UIButton * startBtn;
@property (nonatomic,strong) NSURL * movieURL;

@property (nonatomic,strong) GPUImageMovieWriter * movieWriter;
@property (nonatomic,strong) NSTimer * timer;

@end

@implementation PhotoAlbumVideoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.startBtn];
    
    // 要转换的视频
    NSURL *pathUrl = [[NSBundle mainBundle] URLForResource:@"ceshilive" withExtension:@"mp4"];
    
    AVAsset *asset = [AVAsset assetWithURL:pathUrl];
    
//    _movieFile = [[GPUImageMovie alloc] initWithURL:pathUrl];
    _movieFile = [[GPUImageMovie alloc]initWithAsset:asset];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = NO;
    
    // 随意创建了一个滤镜 (好像是有点泛黄色的效果)
    _filter = [[GPUImageSepiaFilter alloc] init];
    [_movieFile addTarget:_filter];
    
    // 显示
    GPUImageView * filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(50, 250, 300, 400)];
    [self.view addSubview: filterView];
    [_filter addTarget:filterView];
    
    
    // 设置输出路径
    NSString * pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    // - 如果文件已存在,AVAssetWriter不允许直接写进新的帧,所以会删掉老的视频文件
    unlink([pathToMovie UTF8String]);
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    
    // 输出 后面的size可改 ~ 现在来说480*640有点太差劲了
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480.0, 640.0)];
    
    [_filter addTarget:_movieWriter];
    _movieWriter.shouldPassthroughAudio = YES;
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
        _movieFile.audioEncodingTarget = _movieWriter;
    } else {//no audio
        _movieFile.audioEncodingTarget = nil;
    }
    
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    //保存相册
    __weak typeof(self) weakself = self;
    [_movieWriter setCompletionBlock:^{
        __strong typeof (weakself) strongSelf = weakself;
        [strongSelf.filter removeTarget:strongSelf.movieWriter];
        [strongSelf.movieWriter finishRecording];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.timer invalidate];
            strongSelf.progressLabel.text = @"完成 !";
        });
    
        
        // 异步写入相册
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{
           [strongSelf writeToPhotoAlbum];
        });
        
    }];
}

- (void)retrievingProgress {
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", (self.movieFile.progress * 100)];
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 150, 60)];
        _progressLabel.text = @"进度:0%";
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = [UIColor blackColor];
    }
    return _progressLabel;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 180, 150, 60)];
        [_startBtn setTitle:@"开  始" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(clickStartBtn) forControlEvents:UIControlEventTouchUpInside];
        [_startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _startBtn;
}

- (void)clickStartBtn {
    if (![self.progressLabel.text isEqualToString:@"进度:0%"]) {
        return;
    }
    
    // 开始转换
    [self.movieWriter startRecording];
    [self.movieFile startProcessing];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                  target:self
                                                selector:@selector(retrievingProgress)
                                                userInfo:nil
                                                 repeats:YES];
}

///////////////////////////////////////////////////////////////////
- (void)writeToPhotoAlbum {
    [QLPhotoHelper ql_saveVideo:self.movieURL albumName:[NSString stringWithFormat:@"qiu"] completionHandle:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showAlertVCWithTitle:@"错误" message:@"保存失败"];
            } else {
                [self showAlertVCWithTitle:@"提示" message:@"保存到相册成功"];
            }
        });
    }];
}
- (void)showAlertVCWithTitle:(NSString *)title message:(NSString *)massage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:massage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
}

- (void)dealloc {
    
    [_movieFile endProcessing];
    [_filter removeTarget:_movieWriter];
    [_movieWriter finishRecording];
    _movieFile = nil;
    _movieWriter = nil;
    _filter = nil;
    _progressLabel = nil;
}
@end
