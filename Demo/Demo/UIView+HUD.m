//
//  UIView+HUD.m
//  ZTCloud
//
//  Created by LL on 2021/4/25.
//

#import "UIView+HUD.h"

@implementation UIView (HUD)

- (MBProgressHUD *)showLoading {
    return [self showLoadingFromText:nil isTranslucent:YES graceTime:0.5];
}


- (MBProgressHUD *)showLoadingFromText:(NSString *)title isTranslucent:(BOOL)isTranslucent graceTime:(NSTimeInterval)graceTime {
    /// 防止弹出多个信息一样的HUD
    static NSMutableSet<NSString *> *_titleSets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _titleSets = [NSMutableSet set];
    });
    if (title != nil) {
        if ([_titleSets containsObject:title]) return nil;
        [_titleSets addObject:title];
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = UIColor.blackColor;
    [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]].color = UIColor.whiteColor;
    hud.graceTime = graceTime;
    hud.minShowTime = 0.5;
    hud.removeFromSuperViewOnHide = YES;
    if (isTranslucent) {
        hud.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    hud.completionBlock = ^{
        if (title == nil) return;
        [_titleSets removeObject:title];
    };
    hud.userInteractionEnabled = YES;
    hud.label.text = title;
    [self addSubview:hud];
    [hud showAnimated:YES];
    return hud;
}


- (MBProgressHUD *)showPromptFromText:(NSString *)text {
    return [self showTextHUD:text afterDelay:2.0];
}


- (nullable MBProgressHUD *)showTextHUD:(NSString *)text afterDelay:(NSTimeInterval)afterDelay {
    if ([text isKindOfClass:NSString.class] == NO) return nil;
    if (text.length == 0) return nil;
    
    
    /// 防止弹出多个信息一样的HUD
    static NSMutableSet<NSString *> *_titleSets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _titleSets = [NSMutableSet set];
    });
    if ([_titleSets containsObject:text]) return nil;
    [_titleSets addObject:text];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.completionBlock = ^{
        [_titleSets removeObject:text];
    };
    hud.userInteractionEnabled = YES;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.label.numberOfLines = 0;
    [hud hideAnimated:YES afterDelay:afterDelay];
    return hud;
}

@end
