//
//  IBTWKWebViewController.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWKWebViewController.h"
#import "IBTWKWebView.h"
#import "IBTWKWebJSLogicImpl.h"
#import "IBTWKWebUtil.h"
#import "IBTWKWebViewInterface.h"
#import "UIDevice+IBTHardware.h"
#import "UIViewController+IBTExtend.h"
#import "UIDevice+IBTHardware.h"
#import "IBTMacro.h"

typedef NS_ENUM(NSInteger, IBTWKWebViewFailReason) {
    IBTWKWebViewFailReason_LoadFail,     // 加载失败 0x1;
    IBTWKWebViewFailReason_DNSFail,      // DNS 失败 0x3;
};

@interface IBTWKWebViewController () <WKNavigationDelegate, IBTWKWebJSLogicDelegate, UIScrollViewDelegate>
@property (nonatomic, strong, readwrite) IBTWKWebView *webView;
@property (nonatomic, strong, readwrite) IBTWKWebJSLogicImpl *jsLogicImpl;

@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, weak) UIButton *loadFailView;

@property (nonatomic, strong) IBTWebViewPresetUI *presetUI;
@property (nonatomic, strong) NSMutableDictionary *extraInfo;
@property (nonatomic, strong) NSMutableDictionary *jsInitInfo;
@property (nonatomic, strong) NSURL *originUrl;
@property (nonatomic, strong) NSURL *currentUrl;
@property (nonatomic, strong) NSString *loadingUrl;

//@property (nonatomic, assign) BOOL isPageDidLoaded;
@property (nonatomic, assign) NSUInteger loadingCount;
//@property (nonatomic, assign) BOOL isFinishLoaded;
//@property (nonatomic, assign) BOOL newWebLoading;
//@property (nonatomic, assign) BOOL isPageLoadFail;
@property (nonatomic, assign) BOOL bHasFinishLoadOnce;
@property (nonatomic, assign) BOOL bHasInitNotification;

@end

@interface IBTWKWebViewController (ProgressBar)

- (void)updateProgressBarColor:(UIColor *)progressBarColor;

- (void)setupProgressBar;

@end

@implementation IBTWKWebViewController

#pragma mark - Life Cycle

- (instancetype)initWithUrl:(id)url
                  extraInfo:(NSDictionary *)extraInfo
                   presetUI:(IBTWebViewPresetUI *)presetUI
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([url isKindOfClass:[NSString class]]) {
        NSString *urlStr = [url stringByRemovingPercentEncoding];
        if (![urlStr containsString:@"://"]) {
            urlStr = [NSString stringWithFormat:@"%@://%@", @"http", url];
        }
        
        self.originUrl = [NSURL URLWithString:urlStr];
    }
    else if ([url isKindOfClass:[NSURL class]]) {
        self.originUrl = url;
    }
    else {
        self.originUrl = nil;
    }
    
    self.currentUrl = _originUrl;
    
    self.extraInfo = [[NSMutableDictionary alloc] initWithDictionary:extraInfo];
    self.presetUI = presetUI;
    
    self.jsLogicImpl =
    [[IBTWKWebJSLogicImpl alloc] initWithDelegate:self];
    
    [_jsLogicImpl addExtraJSHandlers:_extraInfo[ @"jsHandles" ]];
    
    [self initJsInitInfo];
    
    [self webView];
    
    [self initNotificationAndObservers];
    
    [self StartLoadWeb];
    
    return self;
}

- (void)dealloc {
    _webView.scrollView.delegate = nil;
    
    [self setNetworkIndicateVisible:NO];
    
    [_webView stopLoading];
    
    [self removeNotificationAndObservers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.frame = self.view.bounds;
    
    [self.view addSubview:self.webView];
    
    [self setupLeftBarButtonItems];
    
    self.webView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior =
        UIScrollViewContentInsetAdjustmentNever;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    self.edgesForExtendedLayout = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupProgressBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_progressBar) {
        [_progressBar removeFromSuperview];
    }
    
    [self setNetworkIndicateVisible:NO];
}


#pragma mark - Public Method

- (void)setDisableWebViewScrollViewBounces {
    self.webView.scrollView.bounces = NO;
}

- (void)dismissWebViewController {
    [self dismissSelfWithAnimated:YES];
}

- (void)immediateDismissWebViewController {
    [self dismissSelfWithAnimated:NO];
}

#pragma mark - Private Method

- (void)goToURL:(NSURL *)url {
    self.currentUrl = url;
    
    if ([url isFileURL]) {
        NSError *error = nil;
        NSString *htmlStr =
        [NSString stringWithContentsOfURL:url
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
        
        if (error) {
            DebugLog( @"fail load local html, error:%@", error)
        }
        else {
            [_webView loadHTMLString:htmlStr baseURL:url];
        }
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
}

- (void)StartLoadWeb {
    if (_currentUrl.absoluteString.length) {
        if ([_currentUrl isFileURL]) {
            NSError *error = nil;
            NSString *htmlStr =
            [NSString stringWithContentsOfURL:_currentUrl
                                     encoding:NSUTF8StringEncoding
                                        error:&error];
            
            if (error) {
                DebugLog( @"fail load local html, error:%@", error)
            }
            else {
                [_webView loadHTMLString:htmlStr baseURL:_currentUrl];
            }
        }
        else {
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_currentUrl];
            
            NSDictionary *dict = _extraInfo[ @"httpHeader" ];
            
            if ([dict isKindOfClass:[NSDictionary class]] && dict.count) {
                for (NSString *key in [dict allKeys]) {
                    [req setValue:dict[key] forHTTPHeaderField:key];
                }
            }
            
            [_webView loadRequest:req];
        }
    }
}

- (void)initJsInitInfo {
    NSMutableDictionary *jsInfo = [NSMutableDictionary dictionary];
    jsInfo[ @"init_url" ] = [self.originUrl absoluteString] ? : @"";
    jsInfo[ @"model" ] = [[UIDevice currentDevice] ibt_platform] ? : @"";
    NSString *version = [[UIDevice currentDevice] systemVersion];
    jsInfo[ @"system" ] = [@"iOS " stringByAppendingString:version];
    
    _jsInitInfo = jsInfo;
}

- (void)setupLeftBarButtonItems {
    if ([self isNavigationBarShow]) {
        
        if (self.presetUI.disableGobackMode) {
            if ((self.ibt_isPushedIn || self.ibt_isPresentedIn)
                && !self.navigationItem.leftItemsSupplementBackButton) {
                self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
            }
            else {
                self.navigationItem.leftBarButtonItem = nil;
            }
        }
        else {
            if ([_webView canGoBack])  {
                if (self.navigationItem.leftItemsSupplementBackButton) {
                    if (self.presetUI.showCloseButton) {
                        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem;
                    }
                    else {
                        self.navigationItem.leftBarButtonItem = nil;
                    }
                }
                else {
                    if (self.presetUI.showCloseButton) {
                        self.navigationItem.leftBarButtonItems = @[self.backBarButtonItem,self.closeBarButtonItem];
                    }
                    else {
                        self.navigationItem.leftBarButtonItems = @[self.backBarButtonItem];
                    }
                    
                }
            }
            else {
                if ((self.ibt_isPushedIn || self.ibt_isPresentedIn)
                    && !self.navigationItem.leftItemsSupplementBackButton) {
                    self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
                }
                else {
                    self.navigationItem.leftBarButtonItem = nil;
                }
            }
        }
    }
}

- (void)dismissSelfWithAnimated:(BOOL)animated {
    [self.view endEditing:YES];
    if (self.ibt_isPushedIn) {
        [self.navigationController popViewControllerAnimated:animated];
    }
    else {
        [self dismissViewControllerAnimated:animated completion:NULL];
    }
}

- (void)showLoadFailView:(IBTWKWebViewFailReason)eReason
               errorCode:(NSInteger)code {
    //    _isPageLoadFail = YES;
    UILabel *label = nil;
    if (!_loadFailView) {
        UIButton *loadFailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        loadFailBtn.frame = self.webView.frame;
        
#define IBT_LOAD_FAIL_VIEW_IMAGE_TAG     (3000)
        UIImage *image = [UIImage imageNamed:@"WebView_LoadFail_Refresh_Icon"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = IBT_LOAD_FAIL_VIEW_IMAGE_TAG;
        [loadFailBtn addSubview:imageView];
        
#define IBT_LOAD_FAIL_VIEW_LABEL_TAG     (3001)
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = IBT_LOAD_FAIL_VIEW_LABEL_TAG;
        
        label.accessibilityLabel = label.text;
        
        [loadFailBtn addSubview:label];
        
        [loadFailBtn addTarget:self
                        action:@selector(onClickFailView:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:loadFailBtn];
        
        _loadFailView = loadFailBtn;
        
        [self relayoutLoadFailView];
    }
    
    _loadFailView.tag = eReason;
    _loadFailView.hidden = NO;
    
    if (!label) {
        label = [_loadFailView viewWithTag:IBT_LOAD_FAIL_VIEW_LABEL_TAG];
    }
    
    label.text =
    eReason == IBTWKWebViewFailReason_DNSFail
    ? @"无法解析域名地址，详情请咨询网络服务提供商。"
    : [NSString stringWithFormat:@"网络出错，轻触屏幕重新加载:%@", @(code)];
}

- (void)relayoutLoadFailView {
    _loadFailView.frame = _webView.frame;
    
    UIImageView *imgView = [_loadFailView viewWithTag:IBT_LOAD_FAIL_VIEW_IMAGE_TAG];
    
    UIView *label = [_loadFailView viewWithTag:IBT_LOAD_FAIL_VIEW_LABEL_TAG];
    
    CGSize size = imgView.image.size;
    CGFloat fW = CGRectGetWidth(_loadFailView.frame);
    imgView.frame = (CGRect){
        .origin.x = (fW - size.width) * .5f,
        .origin.y = 80,
        .size = size
    };
    
    label.frame = (CGRect){
        .origin.x = 0,
        .origin.y = CGRectGetMaxY(imgView.frame),
        .size.width = fW,
        .size.height = 40
    };
}

- (void)hideLoadFailView {
    _loadFailView.hidden = YES;
}

- (void)onClickFailView:(UIButton *)sender {
    
    [self hideLoadFailView];
    
    if (sender.tag) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_currentUrl];
        [_webView loadRequest:req];
    }
    else {
        [self StartLoadWeb];
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

#pragma mark - IBTWKWebViewDelegate

- (BOOL)webView:(IBTWKWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(WKNavigationType)navigationType
    isMainFrame:(BOOL)isMainframe
{
    
    _loadingUrl =
    [IBTWKWebUtil fomatedURLStr:request.mainDocumentURL.absoluteString];
    
    NSURL *url = request.URL;
    NSString *scheme = request.URL.scheme;
    BOOL isHttp = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
    
    // 电话
    NSArray *phoneArr = @[ @"tel", @"facetime", @"facetime-audio", @"mailto" ];
    if ([phoneArr containsObject:scheme]) {
        [IBTWKWebUtil openUrl:url];
        return NO;
    }
    
    // 地图
    if (isHttp && [url.host isEqualToString:@"maps.apple.com"] && url.query) {
        [IBTWKWebUtil openUrl:url];
        return NO;
    }
    
    // itunes
    if (isHttp && [url.host isEqualToString:@"itunes.apple.com"]) {
        [IBTWKWebUtil openUrl:url];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(IBTWKWebView *)webView {
    
    //    _isPageDidLoaded = NO;
    _loadingCount += 1;
    //    _isFinishLoaded = NO;
    
    DebugLog(@"[webview-%p]webViewDidStartLoad. loading count %@ ", webView, @(_loadingCount));
    
    [self hideLoadFailView];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(onWebViewDidStartLoad:)]) {
        [self.delegate onWebViewDidStartLoad:webView];
    }
    
    [self setNetworkIndicateVisible:YES];
}

- (void)webViewDidFinishLoad:(IBTWKWebView *)webView {
    
    _loadingCount-= 1;
    //    _isFinishLoaded = YES;
    //    _newWebLoading = NO;
    //    _isPageLoadFail = NO;
    
    [self hideLoadFailView];
    
    self.bHasFinishLoadOnce = YES;
    
    self.currentUrl = webView.request.mainDocumentURL;
    
    [self hideLoadFailView];
    
    [_jsLogicImpl tryInjectIbtJSBridge:_jsInitInfo];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(onWebViewDidFinishLoad:)]) {
        [self.delegate onWebViewDidFinishLoad:webView];
    }
    
    [self setNetworkIndicateVisible:NO];
}

- (void)webView:(IBTWKWebView *)webView didFailLoadWithError:(NSError *)error {
    
    _loadingCount-= 1;
    //    _isPageDidLoaded = YES;
    //    _newWebLoading = NO;
    //    _isPageLoadFail = YES;
    
    DebugLog(@"[webview-%p]didFailLoadWithError. loading count %@ error %@ ", webView, @(_loadingCount), error);
    
    [_jsLogicImpl tryInjectIbtJSBridge:_jsInitInfo];
    [self setNetworkIndicateVisible:NO];
    
    if (error.code != NSURLErrorCancelled   // 当网页内部链接跳转时
        && !(error.code == 102              // 当网页包含 AppStore 链接时
             && [error.domain isEqualToString:@"WebKitError"])
        && !(error.code == 204              // 当链接就视频路径时（不影响视频正常播放）
             && [error.domain isEqualToString:@"WebKitError"])) {
            
            if (self.delegate
                && [self.delegate respondsToSelector:@selector(webViewFailToLoad:Error:)]) {
                NSURL *failUrl = [self.delegate webViewFailToLoad:webView Error:error];
                if (failUrl) {
                    [self goToURL:failUrl];
                }
                else {
                    NSString *currentUrl =
                    [IBTWKWebUtil fomatedURLStr:self.currentUrl.absoluteString];
                    if ([currentUrl isEqualToString:_loadingUrl]) {
                        [_webView evaluateJavaScriptFromString:@"document.body.innerHTML='';" completionBlock:NULL];
                        
                        IBTWKWebViewFailReason eReason;
                        if (error.code == NSURLErrorCannotFindHost
                            && [error.domain isEqualToString:@"WebKitError"]) {
                            eReason = IBTWKWebViewFailReason_DNSFail;
                        }
                        else {
                            eReason = IBTWKWebViewFailReason_LoadFail;
                        }
                        
                        [self showLoadFailView:eReason errorCode:error.code];
                    }
                    else {
                        DebugLog(@"1>>loadingUrl not equal to currenturl>>loadingUrl:%@,currentUrl:%@", _loadingUrl, currentUrl);
                    }
                }
            }
            else {
                NSString *currentUrl =
                [IBTWKWebUtil fomatedURLStr:self.currentUrl.absoluteString];
                if ([currentUrl isEqualToString:_loadingUrl]) {
                    [_webView evaluateJavaScriptFromString:@"document.body.innerHTML='';" completionBlock:NULL];
                    
                    [self showLoadFailView:IBTWKWebViewFailReason_LoadFail errorCode:error.code];
                }
                else {
                    DebugLog(@"2>>loadingUrl not equal to currenturl>>loadingUrl:%@,currentUrl:%@", _loadingUrl, currentUrl);
                }
            }
            
        }
    else {
        self.currentUrl = webView.request.mainDocumentURL;
    }
}

- (void)webViewContentProcessDidTerminate:(IBTWKWebView *)webView {
    // 处理白屏问题
    [webView reload];
}

- (void)webviewDidReceiveScriptMessage:(NSString *)name handler:(id)bodyHandler {
    if ([name isEqualToString:IBT_DISPATCH_MSG_NAME]) {
        if ([bodyHandler isKindOfClass:[NSString class]]) {
            [_jsLogicImpl handleJSApiDispatchMessage:bodyHandler];
        }
    }
}

#pragma mark - IBTWKWebJSLogicDelegate

- (UIViewController<IBTWKWebViewDelegate> *)getCurrentWebviewViewController {
    return self;
}

#pragma mark - Actions

- (void)onGoBackAction:(UIBarButtonItem *)sender {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else {
        [self onCloseAction:sender];
    }
}

- (void)onCloseAction:(UIBarButtonItem *)sender {
    [self dismissSelfWithAnimated:YES];
}

#pragma mark - Utils

- (void)setNetworkIndicateVisible:(BOOL)isVisible {
    UIApplication *application = [UIApplication sharedApplication];
    if (isVisible != application.isNetworkActivityIndicatorVisible) {
        application.networkActivityIndicatorVisible = isVisible;
    }
}

- (BOOL)isNavigationBarShow {
    UINavigationController *rootCtrl = self.navigationController;
    return rootCtrl && !rootCtrl.isNavigationBarHidden;
}

#pragma mark - KVO

+ (NSArray <NSString *> *)observerWebViewKeypaths {
    return @[ @"estimatedProgress", @"title", @"URL", @"canGoBack", @"canGoForward" ];
}

- (void)initNotificationAndObservers {
    NSArray *keyPaths = [[self class] observerWebViewKeypaths];
    for (NSString *keyPath in keyPaths) {
        [self.webView addObserver:self
                       forKeyPath:keyPath
                          options:NSKeyValueObservingOptionNew
                          context:@"IBTWKWebViewController_"];
    }
    
    self.bHasInitNotification = YES;
}

- (void)removeNotificationAndObservers {
    if (_bHasInitNotification) {
        NSArray *keyPaths = [[self class] observerWebViewKeypaths];
        for (NSString *keyPath in keyPaths) {
            [self.webView removeObserver:self
                              forKeyPath:keyPath
                                 context:@"IBTWKWebViewController_"];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == _webView) {
            UIProgressView *progressView = _progressBar;
            if (!progressView) {
                return;
            }
            
            [progressView setAlpha:1.0f];
            double progress = 0;
            id idProgress = change[NSKeyValueChangeNewKey];
            if ([idProgress isKindOfClass:[NSNumber class]]) {
                progress = [idProgress doubleValue];
            }
            [progressView setProgress:progress animated:progress > progressView.progress];
            
            if (progress >= 1.0f) {
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [progressView setProgress:0.0f animated:NO];
                }];
            }
        }
    } else if ([keyPath isEqualToString:@"URL"]) {
        NSURL *loadURL = change[NSKeyValueChangeNewKey];
        if ([loadURL isKindOfClass:[NSURL class]]) {
            self.loadingUrl = [IBTWKWebUtil fomatedURLStr:[loadURL absoluteString]];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        NSString *title = change[NSKeyValueChangeNewKey];
        if ([title isKindOfClass:[NSString class]]) {
            if (self.presetUI.navigationBarTitle) {
                self.title = self.presetUI.navigationBarTitle;
            } else {
                self.title = title;
            }
        }
    } else if ([keyPath isEqualToString:@"canGoBack"] ||
               [keyPath isEqualToString:@"canGoForward"]) {
        [self setupLeftBarButtonItems];
    }
    
}

#pragma mark - Setter & Getter

- (IBTWKWebView *)webView {
    if (nil == _webView) {
        _webView = [[IBTWKWebView alloc] initWithFrame:CGRectZero delegate:self];
        _webView.allowsBackForwardNavigationGestures = !self.presetUI.disableGobackMode; // 允许滑动返回上一级页面手势
        if (@available(iOS 9.0, *)) {
            // 取消 3DTouch 打开 Safari
            _webView.allowsLinkPreview = NO;
        }
        _jsLogicImpl.webview = _webView;
        _webView.scrollView.delegate = self;
    }
    return _webView;
}

- (UIProgressView *)progressBar {
    if (nil == _progressBar) {
        CGFloat fY = 0;
        
        if ([self isNavigationBarShow]) {
            fY += CGRectGetHeight(self.navigationController.navigationBar.bounds);
        }
        else {
            UIApplication *app = [UIApplication sharedApplication];
            if (app && !app.isStatusBarHidden) {
                fY += CGRectGetHeight(app.statusBarFrame);
            }
        }
        
        CGFloat fProgressH = 2.0f;
        
        CGRect frame = CGRectMake(0.0f, fY - fProgressH,
                                  CGRectGetWidth(self.view.bounds), fProgressH);
        _progressBar = [[UIProgressView alloc] initWithFrame:frame];
        _progressBar.trackTintColor = [UIColor clearColor];
        _progressBar.progress = 0;
        
        _progressBar.progressTintColor = self.view.window.tintColor;
    }
    return _progressBar;
}

- (UIBarButtonItem *)backBarButtonItem {
    
    UIBarButtonItem *backBtnItem = nil;
    SEL actSel = self.presetUI.disableGobackMode
    ? @selector(onCloseAction:)
    : @selector(onGoBackAction:);
    if (self.presetUI) {
        if (self.presetUI.navigationBackIconName) {
            UIImage *image = [[UIImage imageNamed:self.presetUI.navigationBackIconName]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            backBtnItem =
            [[UIBarButtonItem alloc] initWithImage:image
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:actSel];
        }
        else if (self.presetUI.navigationBackName) {
            backBtnItem =
            [[UIBarButtonItem alloc] initWithTitle:self.presetUI.navigationBackName
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:actSel];
        }
        
    }
    
    if (!backBtnItem) {
        if (self.ibt_isPushedIn && self.presetUI.disableGobackMode) {
            self.navigationItem.leftItemsSupplementBackButton = YES;
        }
        else {
            backBtnItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:actSel];
        }
    }
    
    return backBtnItem;
}

- (UIBarButtonItem *)closeBarButtonItem {
    UIBarButtonItem *closeBtnItem = nil;
    SEL actSel = @selector(onCloseAction:);
    if (self.presetUI) {
        if (self.presetUI.navigationCloseIconName) {
            UIImage *image = [[UIImage imageNamed:self.presetUI.navigationCloseIconName]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            closeBtnItem =
            [[UIBarButtonItem alloc] initWithImage:image
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:actSel];
        }
        else if (self.presetUI.navigationCloseName) {
            closeBtnItem =
            [[UIBarButtonItem alloc] initWithTitle:self.presetUI.navigationCloseName
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:actSel];
        }
        
    }
    
    if (!closeBtnItem) {
        closeBtnItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:actSel];
    }
    
    return closeBtnItem;
}

@end

///< ProgressBar

@implementation IBTWKWebViewController (ProgressBar)

#pragma mark - Public Method

- (void)updateProgressBarColor:(UIColor *)progressBarColor {
    self.progressBar.progressTintColor = progressBarColor;
}

#pragma mark - Private Method

- (void)setupProgressBar {
    if ([self isNavigationBarShow]) {
        [self.navigationController.navigationBar addSubview:self.progressBar];
    }
    else {
        [self.view addSubview:self.progressBar];
    }
}

@end
