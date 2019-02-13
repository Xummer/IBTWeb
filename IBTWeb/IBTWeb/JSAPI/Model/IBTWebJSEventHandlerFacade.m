//
//  IBTWebJSEventHandlerFacade.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebJSEventHandlerFacade.h"
#import "IBTWebJSEventHandlerBase.h"
#import "IBTJSEvent.h"

@interface IBTWebJSEventHandlerFacade ()
@property (strong, nonatomic) NSMutableDictionary <NSString *, __kindof IBTWebJSEventHandlerBase *> *functionHandlers;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableDictionary *> *functionCallExtraDataMap;
@end

@implementation IBTWebJSEventHandlerFacade
#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.functionHandlers = [NSMutableDictionary new];
    self.functionCallExtraDataMap = [NSMutableDictionary new];
    
    [self setupDefaultEventHandlers];
    
    return self;
}

#pragma mark - Private Method

- (void)setupDefaultEventHandlers {
    // TODO add more default js handlers
    
    NSArray *jsFuncStrArr =
    @[ @"openUrlByExtBrowser",
       @"log",
       @"setPageTitle",
       @"disableBounceScroll",
       @"closeWindow",
       ];
    
    [self addExtraJSHandlers:jsFuncStrArr];
}

#pragma mark - Public Method

- (void)addExtraJSHandlers:(NSArray<NSString *> *)jsFuncStrArr {
    
    NSMutableDictionary *mdic =
    [[NSMutableDictionary alloc] initWithDictionary:self.functionMap];
    
    for (NSString *funcStr in jsFuncStrArr) {
        Class <IBTWebJSEventHandler> clz = NSClassFromString([NSString stringWithFormat:@"IBTWebJSEventHandler_%@", funcStr]);
        if (clz) {
            NSDictionary *mapDic = [clz mapDict];
            if (mapDic) {
                [mdic addEntriesFromDictionary:mapDic];
            }
        }
    }
    
    self.functionMap = [mdic copy];
}

- (void)setDelegate:(id<IBTWebJSEventHandlerBaseDelegate>)delegate {
    _delegate = delegate;
    
    for (IBTWebJSEventHandlerBase *hander in [self.functionHandlers allValues]) {
        hander.delegate = delegate;
    }
}

- (void)handleJSEvent:(IBTJSEvent *)event {
    IBTWebJSEventHandlerBase *handler = [self handlerForFunction:event.funcName];
    if (handler.currentEvent != event) {
        handler.currentEvent.delegate = nil;
    }
    
    handler.currentEvent = event;
    
    [handler handleJSEvent:event
             HandlerFacade:self
                 ExtraData:_functionCallExtraDataMap[event.funcName]];
    
    [_functionHandlers removeObjectForKey:event.funcName];
}

- (NSMutableDictionary *)getExtraDataForEvent:(IBTJSEvent *)event {
    return _functionCallExtraDataMap[event.funcName];
}

- (__kindof IBTWebJSEventHandlerBase *)getExistedHandlerForFunction:(NSString *)functionName {
    return _functionHandlers[ functionName ];
}

- (__kindof IBTWebJSEventHandlerBase *)handlerForFunction:(NSString *)funcName {
    IBTWebJSEventHandlerBase *handler = _functionHandlers[ funcName ];
    if (!handler) {
        Class clz = _functionMap[ funcName ];
        if (clz) {
            handler = [[clz alloc] init];
            if (handler) {
                handler.delegate = _delegate;
                _functionHandlers[ funcName ] = handler;
            }
        }
    }
    
    return handler;
}

- (BOOL)canHandleJSEvent:(IBTJSEvent *)event {
    return _functionMap[ event.funcName ] != nil;
}

- (NSMutableDictionary *)extraDataForNextJSEventCalled:(NSString *)functionName {
    if (!functionName) {
        return nil;
    }
    NSMutableDictionary *extraData = _functionCallExtraDataMap[ functionName ];
    if (!extraData) {
        extraData = [NSMutableDictionary dictionary];
        _functionCallExtraDataMap[ functionName ] = extraData;
    }
    
    return extraData;
}

@end
