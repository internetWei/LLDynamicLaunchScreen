LLDynamicLaunchScreen
==============
[![LLDynamicLaunchScreen CI](https://github.com/internetWei/LLDynamicLaunchScreen/workflows/LLDynamicLaunchScreen%20CI/badge.svg)](https://github.com/internetWei/LLDynamicLaunchScreen/actions)&nbsp;&nbsp; [![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/llDark/blob/master/LICENSE)&nbsp;&nbsp; [![Carthage](https://img.shields.io/badge/Carthage-compatible-blue)](https://github.com/Carthage/Carthage)&nbsp; &nbsp;[![CocoaPods](https://img.shields.io/badge/pod-0.2.2-blue)](http://cocoapods.org/pods/LLDark)&nbsp;&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

Solve the problem of abnormal display of iOS startup map, and support dynamic replacement of startup map.<br>
Chinese mainland users can access[This link](https://gitee.com/internetWei/lldynamic-launch-screen)<br>
[中文介绍](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/README_CN.md)

Features
==============
- After integration, automatically repair the startup map display abnormalities and other issues
- 1 line of code to modify any startup diagram
- Support to get the current startup graph object
- Compatible with systems below iOS13

Demo
==============
| Dynamic modification  | Fix exception |
| :-------------: | :-------------: |
| ![demo.gif](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/Resources/demo.gif)  | ![repair.gif](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/Resources/Repair.gif)  |

Usage
==============
```objc
// 将所有启动图恢复为默认启动图(Restore all launch screen to the initial state)
[LLDynamicLaunchScreen restoreAsBefore];

// 替换指定类型启动图(Replace the specified type of launch Image)
[LLDynamicLaunchScreen replaceLaunchImage:replaceImage type:LLLaunchImageTypeVerticalLight compressionQuality:0.8 customValidation:nil];

// 自定义暗黑系启动图的校验规则(Customize the verification rules of the dark style launch screen)
LLDynamicLaunchScreen.hasDarkImageBlock = ^BOOL(UIImage * _Nonnull image) {
        
};

// 获取指定模式下的本地启动图(Get the local launch screen diagram in the specified mode)
[LLDynamicLaunchScreen launchImageFromType:LLLaunchImageTypeVerticalLight];
```

Installation
==============
### CocoaPods
1. Add pod 'LLDynamicLaunchScreen' to your Podfile
2. Run pod install --repo-update
3. Import \<LLDynamicLaunchScreen/LLDynamicLaunchScreen.h\>

### Carthage
1. Add `github "internetWei/LLDynamicLaunchScreen"` to your Cartfile
2. Run `carthage update --platform ios` and add the framework to your project
3. Import \<LLDynamicLaunchScreen/LLDynamicLaunchScreen.h\>

### Manually
1. Download all the files in the LLDynamicLaunchScreen subdirectory
2. Add (drag and drop) the LLDynamicLaunchScreen folder to your project
3. Import "LLDynamicLaunchScreen.h"

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
