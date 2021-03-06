
### 什么是Block
> Block 是将函数及其执行上下文封装起来的对象

### Block 是由什么组成 __block_impl 和 __main_block_desc_0
> __block_impl
>>1.isa指针 用与指向block的指针
>>2.flags 附加信息
>>3.reserved 保留字段
>>4.funcptr 函数指针指向block实现函数地址

>__main_block_desc_0
>> reserved 
>> Block_size block大小

### block 截获变量
```
1.对于基本数据类型 局部变量截获其值
2.对于对象类型的局部变量连同所有权修饰符一起截获
3.以指针形式截获局部静态变量
4.不截获全局变量 静态全局变量
```
### __block
> 一般情况下 对被截获变量进行赋值操作需要添加__block修饰符

> __block 修饰的变量最后变成了对象
```
1.栈上边的__forwarding 指针 指向__block 修饰的变量自身
2.如果block 使用了copy 操作 那么在堆上会生成出一个副本此时会有一下变更
	1).栈上边的__forwarding执行堆上的__block变量
	2).堆上的__forwarding指向堆上的__block
```

### 为什么使用__weak 可以破除循环引用
```
1. block 使用的对象是当前对象的成员变量或者属性 用strong修饰
2. block 截获局部变量会联同 他的访问修饰符一起截获 
3. 使用__weak 修饰block 中要使用的对象 这样block获取到的访问修饰符就不再是strong 
而是__weak 从而破除循环引用
```

