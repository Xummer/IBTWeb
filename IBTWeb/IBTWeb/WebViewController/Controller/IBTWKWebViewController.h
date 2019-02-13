//
//  IBTWKWebViewController.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IBTWebViewPresetUI.h"
#import "IBTWKWebViewDelegate.h"
#import "IBTWebViewControllerDelegate.h"

@protocol IBTWKWebViewDelegate;

@class IBTWKWebView, IBTWKWebJSLogicImpl;

NS_ASSUME_NONNULL_BEGIN

@interface IBTWKWebViewController : UIViewController  <IBTWKWebViewDelegate>

@property (nonatomic, readonly) IBTWKWebView *webView;
@property (nonatomic, readonly) IBTWKWebJSLogicImpl *jsLogicImpl;
@property (nonatomic, weak) id <IBTWebViewControllerDelegate> delegate;

/**
 钦定的初始化
 
 @param url          请求的具体地址和设置
 @param extraInfo    可扩展额外的设定
 @param presetUI     UI 设定
 @discussion extraInfo 具体的格式
 @{ @"jsHandles": @[ @"jsHandleName", ],
 @"httpHeader": @{ @"key": @"value", },
 }
 */
- (instancetype)initWithUrl:(id)url
                  extraInfo:(NSDictionary *)extraInfo
                   presetUI:(IBTWebViewPresetUI *)presetUI;

- (void)dismissWebViewController;

- (void)immediateDismissWebViewController;
@end

NS_ASSUME_NONNULL_END
