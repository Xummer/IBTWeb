//
//  NSObject+IBTJSON.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "NSObject+IBTJSON.h"

@implementation NSObject (IBTJSON)

- (NSString *)ibt_jsonString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    
    if (error || !jsonData) return nil;
    
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}

- (id)ibt_jsonValue {
    NSError *error = nil;
    NSData *jsonData = nil;
    
    if ([self isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
    }
    else {
        jsonData = (NSData *)self;
    }
    
    id result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:kNilOptions
                                                  error:&error];
    if (error || !result) return nil;
    
    return result;
}

@end
