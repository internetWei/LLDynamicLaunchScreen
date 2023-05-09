//
//  AppDelegate.m
//  LLLaunchScreen
//
//  Created by LL on 2020/12/28.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"沙盒路径:%@/Library/SplashBoard/Snapshots/%@ - {DEFAULT GROUP}/", NSHomeDirectory(), NSBundle.mainBundle.bundleIdentifier);
#endif
    
    // 如果不是由XCTest启动。
    if (!NSProcessInfo.processInfo.environment[@"XCTestBundlePath"]) {
        sleep(3);
    }
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[ViewController alloc] init];
    
    return YES;
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
