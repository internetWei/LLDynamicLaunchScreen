LLDynamicLaunchScreen
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/llDark/blob/master/LICENSE)&nbsp; [![CocoaPods](https://img.shields.io/badge/pod-0.1.0-blue)](http://cocoapods.org/pods/LLDark)&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

Solve abnormal issues such as blank iOS startup map, and support dynamic replacement of startup map.
Chinese mainland users can access[This link](https://gitee.com/internetWei/lldynamic-launch-screen)

特性
==============
- Simple to use, only 1 line of code is needed to modify the startup diagram.
- Powerful function, supports dynamic modification of any type of startup diagram.
- Compatible with models below iOS13.

Demo
==============
![demo.gif](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/Demo/Resources/demo.gif)

Usage
==============
```objc
// Fix the abnormal problem of Launch Screen, or restore Launch Screen to its original state.
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
```

Installation
==============
### CocoaPods
1. Update cocoapods to the latest version.
2. Add pod 'LLDynamicLaunchScreen' to your Podfile.
3. Run pod install or pod update.
4. Import <LLDynamicLaunchScreen/LLDynamicLaunchScreen.h>.

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

Contact
==============
If you have better improvements, please pull reqeust me

If you have any better comments, please create one[Issue](https://github.com/internetWei/LLDynamicLaunchScreen/issues)

The author can be contacted by this email`internetwei@foxmail.com`

License
==============
LLDynamicLaunchScreen is released under the MIT license. See LICENSE file for details.