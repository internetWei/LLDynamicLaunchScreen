//
//  LLDynamicLaunchScreen+Category.m
//  Demo
//
//  Created by XL on 2023/4/26.
//

#import "LLDynamicLaunchScreen.h"

#import <pthread.h>

/// 获取两个颜色之间的差异程度，0表示相同，值越大表示差距越大，例如纯白和纯黑会返回 86，如果遇到异常情况（例如传进来的 color 为 nil，则会返回 CGFLOAT_MAX）。
///
/// 原理是将两个颜色摆放在 HSB(HSV) 模型内，取两个点之间的距离。由于 HSB(HSV) 没有 alpha 的概念，所以色值相同半透明程度不同的两个颜色会返回 0，也即相等。
FOUNDATION_STATIC_INLINE CGFloat colorDistanceBetweenColor(UIColor *color1, UIColor *color2);


@interface UIImage (LLPrivate)

/// 如果是垂直图像返回YES，否则返回NO。
///
/// 等同于调用 `self.size.width < self.size.height`。
@property (readonly) BOOL ll_isVertical;


/// 遍历给定的区域，使用color进行重绘。
- (nullable UIImage *)ll_drawInRects:(NSArray<NSValue *> *)rects toColor:(UIColor *)color;


/// 如果相同像素点数量大于等于90%则返回YES，否则返回NO。
- (BOOL)ll_isEqualToImage:(UIImage *)image;


/// 获取UIImage在UIImageView中的显示位置。
- (CGRect)ll_CGRectWithContentMode:(UIViewContentMode)mode viewSize:(CGSize)viewSize clipsToBounds:(BOOL)clips;


/// 修改图片的scale。
- (UIImage *)ll_resizeScale:(CGFloat)scale;


/// 返回从该图像中裁剪的新图像。
- (nullable UIImage *)ll_imageByCropToRect:(CGRect)rect;


/// 获取图片指定位置上的颜色。
- (nullable UIColor *)ll_colorAtPoint:(CGPoint)point;


+ (nullable UIImage *)ll_snapshotImageForAView:(UIView *)aView;

@end


@implementation LLDynamicLaunchScreen (LLPrivate)

+ (void)ll_checkLaunchImage {
    NSString *oldAppVersion = [self ll_getUserDefaultsWithKey:@"app_version_check"];
    NSString *appVersion = [NSString stringWithFormat:@"%@_check", [self ll_getAPPInfoForKey:@"CFBundleShortVersionString"]];
    
    if ([oldAppVersion isEqualToString:appVersion]) { return; }
    
    // 记一下哪些图片已经被修改过，修改过的图片不用修复。
    NSMutableSet<NSString *> *nameSet = [NSMutableSet set];
    for (NSNumber *obj in [self ll_getAllCases]) {
        LLLaunchImageType type = [obj integerValue];
        NSString *key = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:type]];
        [nameSet addObject:[self ll_getUserDefaultsWithKey:key] ?: @""];
    }
    
    CGRect ver_imageFrame = CGRectZero;
    NSArray<UIImage *> *ver_images = nil;
    if ([self ll_supportVertical]) {
        ver_images = [self ll_getLaunchScreenLastImageWithDirection:YES];
        NSArray<NSValue *> *imageFrames = [self ll_getLaunchImageInfoWithDirection:YES];
        ver_imageFrame = [imageFrames.lastObject CGRectValue];
    }
    
    CGRect hor_imageFrame = CGRectZero;
    NSArray<UIImage *> *hor_images = nil;
    BOOL containSafeAreaLayoutGuide = NO;
    if ([self ll_supportHorizontal]) {
        hor_images = [self ll_getLaunchScreenLastImageWithDirection:NO];
        NSArray<NSValue *> *imageFrames = [self ll_getLaunchImageInfoWithDirection:NO];
        hor_imageFrame = [imageFrames.lastObject CGRectValue];
        containSafeAreaLayoutGuide = [self ll_containSafeAreaLayoutGuide];
    }
    
    // 启动图文件中没有UIImageView元素。
    if (ver_images.count == 0 && hor_images.count == 0) { return; }
    
    BOOL (^checkForAbnormalImage)(UIImage *) = ^ BOOL (UIImage *launchImage) {
        NSArray<UIImage *> *images = launchImage.ll_isVertical ? ver_images : hor_images;
        if (images.count == 0) { return NO; }
        
        CGRect imageFrame = launchImage.ll_isVertical ? ver_imageFrame : hor_imageFrame;
        UIImage *cropImage = [launchImage ll_imageByCropToRect:imageFrame];
        
        for (UIImage *targetImage in images) {
            if ([targetImage ll_isEqualToImage:cropImage]) { return NO; }
        }
        // 如果截图和所有图片都不能匹配，则认为启动图异常。
        return YES;
    };
    
    
    [self ll_operateOnTheLaunchImageFolder:^NSError *(NSString *path) {
        // 保存异常的启动图名称。
        NSMutableArray<NSString *> *imageNames = [NSMutableArray array];
        
        for (NSString *fileName in [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil]) {
            // 跳过修改过的图片。
            if ([nameSet containsObject:fileName]) { continue; }
            
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath] scale:UIScreen.mainScreen.scale];
            if (launchImage == nil) { continue; }
            
            // 如果包含安全区域约束并且是横屏启动图。
            if (containSafeAreaLayoutGuide && !launchImage.ll_isVertical) {
                [imageNames addObject:fileName];
                continue;
            }
            
            if (checkForAbnormalImage(launchImage)) {
                [imageNames addObject:fileName];
            }
        }
        
        // 修复异常的启动图。
        for (NSString *imageName in imageNames) {
            LLLaunchImageType type = [self ll_getImageTypeFromPath:path imageName:imageName];
            
            NSString *key = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:type]];
            [self ll_setUserDefaultsWithKey:key object:imageName];
            
            UIImage *image = [self ll_getAvailableSystemLaunchImageWithType:type];
            NSString *fullPath = [path stringByAppendingPathComponent:imageName];
            [UIImagePNGRepresentation(image) writeToFile:fullPath atomically:YES];
        }
        
        [self ll_setUserDefaultsWithKey:@"app_version_check" object:appVersion];
        return nil;
    }];
}


/// 启动图文件是否包含安全区域约束。
+ (BOOL)ll_containSafeAreaLayoutGuide {
    UIViewController *viewController = [self ll_getLaunchScreenViewController];
    if (viewController == nil) { return NO; }
    
    BOOL (^mainThread)(void) = ^ BOOL {
        UIView *view = viewController.view;
        UILayoutGuide *guide = view.safeAreaLayoutGuide;
        
        for (NSLayoutConstraint *constraint in view.constraints) {
            if (constraint.firstItem == guide && constraint.secondItem != view) { return YES; }
            if (constraint.secondItem == guide && constraint.firstItem != view) { return YES; }
        }
        
        return NO;
    };
    
    
    if (NSThread.isMainThread) {
        return mainThread();
    } else {
        __block BOOL contains;
        dispatch_sync(dispatch_get_main_queue(), ^{
            contains = mainThread();
        });
        return contains;
    }
}


/// 检查启动图文件是否存在。
+ (nullable NSString *)ll_launchImageExistsAtPath:(NSString *)path imageName:(NSString * _Nullable)fileName {
    if (fileName == nil) { return nil; }
    
    NSString *fullPath = [path stringByAppendingPathComponent:fileName];
    if ([NSFileManager.defaultManager fileExistsAtPath:fullPath]) { return fileName; }
    
    // 删除记录中无效的启动图名称。
    for (NSNumber *obj in [self ll_getAllCases]) {
        LLLaunchImageType type = [obj integerValue];
        NSString *key = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:type]];
        if ([[self ll_getUserDefaultsWithKey:key] isEqualToString:fileName]) {
            [self ll_setUserDefaultsWithKey:key object:nil];
            return nil;
        }
    }
    
    return nil;
}


/// 获取某个启动图的类型。
+ (LLLaunchImageType)ll_getImageTypeFromPath:(NSString *)path imageName:(NSString *)fileName {
    NSString *fullPath = [path stringByAppendingPathComponent:fileName];
    UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath] scale:UIScreen.mainScreen.scale];
    
    BOOL isVertical = launchImage.ll_isVertical;
    NSInteger userInterfaceStyle = [self ll_getUserInterfaceStyle];
    
    if (userInterfaceStyle == 0) {
        // 看一下是否记录过相同尺寸的启动图名称(`这意味着当前启动图就是被记录启动图的相反类型`)。
        if (isVertical) {
            NSString *lightKey = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:LLLaunchImageTypeVerticalLight]];
            NSString *lightImageName = [self ll_getUserDefaultsWithKey:lightKey];
            if ([self ll_launchImageExistsAtPath:path imageName:lightImageName]) {
                if (@available(iOS 13.0, *)) { return LLLaunchImageTypeVerticalDark; }
            }
            
            NSString *darkKey = nil;
            if (@available(iOS 13.0, *)) {
                darkKey = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:LLLaunchImageTypeVerticalDark]];
            }
            NSString *darkImageName = [self ll_getUserDefaultsWithKey:darkKey];
            if ([self ll_launchImageExistsAtPath:path imageName:darkImageName]) {
                return LLLaunchImageTypeVerticalLight;
            }
        } else {
            NSString *lightKey = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:LLLaunchImageTypeHorizontalLight]];
            NSString *lightImageName = [self ll_getUserDefaultsWithKey:lightKey];
            if ([self ll_launchImageExistsAtPath:path imageName:lightImageName]) {
                if (@available(iOS 13.0, *)) { return LLLaunchImageTypeHorizontalDark; }
            }
            
            NSString *darkKey = nil;
            if (@available(iOS 13.0, *)) {
                darkKey = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:LLLaunchImageTypeHorizontalDark]];
            }
            NSString *darkImageName = [self ll_getUserDefaultsWithKey:darkKey];
            if ([self ll_launchImageExistsAtPath:path imageName:darkImageName]) {
                return LLLaunchImageTypeHorizontalLight;
            }
        }
        
        
        UIImage *lightImage = [self ll_getAvailableSystemLaunchImageWithType:isVertical ? LLLaunchImageTypeVerticalLight : LLLaunchImageTypeHorizontalLight];
        UIImage *darkImage = nil;
        if (@available(iOS 13.0, *)) {
            darkImage = [self ll_getAvailableSystemLaunchImageWithType:isVertical ? LLLaunchImageTypeVerticalDark : LLLaunchImageTypeHorizontalDark];
        }
        
        // 将图片指定区域替换为纯色后进行比较。
        {
            NSArray<NSValue *> *imageFrames = [self ll_getLaunchImageInfoWithDirection:isVertical];
            
            UIColor *solidColor = UIColor.blackColor;
            UIImage *targetImage = [launchImage ll_drawInRects:imageFrames toColor:solidColor];
            
            NSMutableArray<UIImage *> *results = [NSMutableArray array];
            
            for (UIImage *image in @[lightImage, darkImage]) {
                UIImage *t_image = [image ll_drawInRects:imageFrames toColor:solidColor];
                if ([targetImage ll_isEqualToImage:t_image]) {
                    [results addObject:image];
                }
            }
            
            if (results.count == 1) {
                if (results.firstObject == lightImage) {
                    return isVertical ? LLLaunchImageTypeVerticalLight : LLLaunchImageTypeHorizontalLight;
                } else if (@available(iOS 13.0, *)) {
                    return isVertical ? LLLaunchImageTypeVerticalDark : LLLaunchImageTypeHorizontalDark;
                }
            }
        }
        
        
        // 比较图片右下角1×1像素点颜色。
        {
            UIImage *targetImage = [launchImage ll_resizeScale:1.0];
            CGPoint endPoint = CGPointMake(targetImage.size.width - 1, targetImage.size.height - 1);
            UIColor *targetColor = [targetImage ll_colorAtPoint:endPoint];
            
            CGFloat minSimilarity = CGFLOAT_MAX;
            UIImage *matchedImage = nil;
            
            // 获取相似度最高的那个图片。
            for (UIImage *image in @[lightImage, darkImage]) {
                UIColor *color = [image ll_colorAtPoint:endPoint];
                
                CGFloat similarity = colorDistanceBetweenColor(color, targetColor);
                if (minSimilarity > similarity) {
                    minSimilarity = similarity;
                    matchedImage = image;
                }
            }
            
            if (@available(iOS 13.0, *)) {
                if (matchedImage == darkImage) {
                    return isVertical ? LLLaunchImageTypeVerticalDark : LLLaunchImageTypeHorizontalDark;
                }
            }
            
            return isVertical ? LLLaunchImageTypeVerticalLight : LLLaunchImageTypeHorizontalLight;
        }
    } else {
        if (@available(iOS 13.0, *)) {
            if (userInterfaceStyle == 2) {
                return launchImage.ll_isVertical ? LLLaunchImageTypeVerticalDark : LLLaunchImageTypeHorizontalDark;
            }
        }
        return launchImage.ll_isVertical ? LLLaunchImageTypeVerticalLight : LLLaunchImageTypeHorizontalLight;
    }
}


/// 获取启动图文件中最后1个UIImageView的深色与浅色截图。
+ (NSArray<UIImage *> *)ll_getLaunchScreenLastImageWithDirection:(BOOL)isVertical {
    UIViewController *viewController = [self ll_getLaunchScreenViewController];
    if (viewController == nil) { return @[]; }
    
    NSMutableArray<UIImage *> *imageArray = [NSMutableArray array];
    
    void (^mainThread)(void) = ^{
        CGFloat width = MIN(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
        CGFloat height = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
        
        NSArray<NSValue *> *imageFrames = [self ll_getLaunchImageInfoWithDirection:isVertical];
        if (imageFrames.count == 0) { return; }
        
        CGRect lastFrame = [imageFrames.lastObject CGRectValue];
        
        UIView *view = viewController.view;
        
        if (isVertical) {
            view.bounds = CGRectMake(0, 0, width, height);
        } else {
            view.bounds = CGRectMake(0, 0, height, width);
        }
        
        [view setNeedsLayout];
        [view layoutIfNeeded];
        
        void (^addImage)(void) = ^{
            UIImage *image = [self ll_snapshotImageWithView:view inRect:lastFrame];
            if (image) { [imageArray addObject:image]; }
        };
        
        if (@available(iOS 13.0, *)) {
            if ([self ll_getUserInterfaceStyle] == 0) {
                viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
                addImage();
                viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                addImage();
            }
        }
        
        if (imageArray.count == 0) { addImage(); }
    };
    
    if ([NSThread isMainThread]) {
        mainThread();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            mainThread();
        });
    }
    
    return [imageArray copy];
}


/// 对UIView指定区域进行截图。
+ (nullable UIImage *)ll_snapshotImageWithView:(UIView *)aView inRect:(CGRect)rect {
    return [[UIImage ll_snapshotImageForAView:aView] ll_imageByCropToRect:rect];
}


+ (nullable NSError *)ll_operateOnTheLaunchImageFolder:(NSError * (^ NS_NOESCAPE)(NSString *path))block {
    static pthread_mutex_t _lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_lock, NULL);
    });
    
    pthread_mutex_lock(&_lock);
    
    NSString *launchImagePath = [self ll_getLaunchImagePath];
    NSString *tmpPath = launchImagePath;
    
    // iOS13.0以下无法直接对启动图进行操作，需要将其先移动到其他可操作的文件夹。
    if (UIDevice.currentDevice.systemVersion.floatValue < 13.0) {
        tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_temp", NSStringFromClass(self)]];
        if ([NSFileManager.defaultManager fileExistsAtPath:tmpPath]) {
            [NSFileManager.defaultManager removeItemAtPath:tmpPath error:nil];
        }
        if (![NSFileManager.defaultManager moveItemAtPath:launchImagePath toPath:tmpPath error:nil]) {
            pthread_mutex_unlock(&_lock);
            return [NSError errorWithDomain:@"budo.lldynamiclaunchscreen.com" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey : @"无法获取系统启动图，请联系作者:internetwei@foxmail.com"}];
        }
    }
    
    NSError *error = !block ? nil : block(tmpPath);
    
    if (UIDevice.currentDevice.systemVersion.floatValue < 13.0) {
        [NSFileManager.defaultManager moveItemAtPath:tmpPath toPath:launchImagePath error:nil];
    }
    
    pthread_mutex_unlock(&_lock);
    
    return error;
}


+ (nullable NSString *)ll_getLaunchImageNameWithType:(LLLaunchImageType)type atPath:(NSString *)path {
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) { return nil; }
    
    NSString *key = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:type]];
    
    // 看一下这个类型的图片名称是不是已经记录过了。
    {
        NSString *launchImageName = [self ll_getUserDefaultsWithKey:key];
        launchImageName = [self ll_launchImageExistsAtPath:path imageName:launchImageName];
        if (launchImageName != nil) { return launchImageName; }
    }
    
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
    
    // 已记录的启动图名称。
    NSMutableSet<NSString *> *nameSet = [NSMutableSet set];
    for (NSNumber *obj in [self ll_getAllCases]) {
        LLLaunchImageType type = [obj integerValue];
        NSString *key = [NSString stringWithFormat:@"%@_name", [self ll_getEnumName:type]];
        [nameSet addObject:[self ll_getUserDefaultsWithKey:key] ?: @""];
    }
    
    NSMutableArray<NSString *> *qualifiedPaths = [NSMutableArray array];
    
    for (NSString *fileName in [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil]) {
        if ([nameSet containsObject:fileName]) { continue; }
        
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath] scale:UIScreen.mainScreen.scale];
        if (launchImage == nil) { continue; }
        
        // 过滤掉尺寸不对的图片。
        if ((isVertical && launchImage.ll_isVertical) ||
            (!isVertical && !launchImage.ll_isVertical)) {
            [qualifiedPaths addObject:fullPath];
            continue;
        }
    }
    
    if (qualifiedPaths.count == 0) { return nil; }
    
    if (qualifiedPaths.count == 1) {
        NSString *imageName = qualifiedPaths.firstObject.lastPathComponent;
        [self ll_setUserDefaultsWithKey:key object:imageName];
        return imageName;
    }
    
    
    UIImage *targetImage = [self ll_getAvailableSystemLaunchImageWithType:type];
    if (targetImage == nil) { return nil; }
    
    NSArray<NSString *> *imageNames = [self ll_getLaunchImageNameWithA:targetImage atPaths:qualifiedPaths];
    if (imageNames.count == 1) {
        NSString *imageName = imageNames.firstObject;
        [self ll_setUserDefaultsWithKey:key object:imageName];
        return imageName;
    }
    
    // 如果1张图片都匹配不上，大概率是系统启动图异常(`例如启动图图片黑化或白化`)；
    if (imageNames.count == 0) {
        imageNames = [self ll_getLaunchImageNameWithB:targetImage atPaths:qualifiedPaths];
        if (imageNames.count == 1) {
            NSString *imageName = imageNames.firstObject;
            [self ll_setUserDefaultsWithKey:key object:imageName];
            return imageName;
        }
    }
    
    // 终极解决方案：匹配右下角1×1像素点颜色。
    NSString *imageName = [self ll_getLaunchImageNameWithC:targetImage atPaths:qualifiedPaths];
    [self ll_setUserDefaultsWithKey:key object:imageName];
    return imageName;
}


+ (UIImage *)ll_resizeImage:(UIImage *)aImage isVertical:(BOOL)isVertical {
    if (CGSizeEqualToSize(aImage.size, CGSizeZero)) { return aImage; }
    
    CGSize targetSize = ({
        CGFloat width = MIN(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
        CGFloat height = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
        isVertical ? CGSizeMake(width, height) : CGSizeMake(height, width);
    });
    
    UIImage *image = [aImage ll_resizeScale:UIScreen.mainScreen.scale];
    
    if (CGSizeEqualToSize(image.size, targetSize)) { return aImage; }
    
    return [image ll_imageByResizeToSize:targetSize contentMode:UIViewContentModeScaleAspectFill];
}


/// 遍历系统启动图并和生成的目标启动图进行比较。
+ (NSArray<NSString *> *)ll_getLaunchImageNameWithA:(UIImage *)targetImage atPaths:(NSArray<NSString *> *)paths {
    NSMutableArray<NSString *> *imageNames = [NSMutableArray array];
    
    for (NSString *path in paths) {
        UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:UIScreen.mainScreen.scale];
        if ([targetImage ll_isEqualToImage:launchImage]) {
            [imageNames addObject:path.lastPathComponent];
        }
    }
    
    return [imageNames copy];
}


/// 将启动图指定区域替换为纯色后进行比较。
+ (NSArray<NSString *> *)ll_getLaunchImageNameWithB:(UIImage *)targetImage atPaths:(NSArray<NSString *> *)paths {
    NSArray<NSValue *> *imageFrames = [self ll_getLaunchImageInfoWithDirection:targetImage.ll_isVertical];
    
    targetImage = [targetImage ll_resizeScale:UIScreen.mainScreen.scale];
    UIColor *solidColor = UIColor.blackColor;
    targetImage = [targetImage ll_drawInRects:imageFrames toColor:solidColor];
    
    NSMutableArray<NSString *> *fileNames = [NSMutableArray array];
    
    for (NSString *path in paths) {
        UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:UIScreen.mainScreen.scale];
        launchImage = [launchImage ll_drawInRects:imageFrames toColor:solidColor];
        if ([targetImage ll_isEqualToImage:launchImage]) {
            [fileNames addObject:path.lastPathComponent];
        }
    }
    
    return fileNames;
}


/// 比较启动图右下角1×1像素尺寸的颜色。
+ (nullable NSString *)ll_getLaunchImageNameWithC:(UIImage *)targetImage atPaths:(NSArray<NSString *> *)paths {
    targetImage = [targetImage ll_resizeScale:1.0];
    CGPoint endPoint = CGPointMake(targetImage.size.width - 1, targetImage.size.height - 1);
    UIColor *targetColor = [targetImage ll_colorAtPoint:endPoint];
    
    CGFloat minSimilarity = CGFLOAT_MAX;
    NSString *fileName = nil;
    
    // 获取相似度最高的那个图片名称。
    for (NSString *path in paths) {
        UIImage *launchImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:1.0];
        UIColor *color = [launchImage ll_colorAtPoint:endPoint];
        
        CGFloat similarity = colorDistanceBetweenColor(color, targetColor);
        if (minSimilarity > similarity) {
            minSimilarity = similarity;
            fileName = path.lastPathComponent;
        }
    }
    
    return fileName;
}


+ (nullable UIViewController *)ll_getLaunchScreenViewController {
    // this class is not key value coding-compliant for the key sceneViewController
    //添加异常处理
    @try {
        NSString *launchStoryboardName = [self ll_getAPPInfoForKey:@"UILaunchStoryboardName"];
        launchStoryboardName = [launchStoryboardName stringByDeletingPathExtension];
        if (launchStoryboardName == nil) { return nil; }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:launchStoryboardName bundle:nil];
        return [storyboard instantiateInitialViewController];
    } @catch (NSException *exception) {
        return nil;
    } @finally {
        
    }
}


+ (NSString *)ll_getEnumName:(LLLaunchImageType)type {
    switch (type) {
        case LLLaunchImageTypeVerticalLight: return @"vertical_light";
        case LLLaunchImageTypeVerticalDark: return @"vertical_dark";
        case LLLaunchImageTypeHorizontalLight: return @"horizontal_light";
        case LLLaunchImageTypeHorizontalDark: return @"horizontal_dark";
    }
}


+ (nullable NSString *)ll_getUserDefaultsWithKey:(NSString *)key {
    NSDictionary *dictionary = [NSUserDefaults.standardUserDefaults objectForKey:NSStringFromClass(self)];
    if (![dictionary isKindOfClass:NSDictionary.class]) { return nil; }
    id value = dictionary[key];
    if ([value isKindOfClass:NSString.class]) { return value; }
    return nil;
}


+ (void)ll_setUserDefaultsWithKey:(NSString *)key object:(nullable NSString *)object {
    NSMutableDictionary *dictionary = ({
        NSDictionary *dict = [NSUserDefaults.standardUserDefaults objectForKey:NSStringFromClass(self)];
        if (![dict isKindOfClass:NSDictionary.class]) { dict = @{}; }
        [dict mutableCopy];
    });
    
    [dictionary setValue:object forKey:key];
    
    [NSUserDefaults.standardUserDefaults setObject:dictionary forKey:NSStringFromClass(self)];
}


+ (NSArray<NSNumber *> *)ll_getAllCases {
    NSMutableArray<NSNumber *> *array = [@[
        @(LLLaunchImageTypeVerticalLight),
        @(LLLaunchImageTypeHorizontalLight),
    ] mutableCopy];
    
    if (@available(iOS 13.0, *)) {
        [array addObject:@(LLLaunchImageTypeVerticalDark)];
        [array addObject:@(LLLaunchImageTypeHorizontalDark)];
    }
    
    return [array copy];
}


+ (BOOL)ll_supportVertical {
    NSArray<NSString *> *orientations = [self ll_getAPPInfoForKey:@"UISupportedInterfaceOrientations"];
    if (orientations.count == 0) { return YES; }
    
    if ([orientations containsObject:@"UIInterfaceOrientationPortrait"] ||
        [orientations containsObject:@"UIInterfaceOrientationPortraitUpsideDown"]) {
        return YES;
    }
    
    return NO;
}


+ (BOOL)ll_supportHorizontal {
    NSArray<NSString *> *orientations = [self ll_getAPPInfoForKey:@"UISupportedInterfaceOrientations"];
    if (orientations.count == 0) { return NO; }
    
    if ([orientations containsObject:@"UIInterfaceOrientationLandscapeLeft"] ||
        [orientations containsObject:@"UIInterfaceOrientationLandscapeRight"]) {
        return YES;
    }
    
    return NO;
}


/// 0: 跟随系统，1：强制浅色，2：强制深色。
+ (NSInteger)ll_getUserInterfaceStyle {
    if (@available(iOS 13.0, *)) {
        NSString *style = [self ll_getAPPInfoForKey:@"UIUserInterfaceStyle"];
        if (style == nil) { return 0; }
        if ([style isEqualToString:@"Automatic"]) { return 0; }
        if ([style isEqualToString:@"Light"]) { return 1; }
        if ([style isEqualToString:@"Dark"]) { return 2; }
    }
    
    return 1;
}


+ (nullable id)ll_getAPPInfoForKey:(NSString *)aKey {
    id aValue = NSBundle.mainBundle.localizedInfoDictionary[aKey];
    if (aValue) { return aValue; }
    
    return NSBundle.mainBundle.infoDictionary[aKey];
}


+ (nullable UIImage *)ll_getAvailableSystemLaunchImageWithType:(LLLaunchImageType)type {
    BOOL supportVertical = [self ll_supportVertical];
    BOOL supportHorizontal = [self ll_supportHorizontal];
    NSInteger userInterfaceStyle = [self ll_getUserInterfaceStyle];
    
    switch (type) {
        case LLLaunchImageTypeVerticalLight: {
            if (supportVertical && (userInterfaceStyle == 0 || userInterfaceStyle == 1)) {
                return [self getSystemLaunchImageWithType:LLLaunchImageTypeVerticalLight];
            }
        } break;
        case LLLaunchImageTypeVerticalDark: {
            if (supportVertical && (userInterfaceStyle == 0 || userInterfaceStyle == 2)) {
                if (@available(iOS 13.0, *)) {
                    return [self getSystemLaunchImageWithType:LLLaunchImageTypeVerticalDark];
                }
            }
        } break;
        case LLLaunchImageTypeHorizontalLight: {
            if (supportHorizontal && (userInterfaceStyle == 0 || userInterfaceStyle == 1)) {
                return [self getSystemLaunchImageWithType:LLLaunchImageTypeHorizontalLight];
            }
        } break;
        case LLLaunchImageTypeHorizontalDark: {
            if (supportHorizontal && (userInterfaceStyle == 0 || userInterfaceStyle == 2)) {
                if (@available(iOS 13.0, *)) {
                    return [self getSystemLaunchImageWithType:LLLaunchImageTypeHorizontalDark];
                }
            }
        } break;
    }
    
    return nil;
}


+ (nullable NSString *)ll_getLaunchImagePath {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;

        if (@available(iOS 13.0, *)) {
            NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
            path = [NSString pathWithComponents:@[libraryPath, @"SplashBoard", @"Snapshots", [NSString stringWithFormat:@"%@ - {DEFAULT GROUP}", bundleIdentifier]]];
        } else {
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            path = [NSString pathWithComponents:@[cachePath, @"Snapshots", bundleIdentifier]];
        }
        
        path = [NSFileManager.defaultManager fileExistsAtPath:path] ? path : nil;
    });
    
    return path;
}


/// 获取UIView上关于UIImage的所有位置数据。
+ (NSArray<NSValue *> *)ll_imageInfoFromView:(UIView *)aView {
    NSMutableArray<NSValue *> *imageFrames = [NSMutableArray array];
    NSArray *imageViewArray = [self ll_getAllImageViewForView:aView];
    for (UIImageView *imageView in imageViewArray) {
        // 计算图片视图在启动屏中的坐标
        CGRect imageViewFrame = [imageView convertRect:imageView.bounds toView:aView];
        // 计算image在imageView中的具体位置。
        CGRect imageRect = [imageView.image ll_CGRectWithContentMode:imageView.contentMode viewSize:imageView.bounds.size clipsToBounds:imageView.clipsToBounds];
        CGFloat x = CGRectGetMinX(imageViewFrame) + CGRectGetMinX(imageRect);
        CGFloat y = CGRectGetMinY(imageViewFrame) + CGRectGetMinY(imageRect);
        CGFloat width = CGRectGetWidth(imageRect);
        CGFloat height = CGRectGetHeight(imageRect);
        [imageFrames addObject:[NSValue valueWithCGRect:CGRectMake(x, y, width, height)]];
    }
    return [imageFrames copy];
}


/// 获取launchScreen上关于UIImage的所有位置数据。
+ (NSArray<NSValue *> *)ll_getLaunchImageInfoWithDirection:(BOOL)isVertical {
    static NSArray<NSValue *> *verticalFrames;
    static NSArray<NSValue *> *horizontalFrames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController *viewController = [self ll_getLaunchScreenViewController];
        if (viewController == nil) { return; }
        
        void (^mainThread)(void) = ^{
            UIView *view = viewController.view;
            
            CGFloat width = MIN(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
            CGFloat height = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
            
            if ([self ll_supportVertical]) {
                view.bounds = CGRectMake(0, 0, width, height);
                [view setNeedsLayout];
                [view layoutIfNeeded];
                verticalFrames = [self ll_imageInfoFromView:view];
            }
            
            if ([self ll_supportHorizontal]) {
                view.bounds = CGRectMake(0, 0, height, width);
                [view setNeedsLayout];
                [view layoutIfNeeded];
                horizontalFrames = [self ll_imageInfoFromView:view];
            }
        };
        
        if (NSThread.isMainThread) {
            mainThread();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                mainThread();
            });
        }
    });
    
    return isVertical ? verticalFrames : horizontalFrames;
}

+ (NSArray <UIImageView *> *)ll_getAllImageViewForView:(UIView *)view {
    NSMutableArray *array = @[].mutableCopy;
    for (UIView *subView in view.subviews) {
        [array addObjectsFromArray:[self ll_getAllImageViewForView:subView]];
        if (subView.isHidden) continue;
        if (![subView isKindOfClass:[UIImageView class]]) continue;
        if (!((UIImageView *)subView).image) continue;
        [array addObject:subView];
    }
    return array.copy;
}


@end


FOUNDATION_STATIC_INLINE CGFloat colorDistanceBetweenColor(UIColor *color1, UIColor *color2) {
    if (!color1 || !color2) return CGFLOAT_MAX;
    
    CGFloat R = 100.0;
    CGFloat angle = 30.0;
    CGFloat h = R * cos(angle / 180 * M_PI);
    CGFloat r = R * sin(angle / 180 * M_PI);
    
    void (^block)(UIColor *, CGFloat *, CGFloat *, CGFloat *) = ^(UIColor *color, CGFloat *hue, CGFloat *saturation, CGFloat *brightness) {
        if (![color getHue:hue saturation:saturation brightness:brightness alpha:0]) {
            *hue = 0;
            *saturation = 0;
            *brightness = 0;
        }
        *hue *= 360;
    };
    
    CGFloat hue1, saturation1, brightness1;
    block(color1, &hue1, &saturation1, &brightness1);
    
    CGFloat hue2, saturation2, brightness2;
    block(color2, &hue2, &saturation2, &brightness2);
    
    CGFloat x1 = r * brightness1 * saturation1 * cos(hue1 / 180 * M_PI);
    CGFloat y1 = r * brightness1 * saturation1 * sin(hue1 / 180 * M_PI);
    CGFloat z1 = h * (1 - brightness1);
    CGFloat x2 = r * brightness2 * saturation2 * cos(hue2 / 180 * M_PI);
    CGFloat y2 = r * brightness2 * saturation2 * sin(hue2 / 180 * M_PI);
    CGFloat z2 = h * (1 - brightness2);
    CGFloat dx = x1 - x2;
    CGFloat dy = y1 - y2;
    CGFloat dz = z1 - z2;
    return sqrt(dx * dx + dy * dy + dz * dz);
}
