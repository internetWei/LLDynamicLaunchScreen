//
//  LLDynamicLaunchScreen.h
//  LLDynamicLaunchScreen <https://github.com/internetWei/LLDynamicLaunchScreen>
//
//  Created by LL on 2021/1/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT double LLDynamicLaunchScreenVersionNumber;

FOUNDATION_EXPORT const unsigned char LLDynamicLaunchScreenVersionString[];

typedef NS_ENUM(NSInteger, LLLaunchImageType) {
    LLLaunchImageTypeVerticalLight,   /**< 竖屏浅色启动图*/
    LLLaunchImageTypeVerticalDark API_AVAILABLE(ios(13.0)) ,    /**< 竖屏深色启动图*/
    LLLaunchImageTypeHorizontalLight, /**< 横屏浅色启动图*/
    LLLaunchImageTypeHorizontalDark API_AVAILABLE(ios(13.0)),  /**< 横屏深色启动图*/
};

@interface LLDynamicLaunchScreen : NSObject


/**
 自定义暗黑系启动图片校验规则
 
 @discussion 默认情况下，LLDynamicLaunchScreen通过获取图片右上角1×1像素单位的RGB值来判断该图片是不是暗黑系图片；
 如果您不满意默认的校验规则，可以在修改启动图前实现此Block自定义校验规则。
 */
@property (nonatomic, class, nullable) BOOL (^hasDarkImageBlock) (UIImage *image);


/**
 获取指定模式下的启动图
 
 @discussion 可能会返回nil
 
 当您的APP不支持深色/横屏，尝试获取深色/横屏启动图则返回nil
 */
+ (nullable UIImage *)launchImageFromType:(LLLaunchImageType)launchImageType;


/**
 将所有启动图恢复为默认启动图
 
 @discussion 此操作具有破坏性，会丢失已修改的启动图。
 */
+ (void)restoreAsBefore;


/// 替换指定启动图
/// @param replaceImage 需要写入的图片，传入nil表示恢复为默认启动图。
/// @param launchImageType 替换的图片类型
/// @param quality 图片压缩比例，默认为0.8
/// @param validationBlock 自定义校验回调，返回YES表示替换，NO表示不替换。
+ (BOOL)replaceLaunchImage:(nullable UIImage *)replaceImage
           launchImageType:(LLLaunchImageType)launchImageType
        compressionQuality:(CGFloat)quality
          validation:(BOOL (^ _Nullable) (UIImage *originImage, UIImage *replaceImage))validationBlock;


/// 替换所有竖屏启动图
+ (void)replaceVerticalLaunchImage:(nullable UIImage *)verticalImage;


/// 替换所有横屏启动图
+ (void)replaceHorizontalLaunchImage:(nullable UIImage *)horizontalImage;

@end

NS_ASSUME_NONNULL_END
