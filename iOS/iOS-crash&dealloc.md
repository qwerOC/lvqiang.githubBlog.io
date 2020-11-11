### dealloc 自动打印
>1.Breakpoint Navigator
>2.Symbolic Breakpoint
>3.设置Symbol值-[UIViewController dealloc] || -[UIView dealloc]
>4.设置Action 为Log Message将消息设置为要打印到控制台的任何内容，将其设置为--- dealloc @(id)[$arg1 description]@
>5.勾选Automatically continue after evaluating actions选项，因为我们不希望调试器在释放视图控制器时暂停


### crash



### 打印app 启动时间
DYLD_PRINT_STATISTICS
