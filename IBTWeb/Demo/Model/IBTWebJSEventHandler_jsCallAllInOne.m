//
//  IBTWebJSEventHandler_jsCallAllInOne.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_jsCallAllInOne.h"
#import "IBTWebJSEventHandler_alert.h"
#import "IBTWebJSEventHandler_jsCallQueryAPP.h"
#import "IBTWebJSEventHandler_testCallFromOC.h"

#import "IBTWKWebViewController.h"
#import "IBTWKWebJSLogicImpl.h"

@interface IBTWebJSEventHandler_jsCallAllInOne ()

@property (nonatomic, strong) NSDictionary *subFunctionMap;

@end

@implementation IBTWebJSEventHandler_jsCallAllInOne

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.subFunctionMap = [[self class] mapDict];
    
    return self;
}


#pragma mark - MPWebJSEventHandler

// 多个 Handler
+ (NSArray<Class> *)eventHandlersClassArray {
    return @[ self,
              [IBTWebJSEventHandler_alert class],
              [IBTWebJSEventHandler_jsCallQueryAPP class],
              [IBTWebJSEventHandler_testCallFromOC class]];
}

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    NSDictionary *params = event.params;
    NSString *functionName = params[ @"method" ];
    if (_subFunctionMap[ functionName ]) {
        UIViewController <IBTWKWebViewDelegate> * webVC =
        [self.delegate webviewController];
        
        if ([webVC isKindOfClass:[IBTWKWebViewController class]]) {
            
            id oParams = params[ @"params" ];
            
            NSDictionary *dictParams = nil;
            if ([oParams isKindOfClass:[NSDictionary class]]) {
                dictParams = oParams;
            }
            else if (oParams) {
                dictParams = @{ @"params" : oParams };
            }
            else {
                dictParams = @{};
            }
            
            IBTWKWebJSLogicImpl *jsLogicImpl = ((IBTWKWebViewController *)webVC).jsLogicImpl;
            
            // Handle [event endWithError:] inside the |functionCall:withParams:withCallbackID:|
            
            [jsLogicImpl functionCall:functionName withParams:dictParams withCallbackID:event.callbackID];
        }
        else {
            [event endWithError:@"jsCallAllInOne:fail|enviroment error"];
        }
    }
    else {
        [event endWithError:@"jsCallAllInOne:fail|can not find method"];
    }
}

@end
