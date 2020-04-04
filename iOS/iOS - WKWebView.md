### 使用和配置
```
 //创建网页配置对象
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
WKPreferences *preference = [[WKPreferences alloc]init];
 //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
 // 配置这个后H5会加载不出来.....
 //preference.minimumFontSize = 0;/
 //设置是否支持javaScript 默认是支持的
  preference.javaScriptEnabled = YES;
  // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
  preference.javaScriptCanOpenWindowsAutomatically = YES;
  config.preferences = preference;
        
  // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
   config.allowsInlineMediaPlayback = YES;
  //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
   config.requiresUserActionForMediaPlayback = NO;
  //设置是否允许画中画技术 在特定设备上有效
    config.allowsPictureInPictureMediaPlayback = NO;
  //设置请求的User-Agent信息中应用程序名称 iOS9后可用
  // 这个设置后UA还是不会有的 
  config.applicationNameForUserAgent = [@"xxx/" stringByAppendingString:[业务拼接版本]];
```
### 设置UA
```
 __weak typeof(self) weakSelf = self;
        [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable oldAgent, NSError * _Nullable error) {
            if (![oldAgent isKindOfClass:[NSString class]]) {
                // 为了避免没有获取到oldAgent，所以设置一个默认的userAgent
                // Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
                oldAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", [[UIDevice currentDevice] model], [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
            }
            
            NSString *newAgent = [@"xxxx/" stringByAppendingString:[业务拼接版本]];
            NSString * oldStr = (NSString *)oldAgent;
            if ([oldStr isEqualToString:newAgent]) {
                oldStr = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", [[UIDevice currentDevice] model], [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
                
                oldStr = [[newAgent stringByAppendingString:@"/"] stringByAppendingString:oldStr];
            }
            
            if (![oldStr containsString:newAgent]) {
                newAgent = [[newAgent stringByAppendingString:@"/"] stringByAppendingString:oldAgent];
            }
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":oldStr}];
            // 一定要设置customUserAgent，否则执行navigator.userAgent拿不到oldAgent
            weakSelf.webView.customUserAgent = newAgent;
        }];
```
### 原生调用JS
```
  //就是这么简单
  [self.webView evaluateJavaScript:[NSString stringWithFormat:@"callJs('%@')",[json]] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        }];
```
###  js 掉原生

```
1.创建继承NSobject类
2.遵守WKScriptMessageHandler 协议
3.创建自定义代理
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;
4.重新写创建当前对象的实现
5.- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message 转发此协议收到的内容
6.//自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
 WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //这个类主要用来做native与JavaScript的交互管理
 WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
 [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"callIos"];
  config.userContentController = wkUController;
 7.销毁 [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"callIos"];

```
### wkwebview 一些系统版本兼容和弹alert 问题
```

```
### [代码比较多还是上例子吧](https://github.com/qwerOC/lvqiang.githubBlog.io/tree/master/iOS/wkwebview)


