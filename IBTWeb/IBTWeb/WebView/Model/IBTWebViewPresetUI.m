//
//  IBTWebViewPresetUI.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWebViewPresetUI.h"

@implementation IBTWebViewPresetUI

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.showCloseButton = NO;
    
    return self;
}

@end
