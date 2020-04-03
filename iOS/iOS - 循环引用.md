### 循环引用
>多个对象相互引用导致对象不能正常释放
>堆区才回出现循环引用 栈区 静态区 系统管理

### 解决方案
>将强引用改为弱引用


### 如何查找
>在baseVC/baseView/baseViewCell的delloc方法中打印该方法执行的控制器 /view/cell 是否都销毁
>MLeaksFinder 可以检测循环引用和内存泄漏


### 经常出现问题的范围会有
>自定义的block
>
>>
```objective-c
/// 自定block 传递点击事件 中直接使用self 会导致循环引用
/// 原因1.self首先肯定是当前控制器强引用
/// block 内部也会强持内部对象 这就导致了循环引用
CoustomView *customView = [[CoustomView alloc] initWithFrame:self.view.bounds];
customView.clickBtnBlock=^(){
[self xxxMethod];
}
/// 更改如下
/// 若引用当前对象 
1.__weak typeof(self) weakSelf = self;
customView.clickBtnBlock=^(){
[weakSelf xxxMethod];
}
```
>代理
>定时器
>
>>
```
定时器注意销毁
```
>block二次封装的AFN
>
>>
```
/// 网络请求回掉中会大量使用当前控制器中的属性
/// 尽量不要使用成员变量 如果是弱网环境当前控制器可能已经销毁了 但是网络请求回掉来了 如果是成员变量在网络请求回掉中需要强引用这是 self=nil 所以会引发crash
同理解决方法 需要弱引用当前对象
[httpTool postrequestmethodxxxParams:params successBlock:^(id obj){

}failBlock:^(NSError * _Nonnull error){

}]
```
>UIAlertController 带有textfield的会有问题
>
>>
```
   UIAlertController *actionCon=[UIAlertController alertControllerWithTitle:NGLocalizedString(@"请输入自定义的规格")
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [actionCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"xxx";
    }];
    __weak typeof(actionCon) weakAlert = actionCon;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NGLocalizedString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakAlert)strongAlert = weakAlert;
        UITextField *tf = strongAlert.textFields.firstObject;
        [self coustomSize:tf.text];
        
    }];
    UIAlertAction *canale = [UIAlertAction actionWithTitle:NGLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
    }];
    
    [actionCon addAction:ok];
    [actionCon addAction:canale];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:actionCon animated:YES completion:nil];
    
```
>MJRefresh
>
>>
```
   __weak __typeof(self)weakSelf = self;
    self.MLView.collectionView.mj_header = [HostMuHeaderRefresh headerWithRefreshingBlock:^{
        //加载数据（包括刷新tableView）
        [weakSelf xxxMethod];
    }];
```
### 为什么需要弱引用
>因为weak修饰的变量在是否后自动为指向nil，防止不安全的野指针存在

