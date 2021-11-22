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

/// 深色启动图校验规则，实现它可以修改深色启动图的识别逻辑。
/// @discussion 默认情况下，LLDynamicLaunchScreen会获取启动图右上角1×1像素点的RGB值来判断该图片是不是深色系图片。
///             当您的APP启动图右上角像素点不是明显的深色RGB值时可能会判断错误从而导致修改启动图失败。
///             当APP首次安装或更新后首次打开时，LLDynamicLaunchScreen 会遍历您本地的启动图并且将它们的名称和 LLLaunchImageType 一一对应，
///             默认情况下，框架会获取启动图右上角1×1像素点的RGB值来判断该启动图是不是深色启动图。
///             这有可能会误判，所以您可以实现 hasDarkImageBlock 通过自定义校验规则并返回 YES 告诉框架这是深色启动图。
/// @note 请在 application: didFinishLaunchingWithOptions: 方法返回前实现 hasDarkImageBlock 的判断，否则会失效。
///       我尝试过很多方法希望能自动判断深色图片，包括但不限于网上很多的深色图片识别方法，但是都不理想，
///       如果您有更好的想法，欢迎给我提交Issues。
@property (nonatomic, class, null_resettable) BOOL (^hasDarkImageBlock) (UIImage *image);


/// 设置或获取系统启动图的备份路径。
/// @discussion 默认情况下，LLDynamicLaunchScreen 会将启动图备份到 Document 文件夹下，
///             如果您想修改它的备份路径，请调用 setLaunchImageBackupPath: 告诉它。
/// @note 请在 application: didFinishLaunchingWithOptions:  方法返回前实现它，否则会失效。
///       如果您的APP已经有用户安装了，请您在修改路径前先将原备份的内容拷贝到新路径，
///       否则可能会导致用户更新版本后丢失上次设置的启动图信息。
@property (nonatomic, class, null_resettable) NSString *launchImageBackupPath;


/// 设置或获取替换启动图的备份路径。
/// @discussion 该目录保存用户选择的启动图，作用和注意事项请参考 launchImageBackupPath。
@property (nonatomic, class, null_resettable) NSString *replaceLaunchImageBackupPath;


/// 获取指定模式下APP的启动图，如果获取不到会返回nil。
+ (nullable UIImage *)launchImageFromType:(LLLaunchImageType)launchImageType;


/// 将所有启动图恢复为默认启动图。
+ (void)restoreAsBefore;


/// 替换APP指定启动图
/// @param replaceImage 需要写入的图片，nil表示恢复为默认启动图。
/// @param quality 图片压缩比例，默认为0.8。
/// @param validationBlock 自定义校验回调，返回YES表示替换，NO表示不替换，默认返回YES。
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
