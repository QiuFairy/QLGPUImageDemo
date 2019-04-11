//
//  LocalVideo2WithWatermarkViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/11.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "LocalVideo2WithWatermarkViewController.h"

#import <GPUImage.h>
#import "QLPhotoHelper.h"

@interface LocalVideo2WithWatermarkViewController ()
@property (nonatomic,strong) GPUImageMovie *movie;
@property (nonatomic,strong) GPUImageMovieWriter *movieWriter;

// 展示图像内容
@property (nonatomic,strong) GPUImageView *imageView;
// 水印图层
@property (nonatomic,strong) UIView *watermarkView;
// 透明度混合滤镜，用来实现添加水印
@property (nonatomic,strong) GPUImageAlphaBlendFilter *alphaBlendFilter;
//输出地址
@property (nonatomic,strong) NSURL *movieURL;

@end

@implementation LocalVideo2WithWatermarkViewController

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
    
    // 读取本地资源-->加水印-->保存到本地
    [self readLocalResourceAddWatermark];
    
}

- (void)readLocalResourceAddWatermark {
    
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
    _watermarkView.frame = _imageView.bounds;
    
    _movie = [[GPUImageMovie alloc] initWithURL:movieUrl];
    _movie.playAtActualSpeed = YES;
    _movie.shouldRepeat = NO;
    _movie.runBenchmark = YES;
    
    // 创建水印图形
    GPUImageUIElement *uiElement = [[GPUImageUIElement alloc] initWithView:_watermarkView];
    
    GPUImageFilter *videoFilter = [[GPUImageFilter alloc] init];
    [_movie addTarget:videoFilter];
    [videoFilter addTarget:_alphaBlendFilter];
    [uiElement addTarget:_alphaBlendFilter];
    [_alphaBlendFilter addTarget:_imageView];
    
    
    
    __block GPUImageUIElement *weakElement = uiElement;
    [videoFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [weakElement update];
    }];
    
    // GPUImageMovieWriter 视频编码
    NSString * pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // 判断路径是否存在，如果存在就删除路径下的文件，否则是没法缓存新的数据的。
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:movieSize];
    _movieWriter.shouldPassthroughAudio = YES;
    [_alphaBlendFilter addTarget:_movieWriter];
    
    // 不要设置这两句，会导致内存不断升高
    //    _movieWriter.hasAudioTrack = NO;
    //    _movie.audioEncodingTarget = _movieWriter;
    
    // 允许使用 GPUImageMovieWriter 进行音视频同步编码
    [_movie enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [_movieWriter startRecording];
    [_movie startProcessing];
    
    // 写入完成后可保存到相册
    __weak typeof(self) weakself = self;
    [_movieWriter setCompletionBlock:^{
        __strong typeof (weakself) strongSelf = weakself;
        
        [strongSelf->_alphaBlendFilter removeTarget:strongSelf->_movieWriter];
        [strongSelf->_movieWriter finishRecording];
        
        // 异步写入相册
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{
            [strongSelf writeToPhotoAlbum];
        });
    }];
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
    
    [_movie endProcessing];
    [_alphaBlendFilter removeTarget:_movieWriter];
    [_movieWriter finishRecording];
    _movie = nil;
    _movieWriter = nil;
    _alphaBlendFilter = nil;
}

@end
