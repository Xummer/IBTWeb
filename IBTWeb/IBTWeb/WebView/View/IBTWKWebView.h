//
//  IBTWKWebView.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

@import WebKit;

#import "IBTWKWebViewDelegate.h"
#import "IBTWKWebViewInterface.h"

#define IBT_DISPATCH_MSG_NAME   @"ibtDispatchMessage"

NS_ASSUME_NONNULL_BEGIN

@interface IBTWKWebView : WKWebView <IBTWKWebViewInterface>

@end

NS_ASSUME_NONNULL_END
