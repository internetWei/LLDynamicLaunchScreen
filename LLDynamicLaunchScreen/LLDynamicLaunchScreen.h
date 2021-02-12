//
//  LLDynamicLaunchScreen.h
//  LLDynamicLaunchScreen <https://github.com/internetWei/LLDynamicLaunchScreen>
//
//  Created by LL on 2021/1/18.
//

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
 自定义暗黑系启动图的校验规则(Customize the verification rules of the dark style launch screen)
 
 默认情况下，`LLaunchScreen`通过获取图片最右上角1×1像素单位的RGB值来判断该图片是不是暗黑系图片；
 如果您需要修改它，请在APP启动时实现它。(default, `LLaunchScreen` judges whether the picture is a dark picture by obtaining the RGB value of the 1×1 pixel unit in the upper right corner of the picture; If you need to modify it, please implement it when the APP starts.)
 */
@property (nonatomic, class, null_resettable) BOOL (^hasDarkImageBlock) (UIImage *image);


/**
 获取指定模式下的本地启动图(Get the local launch screen diagram in the specified mode)
      
 当您的APP不支持深色/横屏时，尝试获取启动图会返回nil。(When your APP does not support dark/horizontal launch screen, try to get the launch image and it will return nil)
 
 @param launchImageType 需要获取的启动图类型(The type of launch image that needs to be obtained)
 */
+ (nullable UIImage *)launchImageFromType:(LLLaunchImageType)launchImageType;


/// 将所有启动图恢复为默认启动图(Restore all launch screen to the initial state)
+ (void)restoreAsBefore;


/// 替换指定类型启动图(Replace the specified type of launch Image)
/// @param replaceImage 需要写入的图片，nil表示恢复为默认启动图(image to be written, nil means to restore to the default launch image)
/// @param launchImageType _
/// @param quality 图片压缩比例，默认为0.8(Image compression ratio, the default is 0.8)
/// @param validationBlock 自定义校验回调，返回true表示替换，false表示不替换(Custom callback, return true to replace, false to not replace)
+ (BOOL)replaceLaunchImage:(nullable UIImage *)replaceImage
           launchImageType:(LLLaunchImageType)launchImageType
        compressionQuality:(CGFloat)quality
          validation:(BOOL (^ _Nullable) (UIImage *originImage, UIImage *replaceImage))validationBlock;


/// 替换所有竖屏启动图(Replace all vertical launch Images)
+ (void)replaceVerticalLaunchImage:(nullable UIImage *)verticalImage;


/// 替换所有横屏启动图(Replace all horizontal launch Images)
+ (void)replaceHorizontalLaunchImage:(nullable UIImage *)horizontalImage;

@end

NS_ASSUME_NONNULL_END
