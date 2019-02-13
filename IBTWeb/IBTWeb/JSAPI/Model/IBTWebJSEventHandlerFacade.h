//
//  IBTWebJSEventHandlerFacade.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBTWebJSEventHandlerBaseDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class IBTJSEvent, IBTWebJSEventHandlerBase;
@interface IBTWebJSEventHandlerFacade : NSObject

@property (strong, nonatomic) NSDictionary <NSString *, Class> *functionMap;

@property (weak, nonatomic) id<IBTWebJSEventHandlerBaseDelegate> delegate;

- (void)addExtraJSHandlers:(NSArray<NSString *> *)jsHandlers;

- (BOOL)canHandleJSEvent:(IBTJSEvent *)event;

- (void)handleJSEvent:(IBTJSEvent *)event;

- (NSMutableDictionary *)getExtraDataForEvent:(IBTJSEvent *)event;

- (__kindof IBTWebJSEventHandlerBase *)getExistedHandlerForFunction:(NSString *)functionName;

- (NSMutableDictionary *)extraDataForNextJSEventCalled:(NSString *)functionName;

@end

NS_ASSUME_NONNULL_END
