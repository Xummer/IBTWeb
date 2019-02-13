//
//  IBTWKWebUtil.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "IBTWKWebUtil.h"
#import <UIKit/UIKit.h>

@implementation IBTWKWebUtil

+ (NSString *)fomatedURLStr:(NSString *)urlStr {
    if ([urlStr hasSuffix:@"/"]) {
        urlStr = [urlStr substringToIndex:urlStr.length-1];
    }
    return urlStr;
}

+ (void)openUrl:(NSURL *)url {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:NULL];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
    }
}

@end
