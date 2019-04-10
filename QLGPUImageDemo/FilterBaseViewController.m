//
//  FilterBaseViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "FilterBaseViewController.h"

@interface FilterBaseViewController ()
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@end

@implementation FilterBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"开始" style:UIBarButtonItemStylePlain target:self action:@selector(clickedControlButton:end:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.rightItem = rightItem;
}

- (void)clickedControlButton:(void(^)(void))start end:(void(^)(void))end {
    if ([self.rightItem.title isEqualToString:@"开始"]) {
        NSLog(@"点击开始 ---");
    
        self.rightItem.title = @"结束";
        if (start) {
            start();
        }
    }
    else {
        NSLog(@"点击结束 ---");
        self.rightItem.title = @"开始";
        if (end) {
            end();
        }
    }
}

- (void)showAlertVCWithTitle:(NSString *)title message:(NSString *)massage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:massage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
