//
//  QLPhotoHelper.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "QLPhotoHelper.h"
#import <Photos/Photos.h>

@implementation QLPhotoHelper
+ (void)ql_saveImage:(UIImage *)image albumName:(NSString *)albumName completionHandle:(void (^)(NSError *error, NSString *msg))completionHandler {
    // 1. 获取照片库对象
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    
    // 假如外面需要这个 localIdentifier ，可以通过block传出去
    __block NSString *localIdentifier = @"";
    
    // 2. 调用changeblock
    [library performChanges:^{
        
        // 2.1 创建一个相册变动请求
        PHAssetCollectionChangeRequest *collectionRequest = [self getCurrentPhotoCollectionWithAlbumName:albumName];
        
        // 2.2 根据传入的照片，创建照片变动请求
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        // 2.3 创建一个占位对象
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        localIdentifier = placeholder.localIdentifier;
        
        // 2.4 将占位对象添加到相册请求中
        [collectionRequest addAssets:@[placeholder]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"保存照片出错>>>%@", [error description]);
            completionHandler(error, nil);
        } else {
            completionHandler(nil, localIdentifier);
        }
    }];
}

+ (void)ql_saveVideo:(NSURL *)url albumName:(NSString *)albumName completionHandle:(void (^)(NSError *error, NSString *msg))completionHandler{
    // 1. 获取照片库对象
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    
    // 假如外面需要这个 localIdentifier ，可以通过block传出去
    __block NSString *localIdentifier = @"";
    
    // 2. 调用changeblock
    [library performChanges:^{
        
        // 2.1 创建一个相册变动请求
        PHAssetCollectionChangeRequest *collectionRequest = [self getCurrentPhotoCollectionWithAlbumName:albumName];
        
        // 2.2 根据传入的照片，创建照片变动请求
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        
        // 2.3 创建一个占位对象
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        localIdentifier = placeholder.localIdentifier;
        
        // 2.4 将占位对象添加到相册请求中
        [collectionRequest addAssets:@[placeholder]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"保存视频出错>>>%@", [error description]);
            completionHandler(error, nil);
        } else {
            completionHandler(nil, localIdentifier);
        }
    }];
}

+ (PHAssetCollectionChangeRequest *)getCurrentPhotoCollectionWithAlbumName:(NSString *)albumName {
    // 1. 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2. 遍历搜索集合并取出对应的相册，返回当前的相册changeRequest
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle containsString:albumName]) {
            PHAssetCollectionChangeRequest *collectionRuquest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            return collectionRuquest;
        }
    }
    
    // 3. 如果不存在，创建一个名字为albumName的相册changeRequest
    PHAssetCollectionChangeRequest *collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
    return collectionRequest;
}
@end
