//
//  IBTWebJSEventHandler_setPageTitle.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandlerBase.h"

/**
 JS
 
 IBTJSBridge.invoke('setPageTitle',{
    "title" : "title name",
 },function(res){
    // CallBack
 });
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface IBTWebJSEventHandler_setPageTitle : IBTWebJSEventHandlerBase

@end

NS_ASSUME_NONNULL_END
