//
//  IBTWebJSEventHandler_disableBounceScroll.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_disableBounceScroll.h"
#import "IBTWKWebViewDelegate.h"

@implementation IBTWebJSEventHandler_disableBounceScroll

#pragma mark -  IBTWebJSEventHandler

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data
{
    UIViewController <IBTWKWebViewDelegate> *webVC = [facade.delegate webviewController];
    if ([webVC respondsToSelector:@selector(setDisableWebViewScrollViewBounces)]) {
        [webVC setDisableWebViewScrollViewBounces];
        
        [event endWithError:@"disableBounceScroll:ok"];
    }
    else {
        [event endWithError:@"disableBounceScroll:fail"];
    }
}
@end
