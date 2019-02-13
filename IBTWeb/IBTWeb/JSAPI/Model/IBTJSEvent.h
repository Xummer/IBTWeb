//
//  IBTJSEvent.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSEventHandler;
@interface IBTJSEvent : NSObject
@property (copy, nonatomic) NSString *funcName;
@property (strong, nonatomic) NSDictionary *params;
@property (copy, nonatomic) NSString *callbackID;

@property (weak, nonatomic) id <JSEventHandler> delegate;

- (instancetype)initWithDelegate:(id <JSEventHandler>)delegate
                      parameters:(NSDictionary *)parameters;

- (void)endWithResult:(id)result;

- (void)endWithError:(NSString *)error
      andDescription:(NSString *)description;

- (void)endWithError:(NSString *)error;

@end

@protocol IBTWKWebViewDelegate;
@protocol JSEventHandler
- (UIViewController <IBTWKWebViewDelegate> *)GetCurrentWebviewViewController;
- (void)onEndEvent:(IBTJSEvent *)event withResult:(id)result;
@end

NS_ASSUME_NONNULL_END
