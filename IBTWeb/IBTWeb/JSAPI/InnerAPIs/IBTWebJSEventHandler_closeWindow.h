//
//  IBTWebJSEventHandler_closeWindow.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandlerBase.h"

/**
 JS
 
 IBTJSBridge.invoke('closeWindow',{
    "immediate_close" : "1",
 },function(res){
    // CallBack
 });
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface IBTWebJSEventHandler_closeWindow : IBTWebJSEventHandlerBase

@end

NS_ASSUME_NONNULL_END
