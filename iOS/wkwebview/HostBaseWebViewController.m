

#import "HostBaseWebViewController.h"
#import "WeakWebViewScriptMessageDelegate.h"
#import "HostGetIPAddress.h"
#import "HostMuDeviceIdentifier.h"
@interface HostBaseWebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
//@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation HostBaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (isIphoneX) {
        if (@available(iOS 11.0, *)) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
        }
        
    }
    self.progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, MuScreen_Width, 2)];
    self.progressView.backgroundColor=MainWhite;
    self.progressView.progressTintColor=MainAppColor;
    self.progressView.trackTintColor=MainWhite;
    [self.progressView setProgress:0 animated:NO];
    [self.view addSubview:self.progressView];
}
-(WKWebView*)webView{
    if (!_webView) {
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        //        preference.minimumFontSize = 0;
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
        config.applicationNameForUserAgent = [@"shopshopsHosts/" stringByAppendingString:[HostCommonTools getAPPVersionAndBuild]];
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"callIos"];
        
        config.userContentController = wkUController;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 2, MuScreen_Width, MuScreen_Height-SafeAreaTopHeight-2)
                                      configuration:config];
        _webView.backgroundColor = [UIColor clearColor];
        
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        
        //// Date from
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        //// Execute
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
            // Done
            
        }];
        __weak typeof(self) weakSelf = self;
        [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable oldAgent, NSError * _Nullable error) {
            if (![oldAgent isKindOfClass:[NSString class]]) {
                // 为了避免没有获取到oldAgent，所以设置一个默认的userAgent
                // Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
                oldAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", [[UIDevice currentDevice] model], [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
            }
            
            NSString *newAgent = [@"shopshopsHosts/" stringByAppendingString:[HostCommonTools getAPPVersion]];
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
        //添加监测网页加载进度的观察者
        [self.webView addObserver:self
                       forKeyPath:@"estimatedProgress"
                          options:0
                          context:nil];
        //添加监测网页标题title的观察者
        [self.webView addObserver:self
                       forKeyPath:@"title"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
        [self.view addSubview:_webView];
        
    }
    
    return _webView;
    
}

- (void)loadData{
    NSString * urlStr = [_urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {
        NSLog(@"网页加载进度 = %f",_webView.estimatedProgress);
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
    }else if([keyPath isEqualToString:@"title"]
             && object == _webView){
        self.navigationItem.title = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


-(void)returnClick{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webview didStartProvisionalNavigation 开始加载");
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
    NSLog(@"webview didFailProvisionalNavigation 加载失败");
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"webview didCommitNavigation 内容开始返回");
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webview didFinishNavigation 页面加载完成");
}
//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}
// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}
//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}
#pragma mark -- WKUIDelegate

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NGLocalizedString(@"提示") message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"发送跳转请求：%@",urlStr);
    
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;
    /* 简单判断host，真实App代码中，需要更精确判断itunes链接 */
    if([[navigationAction.request.URL host] isEqualToString:@"apps.apple.com"] && [[UIApplication sharedApplication] openURL:navigationAction.request.URL]){
        policy =WKNavigationActionPolicyCancel;
    }else if([scheme isEqualToString:@"tel"]) {
        NSString *resourceSpecifier = [URL resourceSpecifier];
        NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];
        /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
        });
        policy =WKNavigationActionPolicyCancel;
    }
    
    //拦截URL，判断http或https请求头部信息
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        NSMutableURLRequest *mutableRequest = [navigationAction.request mutableCopy];
        NSDictionary *headFields = mutableRequest.allHTTPHeaderFields;
        NSString *    appVersion  = headFields[@"appVersion"];
        if ([appVersion  length] == 0) {
            NSString *token=[HostUserModel getUserModel].token;
            if (![HostCommonTools isBlankString:token]) {
                [mutableRequest setValue:[NSString stringWithFormat:@"bearer %@",token] forHTTPHeaderField:@"Authorization"];
            }else{
                [mutableRequest setValue:@"" forHTTPHeaderField:@"Authorization"];
            }
            //    请求的版本号 2.0.0这种
            [mutableRequest setValue:[HostCommonTools getAPPVersion] forHTTPHeaderField:@"appVersion"];
            //    设备id
            [mutableRequest setValue:[HostMuDeviceIdentifier deviceIdentifier] forHTTPHeaderField:@"deviceId"];
            //    设备型号
            [mutableRequest setValue:[HostGetDeviceName getPhoneVersion] forHTTPHeaderField:@"deviceModel"];
            //    设备系统 iOS
            [mutableRequest setValue:@"iOS" forHTTPHeaderField:@"deviceSystem"];
            //    设备系统版本
            [mutableRequest setValue:[HostGetDeviceName getDeviceOSVersion] forHTTPHeaderField:@"deviceVersion"];
            //    设备请求IP
            [mutableRequest setValue:[HostGetIPAddress getIPAddress:YES] forHTTPHeaderField:@"loginIp"];
            [mutableRequest setValue:[HostGetDeviceName getSystemLanguage] forHTTPHeaderField:@"currentLocaleLanguageCode"];
            //重新加载设置后的请求
            [webView loadRequest:mutableRequest];
        }
    }
    decisionHandler(policy);
}
// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    //用message.body获得JS传出的参数体
    NSString * str = message.body;
    NSDictionary * parameter = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    //JS调用OC
    if([message.name isEqualToString:@"callIos"]){
        [self callIos:parameter andWebView:_webView];
    }
}

- (void)callIos:(NSDictionary *)dic andWebView:(WKWebView *)webView{
    NSString * type = [HostCommonTools getStringWithDic:dic key:@"type"];
    if([type isEqualToString:@"34"]){
        //证件信息  打开第三方浏览器 跳转icp备案信息
        [self showCertificateHost:YES];
    }else if ([type isEqualToString:@"35"]){
        //证件信息  打开第三方浏览器 跳转文网文备案信息
        [self showCertificateHost:NO];
    }else{
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *token=[HostUserModel getUserModel].token;
        if (![HostCommonTools isBlankString:token]) {
            params[@"Authorization"]=[NSString stringWithFormat:@"bearer %@",token];
        }else{
                  params[@"Authorization"]=@"";
        }
        params[@"Authorization"]=[NSString stringWithFormat:@"bearer %@",token];
        params[@"appVersion"]=[HostCommonTools getAPPVersion];
        params[@"deviceId"]=[HostMuDeviceIdentifier deviceIdentifier];
        params[@"deviceModel"]=[HostGetDeviceName getPhoneVersion];
        params[@"deviceSystem"]=@"iOS";
        params[@"deviceModel"]=[HostCommonTools getAPPVersionAndBuild];
        params[@"deviceVersion"]=[HostGetDeviceName getDeviceOSVersion];
        params[@"loginIp"]=[HostGetIPAddress getIPAddress:YES];
        params[@"currentLocaleLanguageCode"]=[HostGetDeviceName getSystemLanguage];
        params[@"type"]=@"1";
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"callJs('%@')",[HostCommonTools dictionaryToJsonString:params]] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        }];
    }
}
-(void)showCertificateHost:(BOOL)isICP{
    UIAlertController *alc = [UIAlertController alertControllerWithTitle:NGLocalizedString(@"提示") message:isICP?NGLocalizedString(@"下个页面不受我们控制哦,使用时请注意安全\nhttps://tsm.miit.gov.cn"):NGLocalizedString(@"下个页面不受我们控制哦,使用时请注意安全\nhttp://gs.ccm.mct.gov.cn") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NGLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *defatutAction = [UIAlertAction actionWithTitle:NGLocalizedString(@"浏览器打开") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *wwwStr = isICP?@"https://tsm.miit.gov.cn/FineReport/base/publicField/%E4%BA%ACB2-20181972":@"http://gs.ccm.mct.gov.cn/lic/1e5564b4b6374c749499853f3fd575ec";
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:wwwStr]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:wwwStr] options:0 completionHandler:nil];
        }
        
    }];
    [alc addAction:cancelAction];
    [alc addAction:defatutAction];
    [self presentViewController:alc animated:YES completion:nil];
}

-(void)dealloc{
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
    //移除注册的js方法
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"callIos"];
    
}

@end
