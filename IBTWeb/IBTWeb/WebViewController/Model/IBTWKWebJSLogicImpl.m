//
//  IBTWKWebJSLogicImpl.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWKWebJSLogicImpl.h"
#import "IBTWKWebViewInterface.h"
#import "IBTWKWebViewController.h"
#import "IBTWebJSEventHandlerFacade.h"
#import "IBTJSEvent.h"
#import "NSObject+IBTJSON.h"
#import "IBTMacro.h"

@interface IBTWKWebJSLogicImpl () <JSEventHandler, IBTWebJSEventHandlerBaseDelegate>
@property (weak, nonatomic) id <IBTWKWebJSLogicDelegate> delegate;
@property (strong, nonatomic) IBTWebJSEventHandlerFacade *jsEventHandlerFacade;
@property (strong, nonatomic) NSMutableArray<IBTJSEvent *> *jsEvents;
@end

@implementation IBTWKWebJSLogicImpl

#pragma mark - Life Cycle

- (instancetype)initWithDelegate:(id <IBTWKWebJSLogicDelegate>)delegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _delegate = delegate;
    _jsEvents = [NSMutableArray new];
    _jsEventHandlerFacade = [[IBTWebJSEventHandlerFacade alloc] init];
    _jsEventHandlerFacade.delegate = self;
    return self;
}

- (void)dealloc {
    for (IBTJSEvent *event in _jsEvents) {
        event.delegate = nil;
    }
}

#pragma mark - Private Method

- (IBTJSEvent *)jsEventWithFunction:(NSString *)function
                             params:(NSDictionary *)params
                         callBackID:(NSString *)cbId
{
    IBTJSEvent *event = [[IBTJSEvent alloc] initWithDelegate:self parameters:params];
    
    if (event) {
        event.funcName = function;
        event.callbackID = cbId;
        
        [_jsEvents addObject:event];
    }
    
    return event;
}

- (NSString *)getJSBridgeAndPluginStr {
    NSString *path =
    [[NSBundle mainBundle] pathForResource:@"ibtjs" ofType:@"js"];
    NSError *error = nil;
    NSString *str =
    [NSString stringWithContentsOfFile:path
                              encoding:NSUTF8StringEncoding
                                 error:&error];
    if (!error) {
        // TODO replace xx_yy with random id
        str =
        [NSString stringWithFormat:@"%@%@\n", str, @"document.__ibtjsjs__isLoaded = 'loaded';"];
        return str;
    }
    return @"";
}

#pragma mark - Public Method

- (void)addExtraJSHandlers:(NSArray<NSString *> *)jsHandlers {
    if (jsHandlers.count) {
        [_jsEventHandlerFacade addExtraJSHandlers:jsHandlers];
    }
}

- (void)tryInjectIbtJSBridge:(NSDictionary *)dictJsInfo {
    @weakify(self)
    [_webview evaluateJavaScriptFromString:@"document.__ibtjsjs__isLoaded;" completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
        @strongify(self)
        if (!([result isKindOfClass:[NSString class]] &&
              [result isEqualToString:@"loaded"])) {
            [self injectIbtJSBridge];
        }
        [self sysInitDocument:dictJsInfo];
    }];
}

- (void)sysInitDocument:(NSDictionary *)dictJsInfo {
    @weakify(self)
    [_webview evaluateJavaScriptFromString:@"document.__ibtjsjs__sysInit;" completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
        @strongify(self)
        if (!([result isKindOfClass:[NSString class]] &&
              [result isEqualToString:@"yes"])) {
            [self.webview evaluateJavaScriptFromString:@"document.__ibtjsjs__sysInit = 'yes'" completionBlock:NULL];
        }
        [self sendEventToJSBridge:@"sys:init" params:nil completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
        }];
    }];
}

- (void)injectIbtJSBridge {
    NSString *js = [self getJSBridgeAndPluginStr];
    
    @weakify(self)
    [_webview evaluateJavaScriptFromString:js completionBlock:^(id _Nullable result, NSError * _Nullable error) {
        @strongify(self)
        if (error) {
            self.bInjectJSFailed = YES;
        }
        else {
            self.bInjectJSFailed = NO;
        }
    }];
}

- (void)sendMessageToJSBridge:(NSString *)msg
              completionBlock:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))block
{
    if (msg.length == 0) {
        return;
    }
    
    NSString *js = [NSString stringWithFormat:@"if (window.IBTJSBridge){IBTJSBridge._handleMessageFromIBT(%@);}", msg];
    [_webview evaluateJavaScriptFromString:js completionBlock:^(id _Nullable result, NSError * _Nullable error) {
        // TODO log
        if (block) {
            block(result, error);
        }
    }];
}

- (void)sendEventToJSBridge:(NSString *)eventName
                     params:(NSDictionary *)params
            completionBlock:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))block
{
    if (eventName) {
        NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
        mdic[ @"__event_id" ] = eventName;
        mdic[ @"__params" ] = [params ?: @{} ibt_jsonString];
        mdic[ @"__msg_type" ] = @"event";
        
        NSString *str = [mdic ibt_jsonString];
        str = [str stringByReplacingOccurrencesOfString:@"\\/" withString: @"/"];
        
        mdic = [NSMutableDictionary dictionary];
        mdic[ @"__json_message" ] = str;
        
        str = [mdic ibt_jsonString];
        
        [self sendMessageToJSBridge:str completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
            if (block) {
                if (!([result isKindOfClass:[NSString class]]&&
                      [result isEqualToString:@"undefined"])) {
                    
                    NSDictionary *dict = [result ibt_jsonValue];
                    if (!dict) {
                        block(dict, error);
                    }
                    else {
                        block(result, error);
                    }
                }
                else {
                    block(result, error);
                }
            }
        }];
    }
}

- (void)handleJSApiDispatchMessage:(NSString *)message {
    if ([self.webviewController isKindOfClass:[IBTWKWebViewController class]]) {
        
        NSDictionary *dict = [message ibt_jsonValue];
        NSString *qStr = dict[ @"__msg_queue" ];
        NSArray *arr = [qStr ibt_jsonValue];
        
        for (NSString *dicStr in arr) {
            NSDictionary *msgDict = [dicStr ibt_jsonValue];
            if ([msgDict[ @"__msg_type" ] isEqualToString:@"call"]) {
                NSString *funcName = msgDict[ @"func" ];
                NSDictionary *paramsDic = msgDict[ @"params" ];
                NSString *callbackId= msgDict[ @"__callback_id" ];
                [self functionCall:funcName
                        withParams:paramsDic
                    withCallbackID:callbackId];
            }
        }
    }
}

- (void)functionCall:(NSString *)funcName
          withParams:(NSDictionary *)params
      withCallbackID:(NSString *)callbackID
{
    DebugLog(@"[webview]jsapi function call. %@ - %@ callback %@", self.webviewController, funcName, callbackID);
    
    IBTJSEvent *event =
    [self jsEventWithFunction:funcName params:params callBackID:callbackID];
    
    if ([_jsEventHandlerFacade canHandleJSEvent:event]) {
        [_jsEventHandlerFacade handleJSEvent:event];
    }
    
}

- (void)cleanJSAPIDelegate {
    _jsEventHandlerFacade.delegate = nil;
    
    for (IBTJSEvent *event in _jsEvents) {
        event.delegate = nil;
    }
    
}

#pragma mark - IBTWebJSEventHandlerBaseDelegate

- (UIViewController<IBTWKWebViewDelegate> *)webviewController {
    if (self.delegate) {
        return [self.delegate getCurrentWebviewViewController];
    }
    
    return nil;
}

#pragma mark - JSEventHandler

- (UIViewController<IBTWKWebViewDelegate> *)GetCurrentWebviewViewController {
    return self.webviewController;
}

- (void)onEndEvent:(IBTJSEvent *)event withResult:(id)result {
    DebugLog(@"[webview]jsapi function return. %@ - %@ callback %@", self.webviewController, event.funcName, event.callbackID);
    
    if ([_jsEvents containsObject:event]) {
        NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
        mdic[ @"__params" ] = [result ? : @{} ibt_jsonString];
        mdic[ @"__msg_type" ] = @"callback";
        if (event.callbackID.length) {
            mdic[ @"__callback_id" ] = event.callbackID;
        }
        
        NSString *str = [mdic ibt_jsonString];
        str = [str stringByReplacingOccurrencesOfString:@"\\/" withString: @"/"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishedHandleJSApi)]) {
            [self.delegate onFinishedHandleJSApi];
        }
        
        mdic = [NSMutableDictionary dictionary];
        mdic[ @"__json_message" ] = str;
        
        str = [mdic ibt_jsonString];
        [self sendMessageToJSBridge:str completionBlock:NULL];
        
        [_jsEvents removeObject:event];
    }
    else {
        DebugLog(@"[webview]jsapi event not found. %@ - %@ callback %@", self.webviewController, event.funcName, event.callbackID);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishedHandleJSApi)]) {
            [self.delegate onFinishedHandleJSApi];
        }
    }
}

@end

