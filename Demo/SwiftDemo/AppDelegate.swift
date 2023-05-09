//
//  AppDelegate.swift
//  SwiftDemo
//
//  Created by LL on 2023/5/6.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if targetEnvironment(simulator)
        print("沙盒路径:\(NSHomeDirectory())/Library/SplashBoard/Snapshots/\(Bundle.main.bundleIdentifier ?? "") - {DEFAULT GROUP}/")
        #endif
        
        sleep(3)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = ViewController()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

