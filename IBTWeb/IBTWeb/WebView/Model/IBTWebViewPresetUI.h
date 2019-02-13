//
//  IBTWebViewPresetUI.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBTWebViewPresetUI : NSObject

@property (strong, nonatomic) UIColor *progressBarColor;
@property (copy, nonatomic) NSString *navigationBarTitle;
@property (strong, nonatomic) NSString *navigationBackIconName;
@property (strong, nonatomic) NSString *navigationBackName;
@property (strong, nonatomic) NSString *navigationCloseIconName;
@property (strong, nonatomic) NSString *navigationCloseName;
@property (assign, nonatomic) BOOL disableGobackMode;
@property (assign, nonatomic) BOOL showCloseButton;

@end

NS_ASSUME_NONNULL_END
