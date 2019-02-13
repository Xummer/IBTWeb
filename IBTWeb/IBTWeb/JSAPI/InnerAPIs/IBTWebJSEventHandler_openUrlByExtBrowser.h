//
//  IBTWebJSEventHandler_openUrlByExtBrowser.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandlerBase.h"

/**
 JS
 
 IBTJSBridge.invoke('openUrlByExtBrowser',{
    "url" : "http://www.qq.com",
 },function(res){
    // CallBack
 });
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface IBTWebJSEventHandler_openUrlByExtBrowser : IBTWebJSEventHandlerBase

@end

NS_ASSUME_NONNULL_END
