//
//  IBTWebJSEventHandlerBase.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandlerBase.h"
#import "IBTWebJSEventHandlerBaseDelegate.h"
#import "IBTWKWebViewDelegate.h"

@implementation IBTWebJSEventHandlerBase

#pragma mark - Life Cycle
//- (instancetype)init {
//    self = [super init];
//    if ([self conformsToProtocol:@protocol(MPWebJSEventHandler)]) {
//        self.child = (id<MPWebJSEventHandler>)self;
//    } else {
//        // 不遵守这个protocol的就让他crash，防止派生类乱来。
//        NSAssert(NO, @"子类必须要实现 <MPWebJSEventHandler> 这个 protocol。");
//    }
//    return self;
//}

- (void)dealloc {
    self.currentEvent.delegate = nil;
}

#pragma mark -  MPWebJSEventHandler

+ (NSArray <Class> *)eventHandlersClassArray {
    return @[ self ];
}

+ (NSDictionary *)mapDict {
    
    NSArray *clsArr = [self eventHandlersClassArray];
    
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    for (Class cls in clsArr) {
        NSString *key =
        [NSStringFromClass(cls) stringByReplacingOccurrencesOfString:@"IBTWebJSEventHandler_" withString:@""];
        Class value = cls;
        
        if (key && value) {
            mdict[ key ] = value;
        }
    }
    
    return [mdict copy];
    
}

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data {
    // subclass to implement
}

#pragma mark - Private Method
- (UIViewController<IBTWKWebViewDelegate> *)webviewController {
    return self.delegate ? [self.delegate webviewController] : nil;
}

@end
