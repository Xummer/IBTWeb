//
//  IBTWebJSEventHandler_alert.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandler_alert.h"

@implementation IBTWebJSEventHandler_alert

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
        
        if (self.delegate.webviewController) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert From JS" message:msg?:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }])];
            
            [self.delegate.webviewController presentViewController:alertController animated:YES completion:nil];
            
            [event endWithError:@"alert:ok"];
        }
        else {
            [event endWithError:@"alert:fail cannot find view controller to present alert"];
        }
    }
    else {
        [event endWithError:@"missing auguments"];
    }
}

@end
