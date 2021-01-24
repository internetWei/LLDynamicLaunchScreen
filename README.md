LLDynamicLaunchScreen
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/llDark/blob/master/LICENSE)&nbsp; [![Carthage](https://img.shields.io/badge/Carthage-compatible-blue)](https://github.com/Carthage/Carthage)&nbsp; [![CocoaPods](https://img.shields.io/badge/pod-0.2.0-blue)](http://cocoapods.org/pods/LLDark)&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

Solve the problem of abnormal display of iOS startup map, and support dynamic replacement of startup map.<br>
Chinese mainland users can access[This link](https://gitee.com/internetWei/lldynamic-launch-screen)<br>
[中文介绍](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/README_CN.md)

Features
==============
- It is simple to use, only one line of code can modify any startup diagram.
- Powerful, supports dynamic modification/repair of any startup diagram.
- Support to obtain any local startup graph object.
- Compatible with models below iOS13.
- Automatically repair the startup map showing black or abnormal problems.

Demo
==============
![demo.gif](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/Demo/Resources/demo.gif)  ![demo1.gif](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/Demo/Resources/demo1.gif)

Usage
==============
```objc
// Restore all startup maps to the default startup map, and the modified startup map will be lost, please use it with caution.
[LLDynamicLaunchScreen restoreAsBefore];

// Modify the light-colored vertical Launch Screen according to the specified compression rate.
[LLDynamicLaunchScreen replaceLaunchImage:replaceImage type:LLLaunchImageTypeVerticalLight compressionQuality:0.8 customValidation:nil];

// According to the specified compression ratio, it is up to you to determine whether you need to modify Launch Screen.
[LLDynamicLaunchScreen replaceLaunchImage:selectedImage type:LLLaunchImageTypeVerticalLight compressionQuality:0.8 customValidation:^BOOL(UIImage * _Nonnull originImage, UIImage * _Nonnull replaceImage) {
    // Write logic here to determine whether you need to replace Launch Screen?
}];

// Customize the dark picture judgment logic.
LLDynamicLaunchScreen.hasDarkImageBlock = ^BOOL(UIImage * _Nonnull image) {
    // Implement logic here to determine whether the picture is a dark picture.
    // By default, LLDynamicLaunchScreen will obtain the 1×1 pixel RGB at the upper right corner of the picture to determine whether it is a dark picture.
};

// Get the local light-colored startup map object in vertical screen.
[LLDynamicLaunchScreen launchImageFromType:LLLaunchImageTypeVerticalLight];
```

Installation
==============
### CocoaPods
1. Add pod 'LLDynamicLaunchScreen' to your Podfile.
2. Run pod install --repo-update.
3. Import \<LLDynamicLaunchScreen/LLDynamicLaunchScreen.h\>.

### Carthage

1. Add `github "internetWei/LLDynamicLaunchScreen"` to your Cartfile.
2. Run `carthage update --platform ios` and add the framework to your project.
3. Import \<LLDynamicLaunchScreen/LLDynamicLaunchScreen.h\>.

### Manually
1. Download all the files in the LLDynamicLaunchScreen subdirectory.
2. Add (drag and drop) the LLDynamicLaunchScreen folder to your project.
3. Import LLDynamicLaunchScreen.h.

Requirements
==============
The project supports iOS 9.0 and Xcode 10.0 at least. If you want to use it on lower systems, please contact the author.

Note
==============
* The replacement image size is recommended to be consistent with the screen size.
* After updating the APP, the default startup diagram will be displayed when the APP is opened for the first time. This is caused by system limitations and cannot be resolved temporarily.

Contact
==============
If you have better improvements, please pull reqeust me

If you have any better comments, please create one[Issue](https://github.com/internetWei/LLDynamicLaunchScreen/issues)

The author can be contacted by this email`internetwei@foxmail.com`

License
==============
LLDynamicLaunchScreen is released under the MIT license. See LICENSE file for details.
