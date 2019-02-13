//
//  IBTWKWebView.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWKWebView.h"
#import "IBTWKWebViewProcessPoolMgr.h"
#import "IBTWKWebViewScriptMessageHandler.h"
#import "IBTWKWebViewInterface.h"
#import "IBTWKWebViewDelegate.h"
#import "IBTWKWebviewController.h"
#import "UIView+IBTExtend.h"
#import "IBTMacro.h"

@interface IBTWKWebView () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

///> IBTWKWebViewInterface

@property (strong, nonatomic) IBTWKWebViewScriptMessageHandler *scriptMessageHandler;

@property (assign, nonatomic) BOOL bDisablePopup;

@end

@implementation IBTWKWebView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame configuration:[self defaultConfigurationWithPreInjectJSStr:nil hookJSStr:nil]];
    if (!self) {
        return nil;
    }
    
    self.navigationDelegate = self;
    self.UIDelegate = self;
    
    return self;
}

- (void)dealloc {
    self.scriptMessageHandler.delegate = nil;
    [self.configuration.userContentController removeScriptMessageHandlerForName:IBT_DISPATCH_MSG_NAME];
    
    //    [self.configuration.userContentController removeScriptMessageHandlerForName:@"invokeHandler"];
    
    //    [self.configuration.userContentController removeScriptMessageHandlerForName:@"publishHandler"];
}

#pragma mark - Public Method


#pragma mark - Private Method

- (WKWebViewConfiguration *)defaultConfigurationWithPreInjectJSStr:(NSString *)preInjectJSStr
                                                         hookJSStr:(NSString *)hookJSStr
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = [IBTWKWebViewProcessPoolMgr shareInstance].processPool;
    
    self.allowsInlineMediaPlayback = YES;
    
    if (@available(iOS 8.0, *)) {
        self.mediaPlaybackRequiresUserAction = YES;
    }
    
    WKUserContentController *content = config.userContentController;
    
    if (preInjectJSStr.length > 0) {
        WKUserScript *script =
        [[WKUserScript alloc] initWithSource:preInjectJSStr
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                            forMainFrameOnly:YES];
        
        [content addUserScript:script];
    }
    
    if (hookJSStr.length > 0) {
        WKUserScript *script =
        [[WKUserScript alloc] initWithSource:hookJSStr
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                            forMainFrameOnly:NO];
        
        [content addUserScript:script];
    }
    
    self.scriptMessageHandler = [[IBTWKWebViewScriptMessageHandler alloc] init];
    
    _scriptMessageHandler.delegate = self;
    
    [content addScriptMessageHandler:_scriptMessageHandler
                                name:IBT_DISPATCH_MSG_NAME];
    
    return config;
}

- (void)makeAllowDecision:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // TODO
    
    BOOL decision = YES;
    
    decisionHandler(decision ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (self.wvDelegate &&
        [self.wvDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:isMainFrame:)])
    {
        BOOL decision =
        [self.wvDelegate webView:self
      shouldStartLoadWithRequest:navigationAction.request
                  navigationType:navigationAction.navigationType
                     isMainFrame:navigationAction.targetFrame.isMainFrame];
        
        if (decision) {
            [self makeAllowDecision:decisionHandler];
        }
        else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        
    }
    else {
        [self makeAllowDecision:decisionHandler];
    }
}

- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (self.wvDelegate &&
        [self.wvDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.wvDelegate webViewDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    if (self.wvDelegate &&
        [self.wvDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.wvDelegate webView:self didFailLoadWithError:error];
    }
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation
{
    if (self.wvDelegate &&
        [self.wvDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.wvDelegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    if (self.wvDelegate &&
        [self.wvDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.wvDelegate webView:self didFailLoadWithError:error];
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    // TODO Log [self estimatedProgress]
    if (self.wvDelegate &&
        [self.wvDelegate respondsToSelector:@selector(webViewContentProcessDidTerminate:)]) {
        [self.wvDelegate webViewContentProcessDidTerminate:self];
    }
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler
{
    if (_bDisablePopup) {
        DebugLog(@"webViewController disabled input! msg=%@", message);
        return;
    }
    
    UIViewController *vc = [self ibt_firstAvailableUIViewController];
    
    if (vc) {
        // make sure if the vc is the TopViewController
        
        if ([vc isViewLoaded]
            && vc.view.window) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:frame.request.URL.host message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                completionHandler();
            }])];
            
            DebugLog(@"show alert in view controller : %@", vc);
            
            [vc presentViewController:alertController animated:YES completion:nil];
        }
        else {
            DebugLog(@"webViewController is not visiable, don't alert");
        }
    }
    else {
        DebugLog(@"webViewController is nil ignore alert! msg=%@", message);
    }
    
}

- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL))completionHandler
{
    
    if (_bDisablePopup) {
        DebugLog(@"webViewController disabled input! msg=%@", message);
        return;
    }
    
    UIViewController *vc = [self ibt_firstAvailableUIViewController];
    
    // make sure if the vc is the TopViewController
    if ([vc isViewLoaded]
        && vc.view.window) {
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:frame.request.URL.host
                                            message:message?:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(NO);
        }])];
        [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(YES);
        }])];
        [vc presentViewController:alertController animated:YES completion:nil];
    }
    else {
        DebugLog(@"webViewController is not visiable, don't show input panel");
    }
}

- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    if (_bDisablePopup) {
        DebugLog(@"webViewController disabled input! msg=%@", prompt);
        return;
    }
    
    UIViewController *vc = [self ibt_firstAvailableUIViewController];
    
    // make sure if the vc is the TopViewController
    if ([vc isViewLoaded]
        && vc.view.window) {
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:frame.request.URL.host
                                            message:prompt
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = defaultText;
        }];
        [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(alertController.textFields[0].text?:@"");
        }])];
        [vc presentViewController:alertController animated:YES completion:nil];
    }
    else {
        DebugLog(@"webViewController is not visiable, don't show input panel");
    }
}

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // 决定是否新窗口打开
    if (!navigationAction.targetFrame.isMainFrame) {
        [self performSelector:@selector(loadRequest:) withObject:navigationAction.request afterDelay:0];
    }
    return nil;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    DebugLog(@"receive message from wkWebView and name:%@", message.name);
    
    if (self.wvDelegate &&
        [self.wvDelegate respondsToSelector:@selector(webviewDidReceiveScriptMessage:handler:)]) {
        [self.wvDelegate webviewDidReceiveScriptMessage:message.name
                                                handler:message.body];
    }
}

#pragma mark - IBTWKWebViewInterface

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<IBTWKWebViewDelegate>)delegate {
    
    NSString *preInjectJS = nil;
    if (delegate &&
        [delegate respondsToSelector:@selector(getPreInjectScriptStr)]) {
        preInjectJS = [delegate getPreInjectScriptStr];
    }
    
    NSString *hookJS = nil;
    if (delegate &&
        [delegate respondsToSelector:@selector(getHookScriptStr)]) {
        hookJS = [delegate getHookScriptStr];
    }
    
    self = [super initWithFrame:frame configuration:[self defaultConfigurationWithPreInjectJSStr:preInjectJS hookJSStr:hookJS]];
    if (!self) {
        return nil;
    }
    
    if (delegate) {
        BOOL allowInlinePlay = YES;
        if ([delegate respondsToSelector:@selector(allowsInlineMediaPlay)]) {
            allowInlinePlay= [delegate allowsInlineMediaPlay];
        }
        self.allowsInlineMediaPlayback = allowInlinePlay;
        
        BOOL autoPlay = NO;
        if ([delegate respondsToSelector:@selector(allowsAutoMediaPlay)]) {
            autoPlay = [delegate allowsAutoMediaPlay];
        }
        self.mediaPlaybackRequiresUserAction = autoPlay;
    }
    
    self.navigationDelegate = self;
    self.UIDelegate = self;
    self.wvDelegate = delegate;
    
    return self;
}

- (void)evaluateJavaScriptFromString:(NSString *)jsStr
                     completionBlock:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))block
{
    id strongSelf = self;
    [self evaluateJavaScript:jsStr completionHandler:^(id _Nullable resp, NSError * _Nullable error) {
        
        // Fixing crash bug on iOS 8
        [strongSelf title];
        
        if (block) {
            block(resp, error);
        }
    }];
}

- (void)enableJavaScriptPopup:(BOOL)popup {
    _bDisablePopup = !popup;
}

- (NSURLRequest *)request {
    NSURLRequest *req = nil;
    if (self.URL) {
        NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:self.URL];
        mReq.mainDocumentURL = self.URL;
        req = [mReq copy];
    }
    return req;
}

#pragma mark - Getter & Setter

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback {
    self.configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback;
}

- (BOOL)allowsInlineMediaPlayback {
    return self.configuration.allowsInlineMediaPlayback;
}

- (void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction {
    if (@available(iOS 10.0, *)) {
        self.configuration.mediaTypesRequiringUserActionForPlayback = mediaPlaybackRequiresUserAction ? WKAudiovisualMediaTypeAll : WKAudiovisualMediaTypeNone;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.configuration.mediaPlaybackRequiresUserAction = mediaPlaybackRequiresUserAction;
#pragma clang diagnostic pop
    }
}

- (BOOL)mediaPlaybackRequiresUserAction {
    if (@available(iOS 10.0, *)) {
        return self.configuration.mediaTypesRequiringUserActionForPlayback != WKAudiovisualMediaTypeNone;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return self.configuration.mediaPlaybackRequiresUserAction;
#pragma clang diagnostic pop
    }
}

@synthesize wvDelegate;

@end

