//
//  IBTWebJSEventHandlerBase.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBTWebJSEventHandler.h"
#import "IBTJSEvent.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IBTWebJSEventHandlerBaseDelegate;
@interface IBTWebJSEventHandlerBase : NSObject <IBTWebJSEventHandler>

@property (strong, nonatomic) IBTJSEvent *currentEvent;
@property (weak, nonatomic) id<IBTWebJSEventHandlerBaseDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
