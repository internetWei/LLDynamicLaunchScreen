//
//  Tests.m
//  Tests
//
//  Created by LL on 2021/1/30.
//

#import <XCTest/XCTest.h>

#import "LLDynamicLaunchScreen.h"
#import "UIImage+Category.h"
#include <sys/sysctl.h>


FOUNDATION_STATIC_INLINE NSString * imageCaptionForType(LLLaunchImageType type) {
    switch (type) {
        case LLLaunchImageTypeVerticalLight: return @"竖屏浅色启动图";
        case LLLaunchImageTypeVerticalDark: return @"竖屏深色启动图";
        case LLLaunchImageTypeHorizontalLight: return @"横屏浅色启动图";
        case LLLaunchImageTypeHorizontalDark: return @"横屏深色启动图";
    }
}


@interface LLDynamicLaunchScreen (LLPrivate)

+ (nullable NSString *)ll_getLaunchImagePath;

+ (NSString *)ll_getSystemLaunchImageBackupPath;

+ (NSString *)ll_getLaunchImageBackupPath;

// 将图片调整成和系统启动图一样的尺寸。
+ (UIImage *)ll_resizeImage:(UIImage *)aImage isVertical:(BOOL)isVertical;

@end


@interface UIImage (LLPrivate)

- (BOOL)ll_isEqualToImage:(UIImage *)image;

@end


@interface Tests : XCTestCase

@property (nonatomic, copy) NSString *defaultText;

@property (nonatomic, copy) NSString *launchImagePath;

@end


@interface Tests (Private)

- (void)_testReplaceLaunchImageWithType:(LLLaunchImageType)type isRestore:(BOOL)isRestore;

- (void)_testGetSystemLaunchImageWithType:(LLLaunchImageType)type;

- (void)_testGetLaunchImageWithType:(LLLaunchImageType)type;

@end


@implementation Tests

- (void)setUp {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *model = [NSString stringWithUTF8String:machine];
    free(machine);
    
    self.defaultText = [NSString stringWithFormat:@"iOS %@ 版本的 '%@' 机型: ", UIDevice.currentDevice.systemVersion, model];
    self.launchImagePath = [LLDynamicLaunchScreen ll_getLaunchImagePath];
    
    [LLDynamicLaunchScreen restoreAsBefore];
}


- (void)testLaunchImagePath {
    BOOL isDirectory = NO;
    [NSFileManager.defaultManager fileExistsAtPath:self.launchImagePath isDirectory:&isDirectory];
    XCTAssertTrue(isDirectory, @"%@找不到启动图文件夹", self.defaultText);
}


/// 在iOS13.0及以上系统是否可以直接读取启动图文件夹。
- (void)testLaunchImageFolderReadPermissions {
    if (UIDevice.currentDevice.systemVersion.floatValue >= 13.0) {
        NSError *error = nil;
        [NSFileManager.defaultManager contentsOfDirectoryAtPath:self.launchImagePath error:&error];
        XCTAssertNil(error, @"%@无法直接访问启动图文件夹，错误信息：%@", self.defaultText, error);
    }
}


- (void)testReplaceLaunchImageForVerticalLight {
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeVerticalLight isRestore:NO];
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeVerticalLight isRestore:YES];
}


- (void)testReplaceLaunchImageForVerticalDark API_AVAILABLE(ios(13.0)) {
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeVerticalDark isRestore:NO];
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeVerticalDark isRestore:YES];
}


- (void)testReplaceLaunchImageForHorizontalLight {
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeHorizontalLight isRestore:NO];
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeHorizontalLight isRestore:YES];
}


- (void)testReplaceLaunchImageForHorizontalDark API_AVAILABLE(ios(13.0)) {
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeHorizontalDark isRestore:NO];
    [self _testReplaceLaunchImageWithType:LLLaunchImageTypeHorizontalDark isRestore:YES];
}


- (void)testGetSystemLaunchImageForVerticalLight {
    [self _testGetSystemLaunchImageWithType:LLLaunchImageTypeVerticalLight];
}


- (void)testGetSystemLaunchImageForVerticalDark API_AVAILABLE(ios(13.0)) {
    [self _testGetSystemLaunchImageWithType:LLLaunchImageTypeVerticalDark];
}


- (void)testGetSystemLaunchImageForHorizontalLight {
    [self _testGetSystemLaunchImageWithType:LLLaunchImageTypeHorizontalLight];
}


- (void)testGetSystemLaunchImageForHorizontalDark API_AVAILABLE(ios(13.0)) {
    [self _testGetSystemLaunchImageWithType:LLLaunchImageTypeHorizontalDark];
}


- (void)testGetLaunchImageForVerticalLight {
    [self _testGetLaunchImageWithType:LLLaunchImageTypeVerticalLight];
}


- (void)testGetLaunchImageForVerticalDark API_AVAILABLE(ios(13.0)) {
    [self _testGetLaunchImageWithType:LLLaunchImageTypeVerticalDark];
}


- (void)testGetLaunchImageForHorizontalLight {
    [self _testGetLaunchImageWithType:LLLaunchImageTypeHorizontalLight];
}


- (void)testGetLaunchImageForHorizontalDark API_AVAILABLE(ios(13.0)) {
    [self _testGetLaunchImageWithType:LLLaunchImageTypeHorizontalDark];
}


- (void)testRestoreAsBefore {
    UIImage *localImage = [UIImage imageFileNamed:@"ver_light.jpg"];
    [LLDynamicLaunchScreen replaceLaunchImage:localImage type:LLLaunchImageTypeVerticalLight];
    localImage = [UIImage imageFileNamed:@"hor_light.jpg"];
    [LLDynamicLaunchScreen replaceLaunchImage:localImage type:LLLaunchImageTypeHorizontalLight];
    
    if (@available(iOS 13.0, *)) {
        localImage = [UIImage imageFileNamed:@"ver_dark.jpg"];
        [LLDynamicLaunchScreen replaceLaunchImage:localImage type:LLLaunchImageTypeVerticalDark];
        localImage = [UIImage imageFileNamed:@"hor_dark.jpg"];
        [LLDynamicLaunchScreen replaceLaunchImage:localImage type:LLLaunchImageTypeHorizontalDark];
    }
    
    [LLDynamicLaunchScreen restoreAsBefore];
    
    UIImage *originalImage = [UIImage imageFileNamed:@"launchImage_ver_light.ktx"];
    UIImage *launchImage = [LLDynamicLaunchScreen getSystemLaunchImageWithType:LLLaunchImageTypeVerticalLight];
    XCTAssertTrue([originalImage ll_isEqualToImage:launchImage], @"%@%@还原失败", self.defaultText, imageCaptionForType(LLLaunchImageTypeVerticalLight));
    
    originalImage = [UIImage imageFileNamed:@"launchImage_hor_light.ktx"];
    launchImage = [LLDynamicLaunchScreen getSystemLaunchImageWithType:LLLaunchImageTypeHorizontalLight];
    XCTAssertTrue([originalImage ll_isEqualToImage:launchImage], @"%@%@还原失败", self.defaultText, imageCaptionForType(LLLaunchImageTypeHorizontalLight));
    
    if (@available(iOS 13.0, *)) {
        originalImage = [UIImage imageFileNamed:@"launchImage_ver_dark.ktx"];
        launchImage = [LLDynamicLaunchScreen getSystemLaunchImageWithType:LLLaunchImageTypeVerticalDark];
        XCTAssertTrue([originalImage ll_isEqualToImage:launchImage], @"%@%@还原失败", self.defaultText, imageCaptionForType(LLLaunchImageTypeVerticalDark));
        
        originalImage = [UIImage imageFileNamed:@"launchImage_hor_dark.ktx"];
        launchImage = [LLDynamicLaunchScreen getSystemLaunchImageWithType:LLLaunchImageTypeHorizontalDark];
        XCTAssertTrue([originalImage ll_isEqualToImage:launchImage], @"%@%@还原失败", self.defaultText, imageCaptionForType(LLLaunchImageTypeHorizontalDark));
    }
}

@end



@implementation Tests (Private)

- (void)_testGetLaunchImageWithType:(LLLaunchImageType)type {
    UIImage *localImage;
    switch (type) {
        case LLLaunchImageTypeVerticalLight: {
            localImage = [UIImage imageFileNamed:@"launchImage_ver_light.ktx"];
        } break;
        case LLLaunchImageTypeVerticalDark: {
            localImage = [UIImage imageFileNamed:@"launchImage_ver_dark.ktx"];
        } break;
        case LLLaunchImageTypeHorizontalLight: {
            localImage = [UIImage imageFileNamed:@"launchImage_hor_light.ktx"];
        } break;
        case LLLaunchImageTypeHorizontalDark: {
            localImage = [UIImage imageFileNamed:@"launchImage_hor_dark.ktx"];
        } break;
    }
    
    UIImage *launchImage = [LLDynamicLaunchScreen getLaunchImageWithType:type];
    XCTAssertTrue([localImage ll_isEqualToImage:launchImage], @"%@%@获取到的启动图异常", self.defaultText, imageCaptionForType(type));
    
    [self _testReplaceLaunchImageWithType:type isRestore:NO];
    
    BOOL isVertical = YES;
    switch (type) {
        case LLLaunchImageTypeVerticalLight: {
            localImage = [UIImage imageFileNamed:@"ver_light.jpg"];
        } break;
        case LLLaunchImageTypeVerticalDark: {
            localImage = [UIImage imageFileNamed:@"ver_dark.jpg"];
        } break;
        case LLLaunchImageTypeHorizontalLight: {
            localImage = [UIImage imageFileNamed:@"hor_light.jpg"];
            isVertical = NO;
        } break;
        case LLLaunchImageTypeHorizontalDark: {
            localImage = [UIImage imageFileNamed:@"hor_dark.jpg"];
            isVertical = NO;
        } break;
    }
    
    localImage = [LLDynamicLaunchScreen ll_resizeImage:localImage isVertical:isVertical];
    launchImage = [LLDynamicLaunchScreen getLaunchImageWithType:type];
    
    XCTAssertTrue([localImage ll_isEqualToImage:launchImage], @"%@%@修改后的启动图异常", self.defaultText, imageCaptionForType(type));
}


- (void)_testGetSystemLaunchImageWithType:(LLLaunchImageType)type {
    UIImage *localImage;
    switch (type) {
        case LLLaunchImageTypeVerticalLight: {
            localImage = [UIImage imageFileNamed:@"launchImage_ver_light.ktx"];
        } break;
        case LLLaunchImageTypeVerticalDark: {
            localImage = [UIImage imageFileNamed:@"launchImage_ver_dark.ktx"];
        } break;
        case LLLaunchImageTypeHorizontalLight: {
            localImage = [UIImage imageFileNamed:@"launchImage_hor_light.ktx"];
        } break;
        case LLLaunchImageTypeHorizontalDark: {
            localImage = [UIImage imageFileNamed:@"launchImage_hor_dark.ktx"];
        } break;
    }
    UIImage *launchImage = [LLDynamicLaunchScreen getSystemLaunchImageWithType:type];
    XCTAssertTrue([localImage ll_isEqualToImage:launchImage], @"%@%@获取到的系统启动图异常", self.defaultText, imageCaptionForType(type));
    
    [self _testReplaceLaunchImageWithType:type isRestore:NO];
    
    launchImage = [LLDynamicLaunchScreen getSystemLaunchImageWithType:type];
    XCTAssertTrue([localImage ll_isEqualToImage:launchImage], @"%@%@修改后的系统启动图异常", self.defaultText, imageCaptionForType(type));
}


- (void)_testReplaceLaunchImageWithType:(LLLaunchImageType)type isRestore:(BOOL)isRestore {
    UIImage *launchImage, *targetImage, *mirrorImage;
    BOOL isVertical = YES;
    
    switch (type) {
        case LLLaunchImageTypeVerticalLight: {
            launchImage = [UIImage imageFileNamed:@"launchImage_ver_light.ktx"];
            targetImage = [UIImage imageFileNamed:@"ver_light.jpg"];
            mirrorImage = [UIImage imageFileNamed:@"launchImage_ver_dark.ktx"];
        } break;
        case LLLaunchImageTypeVerticalDark:  {
            launchImage = [UIImage imageFileNamed:@"launchImage_ver_dark.ktx"];
            targetImage = [UIImage imageFileNamed:@"ver_dark.jpg"];
            mirrorImage = [UIImage imageFileNamed:@"launchImage_ver_light.ktx"];
        } break;
        case LLLaunchImageTypeHorizontalLight: {
            launchImage = [UIImage imageFileNamed:@"launchImage_hor_light.ktx"];
            targetImage = [UIImage imageFileNamed:@"hor_light.jpg"];
            mirrorImage = [UIImage imageFileNamed:@"launchImage_hor_dark.ktx"];
            isVertical = NO;
        } break;
        case LLLaunchImageTypeHorizontalDark: {
            launchImage = [UIImage imageFileNamed:@"launchImage_hor_dark.ktx"];
            targetImage = [UIImage imageFileNamed:@"hor_dark.jpg"];
            mirrorImage = [UIImage imageFileNamed:@"launchImage_hor_light.ktx"];
            isVertical = NO;
        } break;
    }
    
    UIImage *resizeImage = [LLDynamicLaunchScreen ll_resizeImage:targetImage isVertical:isVertical];
    
    if (isRestore) {
        UIImage *t_image = resizeImage;
        resizeImage = launchImage;
        launchImage = t_image;
        targetImage = nil;
    }
    
    NSError *error = [LLDynamicLaunchScreen replaceLaunchImage:targetImage type:type validation:^BOOL(UIImage * _Nonnull oldImage, UIImage * _Nonnull newImage) {
        XCTAssertTrue([oldImage ll_isEqualToImage:launchImage], @"%@oldImage和系统启动图不一样，修改类型: %@，还原操作: %@", self.defaultText, imageCaptionForType(type), isRestore ? @"YES" : @"NO");
        XCTAssertTrue([newImage ll_isEqualToImage:resizeImage], @"%@newImage和将要写入的图片不一样，修改类型: %@，还原操作: %@", self.defaultText, imageCaptionForType(type), isRestore ? @"YES" : @"NO");
        return YES;
    }];
    
    XCTAssertNil(error, @"%@%@修改失败，还原操作: %@，具体原因：%@", self.defaultText, imageCaptionForType(type), isRestore ? @"YES" : @"NO", error.localizedFailureReason);
    
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    
    // 检查本地启动图是否真的修改了。
    for (NSString *imageName in [NSFileManager.defaultManager contentsOfDirectoryAtPath:self.launchImagePath error:nil]) {
        NSString *fullPath = [self.launchImagePath stringByAppendingPathComponent:imageName];
        UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
        if (image == nil) { continue; }
        
        // 略过尺寸不一样的启动图。
        if (isVertical && image.size.width > image.size.height) { continue; }
        if (!isVertical &&  image.size.width < image.size.height) { continue; }
        
        [images addObject:image];
    }
    
    if ([images[0] ll_isEqualToImage:mirrorImage]) {
        XCTAssertTrue([images[1] ll_isEqualToImage:resizeImage], @"%@%@修改失败", self.defaultText, imageCaptionForType(type));
    } else {
        BOOL result = [images[0] ll_isEqualToImage:resizeImage] && [images[1] ll_isEqualToImage:mirrorImage];
        XCTAssertTrue(result, @"%@%@修改失败", self.defaultText, imageCaptionForType(type));
    }
}

@end
