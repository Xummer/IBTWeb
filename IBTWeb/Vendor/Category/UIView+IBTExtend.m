//
//  UIView+IBTExtend.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "UIView+IBTExtend.h"

@implementation UIView (IBTExtend)

- (UIViewController *)ibt_firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self ibt_traverseResponderChainForUIViewController];
}

- (id)ibt_traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    }
    else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder ibt_traverseResponderChainForUIViewController];
    }
    else {
        return nil;
    }
}

@end
