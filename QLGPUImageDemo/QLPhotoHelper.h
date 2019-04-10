//
//  QLPhotoHelper.h
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QLPhotoHelper : NSObject
+ (void)ql_saveImage:(UIImage *)image albumName:(NSString *)albumName completionHandle:(void (^)(NSError *error, NSString *msg))completionHandler;

+ (void)ql_saveVideo:(NSURL *)url albumName:(NSString *)albumName completionHandle:(void (^)(NSError *error, NSString *msg))completionHandler;

@end

NS_ASSUME_NONNULL_END
