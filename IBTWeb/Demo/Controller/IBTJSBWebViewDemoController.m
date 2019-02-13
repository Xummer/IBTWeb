//
//  IBTJSBWebViewDemoController.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTJSBWebViewDemoController.h"

#import "IBTWKWebJSLogicImpl.h"

@interface IBTWKWebJSLogicImpl (Private)
- (NSString *)getJSBridgeAndPluginStr;
@end

@interface IBTWebJSBridgeJSLogicImpl: IBTWKWebJSLogicImpl

@end

@implementation IBTWebJSBridgeJSLogicImpl

- (NSString *)getJSBridgeAndPluginStr {
    NSString *js = [super getJSBridgeAndPluginStr];
    
    js =
    [NSString stringWithFormat:@"%@if (typeof window.WebViewJavascriptBridge === 'undefined') { var webjsbridge = { callHandler: IBTJSBridge.call, registerHandler: IBTJSBridge.on } ;try { Object.defineProperty(window, 'WebViewJavascriptBridge', { value: webjsbridge, writable: false}) } catch(sa) {};} var callbacks = window.WVJBCallbacks; delete window.WVJBCallbacks; for (var i=0; i<callbacks.length; i++) { callbacks[i](window.WebViewJavascriptBridge); }", js];
    
    return js;
}

@end

@interface IBTWKWebViewController (Private) <IBTWKWebJSLogicDelegate>
@property (nonatomic, strong, readwrite) IBTWKWebJSLogicImpl *jsLogicImpl;
@end

@implementation IBTJSBWebViewDemoController

#pragma mark - MPWKWebViewDelegate

- (NSString *)getPreInjectScriptStr {
    return @"if (typeof window.WVJBCallbacks === 'undefined'){window.WVJBCallbacks=[]};";
}

#pragma mark - Setter

- (void)setJsLogicImpl:(IBTWKWebJSLogicImpl *)logicImpl {
    IBTWebJSBridgeJSLogicImpl* mlogicImpl = [[IBTWebJSBridgeJSLogicImpl alloc] initWithDelegate:self];
    [super setJsLogicImpl:mlogicImpl];
}

@end
