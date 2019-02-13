//
//  NSObject+IBTJSON.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (IBTJSON)

- (NSString *)ibt_jsonString;

- (id)ibt_jsonValue;

@end

NS_ASSUME_NONNULL_END
