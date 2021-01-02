//
//  LLDynamicLaunchScreen.h
//  LLLaunchScreen
//
//  Created by LL on 2020/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LLLaunchImageType) {
    LLLaunchImageTypeVerticalLight,   /**< 浅色竖屏启动图*/
    LLLaunchImageTypeVerticalDark API_AVAILABLE(tvos(13.0)) ,    /**< 深色竖屏启动图*/
    LLLaunchImageTypeHorizontalLight, /**< 浅色横屏启动图*/
    LLLaunchImageTypeHorizontalDark API_AVAILABLE(tvos(13.0)),  /**< 深色横屏启动图*/
};

@interface LLDynamicLaunchScreen : NSObject

/// 启动图文件名称，如果是名称LaunchScreen则不用传递。
@property (nonatomic, class, nullable) NSString *launchScreenName;

/**
 自定义暗黑启动图校验规则
 
 @discussion 默认情况下，通过获取图片右上角1×1像素单位的RGB值来判断该图片是不是暗黑系图片。
 如果实现了此方法，返回YES表示该图片是暗黑系图片，可以参考pixelColorFromPoint属性。
 */
@property (nonatomic, class) BOOL (^hasDarkImageBlock) (UIImage *image);

/// 恢复为系统默认启动图，可以解决启动图异常的问题。
+ (void)restoreAsBefore;

/// 替换所有竖图
+ (void)replaceVerticalLaunchImage:(UIImage *)verticalImage;

/// 替换所有横图
+ (void)replaceHorizontalLaunchImage:(UIImage *)horizontalImage;

/// 替换指定启动图
/// @param replaceImage 需要写入的图片
/// @param type 替换的类型
/// @param quality 图片压缩比例，默认为0.8
/// @param validationBlock 自定义校验回调，返回YES表示替换，NO表示不替换。
+ (BOOL)replaceLaunchImage:(UIImage *)replaceImage type:(LLLaunchImageType)type compressionQuality:(CGFloat)quality customValidation:(BOOL (^ _Nullable) (UIImage *originImage, UIImage *replaceImage))validationBlock;

@end

NS_ASSUME_NONNULL_END
