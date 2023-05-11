LLDynamicLaunchScreen
==============
[![LLDynamicLaunchScreen CI](https://github.com/internetWei/LLDynamicLaunchScreen/workflows/LLDynamicLaunchScreen%20CI/badge.svg)](https://github.com/internetWei/LLDynamicLaunchScreen/actions)&nbsp;&nbsp; [![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/LICENSE)&nbsp;&nbsp; [![Carthage](https://img.shields.io/badge/Carthage-compatible-brightgreen)](https://github.com/Carthage/Carthage)&nbsp; &nbsp;[![CocoaPods](https://img.shields.io/badge/pod-1.0.2-blue)](http://cocoapods.org/pods/LLDynamicLaunchScreen)&nbsp;&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-blue)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![blog](https://img.shields.io/badge/blog-buDo-blue)](https://juejin.cn/user/2418581312385288/posts)

__LLDynamicLaunchScreen__ 是1个专注于解决iOS上启动图各种问题的框架，它仅有 __78kb__，但这并不影响它的强大(`这绝对是你在iOS平台上能找到的最好的启动图的解决方案`)。

特性
==============

- 不用更新APP也能修改启动图(`支持从网络下载图片`)。
- 自动修复启动图显示黑屏或白屏。
- 自动修复启动图在横屏状态下可能显示异常。

演示
==============
| 修改启动图  | 自动修复异常 |
| :-------------: | :-------------: |
| ![demo1](https://github.com/internetWei/LLDynamicLaunchScreen/blob/bf2e322e020c342a3bce91ff8dc65a6bf04846ae/Resources/demo1.gif?raw=true)  | ![demo2](https://github.com/internetWei/LLDynamicLaunchScreen/blob/bf2e322e020c342a3bce91ff8dc65a6bf04846ae/Resources/demo2.gif?raw=true)  |

示例代码
==============
```objc
// objc示例代码：
// 在子线程中修改指定类型的启动图。
[LLDynamicLaunchScreen replaceLaunchImage:replaceImage type:LLLaunchImageTypeVerticalLight completed:nil];
```

```swift
// swift示例代码：
// 在子线程中修改指定类型的启动图。
LLDynamicLaunchScreen.replaceLaunch(replaceImage, type: .verticalLight, completed: nil)
```

安装
==============

### CocoaPods
1. 在 Podfile 中添加 `pod 'LLDynamicLaunchScreen'`。
2. 执行 `pod install` 或 `pod update`。
3. `#import <LLDynamicLaunchScreen/LLDynamicLaunchScreen.h>`。

### Carthage
1. 在 Cartfile 中添加 `github "internetWei/LLDynamicLaunchScreen"`。
2. 执行 `carthage update --platform ios` 并将生成的 framework 添加到你的工程。
3. `#import <LLDynamicLaunchScreen/LLDynamicLaunchScreen.h>`。

### 手动安装
1. 下载 `LLDynamicLaunchScreen` 文件夹内的所有内容。
2. 将LLDynamicLaunchScreen文件夹添加(拖放)到你的工程。
3. `#import "LLDynamicLaunchScreen.h"`。

版本限制
==============

只要你的项目启动图使用的是 `LaunchScreen` 而非 `LaunchImage`，理论上没有最低版本限制；不过我只在iOS11.0及以上系统使用并测试过，如果你在低于iOS11.0的版本上使用并遇到了问题，可以联系我：`internetwei@foxmail.com`。

注意事项
==============

如果你在项目中使用了1整张图片适配启动图(`或者大于屏幕90%区域`)的话，请你勿必在启动图文件的右下角添加1个1×1像素点的辅助视图，并将视图的背景设置成 system color，具体细节请看：[LLDynamicLaunchScreen 设计思路](https://juejin.cn/post/6913163202851241998) 中关于《修改启动图》的内容。

支持
==============

如果你有更好的改进，please pull reqeust me.

如果你有任何更好的意见，请创建一个[issue](https://github.com/internetWei/lldynamic-launch-screen/issues)。

如需支持，请发送电子邮件至 [internetwei@foxmail.com](internetwei@foxmail.com)。

致谢
==============

* [DynamicLaunchImage](https://github.com/iversonxh/DynamicLaunchImage)
* [iOS启动图异常修复方案](https://mp.weixin.qq.com/s/giXmBAC0ft-kRB3BloawzA)

许可证
==============

__LLDynamicLaunchScreen__ 使用 MIT 许可证，详情见 [LICENSE](https://raw.githubusercontent.com/internetWei/LLDynamicLaunchScreen/master/LICENSE) 文件。