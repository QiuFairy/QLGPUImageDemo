//
//  FixFilterViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "FixFilterViewController.h"

#import <GPUImage.h>

@interface FixFilterViewController ()

@end

@implementation FixFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *inputImage = [UIImage imageNamed:@"kawayi.jpg"];
    // 显示
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    imageView.image = inputImage;
    [self.view addSubview:imageView];
    
    
    /*!
     使用GPUImageFilterGroup混合滤镜的步骤如下：
     1）初始化要加载滤镜的GPUImagePicture对象initWithImage: smoothlyScaleOutput:
     2）初始化多个要被使用的单独的GPUImageFilter滤镜
     3）初始化GPUImageFilterGroup对象
     4）将FilterGroup加在之前初始化过的GPUImagePicture上
     5）将多个滤镜加在FilterGroup中(此处切记一定要设置好设置FilterGroup的初始滤镜和末尾滤镜)
     6）之前初始化过的GPUImagePicture处理图片 processImage
     7）拿到处理后的UIImage对象图片imageFromCurrentFramebuffer
     
     */
    [self filterGroup];
    
    
    /*!
     使用GPUImageFilterPipeline混合滤镜的步骤如下：
     1）初始化要加载滤镜的GPUImagePicture对象initWithImage: smoothlyScaleOutput:
     2）初始化GPUImageView并加在自己的UIImageView对象上
     3）初始化多个要被使用的单独的GPUImageFilter滤镜
     4）把多个单独的滤镜对象放到数组中
     5）初始化创建GPUImageFilterPipeline对象initWithOrderedFilters: input: output:
     6）之前初始化过的GPUImagePicture处理图片 processImage
     7）拿到处理后的UIImage对象图片currentFilteredFrame
     
     */
    [self filterPipeLine];
    
    
}
#pragma mark - 两种组合渲染之一 GPUImageFilterGroup
- (void)filterGroup{
    // 原图
    UIImage *inputImage = [UIImage imageNamed:@"kawayi.jpg"];
    
    GPUImagePicture * pic = [[GPUImagePicture alloc] initWithImage:inputImage];
    
    // 显示
    GPUImageView * imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(100, 320, 200, 200)];
    [self.view addSubview: imageView];
    
    // 混合滤镜关键
    GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];
    
    // 添加 filter
    /**
     原理：
     1. filterGroup(addFilter) 滤镜组添加每个滤镜
     2. 按添加顺序（可自行调整）前一个filter(addTarget) 添加后一个filter
     3. filterGroup.initialFilters = @[第一个filter]];
     4. filterGroup.terminalFilter = 最后一个filter;
     */
    GPUImageColorInvertFilter *filter1 = [[GPUImageColorInvertFilter alloc] init];
    
    //伽马线滤镜
    GPUImageGammaFilter *filter2 = [[GPUImageGammaFilter alloc]init];
    filter2.gamma = 0.2;
    
    //曝光度滤镜
    GPUImageExposureFilter *filter3 = [[GPUImageExposureFilter alloc]init];
    filter3.exposure = -1.0;
    
    //怀旧
    GPUImageSepiaFilter *filter4 = [[GPUImageSepiaFilter alloc] init];
    
    
    // 所有的filter添加到filterGroup上
    [filterGroup addFilter:filter1];
    [filterGroup addFilter:filter2];
    [filterGroup addFilter:filter3];
    [filterGroup addFilter:filter4];
    
    // 注意下面的add ~ (感觉就是一个摞一个.)
    [filter1 addTarget:filter2];
    [filter2 addTarget:filter3];
    [filter3 addTarget:filter4];
    
    filterGroup.initialFilters = @[filter1];
    filterGroup.terminalFilter = filter4;
    
    [pic removeAllTargets];
    [pic addTarget:filterGroup];
    [filterGroup addTarget:imageView];
    
    [pic processImage];
    
    [filterGroup useNextFrameForImageCapture];
    
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        // 保存到相册
    //        UIImage * outImage = [filterGroup imageFromCurrentFramebuffer];
    //        if (outImage) {
    //            UIImageWriteToSavedPhotosAlbum(outImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //        }
    //    });
}


#pragma mark - 两种组合渲染之二 GPUImageFilterPipeline
- (void)filterPipeLine{
    
    // 原图
    UIImage *inputImage = [UIImage imageNamed:@"kawayi.jpg"];
    
    GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    
    // 显示
    GPUImageView * imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(100, 540, 200, 200)];
    [self.view addSubview: imageView];
    
    // 使用 GPUImageFilterPipeline 添加组合滤镜
    GPUImageColorInvertFilter *filter1 = [[GPUImageColorInvertFilter alloc] init];
    //伽马线滤镜
    GPUImageGammaFilter *filter2 = [[GPUImageGammaFilter alloc]init];
    filter2.gamma = 0.2;
    //曝光度滤镜
    GPUImageExposureFilter *filter3 = [[GPUImageExposureFilter alloc]init];
    filter3.exposure = -1.0;
    //怀旧
    GPUImageSepiaFilter *filter4 = [[GPUImageSepiaFilter alloc] init];
    
    
    NSMutableArray *arrayTemp = [NSMutableArray array];
    
    [arrayTemp addObject:filter1];
    [arrayTemp addObject:filter2];
    [arrayTemp addObject:filter3];
    [arrayTemp addObject:filter4];
    
    /**
     *  @author ql 2019-04-09 11:45
     *
     *  初始化 pipeline
     *
     *  filters 滤镜数组
     *  input   被渲染的输入源，可以是GPUImagePicture、GPUImageVideoCamera等
     *  output  渲染后的输出容器，一般是显示的视图
     *
     *  GPUImageFilterPipeline的对象
     */
    GPUImageFilterPipeline *pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:arrayTemp input:picture output:imageView];
    
    // 处理图片
    [picture processImage];
    [filter1 useNextFrameForImageCapture]; // 这个filter 可以是filter1 filter2等
    
    
    
    //    // 保存到系统相册
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        // 保存到相册
    //        // 输出处理后的图片
    //        UIImage *outputImage = [pipeline currentFilteredFrame];
    //        if (outputImage) {
    //            UIImageWriteToSavedPhotosAlbum(outputImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //        }
    //    });
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"保存处理后的图片到相册" message:@"保存成功" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
