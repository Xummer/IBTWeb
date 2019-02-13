//
//  IBTWebJSEventHandler_log.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_log.h"
#import "IBTMacro.h"

@implementation IBTWebJSEventHandler_log

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    NSDictionary *params = event.params;
    
    if (params &&
        params[ @"msg" ]) {
        id msg = params[ @"msg" ];
        
        if (![msg isKindOfClass:[NSString class]]) {
            msg = [msg description];
        }
        
        NSString *logMsg = [NSString stringWithFormat:@"[js-%@]:%@", event.funcName, msg];
        
        DebugLog(@"%@", logMsg);
        
        [event endWithError:@"log|ok"];
    }
    else {
        [event endWithError:@"missing auguments"];
    }
}

@end
