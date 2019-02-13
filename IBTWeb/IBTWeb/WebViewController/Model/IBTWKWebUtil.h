//
//  IBTWKWebUtil.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBTWKWebUtil : NSObject

+ (NSString *)fomatedURLStr:(NSString *)urlStr;

+ (void)openUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
