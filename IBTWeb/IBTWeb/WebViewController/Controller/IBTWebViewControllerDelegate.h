//
//  IBTWebViewControllerDelegate.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBTWKWebViewInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IBTWebViewControllerDelegate <NSObject>
@optional
- (void)onWebViewDidStartLoad:(UIView <IBTWKWebViewInterface> *)webView;
- (void)onWebViewDidFinishLoad:(UIView <IBTWKWebViewInterface> *)webView;
- (NSURL *)webViewFailToLoad:(UIView <IBTWKWebViewInterface> *)webView
                       Error:(NSError *)error;
- (void)onWebViewWillClose:(NSDictionary *)info;
@end

NS_ASSUME_NONNULL_END
