//
//  IBTWebJSEventHandler.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBTWebJSEventHandlerFacade.h"

NS_ASSUME_NONNULL_BEGIN

@class IBTJSEvent;
@protocol IBTWebJSEventHandler <NSObject>

+ (NSArray <Class> *)eventHandlersClassArray;

+ (NSDictionary *)mapDict;

- (void)handleJSEvent:(IBTJSEvent *)event
        HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
            ExtraData:(id)data;

@end

NS_ASSUME_NONNULL_END
