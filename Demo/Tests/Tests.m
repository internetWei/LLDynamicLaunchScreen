//
//  Tests.m
//  Tests
//
//  Created by LL on 2021/1/30.
//

#import <XCTest/XCTest.h>

#import "LLDynamicLaunchScreen.h"

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


// 测试本地启动图名称字典是否正确
//- (void)testLaunchImageNameDictionary {
//    NSMutableArray *nameArray = [NSMutableArray array];
//    [nameArray addObject:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalLight)];
//
//    BOOL supportHorizontalScreen = NO;
//    NSArray *t_array = [NSBundle.mainBundle.infoDictionary objectForKey:@"UISupportedInterfaceOrientations"];
//    XCTAssertNotNil(t_array, "t_array not nil");
//
//    if ([t_array containsObject:@"UIInterfaceOrientationLandscapeLeft"] ||
//        [t_array containsObject:@"UIInterfaceOrientationLandscapeRight"]) {
//        supportHorizontalScreen = YES;
//    }
//
//    if (supportHorizontalScreen) {
//        [nameArray addObject:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalLight)];
//    }
//
//    if (@available(iOS 13.0, *)) {
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        NSString *interfaceStyle = [infoDictionary objectForKey:@"UIUserInterfaceStyle"];
//        if (![interfaceStyle isEqualToString:@"Light"]) {
//            [nameArray addObject:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeVerticalDark)];
//
//            if (supportHorizontalScreen == YES) {
//                [nameArray addObject:LaunchImageNameFromLaunchImageType(LLLaunchImageTypeHorizontalDark)];
//            }
//        }
//    }
//
//
//    NSDictionary *infoDictionary = [NSUserDefaults.standardUserDefaults objectForKey:launchImageInfoIdentifier];
//    for (NSString *obj in nameArray) {
//        if ([infoDictionary objectForKey:obj] == nil) {
//            XCTFail();
//        }
//    }
//}

@end
