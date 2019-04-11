//
//  CameraVideoWithWatermarkViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/11.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "CameraVideoWithWatermarkViewController.h"

#import <GPUImage.h>

#import "QLPhotoHelper.h"

@interface CameraVideoWithWatermarkViewController ()

@property (nonatomic,strong) GPUImageMovieWriter *movieWriter;
//输入设备
@property (nonatomic,strong) GPUImageVideoCamera *videoCamera;
// 展示图像内容
@property (nonatomic,strong) GPUImageView *imageView;
// 水印图层
@property (nonatomic,strong) UIView *watermarkView;
// 透明度混合滤镜，用来实现添加水印
@property (nonatomic,strong) GPUImageAlphaBlendFilter *alphaBlendFilter;
//输出地址
@property (nonatomic,strong) NSURL *movieURL;

@end

@implementation CameraVideoWithWatermarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    _imageView.center = self.view.center;
    [self.view addSubview:_imageView];
    
    // 创建水印视图
    _watermarkView = [[UIView alloc] initWithFrame:_imageView.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    label.text = @"QiuFairy";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [_watermarkView addSubview:label];
    
    // 创建透明度混合滤镜
    _alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    // 融合的比例，默认就是1.0
    _alphaBlendFilter.mix = 1.0;

    // 调用相机录制视频加水印
    [self cameraAddWartermark];
}
- (void)cameraAddWartermark{
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // 适配视图的大小
    _imageView.frame = [self frameWithAspectRatio:480.0 / 640.0];
    _watermarkView.frame = _imageView.bounds;
    // 创建水印图形
    GPUImageUIElement *uiElement = [[GPUImageUIElement alloc] initWithView:_watermarkView];
    
    GPUImageFilter *videoFilter = [[GPUImageFilter alloc] init];
    [_videoCamera addTarget:videoFilter];
    
    [videoFilter addTarget:_alphaBlendFilter];
    [uiElement addTarget:_alphaBlendFilter];
    [_alphaBlendFilter addTarget:_imageView];
    
    // GPUImageVideoCamera 开始捕获画面展示在 GPUImageView
    [_videoCamera startCameraCapture];
    
    __block GPUImageUIElement *weakElement = uiElement;
    [videoFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [weakElement update];
    }];
    
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake(self.view.bounds.size.width / 2.0 - 30, self.view.bounds.size.height - 80, 60, 60);
    [recordBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [recordBtn setTitle:@"开始" forState:UIControlStateNormal];
    [recordBtn setTitle:@"暂停" forState:UIControlStateSelected];
    [recordBtn addTarget:self action:@selector(recordBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordBtn];
    
}

- (void)recordBtnAction:(UIButton *)sender{
    if (sender.selected) {  // 录像状态
        [_movieWriter finishRecording];
        
        [self writeToPhotoAlbum];
        [_alphaBlendFilter removeTarget:_movieWriter];
    }
    else{   // 没有录像
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mov"];
        unlink([pathToMovie UTF8String]); // 判断路径是否存在，如果存在就删除路径下的文件，否则是没法缓存新的数据的。
        self.movieURL = [NSURL fileURLWithPath:pathToMovie];
        
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(640.0, 480.0)];
        [_movieWriter setHasAudioTrack:YES audioSettings:nil];
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_alphaBlendFilter addTarget:_movieWriter];
        
        [_movieWriter startRecording];
    }
    sender.selected = !sender.selected;
}

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

- (void)dealloc {
    [self.alphaBlendFilter removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
}
@end
