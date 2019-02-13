//
//  IBTWKWebViewInterface.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol IBTWKWebViewDelegate;

@protocol IBTWKWebViewInterface <NSObject>
@property (assign, nonatomic) BOOL mediaPlaybackRequiresUserAction;
@property (assign, nonatomic) BOOL allowsInlineMediaPlayback;

@property (readonly, assign, nonatomic) NSURLRequest *request;

@property (weak, nonatomic) id <IBTWKWebViewDelegate> wvDelegate;

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id <IBTWKWebViewDelegate>)delegate;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)hmlt baseURL:(id)url;

- (void)evaluateJavaScriptFromString:(NSString *)jsStr
                     completionBlock:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))block;
- (void)enableJavaScriptPopup:(BOOL)popup;

@end

NS_ASSUME_NONNULL_END
