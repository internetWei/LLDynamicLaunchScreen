//
//  Tests.m
//  Tests
//
//  Created by LL on 2021/1/30.
//

#import <XCTest/XCTest.h>

@interface Tests : XCTestCase

@end

@implementation Tests

NSString *launchScreenRootPath(void) {
    NSString *bundleID = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
    NSString *snapshotsPath;
    if (@available(iOS 13.0, *)) {
        NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        snapshotsPath = [NSString stringWithFormat:@"%@/SplashBoard/Snapshots/%@ - {DEFAULT GROUP}", libraryDirectory, bundleID];
    } else {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        snapshotsPath = [[cachesDirectory stringByAppendingPathComponent:@"Snapshots"] stringByAppendingPathComponent:bundleID];
    }
    
    return snapshotsPath;
}

BOOL isSnapShotSuffix(NSString *imageName) {
    // 新系统后缀
    if ([imageName hasSuffix:@".ktx"]) return YES;
    // 老系统后缀
    if ([imageName hasSuffix:@".png"]) return YES;
    return NO;
}

/// 测试系统启动图文件夹路径是否变更
- (void)testPathChange {
    BOOL isExist = [NSFileManager.defaultManager fileExistsAtPath:launchScreenRootPath()];
    XCTAssertTrue(isExist);
}

/// 测试主功能是否正常(是否可以操作启动图文件夹)
- (void)testMainFuction {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *systemDirectory = launchScreenRootPath();
    if ([fileManager fileExistsAtPath:systemDirectory] == NO) {
        XCTFail(@"启动图文件夹路径不合法");
    }
    
    NSString *tmpDirectory = ({
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *tmpDirectory = [rootPath stringByAppendingPathComponent:@"LLDynamicLaunchScreen_tmp"];
        tmpDirectory;
    });
    
    // 清理工作目录
    if ([fileManager fileExistsAtPath:tmpDirectory]) {
        [fileManager removeItemAtPath:tmpDirectory error:nil];
    }
    
    // 移动系统启动图文件夹至工作目录
    NSError *error = nil;
    BOOL moveResult = [fileManager moveItemAtPath:systemDirectory toPath:tmpDirectory error:&error];
    if (moveResult == NO) {
        XCTFail(@"当前环境不支持移动系统启动图文件夹");
    } else {
        
        BOOL imageNameCheck = NO;
        for (NSString *imageName in [fileManager contentsOfDirectoryAtPath:tmpDirectory error:nil]) {
            if (isSnapShotSuffix(imageName)) {
                imageNameCheck = YES;
                break;
            }
        }
        
        [fileManager moveItemAtPath:tmpDirectory toPath:systemDirectory error:nil];
        
        XCTAssertTrue(imageNameCheck, @"启动图路径不合法");
    }
}

@end
