//
//  LLDynamicLaunchScreen.m
//  LLDynamicLaunchScreen <https://github.com/internetWei/LLDynamicLaunchScreen>
//
//  Created by LL on 2021/1/18.
//

#import "LLDynamicLaunchScreen.h"

@interface LLDynamicLaunchScreen (LLPrivate)

/// 操作启动图文件夹。
+ (nullable NSError *)ll_operateOnTheLaunchImageFolder:(NSError * (^ NS_NOESCAPE)(NSString *path))block;


/// 获取系统启动图名称。
+ (nullable NSString *)ll_getLaunchImageNameWithType:(LLLaunchImageType)type atPath:(NSString *)path;


+ (nullable UIViewController *)ll_getLaunchScreenViewController;


+ (nullable NSString *)ll_getEnumName:(LLLaunchImageType)type;


+ (nullable NSString *)ll_getUserDefaultsWithKey:(NSString *)key;


+ (void)ll_setUserDefaultsWithKey:(NSString *)key object:(nullable NSString *)object;


/// 返回1个数组，其中包含APP支持的所有启动图类型。
+ (NSArray<NSNumber *> *)ll_getAllCases;


/// 获取受支持的系统启动图。
///
/// 如果指定了Appearance为Light/Dark，尝试获取Dark/Light类型启动图时会返回nil；
/// 如果勾选了仅支持竖屏或横屏，尝试获取横屏或竖屏启动图时会返回nil；
/// 如果在iOS13.0以下系统尝试获取Dark类型启动图会返回nil。
+ (nullable UIImage *)ll_getAvailableSystemLaunchImageWithType:(LLLaunchImageType)type;


/// 将传入的图片尺寸调整成和系统启动图一样。
+ (UIImage *)ll_resizeImage:(UIImage *)aImage isVertical:(BOOL)isVertical;


/// 检查启动图。
+ (void)ll_checkLaunchImage;


+ (nullable id)ll_getAPPInfoForKey:(NSString *)aKey;

@end


@interface UIImage (LLPrivate)

+ (nullable UIImage *)ll_snapshotImageForAView:(UIView *)aView;

@end


@implementation LLDynamicLaunchScreen

+ (void)load {
    /*
     当用户更新APP版本并首次打开时，系统会重新生成启动图(`即使你没有修改启动图文件`)；
     这会导致上个版本修改的启动图信息失效，所以需要在首次打开后重新将上个版本的修改信息应用到当前版本。
     */
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didFinishLaunchingNotification) name:UIApplicationDidFinishLaunchingNotification object:nil];
}


+ (NSString *)versionString { return @"1.0.8"; }


+ (CGFloat)versionNumber { return 1.0;}


+ (void)setReplaceLaunchImageBackupPath:(NSString *)backupPath {
    if (![backupPath isKindOfClass:NSString.class]) { return; }
    [self LLMigrateDataFromPath:backupPath completion:nil];
}


+ (NSString *)replaceLaunchImageBackupPath { return nil; }


static BOOL (^_migrationHandler)(LLLaunchImageType, UIImage * _Nonnull);
+ (void)setMigrationHandler:(BOOL (^)(LLLaunchImageType, UIImage * _Nonnull))migrationHandler {
    _migrationHandler = migrationHandler;
}


+ (BOOL (^)(LLLaunchImageType, UIImage * _Nonnull))migrationHandler { return _migrationHandler; }


#define APPVERSION [self ll_getAPPInfoForKey:@"CFBundleShortVersionString"]
+ (nullable UIImage *)getSystemLaunchImageWithType:(LLLaunchImageType)type {
    // 看一下本地缓存是否有之前生成好的启动图，如果有的话就直接返回。
    NSString *suffix = [NSString stringWithFormat:@"%@_%@", [self ll_getEnumName:type], APPVERSION];
    NSString *cachePath = [[self ll_getSystemLaunchImageBackupPath] stringByAppendingPathComponent:suffix];
    {
        if ([NSFileManager.defaultManager fileExistsAtPath:cachePath]) {
            UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:cachePath] scale:UIScreen.mainScreen.scale];
            if (launchImage != nil) { return launchImage; }
            [NSFileManager.defaultManager removeItemAtPath:cachePath error:nil];
        }
    }
    
    
    UIViewController *viewController = [self ll_getLaunchScreenViewController];
    if (viewController == nil) { return nil; }
    
    UIImage * (^getLaunchImage)(void) = ^{
        if (@available(iOS 13.0, *)) {
            if (type == LLLaunchImageTypeVerticalDark ||
                type == LLLaunchImageTypeHorizontalDark) {
                viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            } else {
                viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
        
        UIView *view = viewController.view;
        
        CGFloat width = MIN(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
        CGFloat height = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
        
        switch (type) {
            case LLLaunchImageTypeVerticalLight:
            case LLLaunchImageTypeVerticalDark: {
                view.bounds = CGRectMake(0, 0, width, height);
            } break;
            case LLLaunchImageTypeHorizontalLight:
            case LLLaunchImageTypeHorizontalDark:{
                view.bounds = CGRectMake(0, 0, height, width);
            } break;
        }
        
        return [UIImage ll_snapshotImageForAView:view];
    };
    
    UIImage * (^saveImage)(UIImage *) = ^ UIImage * (UIImage *image) {
        if (image == nil) { return nil; }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self ll_writeContents:UIImagePNGRepresentation(image) atPath:cachePath];
        });
        return image;
    };
    
    if (NSThread.isMainThread) {
        return saveImage(getLaunchImage());
    } else {
        __block UIImage *launchImage = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            launchImage = getLaunchImage();
        });
        return saveImage(launchImage);
    }
}


+ (nullable UIImage *)getLaunchImageWithType:(LLLaunchImageType)type {
    NSString *cachePath = [[self ll_getLaunchImageBackupPath] stringByAppendingPathComponent:[self ll_getEnumName:type]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:cachePath] scale:UIScreen.mainScreen.scale];
    if (image != nil) { return image; }
    return [self ll_getAvailableSystemLaunchImageWithType:type];
}


+ (BOOL)replaceLaunchImage:(nullable UIImage *)image
                      type:(LLLaunchImageType)type {
    return ([self replaceLaunchImage:image type:type validation:nil] == nil);
}


+ (void)replaceLaunchImage:(nullable UIImage *)image
                      type:(LLLaunchImageType)type
                 completed:(void (^ _Nullable)(NSError * _Nullable))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error = [self replaceLaunchImage:image type:type validation:nil];
        !handler ?: handler(error);
    });
}


#define errorWithDescription(desc) [NSError errorWithDomain:@"budo.lldynamiclaunchscreen.com" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey : desc}]
+ (nullable NSError *)replaceLaunchImage:(nullable UIImage *)image
                      type:(LLLaunchImageType)type
                validation:(BOOL (^ _Nullable NS_NOESCAPE) (UIImage *oldImage, UIImage *newImage))handler {
    if (image != nil && ![image isKindOfClass:UIImage.class]) { return errorWithDescription(@"参数image只能是UIImage或nil"); }
    
    BOOL isReplace = (image != nil);
    
    if (image == nil) {
        image = [self ll_getAvailableSystemLaunchImageWithType:type];
    }
    
    // 调整图片尺寸，保持和系统启动图一样。
    BOOL isVertical = ({
        switch (type) {
            case LLLaunchImageTypeVerticalLight:
            case LLLaunchImageTypeVerticalDark:
                isVertical = YES;
                break;
            default: isVertical = NO;
        }
        isVertical;
    });
    image = [self ll_resizeImage:image isVertical:isVertical];
    
    if (image == nil) { return errorWithDescription(@"image不能是nil，请联系作者:internetwei@foxmail.com"); }
    
    return [self ll_operateOnTheLaunchImageFolder:^NSError * _Nonnull(NSString * _Nonnull path) {
        NSString *launchImageName = [self ll_getLaunchImageNameWithType:type atPath:path];
        if (launchImageName == nil) {
            return errorWithDescription(@"无法获取系统启动图名称，请联系作者:internetwei@foxmail.com");
        }
        
        NSString *imagePath = [path stringByAppendingPathComponent:launchImageName];
        UIImage *oldImage = nil;
        
        if (handler != nil) {
            oldImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath] scale:UIScreen.mainScreen.scale];
            if (oldImage == nil) {
                return errorWithDescription(@"无法获取系统启动图，请联系作者:internetwei@foxmail.com");
            }
        }
        
        BOOL result = !handler ? YES : handler(oldImage, image);
        if (!result) {
            return errorWithDescription(@"handler校验未通过，用户取消操作");
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        if (![imageData writeToFile:imagePath atomically:YES]) {
            return errorWithDescription(@"图片写入失败，请联系作者:internetwei@foxmail.com");
        }
        
        // 更新启动图的修改记录。
        NSString *key = [NSString stringWithFormat:@"%@_modify", [self ll_getEnumName:type]];
        [self ll_setUserDefaultsWithKey:key object:isReplace ? @"YES" : @"NO"];
        
        // 更新启动图的备份文件夹。
        NSString *backupPath = [[self ll_getLaunchImageBackupPath] stringByAppendingPathComponent:[self ll_getEnumName:type]];
        if (isReplace) {
            [self ll_writeContents:imageData atPath:backupPath];
        } else {
            [NSFileManager.defaultManager removeItemAtPath:backupPath error:nil];
        }
        
        return nil;
    }];
}
#undef errorWithDescription


+ (void)restoreAsBefore {
    for (NSNumber *obj in [self ll_getAllCases]) {
        LLLaunchImageType type = [obj integerValue];
        NSString *key = [NSString stringWithFormat:@"%@_modify", [self ll_getEnumName:type]];
        if ([[self ll_getUserDefaultsWithKey:key] isEqualToString:@"YES"]) {
            [self replaceLaunchImage:nil type:type completed:nil];
        }
    }
}


#pragma mark - Notification
+ (void)didFinishLaunchingNotification {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    // 如果是由XCTest启动的话，不用执行迁移等逻辑。
#if TARGET_IPHONE_SIMULATOR
    if (NSProcessInfo.processInfo.environment[@"XCTestBundlePath"]) { return; }
#endif
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self ll_checkLaunchImage];
    });
    
    NSString *oldAppVersion = [self ll_getUserDefaultsWithKey:@"app_version"];
    // 兼容老版本。
    if (oldAppVersion == nil) {
        oldAppVersion = [NSUserDefaults.standardUserDefaults objectForKey:@"launchImage_app_version_identifier"];
    }
    
    // 仅当迁移完成后才保存版本号。
    void (^migrationCompletion) (void) = ^{
        [self ll_setUserDefaultsWithKey:@"app_version" object:APPVERSION];
    };
    
    if (oldAppVersion == nil || [oldAppVersion isEqualToString:APPVERSION]) {
        if (oldAppVersion == nil) { migrationCompletion(); }
        _migrationHandler = nil;
        return;
    }
    
    
    // APP上个版本使用的是不是老版本框架？如果是的话需要将老版本的数据迁移到新版本。
    BOOL isOldVersion = ([NSUserDefaults.standardUserDefaults objectForKey:@"launchImage_app_version_identifier"] != nil);
    
    // 兼容老版本。
    if (isOldVersion) {
        [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"launchImage_app_version_identifier"];
        
        // 删除老版本的启动图修改信息。
        [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"launchImageModifyIdentifier"];
        
        // 删除老版本的启动图名称。
        [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"launchImageInfoIdentifier"];
        
        // 删除老版本的新版本记录。
        [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"launchImageVersionIdentifier"];
        
        // 删除老版本的系统启动图备份文件夹。
        NSString *backupPath = [NSString pathWithComponents:@[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject, @"LLDynamicLaunchScreen", @"custom_launchImage_backup_rootpath"]];
        [NSFileManager.defaultManager removeItemAtPath:backupPath error:nil];
        
        // 将老版本的启动图迁移到新版本。
        backupPath = [NSString pathWithComponents:@[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject, @"LLDynamicLaunchScreen", @"origin_launchImage_backup_rootpath"]];
        [self LLMigrateDataFromPath:backupPath completion:migrationCompletion];
        
        return;
    }
    
    // 删除上个版本的系统启动图备份文件。
    NSString *path = [self ll_getSystemLaunchImageBackupPath];
    for (NSString *fileName in [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil]) {
        if ([fileName hasSuffix:APPVERSION]) { continue; }
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        [NSFileManager.defaultManager removeItemAtPath:fullPath error:nil];
    }
    
    // 找出上个版本修改过的启动图类型。
    NSMutableArray<NSNumber *> *allCases = [[self ll_getAllCases] mutableCopy];
    
    for (NSNumber *obj in [allCases copy]) {
        LLLaunchImageType type = [obj integerValue];
        NSString *key = [NSString stringWithFormat:@"%@_modify", [self ll_getEnumName:type]];
        if (![[self ll_getUserDefaultsWithKey:key] isEqualToString:@"YES"]) {
            // 移除未修改的类型，最后保留下来的就是修改过的类型。
            [allCases removeObject:obj];
        }
        // 删除上个版本记录的启动图名称。
        key = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:type]];
        [self ll_setUserDefaultsWithKey:key object:nil];
    }
    
    // 上个版本没有修改过启动图。
    if (allCases.count == 0) {
        _migrationHandler = nil;
        migrationCompletion();
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *path = [self ll_getLaunchImageBackupPath];
        for (NSNumber *obj in allCases) {
            LLLaunchImageType type = [obj integerValue];
            NSString *imageName = [self ll_getEnumName:type];
            NSString *key = [NSString stringWithFormat:@"%@_modify", imageName];
            NSString *imagePath = [path stringByAppendingPathComponent:imageName];
            UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath] scale:UIScreen.mainScreen.scale];
            
            if (launchImage == nil) {
                [self ll_setUserDefaultsWithKey:key object:nil];
                continue;
            }
            
            BOOL result = !_migrationHandler ? YES : _migrationHandler(type, launchImage);
            if (result) {
                [self replaceLaunchImage:launchImage type:type];
            } else {
                [self ll_setUserDefaultsWithKey:key object:nil];
                [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
            }
        }
        _migrationHandler = nil;
        migrationCompletion();
    });
}
#undef APPVERSION


#pragma mark - Private
/// 和直接调用 `writeToFile:atomically:` 方法的不同在于，该方法会自动创建路径上不存在的文件夹。
+ (BOOL)ll_writeContents:(NSData *)data atPath:(NSString *)path {
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    BOOL isDirectory = NO;
    BOOL isExist = [NSFileManager.defaultManager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    
    if (!isDirectory) {
        if (isExist) {
            [NSFileManager.defaultManager removeItemAtPath:directoryPath error:nil];
        }
        [NSFileManager.defaultManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [data writeToFile:path atomically:YES];
}


/// 获取系统启动图的备份路径。
+ (NSString *)ll_getSystemLaunchImageBackupPath {
    return [self ll_getDirectoryPathWithSuffix:@"systemLaunchImage"];
}


/// 获取启动图的备份路径。
+ (NSString *)ll_getLaunchImageBackupPath {
    return [self ll_getDirectoryPathWithSuffix:@"launchImage"];
}


+ (NSString *)ll_getDirectoryPathWithSuffix:(NSString *)suffix {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [NSString pathWithComponents:@[cachePath, NSStringFromClass(self), suffix]];
    BOOL isDirectory = NO;
    BOOL isExist = [NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!isDirectory) {
        if (isExist) {
            [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        }
        [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}


/// 兼容老版本。
+ (NSInteger)LLGetTypeWithName:(NSString *)name {
    if ([name isEqualToString:@"LLLaunchImageTypeVerticalLight"]) { return LLLaunchImageTypeVerticalLight; }
    if ([name isEqualToString:@"LLLaunchImageTypeHorizontalLight"]) { return LLLaunchImageTypeHorizontalLight; }
    
    if (@available(iOS 13.0, *)) {
        if ([name isEqualToString:@"LLLaunchImageTypeVerticalDark"]) { return LLLaunchImageTypeVerticalDark; }
        if ([name isEqualToString:@"LLLaunchImageTypeHorizontalDark"]) { return LLLaunchImageTypeHorizontalDark; }
    }
    
    return -1;
}


/// 将旧版本数据迁移到新版本。
+ (void)LLMigrateDataFromPath:(NSString *)path completion:(void(^)(void))completion {
    NSError *error;
    NSArray<NSString *> *fileNames = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:&error];
    
    if (fileNames.count == 0) {
        _migrationHandler = nil;
        !completion ?: completion();
        if (error == nil) {
            [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (NSString *fileName in fileNames) {
            NSString *imageName = [fileName stringByDeletingPathExtension];
            NSInteger type = [self LLGetTypeWithName:imageName];
            if (type == -1) { continue; }
            
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath] scale:UIScreen.mainScreen.scale];
            if (launchImage == nil) { continue; }
            
            if (!_migrationHandler ? YES : _migrationHandler(type, launchImage)) {
                [self replaceLaunchImage:launchImage type:type validation:nil];
            }
        }
        
        _migrationHandler = nil;
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        !completion ?: completion();
    });
}

@end
