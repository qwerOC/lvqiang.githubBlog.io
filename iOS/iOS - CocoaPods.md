### 安装
```
# 安装最新beta版
sudo gem install cocoapods --pre -n /usr/local/bin
# 安装最新稳定版
sudo gem install cocoapods -n /usr/local/bin
```
### 切换gem 源
```
//查看当前源 
gem sources -l
// 删除源
gem sources --remove
// 添加源
gem sources -a 
```



### 卸载

> 卸载pod
```
sudo rm -rf /usr/local/bin/pod
```
> 卸载所有cocoapods 组件
```
//查看列表
gem list
//单个删除
sudo gem uninstall cocoapods-XXX
//批量删除
sudo rm -rf /usr/local/bin/pod ; gem list | grep cocoapods | awk '{print $1}' | while read line; do sudo gem uninstall $line; done
```