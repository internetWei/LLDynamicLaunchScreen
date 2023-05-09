//
//  UIView+HUD.h
//  ZTCloud
//
//  Created by LL on 2021/4/25.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (HUD)

- (MBProgressHUD *)showLoading;

- (nullable MBProgressHUD *)showPromptFromText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
