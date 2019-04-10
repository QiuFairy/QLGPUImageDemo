//
//  ImageFilterViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "ImageFilterViewController.h"
#import <GPUImage.h>
@interface ImageFilterViewController ()
@property (nonatomic,strong) GPUImagePicture * sourcePicture;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *sepiaFilter;

@property (nonatomic,strong) UIImage *inputImage;
@end

@implementation ImageFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 原图
    UIImage *inputImage = [UIImage imageNamed:@"kawayi.jpg"];
    self.inputImage = inputImage;
    // 生成GPUImagePicture
    _sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    
    // 如果要显示话,得创建一个GPUImageView来进行显示
    GPUImageView * imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 400)];
    [self.view addSubview: imageView];
    
    // 随便用一个滤镜 （上下虚化）
    _sepiaFilter = [[GPUImageTiltShiftFilter alloc] init];
    //滤镜尺寸
    [_sepiaFilter forceProcessingAtSize:imageView.sizeInPixels];
    
    // 个人理解,这个add其实就是把_sourcePicture给_sepiaFilter来处理
    [_sourcePicture addTarget:_sepiaFilter];
    // 用这个imageView来显示_sepiaFilter处理的效果
    [_sepiaFilter addTarget:imageView];
    
    // 开始!
    [_sourcePicture processImage];
    
}
- (void)clickedControlButton:(void (^)(void))start end:(void (^)(void))end {
    start = ^(){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 保存到相册
            UIImage *keepImage = [self.sepiaFilter imageByFilteringImage:self.inputImage];
            if (keepImage) {
                UIImageWriteToSavedPhotosAlbum(keepImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        });
    };
    
    [super clickedControlButton:start end:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [self showAlertVCWithTitle:@"提示" message:@"保存到相册成功"];
    }
}


@end
