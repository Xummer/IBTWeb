//
//  IBTJSEvent.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTJSEvent.h"
#import "IBTWKWebViewDelegate.h"

@implementation IBTJSEvent

#pragma mark - Life Cycle

- (instancetype)initWithDelegate:(id <JSEventHandler>)delegate
                      parameters:(NSDictionary *)parameters
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    _delegate = delegate;
    
    return self;
}

#pragma mark - Private Method

- (UIViewController <IBTWKWebViewDelegate> *)webviewController {
    return self.delegate ? [self.delegate GetCurrentWebviewViewController] : nil;
}

#pragma mark - Public Method

- (void)endWithResult:(id)result {
    if (self.delegate) {
        [self.delegate onEndEvent:self withResult:result];
    }
}

- (void)endWithError:(NSString *)error {
    [self endWithResult:@{ @"err_msg": error ?: @""}];
}

- (void)endWithError:(NSString *)error
      andDescription:(NSString *)description {
    [self endWithResult:@{ @"err_msg": error ?: @"",
                           @"err_desc": description ?: @""
                           }];
}

@end
