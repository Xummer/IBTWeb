//
//  IBTWKWebViewProcessPoolMgr.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTService.h"

NS_ASSUME_NONNULL_BEGIN

@import WebKit;

@interface IBTWKWebViewProcessPoolMgr : IBTService <IBTService>

+ (instancetype)shareInstance;

- (WKProcessPool *)processPool;

@end

NS_ASSUME_NONNULL_END
