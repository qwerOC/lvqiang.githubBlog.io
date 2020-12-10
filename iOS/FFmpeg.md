##### ffmpeg的简单使用

```
//打印出来视频的编码信息 分辨率 桢率 码率 音频信息
ffmpeg -i 视频连接 
//播放视频
ffplay 视频连接/地址 

```

```
// 更改视频编码协议的profile [Profile 介绍](https://www.cnblogs.com/lidabo/p/7419393.html)
ffmpeg -i 视频地址 -profile:v main -level 4.0 视频的名字.视频的格式

附加选项：-r 指定帧率
        -s 指定分辨率
        -b 指定比特率
        -vcodec 指定编码协议 （h264 hevc）
于此同时可以对声道进行转码
        -acodec 指定音频编码
        -ab 指定音频比特率
        -ac 指定声道数

```
```
// 下载视频
ffmpeg -i 视频地址 -c copy 视频地址和.格式
```
