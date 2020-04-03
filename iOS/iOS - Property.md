### atomic 和 noatmoic

> 1.atomic 表示线程安全 但是只保证 在赋值 和取值 时线程安全 如果删除 和修改 则不安全

> 2.noatmoic线程不安全


### assign 和 weak

> 1.assign 

>> 1.修饰基本数据类型

>> 2.修饰对象的时候不更改引用计数

>> 3.修饰对象的时 在对象被释放的时候 assign仍然会指向其内存地址 会造成 野指针


> 2.weak

>> 1.修饰对象的时候不更改引用计数

>> 1.所指对象释放之后会自动置nil

```
如果 assign 和 weak的共同点都可以避免循环引用 但是assign的垂直指针问题 还会造成 野指针所以修饰代理最好用weak
```
> 3. 为什么置nil

>>1. runtime 对注册的类 会进行布局 对于weak对象会放入hash表中

>>2. 使用weak指向的对象内存地址为key 当对象引用计数为0是 调用delloc 之后找到内存地址为键 weak 对象 从而置nil



### copy

> 1.深拷贝 不会修改引用计数

![copy_01](https://raw.githubusercontent.com/qwerOC/testOne/qwerOC-patch-1/WechatIMG14.png)

![copy_02](https://github.com/qwerOC/testOne/blob/qwerOC-patch-1/WechatIMG15.png?raw=true)



