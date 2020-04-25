#### frame 和 bounds
> frame 改变的都是自身的位置
> frame 的参照物是父类，从而确定自身位置
> bounds 是以自身的左上角 为参照物

#### 1+2+3+.....n  如n=100 不用if  while  do whild 计算

```
/// 逻辑短路
-(int)addMethod:(int)num{
  int aTemp = num;
  num && (aTemp += [self addMethod:num-1]);
 	return aTemp;
}
```
#### arm 寄存器 x0 和 x1 代表什么
> x0 代表 对象
> x1 代表 sel（sel 方法选择器）

#### runtime 
> sel 选择器 只是个代称
> imp 函数指针

#### load 在父类 和子类 分类中都存在 执行顺序
> 类 -> 子类 ->分类
> 存在多个子类 和 分类 在子类和分类的 区域中顺序不一致

#### load 和 initialize
> 相同点
>> 1. 都会自动调用 不需要手动调用
>> 2. 内部都使用了锁 线程是安全的

> 不同点
>
> > 1. load 在main函数执行前调用 而 initialize是在函数初始化后

> 使用场景
>> 1. +load一般是用来交换方法Method Swizzle，由于它是线程安全的，而且一定会调用且只会调用一次，通常在使用UrlRouter的时候注册类的时候也在+load方法中注册。
>> 2. +initialize方法主要用来对一些不方便在编译期初始化的对象进行赋值，或者说对一些静态常量进行初始化操作
