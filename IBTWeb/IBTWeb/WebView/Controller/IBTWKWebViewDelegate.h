//
//  IBTWKWebViewDelegate.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;

NS_ASSUME_NONNULL_BEGIN

@class IBTWKWebView;
@protocol IBTWKWebViewDelegate <NSObject>
@optional
- (NSString *)getHookScriptStr;
- (NSString *)getPreInjectScriptStr;

- (BOOL)allowsAutoMediaPlay;
- (BOOL)allowsInlineMediaPlay;

- (void)setDisableWebViewScrollViewBounces;

- (BOOL)webView:(IBTWKWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(WKNavigationType)navigationType
    isMainFrame:(BOOL)isMainframe;

- (void)webViewDidStartLoad:(IBTWKWebView *)webView;
- (void)webViewDidFinishLoad:(IBTWKWebView *)webView;
- (void)webViewContentProcessDidTerminate:(IBTWKWebView *)webView;
- (void)webView:(IBTWKWebView *)webView didFailLoadWithError:(NSError *)error;

- (void)webviewDidReceiveScriptMessage:(NSString *)name
                               handler:(id)bodyHandler;
@end

NS_ASSUME_NONNULL_END
