//
//  VideoWithWatermarkViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/10.
//  Copyright © 2019 qiu. All rights reserved.
//

/*!
 给视频添加文字水印、动态图像水印
 */

/*!
 1、UIView上面有UILabel（文字水印）和UIImageView（图片水印），再通过GPUImageUIElement把UIView对象转换成纹理对象，进入响应链；
 2、视频文件的图像数据通过GPUImageMovie进入响应链；
 3、GPUImageDissolveBlendFilter合并水印图像和视频，把数据传给响应链的终点GPUImageView以显示到UI和GPUImageMovieWriter以写入临时文件；
 4、视频文件的音频数据通过GPUImageMovie传给GPUImageMovieWriter以写入临时文件；
 5、最后临时文件通过QLPhotoHelper写入系统库。
 */

/*!
 具体细节
 一、GPUImageUIElement
    GPUImageUIElement继承GPUImageOutput类，作为响应链的源头。通过CoreGraphics把UIView渲染到图像，并通过glTexImage2D绑定到outputFramebuffer指定的纹理，最后通知targets纹理就绪。
 二、GPUImageOutput和GPUImageFilter
    本次demo主要用到了frameProcessingCompletionBlock属性，当GPUImageFilter渲染完纹理后，会调用frameProcessingCompletionBlock回调。
 三、响应链解析
     1、当GPUImageMovie的纹理就绪时，会通知GPUImageFilter处理图像；
     2、GPUImageFilter会调用frameProcessingCompletionBlock回调；
     3、GPUImageUIElement在回调中渲染图像，纹理就绪后通知
     GPUImageDissolveBlendFilter；
     4、frameProcessingCompletionBlock回调结束后，通知
     GPUImageDissolveBlendFilter纹理就绪；
     5、GPUImageDissolveBlendFilter收到两个纹理后开始渲染，纹理就绪后通知GPUImageMovieWriter
 */

/*!
 GPUImageAlphaBlendFilter 与 GPUImageDissolveBlendFilter
 
 从名称翻译就是透明度混合滤镜效果。我们的实现原理就是把水印视图 _watermarkView 和视频中的每一帧图片作为输入源经过 GPUImageAlphaBlendFilter 处理后生成新的图片作为播放的帧图片。
 说明：有很多种混合效果可以用，在网上搜的很多是用的 GPUImageDissolveBlendFilter 处理的，用法跟 GPUImageAlphaBlendFilter一样，经自己测试发现，GPUImageDissolveBlendFilter 处理的水印会影响原视频的亮度，使视频变暗。
 
 */

#import "VideoWithWatermarkViewController.h"

#import <GPUImage.h>

#import "QLPhotoHelper.h"

@interface VideoWithWatermarkViewController ()

@property (nonatomic,strong) GPUImageMovie * movieFile;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> * filter;

@property (nonatomic,strong) UILabel * progressLabel;
@property (nonatomic,strong) UIButton * startBtn;
@property (nonatomic,strong) NSURL * movieURL;

@property (nonatomic,strong) GPUImageMovieWriter * movieWriter;
@property (nonatomic,strong) NSTimer * timer;

@end

@implementation VideoWithWatermarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.startBtn];
    
    // 要转换的视频
    NSURL *pathUrl = [[NSBundle mainBundle] URLForResource:@"ceshilive" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:pathUrl];
    
    //源
    _movieFile = [[GPUImageMovie alloc]initWithAsset:asset];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = NO;
    
    // 滤镜 合成水印
    _filter = [[GPUImageDissolveBlendFilter alloc] init];
    [(GPUImageDissolveBlendFilter *)_filter setMix:0.5];
    
    // 显示
    GPUImageView * filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(50, 250, 300, 400)];
    [self.view addSubview: filterView];
    
    // 水印
    CGSize size = self.view.bounds.size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    label.text = @"我是水印";
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor redColor];
    [label sizeToFit];
    UIImage *image = [UIImage imageNamed:@"kawayi.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(0, 0, 100, 100);
    imageView.center = CGPointMake(subView.bounds.size.width / 2, subView.bounds.size.height / 2);
    [subView addSubview:imageView];
    [subView addSubview:label];
    
    //
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    
    // 设置输出路径
    NSString * pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    // - 如果文件已存在
    unlink([pathToMovie UTF8String]);
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    // 输出 后面的size可改
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480.0, 640.0)];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [_movieFile addTarget:progressFilter];
    [progressFilter addTarget:_filter];
    [uielement addTarget:_filter];
    
    _movieWriter.shouldPassthroughAudio = YES;
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
        _movieFile.audioEncodingTarget = _movieWriter;
    } else {
        //no audio
        _movieFile.audioEncodingTarget = nil;
    }
    
    [_filter addTarget:filterView];
    [_filter addTarget:_movieWriter];
    
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect frame = imageView.frame;
            frame.origin.x += 1;
            frame.origin.y += 1;
            imageView.frame = frame;
            //第8秒之后隐藏imageView
            if (time.value/time.timescale>=8.0) {
                [imageView removeFromSuperview];
            }
        });
        
        [uielement updateWithTimestamp:time];
    }];
    
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
