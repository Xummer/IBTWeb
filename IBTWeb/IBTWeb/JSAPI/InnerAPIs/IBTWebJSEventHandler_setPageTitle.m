//
//  IBTWebJSEventHandler_setPageTitle.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_setPageTitle.h"

@implementation IBTWebJSEventHandler_setPageTitle

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    NSDictionary *params = event.params;
    if (params &&
        [params[ @"title" ] isKindOfClass:[NSString class]]) {
        
        NSString *title = params[ @"title" ];
        
        [facade.delegate webviewController].title = title;
        
        [event endWithError:@"setPageTitle:ok"];
    }
    else {
        [event endWithError:@"setPageTitle:fail_missing arguments"];
    }
}

@end
