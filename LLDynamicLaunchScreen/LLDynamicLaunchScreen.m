//
//  LLDynamicLaunchScreen.m
//  LLDynamicLaunchScreen <https://github.com/internetWei/LLDynamicLaunchScreen>
//
//  Created by LL on 2021/1/18.
//

#import "LLDynamicLaunchScreen.h"

#import <objc/runtime.h>

@interface UIImage (LLDynamicLaunchScreen)

@property (nonatomic, readonly) BOOL hasDarkImage;

/// 获取图片上某个点的RGB(不包含alpha)。
- (nullable NSArray<NSNumber *> *)pixelColorFromPoint:(CGPoint)point;

- (UIImage *)resizeImageWithDirection:(BOOL)vertical;

/// 根据竖屏状态、暗黑状态从launchScreen.storyboard创建并返回启动图
+ (UIImage *)createLaunchimageFromSnapshotStoryboardWithisPortrait:(BOOL)isPortrait isDark:(BOOL)isDark;

@end



static NSString * const launchImageInfoIdentifier = @"launchImageInfoIdentifier";
static NSString * const launchImageModifyIdentifier = @"launchImageModifyIdentifier";
static NSString * const launchImageVersionIdentifier = @"launchImageVersionIdentifier";

static BOOL launchImage_repairException = NO;
static BOOL launchImage_restoreAsBefore = NO;

@implementation LLDynamicLaunchScreen

+ (void)didFinishLaunching {
    [self launchImageIsNewVersion:^{
        NSDictionary *modifyDictionary = [NSUserDefaults.standardUserDefaults objectForKey:launchImageModifyIdentifier];
        for (NSString *key in modifyDictionary) {
            NSString *isModify = modifyDictionary[key];
            if ([isModify isEqualToString:@"YES"]) {
                NSString *fullPath = [customLaunchImageBackupPath() stringByAppendingPathComponent:[key stringByAppendingString:@".png"]];
                [self replaceLaunchImage:[UIImage imageWithContentsOfFile:fullPath] launchImageType:LaunchImageTypeFromLaunchImageName(key) compressionQuality:0.8 validation:nil];
            }
        }
    } identifier:NSStringFromSelector(@selector(didFinishLaunching))];
    
    [self repairException];
}

+ (void)initialize {
    NSMutableDictionary *modifyDictionary = [[NSUserDefaults.standardUserDefaults objectForKey:launchImageModifyIdentifier] mutableCopy];
    if (modifyDictionary == nil) {
        modifyDictionary = [NSMutableDictionary dictionary];
        [modifyDictionary setObject:@"NO" forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalLight)];
        [modifyDictionary setObject:@"NO" forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalLight)];
        if (@available(iOS 13.0, *)) {
            [modifyDictionary setObject:@"NO" forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalDark)];
            [modifyDictionary setObject:@"NO" forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalDark)];
        }
        [NSUserDefaults.standardUserDefaults setObject:modifyDictionary.copy forKey:launchImageModifyIdentifier];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *old_app_version = [NSUserDefaults.standardUserDefaults objectForKey:@"launchImage_app_version_identifier"];
    
    if ([app_version isEqualToString:old_app_version] == NO) {
        NSMutableDictionary *versionDictionary = [[NSUserDefaults.standardUserDefaults objectForKey:launchImageVersionIdentifier] mutableCopy];
        if (versionDictionary == nil) versionDictionary = [NSMutableDictionary dictionary];
        
        [versionDictionary setObject:@"YES" forKey:NSStringFromSelector(@selector(didFinishLaunching))];
        [versionDictionary setObject:@"YES" forKey:NSStringFromSelector(@selector(initialization))];
        [versionDictionary setObject:@"YES" forKey:NSStringFromSelector(@selector(backupSystemLaunchImage))];
        [versionDictionary setObject:@"YES" forKey:NSStringFromSelector(@selector(repairException))];
        
        [NSUserDefaults.standardUserDefaults setObject:versionDictionary.copy forKey:launchImageVersionIdentifier];
        
        [NSUserDefaults.standardUserDefaults setObject:app_version forKey:@"launchImage_app_version_identifier"];
    }
    
    [self initialization];
}

+ (void)initialization {
    [self launchImageIsNewVersion:^{
        [self launchImageCustomBlock:^(NSString *tmpDirectory) {
            
            // 记录启动图信息
            NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionary];
            for (NSString *name in [NSFileManager.defaultManager contentsOfDirectoryAtPath:tmpDirectory error:nil]) {
                if ([self isSnapShotSuffix:name] == NO) continue;
                
                UIImage *tmpImage = [UIImage imageWithContentsOfFile:[tmpDirectory stringByAppendingPathComponent:name]];
                if (@available(iOS 13.0, *)) {
                    BOOL hasDarkImage = LLDynamicLaunchScreen.hasDarkImageBlock(tmpImage);
                    
                    if (tmpImage.size.width < tmpImage.size.height) {
                        if (hasDarkImage) {// 竖屏深色启动图
                            [infoDictionary setObject:name forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalDark)];
                        } else {// 竖屏浅色启动图
                            [infoDictionary setObject:name forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalLight)];
                        }
                    } else {
                        if (hasDarkImage) {// 横屏深色启动图
                            [infoDictionary setObject:name forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalDark)];
                        } else {// 横屏浅色启动图
                            [infoDictionary setObject:name forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalLight)];
                        }
                    }
                } else {
                    if (tmpImage.size.width < tmpImage.size.height) {// 竖屏浅色启动图
                        [infoDictionary setObject:name forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalLight)];
                    } else {// 横屏浅色启动图
                        [infoDictionary setObject:name forKey:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalLight)];
                    }
                }
                
            }
            
            [NSUserDefaults.standardUserDefaults setObject:infoDictionary.copy forKey:launchImageInfoIdentifier];
        }];
    } identifier:NSStringFromSelector(@selector(initialization))];
}

+ (UIImage *)launchImageFromType:(LLLaunchImageType)launchImageType {
    UIImage * __block launchImage = nil;
    
    BOOL __block result = [self launchImageCustomBlock:^(NSString *tmpDirectory) {
        NSString *imageName = LaunchImageNameFromLaunchImageType(launchImageType);
        NSDictionary *launchImageInfo = [NSUserDefaults.standardUserDefaults objectForKey:launchImageInfoIdentifier];
        imageName = [launchImageInfo objectForKey:imageName];
        
        if (imageName == nil) result = NO;
        
        if (imageName) {
            NSString *fullPath = [tmpDirectory stringByAppendingPathComponent:imageName];
            launchImage = [UIImage imageWithContentsOfFile:fullPath];
        }
    }];
    
    if (result == NO) return nil;
    
    return launchImage;
}

+ (void)replaceVerticalLaunchImage:(nullable UIImage *)verticalImage {
    [self replaceLaunchImage:verticalImage launchImageType:LLLaunchImageTypeVerticalLight compressionQuality:0.8 validation:nil];
    if (@available(iOS 13.0, *)) {
        [self replaceLaunchImage:verticalImage launchImageType:LLLaunchImageTypeVerticalDark compressionQuality:0.8 validation:nil];
    }
}

+ (void)replaceHorizontalLaunchImage:(nullable UIImage *)horizontalImage {
    [self replaceLaunchImage:horizontalImage launchImageType:LLLaunchImageTypeHorizontalLight compressionQuality:0.8 validation:nil];
    if (@available(iOS 13.0, *)) {
        [self replaceLaunchImage:horizontalImage launchImageType:LLLaunchImageTypeHorizontalDark compressionQuality:0.8 validation:nil];
    }
}

+ (void)repairException {
    [self launchImageIsNewVersion:^{
        if (doesExistsOriginLaunchImage()) {
            NSDictionary *modifyDictionary = [NSUserDefaults.standardUserDefaults objectForKey:launchImageModifyIdentifier];
            for (NSString *key in modifyDictionary) {
                NSString *isModify = modifyDictionary[key];
                if ([isModify isEqualToString:@"NO"]) {
                    [self replaceLaunchImage:nil launchImageType:LaunchImageTypeFromLaunchImageName(key) compressionQuality:0.8 validation:nil];
                }
            }
            launchImage_repairException = NO;
        } else {
            launchImage_repairException = YES;
        }
    } identifier:NSStringFromSelector(@selector(repairException))];
}

+ (void)restoreAsBefore {
    if (doesExistsOriginLaunchImage()) {
        [self replaceLaunchImage:nil launchImageType:LLLaunchImageTypeVerticalLight compressionQuality:0.8 validation:nil];
        [self replaceLaunchImage:nil launchImageType:LLLaunchImageTypeHorizontalLight compressionQuality:0.8 validation:nil];
        if (@available(iOS 13.0, *)) {
            [self replaceLaunchImage:nil launchImageType:LLLaunchImageTypeVerticalDark compressionQuality:0.8 validation:nil];
            [self replaceLaunchImage:nil launchImageType:LLLaunchImageTypeHorizontalDark compressionQuality:0.8 validation:nil];
        }
        
        [NSFileManager.defaultManager removeItemAtPath:customLaunchImageBackupPath() error:nil];
        launchImage_restoreAsBefore = NO;
    } else {
        launchImage_restoreAsBefore = YES;
    }
}

+ (BOOL)replaceLaunchImage:(nullable UIImage *)replaceImage
           launchImageType:(LLLaunchImageType)launchImageType
        compressionQuality:(CGFloat)quality
                validation:(BOOL (^ _Nullable) (UIImage *originImage, UIImage *replaceImage))validationBlock {
    BOOL isReplace = (replaceImage != nil);
    
    if (replaceImage == nil) {
        NSString *imageName = LaunchImageNameFromLaunchImageType(launchImageType);
        NSString *fullPath = [originLaunchImageFullBackupPath() stringByAppendingPathComponent:[imageName stringByAppendingString:@".png"]];
        replaceImage = [UIImage imageWithContentsOfFile:fullPath];
    }
    
    BOOL isVertical = NO;
    if (launchImageType == LLLaunchImageTypeVerticalLight) {
        isVertical = YES;
    }
    
    if (@available(iOS 13.0, *)) {
        if (launchImageType == LLLaunchImageTypeVerticalDark) {
            isVertical = YES;
        }
    }
    
    /// 调整图片大小与启动图一致
    replaceImage = [replaceImage resizeImageWithDirection:isVertical];
    
    NSData *replaceImageData = UIImageJPEGRepresentation(replaceImage, quality);
    if (!replaceImageData) return NO;
    
    // 替换启动图
    BOOL __block result = [self launchImageCustomBlock:^(NSString *tmpDirectory) {
        NSString *imageName = LaunchImageNameFromLaunchImageType(launchImageType);
        NSDictionary *launchImageInfo = [NSUserDefaults.standardUserDefaults objectForKey:launchImageInfoIdentifier];
        imageName = [launchImageInfo objectForKey:imageName];
        
        if (imageName == nil) result = NO;
        
        if (imageName) {
            NSString *fullPath = [tmpDirectory stringByAppendingPathComponent:imageName];
            UIImage *originImage = [UIImage imageWithContentsOfFile:fullPath];
            
            BOOL result = !validationBlock ? YES : validationBlock(originImage, replaceImage);
            if (result == YES) {
                [replaceImageData writeToFile:fullPath atomically:YES];
            }
        }
    }];
    
    if (result == NO) return NO;
    
    // 备份replaceImage
    NSString *customLaunchImageFullPath = [customLaunchImageBackupPath() stringByAppendingPathComponent:[LaunchImageNameFromLaunchImageType(launchImageType) stringByAppendingString:@".png"]];
    if (isReplace) {
        [replaceImageData writeToFile:customLaunchImageFullPath atomically:YES];
    } else {
        [NSFileManager.defaultManager removeItemAtPath:customLaunchImageFullPath error:nil];
    }
    
    // 记录启动图修改记录
    NSMutableDictionary *modifyDictionary = [[NSUserDefaults.standardUserDefaults objectForKey:launchImageModifyIdentifier] mutableCopy];
    [modifyDictionary setObject:isReplace ? @"YES" : @"NO" forKey:LaunchImageNameFromLaunchImageType(launchImageType)];
    [NSUserDefaults.standardUserDefaults setObject:modifyDictionary.copy forKey:launchImageModifyIdentifier];
    
    return YES;
}

+ (void)backupSystemLaunchImage {
    [self launchImageIsNewVersion:^{
        NSString *backupPath = originLaunchImageFullBackupPath();
        
        // 1.删除原始启动图备份文件
        for (NSString *name in [NSFileManager.defaultManager contentsOfDirectoryAtPath:backupPath error:nil]) {
            NSString *fullPath = [backupPath stringByAppendingPathComponent:name];
            [NSFileManager.defaultManager removeItemAtPath:fullPath error:nil];
        }
        
        // 2.生成APP的启动图对象
        UIImage *verticalLightImage, *verticalDarkImage, *horizontalLightImage, *horizontalDarkImage;
        if (@available(iOS 13.0, *)) {
            verticalDarkImage = [UIImage createLaunchimageFromSnapshotStoryboardWithisPortrait:YES isDark:YES];
        }
        verticalLightImage = [UIImage createLaunchimageFromSnapshotStoryboardWithisPortrait:YES isDark:NO];
        
        if (supportHorizontalScreen()) {
            horizontalLightImage = [UIImage createLaunchimageFromSnapshotStoryboardWithisPortrait:NO isDark:NO];
            if (@available(iOS 13.0, *)) {
                horizontalDarkImage = [UIImage createLaunchimageFromSnapshotStoryboardWithisPortrait:NO isDark:YES];
            }
        }
        
        // 本地启动图路径
        NSString *verticalLightPath = [backupPath stringByAppendingPathComponent:[LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalLight) stringByAppendingString:@".png"]];
        NSString *horizontalLightPath = [backupPath stringByAppendingPathComponent:[LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalLight) stringByAppendingString:@".png"]];
        NSString *verticalDarkPath, *horizontalDarkPath;
        if (@available(iOS 13.0, *)) {
            verticalDarkPath = [backupPath stringByAppendingPathComponent:[LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalDark) stringByAppendingString:@".png"]];
            horizontalDarkPath = [backupPath stringByAppendingPathComponent:[LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalDark) stringByAppendingString:@".png"]];
        }
        
        // 3.将启动图保存到备份文件夹
        if (verticalLightImage && verticalLightPath) {
            [UIImageJPEGRepresentation(verticalLightImage, 0.8) writeToFile:verticalLightPath atomically:YES];
        }
        if (verticalDarkImage && verticalDarkPath) {
            [UIImageJPEGRepresentation(verticalDarkImage, 0.8) writeToFile:verticalDarkPath atomically:YES];
        }
        if (horizontalLightImage && horizontalLightPath) {
            [UIImageJPEGRepresentation(horizontalLightImage, 0.8) writeToFile:horizontalLightPath atomically:YES];
        }
        if (horizontalDarkImage && horizontalDarkPath) {
            [UIImageJPEGRepresentation(horizontalDarkImage, 0.8) writeToFile:horizontalDarkPath atomically:YES];
        }
        
        if (launchImage_repairException == YES) {
            [self repairException];
        }
        
        if (launchImage_restoreAsBefore == YES) {
            [self restoreAsBefore];
        }
    } identifier:NSStringFromSelector(@selector(backupSystemLaunchImage))];
}

+ (BOOL)launchImageCustomBlock:(void (^) (NSString *tmpDirectory))complete {
    /// 获取系统启动图路径
    NSString *systemDirectory = systemLaunchImagePath();
    if (!systemDirectory) return NO;
    
    // 工作目录
    NSString *tmpDirectory = ({
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *tmpDirectory = [rootPath stringByAppendingPathComponent:@"LLDynamicLaunchScreen_tmp"];
        tmpDirectory;
    });
    
    // 清理工作目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmpDirectory]) {
        [fileManager removeItemAtPath:tmpDirectory error:nil];
    }
    
    // 移动系统启动图文件夹至工作目录
    BOOL moveResult = [fileManager moveItemAtPath:systemDirectory toPath:tmpDirectory error:nil];
    if (!moveResult) return NO;
    
    !complete ?: complete(tmpDirectory);
    
    // 还原系统启动图信息
    moveResult = [fileManager moveItemAtPath:tmpDirectory toPath:systemDirectory error:nil];
    
    if (!moveResult) return NO;
    
    // 清理工作目录
    if ([fileManager fileExistsAtPath:tmpDirectory]) {
        [fileManager removeItemAtPath:tmpDirectory error:nil];
    }
    
    return YES;
}

/// 根据标识符判断是否是新版本
+ (void)launchImageIsNewVersion:(void (^) (void))complete identifier:(NSString *)identifier {
#ifdef DEBUG
    !complete ?: complete();
#else
    NSMutableDictionary *versionDictionary = [[NSUserDefaults.standardUserDefaults objectForKey:launchImageVersionIdentifier] mutableCopy];
    
    NSString *isNewVersion = [versionDictionary objectForKey:identifier];
    
    if ([isNewVersion isEqualToString:@"YES"]) {
        !complete ?: complete();
        [versionDictionary setObject:@"NO" forKey:identifier];
        [NSUserDefaults.standardUserDefaults setObject:versionDictionary.copy forKey:launchImageVersionIdentifier];
    }
#endif
}

/// 判断是不是启动图后缀
+ (BOOL)isSnapShotSuffix:(NSString *)name {
    // 新系统后缀
    if ([name hasSuffix:@".ktx"]) return YES;
    // 老系统后缀
    if ([name hasSuffix:@".png"]) return YES;
    return NO;
}

BOOL supportHorizontalScreen(void) {
    NSArray *t_array = [NSBundle.mainBundle.infoDictionary objectForKey:@"UISupportedInterfaceOrientations"];
    if ([t_array containsObject:@"UIInterfaceOrientationLandscapeLeft"] ||
        [t_array containsObject:@"UIInterfaceOrientationLandscapeRight"]) {
        return YES;
    } else {
        return NO;
    }
}

NSString * launchScreenName(void) {
    static NSString *launchScreenName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = NSBundle.mainBundle.infoDictionary;
        launchScreenName = [info objectForKey:@"UILaunchStoryboardName"];
    });
    return launchScreenName;
}

NSString * LaunchImageNameFromLaunchImageType(LLLaunchImageType launchImageType) {
    switch (launchImageType) {
        case LLLaunchImageTypeVerticalLight:
            return @"LLLaunchImageTypeVerticalLight";
        case LLLaunchImageTypeVerticalDark:
            return @"LLLaunchImageTypeVerticalDark";
        case LLLaunchImageTypeHorizontalLight:
            return @"LLLaunchImageTypeHorizontalLight";
        case LLLaunchImageTypeHorizontalDark:
            return @"LLLaunchImageTypeHorizontalDark";
    }
}

LLLaunchImageType LaunchImageTypeFromLaunchImageName(NSString *launchImageName) {
    if ([launchImageName isEqualToString:@"LLLaunchImageTypeVerticalDark"]) {
        if (@available(iOS 13.0, *)) {
            return LLLaunchImageTypeVerticalDark;
        } else {
            return LLLaunchImageTypeVerticalLight;
        }
    }
    
    if ([launchImageName isEqualToString:@"LLLaunchImageTypeHorizontalLight"]) {
        return LLLaunchImageTypeHorizontalLight;
    }
    
    if ([launchImageName isEqualToString:@"LLLaunchImageTypeHorizontalDark"]) {
        if (@available(iOS 13.0, *)) {
            return LLLaunchImageTypeHorizontalDark;
        } else {
            return LLLaunchImageTypeHorizontalLight;
        }
    } else {
        return LLLaunchImageTypeVerticalLight;
    }
}

+ (BOOL (^)(UIImage * _Nonnull))hasDarkImageBlock {
    static BOOL (^hasDarkImageBlock) (UIImage *) = ^(UIImage *image) {
        return image.hasDarkImage;
    };
    return hasDarkImageBlock;
}

+ (void)setHasDarkImageBlock:(BOOL (^)(UIImage * _Nonnull))hasDarkImageBlock {
    if (hasDarkImageBlock) {
        LLDynamicLaunchScreen.hasDarkImageBlock = hasDarkImageBlock;
    }
}

BOOL doesExistsOriginLaunchImage(void) {
    for (NSString *obj in [NSFileManager.defaultManager contentsOfDirectoryAtPath:originLaunchImageFullBackupPath() error:nil]) {
        if ([LLDynamicLaunchScreen isSnapShotSuffix:obj] == YES) {
            return YES;
        }
    }
    return NO;
}

NSString * systemLaunchImagePath(void) {
    NSString *bundleID = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];

    NSString *snapshotsPath;
    if (@available(iOS 13.0, *)) {
        NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        snapshotsPath = [NSString stringWithFormat:@"%@/SplashBoard/Snapshots/%@ - {DEFAULT GROUP}", libraryDirectory, bundleID];
    } else {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        snapshotsPath = [[cachesDirectory stringByAppendingPathComponent:@"Snapshots"] stringByAppendingPathComponent:bundleID];
    }
    
    if ([NSFileManager.defaultManager fileExistsAtPath:snapshotsPath]) return snapshotsPath;
    
    return nil;
}

NSString * customLaunchImageBackupPath(void) {
    return (id)[LLDynamicLaunchScreen createFolder:@"custom_launchImage_backup_rootpath"];
}

NSString * originLaunchImageFullBackupPath(void) {
    return (id)[LLDynamicLaunchScreen createFolder:@"origin_launchImage_backup_rootpath"];
}

+ (NSString *)createFolder:(NSString *)folderName {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"LLDynamicLaunchScreen"];
    NSString *fullPath = [rootPath stringByAppendingPathComponent:folderName];
    if ([NSFileManager.defaultManager fileExistsAtPath:fullPath] == NO) {
        [NSFileManager.defaultManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    return fullPath;
}

@end



@implementation UIImage (LLDynamicLaunchScreen)

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

- (UIImage *)resizeImageWithDirection:(BOOL)vertical {
    CGSize imageSize = CGSizeApplyAffineTransform(self.size,
                                                  CGAffineTransformMakeScale(self.scale, self.scale));
    CGSize contextSize = [self contextSizeForPortrait:vertical];
    
    if (!CGSizeEqualToSize(imageSize, contextSize)) {
        UIGraphicsBeginImageContext(contextSize);
        CGFloat ratio = MAX((contextSize.width / self.size.width),
                            (contextSize.height / self.size.height));
        CGRect rect = CGRectMake(0, 0, self.size.width * ratio, self.size.height * ratio);
        [self drawInRect:rect];
        UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage;
    }
    
    return self;
}

- (CGSize)contextSizeForPortrait:(BOOL)isPortrait {
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

+ (UIImage *)createLaunchimageFromSnapshotStoryboardWithisPortrait:(BOOL)isPortrait isDark:(BOOL)isDark {
    
    NSArray<UIWindow *> *currentWindows = UIApplication.sharedApplication.windows;
    
    NSArray<NSNumber *> *interfaceStyleArray = ({
        NSMutableArray<NSNumber *> *interfaceStyleArray = [NSMutableArray array];
        if (@available(iOS 13.0, *)) {
            for (UIWindow *window in currentWindows) {
                [interfaceStyleArray addObject:[NSNumber numberWithInteger:window.overrideUserInterfaceStyle]];
            }
        }
        interfaceStyleArray.copy;
    });
        
    if (@available(iOS 13.0, *)) {
        for (UIWindow *currentwindow in currentWindows) {
            if (currentwindow.hidden == NO) {
                if (isDark) {
                    currentwindow.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
                } else {
                    currentwindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                }
            }
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:launchScreenName() bundle:nil];
    UIViewController *launchImageVC = storyboard.instantiateInitialViewController;
    launchImageVC.view.frame = [UIScreen mainScreen].bounds;
    
    if (isPortrait) {
        if (launchImageVC.view.frame.size.width > launchImageVC.view.frame.size.height) {
            launchImageVC.view.frame = CGRectMake(0, 0, launchImageVC.view.frame.size.height, launchImageVC.view.frame.size.width);
        }
    } else {
        if (launchImageVC.view.frame.size.width < launchImageVC.view.frame.size.height) {
            launchImageVC.view.frame = CGRectMake(0, 0, launchImageVC.view.frame.size.height, launchImageVC.view.frame.size.width);
        }
    }
    
    [launchImageVC.view setNeedsLayout];
    [launchImageVC.view layoutIfNeeded];
    
    UIGraphicsBeginImageContextWithOptions(launchImageVC.view.frame.size, NO, [UIScreen mainScreen].scale);
    [launchImageVC.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *launchImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (@available(iOS 13.0, *)) {
        [interfaceStyleArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIWindow *window = [currentWindows objectAtIndex:idx];
            window.overrideUserInterfaceStyle = obj.integerValue;
        }];
    }
    
    return launchImage;
}

@end



@implementation UIViewController (LLDynamicLaunchScreen)

+ (void)load {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewDidAppear:)), class_getInstanceMethod(self, @selector(llDynamicLaunchScreen_viewDidAppear:)));
}

+ (void)didFinishLaunching {
    [LLDynamicLaunchScreen didFinishLaunching];
}

- (void)llDynamicLaunchScreen_viewDidAppear:(BOOL)animated {
    [self llDynamicLaunchScreen_viewDidAppear:animated];
        
    [LLDynamicLaunchScreen backupSystemLaunchImage];
    
    method_exchangeImplementations(class_getInstanceMethod(UIViewController.class, @selector(llDynamicLaunchScreen_viewDidAppear:)), class_getInstanceMethod(UIViewController.class, @selector(viewDidAppear:)));
}

@end
