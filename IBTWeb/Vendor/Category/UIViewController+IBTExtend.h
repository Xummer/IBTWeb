//
//  UIViewController+IBTExtend.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (IBTExtend)

- (BOOL)ibt_isPresentedIn;

- (BOOL)ibt_isPushedIn;

@end

NS_ASSUME_NONNULL_END
