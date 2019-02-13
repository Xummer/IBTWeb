//
//  IBTWebJSEventHandler_closeWindow.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_closeWindow.h"
#import "IBTWKWebViewController.h"
#import "IBTWKWebView.h"
#import "IBTMacro.h"

@implementation IBTWebJSEventHandler_closeWindow

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    BOOL isEventHandled = NO;
    
    NSDictionary *params = event.params;
    if (params) {
        UIViewController <IBTWKWebViewDelegate> * webVC =
        [self.delegate webviewController];
        if ([webVC.navigationController.viewControllers count] > 0) {
            if ([webVC.navigationController.viewControllers lastObject] != webVC) {
                [event endWithError:@"closeWindow:fail|wrong level"];
                isEventHandled = YES;
                DebugLog(@"hanlde webview close window jsapi wrong level");
            }
            else {
                if ([webVC isKindOfClass:[IBTWKWebViewController class]]) {
                    DebugLog(@"hanlde webview close window jsapi");
                    
                    IBTWKWebViewController *mWebVC = (id)webVC;
                    if ([mWebVC.delegate respondsToSelector:@selector(onWebViewWillClose:)]) {
                        [mWebVC.delegate onWebViewWillClose:params];
                    }
                    
                    [mWebVC.webView evaluateJavaScriptFromString:@"document.__ibtjsjs__isWebviewWillClosed='yes';" completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
                        
                    }];
                    
                    if ([params[@"immediate_close"] integerValue]) {
                        [mWebVC immediateDismissWebViewController];
                    }
                    else {
                        [mWebVC dismissWebViewController];
                    }
                    
                    [event endWithError:@"closeWindow:ok"];
                    isEventHandled = YES;
                }
            }
        }
    }
    
    if (!isEventHandled) {
        [event endWithError:@"closeWindow:fail"];
    }
}

@end
