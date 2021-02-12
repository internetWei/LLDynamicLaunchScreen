//
//  AppDelegate.m
//  LLLaunchScreen
//
//  Created by LL on 2020/12/28.
//

#import "AppDelegate.h"

#import "ViewController.h"

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
    
    return YES;
}

@end
