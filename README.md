# QLGPUImageDemo
--
> 主要是研究GPUImage框架的demo

## 一、介绍
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;` GPUImage `是一个基于` OpenGL ES 2.0 `的开源的图像处理库，作者是[Brad Larson](https://link.jianshu.com/?t=https://github.com/BradLarson)。` GPUImage `将` OpenGL ES `封装为简洁的` Objective-C `或` Swift `接口，可以用来给图像、实时相机视频、电影等添加滤镜。

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

- [x] 相机录像添加实时滤镜,
- [x] 相册内视频添加滤镜处理,
- [x] 相机拍照添加实时滤镜,
- [x] 给已有的图片/照片添加滤镜,
- [x] 混合滤镜 (GPUImageFilterGroup/GPUImageFilterPipeline)



----
# BY -- QiuFairy