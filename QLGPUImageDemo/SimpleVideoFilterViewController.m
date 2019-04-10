//
//  SimpleVideoFilterViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "SimpleVideoFilterViewController.h"
#import <GPUImage.h>

#import "QLPhotoHelper.h"

@interface SimpleVideoFilterViewController ()

@property (nonatomic,strong) GPUImageVideoCamera * videoCamera;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> * filter;

@property (nonatomic,strong) GPUImageMovieWriter * movieWriter;
@property (nonatomic,strong) NSURL * movieURL;

@end

@implementation SimpleVideoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置摄像头
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //镜像策略，这里这样设置是最自然的。跟系统相机默认一样。
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    // 显示
    GPUImageView * filterView = [[GPUImageView alloc] init];
    self.view = filterView;
    
    // 随意创建了一个滤镜 (好像是有点泛黄色的效果)
    _filter = [[GPUImageSepiaFilter alloc] init];
    [_videoCamera addTarget:_filter];
    
    //存储路径
    NSString * pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    // - 如果文件已存在,AVAssetWriter不允许直接写进新的帧,所以会删掉老的视频文件
    unlink([pathToMovie UTF8String]);
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    // 设置writer 使用它进行存储
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480.0, 640.0)];
    _movieWriter.encodingLiveVideo = YES;

    [_filter addTarget:_movieWriter];
    
    [_filter addTarget:filterView];
    // 开始
    [_videoCamera startCameraCapture];
}

// 开始录制
- (void)clickedControlButton:(void (^)(void))start end:(void (^)(void))end {
    start = ^(){
        NSLog(@"开始录制 -");
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        [self.movieWriter startRecording];
        
    };
    
    end = ^(){
        [self.filter removeTarget:self.movieWriter];
        self.videoCamera.audioEncodingTarget = nil;
        [self.movieWriter finishRecording];
        // 写入相册
        [self writeToPhotoAlbum];
    };
    
    [super clickedControlButton:start end:end];
    
}

///////////////////////////////////////////////////////////////////

- (void)writeToPhotoAlbum {
    [QLPhotoHelper ql_saveVideo:self.movieURL albumName:[NSString stringWithFormat:@"%@",self.movieURL] completionHandle:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showAlertVCWithTitle:@"错误" message:@"保存失败"];
                
                
            } else {
                [self showAlertVCWithTitle:@"提示" message:@"保存到相册成功"];
            }
        });
    }];
}

- (void)dealloc {
    
    [self.filter removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
}

@end
