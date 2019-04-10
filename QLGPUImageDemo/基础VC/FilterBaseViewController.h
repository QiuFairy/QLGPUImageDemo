//
//  FilterBaseViewController.h
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterBaseViewController : UIViewController
- (void)clickedControlButton:(void(^)(void))start end:(void(^)(void))end;

- (void)showAlertVCWithTitle:(NSString *)title message:(NSString *)massage;
@end

NS_ASSUME_NONNULL_END
