//
//  PhotoFilterViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "PhotoFilterViewController.h"
#import <GPUImage.h>

#import "QLPhotoHelper.h"

@interface PhotoFilterViewController ()
@property (nonatomic,strong) GPUImageStillCamera * stillCamera;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> * filter;
@end

@implementation PhotoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //相机
    _stillCamera = [[GPUImageStillCamera alloc] init];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // 随便一个滤镜
    _filter = [[GPUImageSketchFilter alloc] init];
    [_stillCamera addTarget:_filter];
    
    //显示
    GPUImageView * filterView = [[GPUImageView alloc] init];
    self.view = filterView;
    
    [_filter addTarget:filterView];
    [_stillCamera startCameraCapture];
}

- (void)clickedControlButton:(void (^)(void))start end:(void (^)(void))end {
    start = ^(){
        [self takePhoto];
    };
    
    [super clickedControlButton:start end:nil];
}

- (void)takePhoto {
    [_stillCamera capturePhotoAsJPEGProcessedUpToFilter:_filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        
        UIImage * chooseImage = [UIImage imageWithData:processedJPEG];
        if (chooseImage) {
            UIImageWriteToSavedPhotosAlbum(chooseImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }];
}

- (void)takePhotoTwo{
    [_stillCamera capturePhotoAsJPEGProcessedUpToFilter:_filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        
        UIImage * chooseImage = [UIImage imageWithData:processedJPEG];
        if (chooseImage) {
            [QLPhotoHelper ql_saveImage:chooseImage albumName:@"YUAN" completionHandle:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
                if (error) {
                    [self showAlertVCWithTitle:@"错误" message:@"保存失败"];
                } else {
                    [self showAlertVCWithTitle:@"提示" message:@"保存到相册成功"];
                }
            }];
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [self showAlertVCWithTitle:@"提示" message:@"保存到相册成功"];
    }
}
@end
