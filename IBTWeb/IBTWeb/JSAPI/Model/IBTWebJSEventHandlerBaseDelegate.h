//
//  IBTWebJSEventHandlerBaseDelegate.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IBTWKWebViewDelegate;
@protocol IBTWebJSEventHandlerBaseDelegate <NSObject>
- (UIViewController<IBTWKWebViewDelegate> *)webviewController;
@optional
- (id)isExistJSApis:(id)apis;
@end

NS_ASSUME_NONNULL_END
