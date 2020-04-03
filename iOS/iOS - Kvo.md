### 什么是kvo

> 1. kvo oc 对观察者模式的又一种实现
> 2. 苹果 使用isa混写来实现的


### kvo 原理 

> 1.![kvo](https://raw.githubusercontent.com/qwerOC/testOne/71a0e1ed2ecdf408350b8361317973e3c5420980/WechatIMG7.png)

> 2.系统在运行时创建监听对象子类 改写isa指针重写 方法 来实现的kvo

> 3.通过kvc 来设置kvo 也可以生效 最终都会掉用到 kvo底层的setter 方法

> 4.如果是成员变量需要重写![手动kvo的实现](https://raw.githubusercontent.com/qwerOC/testOne/290df8fdf0e77fb4f7576cc6f6af0d1e565dab4a/WechatIMG10.png)

```
/*这样也叫做手动kvo 同时 也可以更改成员变量的内容
因为会调用到 isa所创建运行时子类NSNotifation——kvo 重写的setter方法 所以可以实现修改
*/
[self willChangeValueForkey:"属性名称"]；
属性+=1;
[self didChangeValueForKey:@"属性名称"]；

```