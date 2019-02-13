//
//  IBTWebJSEventHandler_jsCallQueryAPP.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_jsCallQueryAPP.h"
#import "IBTMacro.h"

@implementation IBTWebJSEventHandler_jsCallQueryAPP

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    NSString *bundleID = event.params[ @"params" ];
    if (bundleID) {
        DebugLog(@"Check BundleID:%@", bundleID);
        [event endWithResult:@{ @"code": @(200),
                                @"versioncode": @"100"
                                }];
    }
    else {
        [event endWithError:@"jsCallQueryAPP:fail| cannot find bundleID"];
    }
}

@end
