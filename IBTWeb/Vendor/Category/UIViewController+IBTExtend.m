//
//  UIViewController+IBTExtend.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "UIViewController+IBTExtend.h"

@implementation UIViewController (IBTExtend)

- (BOOL)ibt_isPresentedIn {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

- (BOOL)ibt_isPushedIn {
    if ([self.navigationController.viewControllers count] > 1) {
        return self != [self.navigationController.viewControllers firstObject];
    }
    else {
        return NO;
    }
}

@end
