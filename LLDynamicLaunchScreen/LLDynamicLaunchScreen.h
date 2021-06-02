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
 深色启动图校验规则，实现它可以修改深色启动图的识别逻辑。
 
 @discussion 默认情况下，LLDynamicLaunchScreen会获取启动图最右上角1×1像素点的RGB值来判断
 该图片是不是深色系图片。当您的APP启动图右上角像素点不是明显的深色RGB值时框架可能会判断错误深色
 图片而导致启动图的修改失败，如果不幸发生了上述情况，您可以实现此Block来修改它的校验规则。
 
 
 我尝试过各种方法来希望能自动判断深色图片，包括介不限于将图片压缩成1×1像素单位，然后对其取色进行判断。
 但是都失败了，最后尝试了很多种方案发现还是目前的方案比较稳妥，但是如果您的启动图右上角颜色比较深，那么
 可能会判断错误，导致启动图的修改失败。这时您就需要实现此Block来适配(如果您有更好的想法可以在github上留言或者邮箱联系我)。
 
 @warnning 请尽量在`application: didFinishLaunchingWithOptions:`方法返回前实现它，否则可能无效。
 */
@property (nonatomic, class, null_resettable) BOOL (^hasDarkImageBlock) (UIImage *image);


/**
 设置/获取系统启动图的备份路径
 
 @warnning 请尽量在`application: didFinishLaunchingWithOptions:`方法返回前实现它，否则可能无效。
 
 如果已上线，建议不要再修改路径。如果一定要修改请将之前路径上的文件备份到新路径下，否则可能会
 导致用户更新版本后丢失上次设置的启动图信息。
 */
@property (nonatomic, class, null_resettable) NSString *launchImageBackupPath;


/**
 设置/获取替换启动图的备份路径
 
 @warnning 请尽量在`application: didFinishLaunchingWithOptions:`方法返回前实现它，否则可能无效。
 
 如果已上线，建议不要再修改路径。如果一定要修改请将之前路径上的文件备份到新路径下，否则可能会
 导致用户更新版本后丢失上次设置的启动图信息。
 */
@property (nonatomic, class, null_resettable) NSString *replaceLaunchImageBackupPath;


/// 获取指定模式下APP的启动图(获取不到会返回nil)
+ (nullable UIImage *)launchImageFromType:(LLLaunchImageType)launchImageType;


/// 将所有启动图恢复为默认启动图
+ (void)restoreAsBefore;


/// 替换APP指定启动图
/// @param replaceImage 需要写入的图片，nil表示恢复为默认启动图
/// @param launchImageType _
/// @param quality 图片压缩比例，默认为0.8
/// @param validationBlock 自定义校验回调，返回YES表示替换，NO表示不替换，默认返回YES
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
