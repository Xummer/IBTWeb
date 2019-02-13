//
//  IBTWebJSEventHandler_log.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandlerBase.h"

/**
 JS
 
 IBTJSBridge.log('string or object to log');
 
 or
 
 IBTJSBridge.invoke('log',{
    "msg" : "string or object to log",
 },function(res){
    // CallBack
 });
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface IBTWebJSEventHandler_log : IBTWebJSEventHandlerBase

@end

NS_ASSUME_NONNULL_END
