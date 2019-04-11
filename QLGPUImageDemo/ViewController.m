//
//  ViewController.m
//  QLGPUImageDemo
//
//  Created by qiu on 2019/4/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "ViewController.h"
#define KWidth [UIScreen mainScreen].bounds.size.width
#define KHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * rootTableView;
@property (nonatomic,strong) NSArray * dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GPUImage";
    
    [self.view addSubview:self.rootTableView];
    
    
}
- (UITableView *)rootTableView {
    if (!_rootTableView) {
        _rootTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, KWidth, KHeight-80) style:UITableViewStylePlain];
        _rootTableView.delegate = self;
        _rootTableView.dataSource = self;
    }
    return _rootTableView;
}

-(NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[@"GPUImageMovie基本用法",
                     @"相机录像添加实时滤镜",
                     @"相册内视频添加滤镜处理",
                     @"相机拍照添加实时滤镜",
                     @"给已有的图片/照片添加滤镜",
                     @"混合滤镜",
                     @"实时视频添加水印",
                     @"本地视频添加水印",
                     @"本地视频添加水印2",
                     @"给本地图片添加水印"].copy;
    }
    return _dataArr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"cellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * vcStr = @"";
    switch (indexPath.row) {
        case 0:
            //GPUImageMovie基本用法
            vcStr = @"GPUImageMovieViewController";
            break;
        case 1:
            //相机录像添加实时滤镜
            vcStr = @"SimpleVideoFilterViewController";
            break;
        case 2:
            //相册内视频添加滤镜处理
            vcStr = @"PhotoAlbumVideoFilterViewController";
            break;
        case 3:
            //相机拍照添加实时滤镜
            vcStr = @"PhotoFilterViewController";
            break;
        case 4:
            //给已有的图片/照片添加滤镜
            vcStr = @"ImageFilterViewController";
            break;
        case 5:
            //混合滤镜
            vcStr = @"FixFilterViewController";
            break;
        case 6:
            //实时视频添加水印
            vcStr = @"CameraVideoWithWatermarkViewController";
            break;
        case 7:
            //本地视频添加水印
            vcStr = @"VideoWithWatermarkViewController";
            break;
        case 8:
            //本地视频添加水印2
            vcStr = @"LocalVideo2WithWatermarkViewController";
            break;
        case 9:
            //本地图片添加水印
            vcStr = @"PhotoWithWatermarkViewController";
            break;
        default:
            break;
    }
    
    UIViewController* vc = [self stringChangeToClass:vcStr];
    if (vc) {
        vc.navigationItem.title = vcStr;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (UIViewController*)stringChangeToClass:(NSString *)str {
    id vc = [[NSClassFromString(str) alloc]init];
    if ([vc isKindOfClass:[UIViewController class]]) {
        return vc;
    }
    return nil;
}

@end
