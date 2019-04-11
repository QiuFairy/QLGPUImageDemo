# QLGPUImageDemo

> 主要是研究GPUImage框架的demo

## 一、介绍
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;` GPUImage `是一个基于` OpenGL ES 2.0 `的开源的图像处理库，作者是[Brad Larson](https://link.jianshu.com/?t=https://github.com/BradLarson)。` GPUImage `将` OpenGL ES `封装为简洁的` Objective-C `或` Swift `接口，可以用来给图像、实时相机视频、电影等添加滤镜。


- GPUImage是采用链式方法来处理画面，通过`addTarget`方法添加对象到链中，处理完一个target，就会把上一个环节处理好的图像数据传递到下一个target处理，成为GPUImage处理链。

- GPUImage的四大输入基础类，都可以作为响应链的起点，这些基础类会把图像作为纹理传给OpenGL ES处理，然后把纹理传递给响应链的下一个target对象。

- GPUImage的处理环节

`source(视频，图片源)->filter(滤镜)->final target(处理后的视频、图片)`

### - source:

	- GPUImageVideoCamera 摄像头-用于实时拍摄视频

	- GPUImageStillCamera 摄像头-用于实时拍摄照片

	- GPUImagePicture 用于处理已经拍摄好的图片

	- GPUImageMovie 用于处理已经拍摄好的视频

### - filter

	- GPUImageFilter:就是用来接收源图像，通过自定义的顶点，片元着色器来渲染新的图像，并在绘制完成后通知响应链的下一个对象。

	- GPUImageFramebuffer:就是用来管理纹理缓存的格式与读写帧缓存的buffer。


## 二、使用
### 1.导入GPUImage两种方式
#### a.使用 ` cocopods `导入
```
platform :ios, '9.0'
target 'QLGPUImageDemo' do
pod 'GPUImage'
end
```
>注：给项目添加cocopods等操作在此不做多余赘述

#### b.手动导入
请自行下载导入：[GPUImage下载地址](https://github.com/BradLarson/GPUImage)

## 三、概念解析

` output `为输出源

` intput `为输入源

` filter `为滤镜
 
> [点击查看滤镜，添加了部分注释](https://github.com/qiufairy/QLGPUImageDemo/blob/master/GPUImageFilter.md) 

## 四、主要实现功能

- [x] GPUImageMovie基本用法
- [x] 相机录像添加实时滤镜,
- [x] 相册内视频添加滤镜处理,
- [x] 相机拍照添加实时滤镜,
- [x] 给已有的图片/照片添加滤镜,
- [x] 混合滤镜 (GPUImageFilterGroup/GPUImageFilterPipeline),
- [x] 实时视频添加水印,
- [x] 本地视频添加水印 (采用 GPUImageDissolveBlendFilter),
- [x] 本地视频添加水印2 (采用 GPUImageAlphaBlendFilter),
- [x] 本地图片添加水印,



----
# BY -- QiuFairy