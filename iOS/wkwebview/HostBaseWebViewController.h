

#import "HostBaseViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HostBaseWebViewController : HostBaseViewController
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic,copy) NSString *urlStr;

- (void)loadData;
@end

NS_ASSUME_NONNULL_END
