//
//  IBTWebJSEventHandler_openUrlByExtBrowser.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_openUrlByExtBrowser.h"

@implementation IBTWebJSEventHandler_openUrlByExtBrowser

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    NSDictionary *params = event.params;
    if (params &&
        [params[ @"url" ] isKindOfClass:[NSString class]] &&
        [params[ @"url" ] length]) {
        NSURL *url = [NSURL URLWithString:params[ @"url" ]];
        
        if (@available(iOS 10.0, *)) {
            
            // 如果使用非即时的回调，如 Block, 需要暂时 Retain self 防止被释放
            
            __block id retainedSelf = self;
            
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    [event endWithError:@"openUrlByExtBrowser:ok"];
                }
                else {
                    [event endWithError:@"openUrlByExtBrowser:fail"];
                }
                
                // 释放 retained Self
                
                retainedSelf = nil;
            }];
        }
        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            BOOL success = [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
            if (success) {
                [event endWithError:@"openUrlByExtBrowser:ok"];
            }
            else {
                [event endWithError:@"openUrlByExtBrowser:fail"];
            }
        }
    }
    else {
        [event endWithError:@"missing auguments"];
    }
}

@end
