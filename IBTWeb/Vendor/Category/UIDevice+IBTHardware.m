//
//  UIDevice+IBTHardware.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#include <sys/sysctl.h>

#import "UIDevice+IBTHardware.h"

@implementation UIDevice (IBTHardware)

#pragma mark sysctlbyname utils

+ (id)ibt_getSysInfoByName:(char *)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *)ibt_platform {
    return [[self class] ibt_getSysInfoByName:"hw.machine"];
}

@end
