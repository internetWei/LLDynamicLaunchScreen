//
//  Tests.m
//  Tests
//
//  Created by LL on 2021/1/30.
//

#import <XCTest/XCTest.h>

static NSString * const launchImageInfoIdentifier = @"launchImageInfoIdentifier";

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
    if ([imageName hasSuffix:@".ktx"]) return YES;
    if ([imageName hasSuffix:@".png"]) return YES;
    return NO;
}


- (void)testMainFuction {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *systemDirectory = launchScreenRootPath();
    if ([fileManager fileExistsAtPath:systemDirectory] == NO) {
        XCTFail(@"系统启动图文件夹路径不存在");
    }
    
    NSString *tmpDirectory = ({
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *tmpDirectory = [rootPath stringByAppendingPathComponent:@"LLDynamicLaunchScreen_tmp"];
        tmpDirectory;
    });
    
    
    if ([fileManager fileExistsAtPath:tmpDirectory]) {
        [fileManager removeItemAtPath:tmpDirectory error:nil];
    }
    
    
    NSError *error = nil;
    BOOL moveResult = [fileManager moveItemAtPath:systemDirectory toPath:tmpDirectory error:&error];
    if (moveResult == NO) {
        XCTFail(@"启动图文件夹移动失败");
    } else {
        BOOL imageNameCheck = NO;
        for (NSString *imageName in [fileManager contentsOfDirectoryAtPath:tmpDirectory error:nil]) {
            if (isSnapShotSuffix(imageName)) {
                imageNameCheck = YES;
                break;
            }
        }
        
        [fileManager moveItemAtPath:tmpDirectory toPath:systemDirectory error:nil];
        XCTAssertTrue(imageNameCheck, @"文件夹内没有合适的启动图");
    }
}


- (void)testInfoDictionary {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (app_version == nil ||
        app_version.length == 0) {
        XCTFail(@"版本号获取失败");
    }
}

@end
