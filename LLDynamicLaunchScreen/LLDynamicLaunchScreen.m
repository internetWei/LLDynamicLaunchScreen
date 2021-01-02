//
//  LLDynamicLaunchScreen.m
//  LLLaunchScreen
//
//  Created by LL on 2020/12/28.
//

#import "LLDynamicLaunchScreen.h"


@interface UIImage (LLDynamicLaunchScreen)

/// YES：是深色系图片，NO：是浅色系图片
@property (nonatomic, readonly) BOOL hasDarkImage;

/// 检查图片大小
@property (nonatomic, readonly) BOOL checkSize;

/// 获取图片上某个点的RGB值(不包含alpha)。
- (nullable NSArray<NSNumber *> *)pixelColorFromPoint:(CGPoint)point;

+ (UIImage *)resizeImage:(UIImage *)image toPortraitScreenSize:(BOOL)isPortrait;

@end

/// 竖屏浅色启动图名称
static NSString * const verticalLightName = @"verticalLight";

/// 竖屏深色启动图名称
static NSString * const verticalDarkName = @"verticalDark";

/// 横屏浅色启动图名称
static NSString * const horizontalLightName = @"horizontalLight";

/// 横屏深色启动图名称
static NSString * const horizontalDarkName = @"horizontalDark";

static NSString * const nameMapppingIdentifier = @"ll_launchImage_nameMapppingIdentifier";

/// 获取APP的主要Window
static inline UIWindow * currentWindow(void) {
    if (@available(iOS 13.0, *)) {
        return UIApplication.sharedApplication.windows.firstObject;
    } else {
        return UIApplication.sharedApplication.keyWindow;
    }
}

@implementation LLDynamicLaunchScreen

+ (void)restoreAsBefore {
    [self initialization];
    
    // 获取系统缓存启动图路径
    NSString *cacheDir = [self launchImageCacheDirectory];
    if (!cacheDir) return;
    
    // 工作目录
    NSString *cachesParentDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tmpDir = [cachesParentDir stringByAppendingPathComponent:@"ll_launchImageCachesTmp"];
    
    // 清理工作目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmpDir]) {
        [fileManager removeItemAtPath:tmpDir error:nil];
    }
    
    // 移动系统缓存目录内容至工作目录
    BOOL moveResult = [fileManager moveItemAtPath:cacheDir toPath:tmpDir error:nil];
    if (!moveResult) return;
    
    NSString *localPath = [self launchImageBackupPath];
    NSDictionary *nameMapping = [NSUserDefaults.standardUserDefaults objectForKey:nameMapppingIdentifier];
    for (NSString *name in [NSFileManager.defaultManager contentsOfDirectoryAtPath:localPath error:nil]) {
        NSString *imageName = [name stringByDeletingPathExtension];
        // 获取系统的启动图完整名称
        NSString *realName = [nameMapping objectForKey:imageName];
        NSData *replaceData = [NSData dataWithContentsOfFile:[localPath stringByAppendingPathComponent:name]];
        [replaceData writeToFile:[tmpDir stringByAppendingPathComponent:realName] atomically:YES];
    }
    
    // 还原系统缓存目录
    moveResult = [fileManager moveItemAtPath:tmpDir toPath:cacheDir error:nil];
    
    // 清理工作目录
    if ([fileManager fileExistsAtPath:tmpDir]) {
        [fileManager removeItemAtPath:tmpDir error:nil];
    }
}

+ (void)replaceVerticalLaunchImage:(UIImage *)verticalImage {
    // 替换竖屏启动图
    [self replaceLaunchImage:verticalImage type:LLLaunchImageTypeVerticalLight compressionQuality:0.8 customValidation:nil];
    [self replaceLaunchImage:verticalImage type:LLLaunchImageTypeVerticalDark compressionQuality:0.8 customValidation:nil];
}

+ (void)replaceHorizontalLaunchImage:(UIImage *)horizontalImage {
    // 替换横屏启动图
    [self replaceLaunchImage:horizontalImage type:LLLaunchImageTypeHorizontalLight compressionQuality:0.8 customValidation:nil];
    [self replaceLaunchImage:horizontalImage type:LLLaunchImageTypeHorizontalDark compressionQuality:0.8 customValidation:nil];
}

+ (BOOL)replaceLaunchImage:(UIImage *)replaceImage type:(LLLaunchImageType)type compressionQuality:(CGFloat)quality customValidation:(BOOL (^ _Nullable) (UIImage *originImage, UIImage *replaceImage))validationBlock {
    if (!replaceImage) return NO;
    
    BOOL isVertical = NO;
    if (type == LLLaunchImageTypeVerticalLight ||
        type == LLLaunchImageTypeVerticalDark) {
        isVertical = YES;
    }
    
    replaceImage = [UIImage resizeImage:replaceImage toPortraitScreenSize:isVertical];
    
    // 转为jpeg
    NSData *data = UIImageJPEGRepresentation(replaceImage, quality);
    if (!data) return NO;
    
    [self initialization];
    
    // 检查图片尺寸是否等同屏幕分辨率
    if (!replaceImage.checkSize) return NO;
    
    // 获取系统缓存启动图路径
    NSString *cacheDir = [self launchImageCacheDirectory];
    if (!cacheDir) return NO;
    
    // 工作目录
    NSString *cachesParentDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tmpDir = [cachesParentDir stringByAppendingPathComponent:@"ll_launchImageCachesTmp"];
    
    // 清理工作目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmpDir]) {
        [fileManager removeItemAtPath:tmpDir error:nil];
    }
    
    // 移动系统缓存目录内容至工作目录
    BOOL moveResult = [fileManager moveItemAtPath:cacheDir toPath:tmpDir error:nil];
    if (!moveResult) return NO;
    
    NSDictionary *nameMapping = [NSUserDefaults.standardUserDefaults objectForKey:nameMapppingIdentifier];
    NSString *realName = nil;
    // 替换指定启动图
    switch (type) {
        case LLLaunchImageTypeVerticalLight:
            realName = [nameMapping objectForKey:verticalLightName];
            break;
        case LLLaunchImageTypeVerticalDark:
            realName = [nameMapping objectForKey:verticalDarkName];
            break;
        case LLLaunchImageTypeHorizontalLight:
            realName = [nameMapping objectForKey:horizontalLightName];
            break;
        case LLLaunchImageTypeHorizontalDark:
            realName = [nameMapping objectForKey:horizontalDarkName];
            break;
    }
    
    NSString *fullPath = [tmpDir stringByAppendingPathComponent:realName];
    UIImage *originImage = [UIImage imageWithContentsOfFile:fullPath];
    if (validationBlock) {
        BOOL result = validationBlock(originImage, replaceImage);
        if (result) {
            [data writeToFile:fullPath atomically:YES];
        }
    } else {
        [data writeToFile:fullPath atomically:YES];
    }
    
    // 还原系统缓存目录
    moveResult = [fileManager moveItemAtPath:tmpDir toPath:cacheDir error:nil];

    // 清理工作目录
    if ([fileManager fileExistsAtPath:tmpDir]) {
        [fileManager removeItemAtPath:tmpDir error:nil];
    }
    
    return YES;
}

+ (void)initialization {
    NSString *localPath = [self launchImageBackupPath];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *old_app_version = [NSUserDefaults.standardUserDefaults objectForKey:@"ll_launchImage_app_version"];
    
    // 判断是否需要重新初始化启动图资源
    if ([app_version isEqualToString:old_app_version] &&
        ![self isEmptyDir:localPath]) return;
    
    // 清空本地启动图
    for (NSString *name in [NSFileManager.defaultManager contentsOfDirectoryAtPath:localPath error:nil]) {
        NSString *fullPath = [localPath stringByAppendingPathComponent:name];
        [NSFileManager.defaultManager removeItemAtPath:fullPath error:nil];
    }
    
    UIWindow *window = currentWindow();
    NSInteger interfaceStyle = 0;
    if (@available(iOS 13.0, *)) {
        // 保存APP当前的主题模式
        interfaceStyle = window.overrideUserInterfaceStyle;
    }
    
    NSString *launchScreenName = @"LaunchScreen";
    if (LLDynamicLaunchScreen.launchScreenName.length > 0) {
        launchScreenName = LLDynamicLaunchScreen.launchScreenName;
    }
    
    /*-------1.生成启动图资源-------*/
    UIImage *verticalLight = [self snapshotStoryboard:launchScreenName isPortrait:YES isDark:NO];
    UIImage *verticalDark = nil;
    if (@available(iOS 13.0, *)) {
        verticalDark = [self snapshotStoryboard:launchScreenName isPortrait:YES isDark:YES];
    }
    
    UIImage *horizontalLight = nil;
    UIImage *horizontalDark = nil;
    if ([self supportHorizontalScreen]) {
        horizontalLight = [self snapshotStoryboard:launchScreenName isPortrait:NO isDark:NO];
        if (@available(iOS 13.0, *)) {
            horizontalDark = [self snapshotStoryboard:launchScreenName isPortrait:NO isDark:YES];
        }
    }
    
    // 恢复APP主题模式
    if (@available(iOS 13.0, *)) {
        window.overrideUserInterfaceStyle = interfaceStyle;
    }
    
    // 本地启动图路径
    NSString *verticalLightPath = [localPath stringByAppendingPathComponent:[verticalLightName stringByAppendingString:@".png"]];
    NSString *verticalDarkPath = [localPath stringByAppendingPathComponent:[verticalDarkName stringByAppendingString:@".png"]];
    NSString *horizontalLightPath = [localPath stringByAppendingPathComponent:[horizontalLightName stringByAppendingString:@".png"]];
    NSString *horizontalDarkPath = [localPath stringByAppendingPathComponent:[horizontalDarkName stringByAppendingString:@".png"]];

    // 将生成的启动图保存到本地
    if (verticalLight) {
        [UIImageJPEGRepresentation(verticalLight, 0.8) writeToFile:verticalLightPath atomically:YES];
    }
    if (verticalDark) {
        [UIImageJPEGRepresentation(verticalDark, 0.8) writeToFile:verticalDarkPath atomically:YES];
    }
    if (horizontalLight) {
        [UIImageJPEGRepresentation(horizontalLight, 0.8) writeToFile:horizontalLightPath atomically:YES];
    }
    if (horizontalDark) {
        [UIImageJPEGRepresentation(horizontalDark, 0.8) writeToFile:horizontalDarkPath atomically:YES];
    }
    
    // 保存APP当前版本号信息
    [NSUserDefaults.standardUserDefaults setObject:app_version forKey:@"ll_launchImage_app_version"];
    
    [self createLaunchImageNameMapping];
}

/// 生成启动图名称映射表
+ (void)createLaunchImageNameMapping {
    NSMutableDictionary *nameMappping = [NSMutableDictionary dictionary];
    
    // 获取系统缓存启动图路径
    NSString *cacheDir = [self launchImageCacheDirectory];
    if (!cacheDir) return;
    
    // 工作目录
    NSString *cachesParentDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tmpDir = [cachesParentDir stringByAppendingPathComponent:@"ll_launchImageCachesTmp"];
    
    // 清理工作目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmpDir]) {
        [fileManager removeItemAtPath:tmpDir error:nil];
    }
    
    // 移动系统缓存目录内容至工作目录
    BOOL moveResult = [fileManager moveItemAtPath:cacheDir toPath:tmpDir error:nil];
    if (!moveResult) return;
    
    // 遍历记录需要操作的图片名
    for (NSString *name in [fileManager contentsOfDirectoryAtPath:tmpDir error:nil]) {
        if ([self isSnapShotName:name]) {
            UIImage *tmpImage = [UIImage imageWithContentsOfFile:[tmpDir stringByAppendingPathComponent:name]];
            if (@available(iOS 13.0, *)) {
                // 判断是横图还是竖图
                if (tmpImage.size.width < tmpImage.size.height) {// 竖图
                    if (_hasDarkImageBlock) {// 用户实现了自定义深色图片校验
                        BOOL hasDark = _hasDarkImageBlock(tmpImage);
                        if (hasDark) {
                            [nameMappping setObject:name forKey:verticalDarkName];
                        } else {
                            [nameMappping setObject:name forKey:verticalLightName];
                        }
                    } else {
                        if (tmpImage.hasDarkImage) {// 深色竖图
                            [nameMappping setObject:name forKey:verticalDarkName];
                        } else {// 浅色竖图
                            [nameMappping setObject:name forKey:verticalLightName];
                        }
                    }
                } else {// 横图
                    if (_hasDarkImageBlock) {
                        BOOL hasDark = _hasDarkImageBlock(tmpImage);
                        if (hasDark) {
                            [nameMappping setObject:name forKey:horizontalDarkName];
                        } else {
                            [nameMappping setObject:name forKey:horizontalLightName];
                        }
                    } else {
                        if (tmpImage.hasDarkImage) {// 深色横图
                            [nameMappping setObject:name forKey:horizontalDarkName];
                        } else {// 浅色横图
                            [nameMappping setObject:name forKey:horizontalLightName];
                        }
                    }
                }
            } else {
                if (tmpImage.size.width < tmpImage.size.height) {// 竖图
                    [nameMappping setObject:name forKey:verticalLightName];
                    [nameMappping setObject:name forKey:verticalDarkName];
                } else {
                    [nameMappping setObject:name forKey:horizontalLightName];
                    [nameMappping setObject:name forKey:horizontalDarkName];
                }
            }
        }
    }
    
    // 还原系统缓存目录
    moveResult = [fileManager moveItemAtPath:tmpDir toPath:cacheDir error:nil];
    
    // 清理工作目录
    if ([fileManager fileExistsAtPath:tmpDir]) {
        [fileManager removeItemAtPath:tmpDir error:nil];
    }
    
    [NSUserDefaults.standardUserDefaults setObject:nameMappping forKey:nameMapppingIdentifier];
}

/// 系统启动图缓存路径
+ (nullable NSString *)launchImageCacheDirectory {
    NSString *bundleID = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // iOS13之前
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *snapshotsPath = [[cachesDirectory stringByAppendingPathComponent:@"Snapshots"] stringByAppendingPathComponent:bundleID];
    if ([fileManager fileExistsAtPath:snapshotsPath]) {
        return snapshotsPath;
    }
    
    // iOS13
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    snapshotsPath = [NSString stringWithFormat:@"%@/SplashBoard/Snapshots/%@ - {DEFAULT GROUP}", libraryDirectory, bundleID];
    if ([fileManager fileExistsAtPath:snapshotsPath]) {
        return snapshotsPath;
    }
    
    return nil;
}

/// 启动图备份文件夹
+ (NSString *)launchImageBackupPath {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fullPath = [rootPath stringByAppendingPathComponent:@"ll_launchImage_backup"];
    if (![NSFileManager.defaultManager fileExistsAtPath:fullPath]) {
        [NSFileManager.defaultManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    return fullPath;
}

+ (BOOL)isEmptyDir:(NSString *)path {
    for (NSString *name in [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil]) {
        if ([self isSnapShotName:name]) {
            return NO;
        }
    }
    return YES;
}

/// 系统缓存启动图后缀名
+ (BOOL)isSnapShotName:(NSString *)name {
    // 新系统后缀
    if ([name hasSuffix:@".ktx"]) {
        return YES;
    }
    // 老系统后缀
    if ([name hasSuffix:@".png"]) {
        return YES;
    }
    return NO;
}

static NSString *_launchScreenName;
+ (void)setLaunchScreenName:(NSString *)launchScreenName {
    _launchScreenName = launchScreenName;
}

+ (NSString *)launchScreenName {
    return _launchScreenName;
}

/// 根据LaunchScreen名称、是否竖屏、是否暗黑3个参数生成启动图。
+ (UIImage *)snapshotStoryboard:(NSString *)sbName isPortrait:(BOOL)isPortrait isDark:(BOOL)isDark {
    if (@available(iOS 13.0, *)) {
        UIWindow *window = currentWindow();
        if (isDark) {
            window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        } else {
            window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:sbName bundle:nil];
    UIViewController *vc = storyboard.instantiateInitialViewController;
    vc.view.frame = [UIScreen mainScreen].bounds;
    
    if (isPortrait) {
        if (vc.view.frame.size.width > vc.view.frame.size.height) {
            vc.view.frame = CGRectMake(0, 0, vc.view.frame.size.height, vc.view.frame.size.width);
        }
    } else {
        if (vc.view.frame.size.width < vc.view.frame.size.height) {
            vc.view.frame = CGRectMake(0, 0, vc.view.frame.size.height, vc.view.frame.size.width);
        }
    }
    
    [vc.view setNeedsLayout];
    [vc.view layoutIfNeeded];
    
    UIGraphicsBeginImageContextWithOptions(vc.view.frame.size, NO, [UIScreen mainScreen].scale);
    [vc.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/// YES：APP支持横屏，NO：不支持
+ (BOOL)supportHorizontalScreen {
    NSArray *t_array = [NSBundle.mainBundle.infoDictionary objectForKey:@"UISupportedInterfaceOrientations"];
    if ([t_array containsObject:@"UIInterfaceOrientationLandscapeLeft"] ||
        [t_array containsObject:@"UIInterfaceOrientationLandscapeRight"]) {
        return YES;
    } else {
        return NO;
    }
}

static BOOL (^_hasDarkImageBlock) (UIImage *image);
+ (void)setHasDarkImageBlock:(BOOL (^)(UIImage * _Nonnull))hasDarkImageBlock {
    _hasDarkImageBlock = hasDarkImageBlock;
}

+ (BOOL (^)(UIImage * _Nonnull))hasDarkImageBlock {
    return _hasDarkImageBlock;
}

@end


@implementation UIImage (LLDynamicLaunchScreen)

/// 获取图片上某个点的颜色值(不包含alpha)。
- (nullable NSArray<NSNumber *> *)pixelColorFromPoint:(CGPoint)point {
    // 判断点是否超出图像范围
    if (!CGRectContainsPoint(CGRectMake(0, 0, self.size.width, self.size.height), point)) return nil;
    
    // 将像素绘制到一个1×1像素字节数组和位图上下文。
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = {0, 0, 0, 0};
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // 将指定像素绘制到上下文中
    CGContextTranslateCTM(context, -pointX, pointY - height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), cgImage);
    CGContextRelease(context);
    
    CGFloat red = (CGFloat)pixelData[0];
    CGFloat green = (CGFloat)pixelData[1];
    CGFloat blue = (CGFloat)pixelData[2];
    return @[@(red), @(green), @(blue)];
}

- (BOOL)hasDarkImage {
    // 获取图片右上角1×1像素点的颜色值。
    NSArray<NSNumber *> *RGBArr = [self pixelColorFromPoint:CGPointMake(self.size.width - 1, 1)];
    
    CGFloat max = [RGBArr.firstObject floatValue];
    
    // 找到颜色的最大值
    for (NSNumber *number in RGBArr) {
        if (max < [number floatValue]) {
            max = [number floatValue];
        }
    }
    
    // 判断如果其他颜色小于最大值且差值在10以内则是暗色，并且最大值需小于190。
    if (max >= 190) {
        return NO;
    }
    
    for (NSNumber *number in RGBArr) {
        if ([number floatValue] + 10 < max) {
            return NO;
        }
    }
    
    return YES;
}

+ (CGSize)contextSizeForPortrait:(BOOL)isPortrait {
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat width = MIN(screenSize.width, screenSize.height);;
    CGFloat height = MAX(screenSize.width, screenSize.height);
    if (!isPortrait) {
        width = MAX(screenSize.width, screenSize.height);
        height = MIN(screenSize.width, screenSize.height);
    }
    CGSize contextSize = CGSizeMake(width * screenScale, height * screenScale);
    return contextSize;
}

+ (UIImage *)resizeImage:(UIImage *)image toPortraitScreenSize:(BOOL)isPortrait {
    CGSize imageSize = CGSizeApplyAffineTransform(image.size,
                                                  CGAffineTransformMakeScale(image.scale, image.scale));
    CGSize contextSize = [self contextSizeForPortrait:isPortrait];
    
    if (!CGSizeEqualToSize(imageSize, contextSize)) {
        UIGraphicsBeginImageContext(contextSize);
        CGFloat ratio = MAX((contextSize.width / image.size.width),
                            (contextSize.height / image.size.height));
        CGRect rect = CGRectMake(0, 0, image.size.width * ratio, image.size.height * ratio);
        [image drawInRect:rect];
        UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage;
    }
    
    return image;
}

- (BOOL)checkSize {
    CGSize screenSize = CGSizeApplyAffineTransform([UIScreen mainScreen].bounds.size,
                                                   CGAffineTransformMakeScale([UIScreen mainScreen].scale,
                                                                              [UIScreen mainScreen].scale));
    CGSize imageSize = CGSizeApplyAffineTransform(self.size,
                                                  CGAffineTransformMakeScale(self.scale, self.scale));
    if (CGSizeEqualToSize(imageSize, screenSize)) {
        return YES;
    }
    if (CGSizeEqualToSize(CGSizeMake(imageSize.height, imageSize.width), screenSize)) {
        return YES;
    }
    return NO;
}

@end
