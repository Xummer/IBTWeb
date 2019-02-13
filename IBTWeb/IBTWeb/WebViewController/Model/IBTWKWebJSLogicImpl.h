//
//  IBTWKWebJSLogicImpl.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IBTWKWebViewInterface, IBTWKWebJSLogicDelegate;
@class IBTWebJSEventHandlerBase;

@interface IBTWKWebJSLogicImpl: NSObject
@property (weak, nonatomic) UIView <IBTWKWebViewInterface> *webview;
@property (assign, nonatomic) BOOL bInjectJSFailed;

- (instancetype)initWithDelegate:(id <IBTWKWebJSLogicDelegate>)delegate;

- (void)tryInjectIbtJSBridge:(NSDictionary *)dictJsInfo;

- (void)addExtraJSHandlers:(NSArray<NSString *> *)jsHandlers;

- (void)sendMessageToJSBridge:(NSString *)msg
              completionBlock:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))block;

- (void)sendEventToJSBridge:(NSString *)eventName
                     params:(NSDictionary *)params
            completionBlock:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))block;

- (void)handleJSApiDispatchMessage:(NSString *)message;

- (void)functionCall:(NSString *)callName
          withParams:(NSDictionary *)params
      withCallbackID:(NSString *)callbackID;

@end

@protocol IBTWKWebViewDelegate;
@protocol IBTWKWebJSLogicDelegate <NSObject>
- (UIViewController<IBTWKWebViewDelegate> *)getCurrentWebviewViewController;
@optional
- (void)onFinishedHandleJSApi;
@end

NS_ASSUME_NONNULL_END
