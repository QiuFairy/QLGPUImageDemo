//
//  PhotoWithWatermarkViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/11.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "PhotoWithWatermarkViewController.h"
#import <GPUImage.h>

#import "QLPhotoHelper.h"

@interface PhotoWithWatermarkViewController ()
// 展示图像内容
@property (nonatomic, strong) GPUImageView *imageView;
// 水印图层
@property (nonatomic, strong) UIView *watermarkView;
// 透明度混合滤镜，用来实现添加水印
@property (nonatomic, strong) GPUImageAlphaBlendFilter *alphaBlendFilter;
@end

@implementation PhotoWithWatermarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //获取图片
    UIImage *image = [UIImage imageNamed:@"kawayi.jpg"];
    
    //构造展示view
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    _imageView.center = self.view.center;
    [self.view addSubview:_imageView];
    // 修改视图的大小
    _imageView.frame = [self frameWithAspectRatio:image.size.width / image.size.height];
    
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
    
    //创建GPUImagePicture
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    
    // 创建水印图形
    GPUImageUIElement *uiElement = [[GPUImageUIElement alloc] initWithView:_watermarkView];
    //创建滤镜
    GPUImageFilter *imageFilter = [[GPUImageFilter alloc] init];
    
    [picture addTarget:imageFilter];

    [imageFilter addTarget:_alphaBlendFilter];
    [uiElement addTarget:_alphaBlendFilter];
    
    [_alphaBlendFilter addTarget:_imageView];
    
    //水印处理
    __block GPUImageUIElement *weakElement = uiElement;
    [imageFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [weakElement update];
    }];
    
    //图片处理
    [picture processImageUpToFilter:_alphaBlendFilter withCompletionHandler:^(UIImage *processedImage) {
        
        [QLPhotoHelper ql_saveImage:processedImage albumName:@"YUAN" completionHandle:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
            if (error) {
                [self showAlertVCWithTitle:@"错误" message:@"保存失败"];
            } else {
                [self showAlertVCWithTitle:@"提示" message:@"保存到相册成功"];
            }
        }];
        
    }];
    
//    [picture processImage];
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

@end
