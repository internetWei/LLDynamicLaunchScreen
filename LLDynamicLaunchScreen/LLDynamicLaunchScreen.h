//
//  LLDynamicLaunchScreen.h
//  LLDynamicLaunchScreen <https://github.com/internetWei/LLDynamicLaunchScreen>
//
//  Created by LL on 2021/1/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LLLaunchImageType) {
    LLLaunchImageTypeVerticalLight,                              /**< 竖屏浅色启动图*/
    LLLaunchImageTypeVerticalDark API_AVAILABLE(ios(13.0)),      /**< 竖屏深色启动图*/
    LLLaunchImageTypeHorizontalLight,                            /**< 横屏浅色启动图*/
    LLLaunchImageTypeHorizontalDark API_AVAILABLE(ios(13.0)),    /**< 横屏深色启动图*/
};

@interface LLDynamicLaunchScreen : NSObject

/// 返回框架当前版本号字符串，例如：@"1.0.0"。
@property (class, readonly) NSString *versionString;


/// 返回框架当前版本号数字，例如：1.0。
@property (class, readonly) CGFloat versionNumber;


/// 为了提高框架稳定性和API整洁度，该属性将在2023年12月30日更新并删除。
///
/// 如果你正在使用它的话，请仔细阅读以下注意事项：
///
/// 1. 如果你正在使用该属性，你应该什么都不做(`不要修改它`)，直到未来框架移除该属性，到那时，你只需要删除报错的代码即可；
///
/// 2. 在移除之前，你只能对它进行赋值操作，虽然你可以读取它，但是它始终返回 nil；
///
/// 3. 在移除之前，虽然你能对它赋值，但是你无法修改备份路径，框架内部会自动将原备份路径上的文件迁移到新备份路径。
@property (class, nullable) NSString *replaceLaunchImageBackupPath;


/// 控制APP更新后是否需要恢复上个版本修改的启动图，一般情况下不使用。
///
/// 当用户更新APP版本并首次打开时，系统会重新生成启动图(`即使你没有修改启动图文件`)，此时框架内部会在合适的时机将上个版本修改的启动图应用到当前版本，这样当用户下次打开APP时就会拥有和上个版本一样的启动图体验，这是默认行为；
///
/// 如果你不想还原到上个版本的启动图，可以在回调内返回NO，你可以精确控制哪个类型的启动图需要迁移，哪个类型不需要。
///
/// - Notes:
/// 1. 仅在APP更新版本并且首次打开时触发；
/// 2. 只会回调上个版本修改过的启动图；
/// 3. 该回调会在子线程触发；
/// 4. 如果你在回调中返回NO，将会从本地删除这张启动图以及相关信息，如果你需要在未来恢复它，请自行缓存；
/// 5. 勿必在`application:didFinishLaunchingWithOptions:`方法返回前实现它，否则无效；
/// 6. 当迁移操作完成后属性会自动置空。
@property (class, nullable) BOOL(^migrationHandler)(LLLaunchImageType type, UIImage *image);


/// 获取APP本来的启动图。
///
/// 返回启动图文件中配置的那张图，无论你修改多少次启动图，它始终返回那一张图片，该方法可以返回系统不支持的启动图，
/// 例如设置了Light样式，也可以获取Dark样式的启动图。
///
/// 该方法可以在子线程调用。
+ (nullable UIImage *)getSystemLaunchImageWithType:(LLLaunchImageType)type;


/// 获取APP当前显示的启动图。
///
/// 如果没有修改过，返回本来的启动图，如果修改过，返回最后一次修改成功的图片；
///
/// 该方法可以在子线程调用。
+ (nullable UIImage *)getLaunchImageWithType:(LLLaunchImageType)type;


/// 修改启动图。
///
/// 具体信息请查看 `replaceLaunchImage:type:validation:`。
+ (BOOL)replaceLaunchImage:(nullable UIImage *)image
                      type:(LLLaunchImageType)type;


/// 立即返回并开启一个子线程修改启动图。
///
/// 具体信息请查看 `replaceLaunchImage:type:validation:`。
+ (void)replaceLaunchImage:(nullable UIImage *)image
                      type:(LLLaunchImageType)type
                 completed:(void (^ _Nullable)(NSError * _Nullable))handler;


/// 修改启动图。
///
/// 修改启动图可能会比较耗时，建议在子线程修改。
///
/// @param image 需要写入的启动图，nil 表示恢复为默认启动图，
///              请保证传入的image尺寸和APP屏幕尺寸一致，否则框架内部会按照UIViewContentModeScaleAspectFill进行缩放修改，
///              如果你想修改缩放类型，可以使用 UIImage 的分类方法 `ll_imageByResizeToSize:contentMode:` 提前修改。
/// @param type 需要修改的启动图样式。
/// @param handler 你可以控制是否需要修改，返回 YES 表示需要修改，返回 NO 表示取消。
/// @return 返回nil表示操作成功，否则可通过NSError的实例方法`localizedFailureReason`获取具体失败原因。
+ (nullable NSError *)replaceLaunchImage:(nullable UIImage *)image
                                    type:(LLLaunchImageType)type
                              validation:(BOOL (^ _Nullable) (UIImage *oldImage, UIImage *newImage))handler;


/// 将所有修改过的启动图恢复为默认样式。
///
/// 该方法可以在子线程调用。
+ (void)restoreAsBefore;

@end


@interface UIImage (LLCategory)

/// 返回从该图像缩放的新图像，图像内容将使用contentMode进行修改。
- (nullable UIImage *)ll_imageByResizeToSize:(CGSize)size
                                 contentMode:(UIViewContentMode)contentMode;

@end

NS_ASSUME_NONNULL_END
