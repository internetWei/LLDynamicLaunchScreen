//
//  AppDelegate.m
//  LLLaunchScreen
//
//  Created by LL on 2020/12/28.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import "LLDynamicLaunchScreen.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"沙盒路径:%@", NSHomeDirectory());
    sleep(2);
    if (@available(iOS 13.0, *)) {} else {
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        
        ViewController * vc = [[ViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    }
    
    // 修改启动图的备份路径
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ZTY"];
    NSString *rootPath = [libraryPath stringByAppendingPathComponent:@"ABC"];
    LLDynamicLaunchScreen.launchImageBackupPath = rootPath;
    NSString *rootPath2 = [libraryPath stringByAppendingPathComponent:@"CBA"];
    LLDynamicLaunchScreen.replaceLaunchImageBackupPath = rootPath2;
    
    return YES;
}

@end
