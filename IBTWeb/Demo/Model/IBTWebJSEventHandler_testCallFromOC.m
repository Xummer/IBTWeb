//
//  IBTWebJSEventHandler_testCallFromOC.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_testCallFromOC.h"
#import "IBTWKWebViewController.h"
#import "IBTWKWebJSLogicImpl.h"
#import "IBTMacro.h"

@implementation IBTWebJSEventHandler_testCallFromOC

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    UIViewController <IBTWKWebViewDelegate> *webVC = [facade.delegate webviewController];
    
    if ([webVC isKindOfClass:[IBTWKWebViewController class]]) {
        IBTWKWebViewController *wkWebVC = (id)webVC;
        
        /**
         // 注册给 OC 调用的 Event
         IBTJSBridge.on("callFromOC", function(resDict) {
             // resDict { "param" : "value" }
             IBTJSBridge.invoke('alert',{
                "msg" : resDict[ "param1" ] ? resDict[ "param1" ] : "callFromOC(no params)",
             },function(res){
                IBTJSBridge.log(res);
             });
         })
         */
        
        // OC 调用 JS 中注册的 Event |callFromOC|
        [wkWebVC.jsLogicImpl sendEventToJSBridge:@"callFromOC"
                                          params:@{ @"param" : @"I'm the Parameters from OC!!!"}completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
                                              if (result) {
                                                  DebugLog(@"%@", result);
                                              }
                                          }];
        
        [event endWithError:@"testCallFromOC:ok"];
    }
    else {
        [event endWithError:@"testCallFromOC:fail"];
    }
}

@end
