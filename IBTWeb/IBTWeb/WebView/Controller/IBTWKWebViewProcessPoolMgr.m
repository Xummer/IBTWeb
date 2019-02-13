//
//  IBTWKWebViewProcessPoolMgr.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWKWebViewProcessPoolMgr.h"
#import "IBTServiceCenter.h"

@interface IBTWKWebViewProcessPoolMgr ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, WKProcessPool *> *dicUsrName2Pool;
@end

@implementation IBTWKWebViewProcessPoolMgr

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _dicUsrName2Pool = [NSMutableDictionary dictionary];
    
    return self;
}

#pragma mark - Public Method

+ (instancetype)shareInstance {
    return IBTServiceWithName(IBTWKWebViewProcessPoolMgr);
}

- (WKProcessPool *)processPool {
    NSString *userName = @"default";
    WKProcessPool *pool = _dicUsrName2Pool[ userName ];
    if (!pool) {
        pool = [[WKProcessPool alloc] init];
        _dicUsrName2Pool[ userName ] = pool;
    }
    return pool;
}

@end
