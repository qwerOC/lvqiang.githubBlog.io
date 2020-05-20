### 什么是RunLoop
```
1.通过内部维护事件循环/来对事件消息 进行管理一个对象

2.事件循环是 有消息处理的时候激活 无事件做的时候休眠 避免资源占用

3.无事件做的时候休眠 避免资源占用
	用户态----内核态 切换
4.有消息处理的时候激活
	内核态----用户态 切换
	
例子
int main（）{
  uiapplicationMain中会启动住线程的runloop 启动事件循环
  有事情做的时候做事 无事情做的时候休息 避免资源占用
}

创建线程默认是没有runloop
需要开启runloop（创建） 模式必须是一个
```


### Runloop 的数据结构
>1. CFRunloop
>>1. pthread  -- RunLoop 和线程是一一对应的
>>2. currentMode -- CFRunLoopMode
>>3. modes  --  NSMutableSet(CFRunLoopMode)
>>4. commonModes --  NSMutableSet(NSString)
>>5. cmomonModeItems --多个Observer/多个timer/多个Source
>2. CFRunloopModel
>3. Source/Timer/Observer

### CFRunLoopMode
>1. name NSRunLoopDefautMode
>2. sources0 可变集合 
>3. sources1 可变集合
>4. observers 可变数组
>5. Timers   可变数组

### CFRunLoopSource
>1. source0 需要手动切换线程 从内核态切换到用户态
>2. source1 具备换成线程的能力

### CFRunLoopObserver 的可监听周期
>1. kcfRunLoopEntry 入口
>2. kCFRunLoopBeforeTimer 要对timer事件进行处理前
>3. kCFRunLoopBeforeSources 要对sources事件进行处理前
>4. kCFRunLoopBeforeWaiting 
```
用户态到内核态的切换
runloop要进入休眠状态
```
>5. kCFRunLoopAfterWaiting
```
内核态切换到用户态之后
```
>6. kCFRunLoopExit runloop 推出

### RunLoop 的 model
```
1. 首先runloop和线程是一一对应的 
2. runloop 中可以包含多个model 每个model中可以有多个sources/times/observers
3. 当运行在某个model中时 其他model的回掉事件时无法接受的
4. model起到了屏蔽的效果

例子：如果timer 想要存在与多个model中时
1. timer 切换模式到NSRunLoopCommonmodes
2. Commonmodes 不是实际存在的一种mode
3. Commonmodes 是同步Source/Timer/observer到多个mode 中的一种技术解决方案
```