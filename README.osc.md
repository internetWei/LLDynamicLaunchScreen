LLDynamicLaunchScreen
==============
[![CI](https://github.com/internetWei/LLDynamicLaunchScreen/workflows/LLDynamicLaunchScreen%20CI/badge.svg)](https://github.com/internetWei/LLDynamicLaunchScreen/actions)&nbsp;&nbsp; [![Carthage](https://img.shields.io/badge/Carthage-compatible-brightgreen)](https://github.com/Carthage/Carthage)&nbsp; &nbsp;[![CocoaPods](https://img.shields.io/badge/pod-1.0.8-blue)](http://cocoapods.org/pods/LLDynamicLaunchScreen)&nbsp;&nbsp; [![Platform](https://img.shields.io/badge/platform-iOS-blue)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://gitee.com/internetWei/lldynamic-launch-screen/blob/master/LICENSE)

__LLDynamicLaunchScreen__ 是1个可以让你不用更新APP并修改iPhone上的各种启动图；它还可以自动修复启动图的各种显示异常。

> 该框架目前没有使用 swift 重写的计划，因为swift没有load方法，有些逻辑需要开发者手动调用，这可能会增加使用成本；当然，它支持和swift混编；如果你想作者提供1个swift版本的话，请在这个 [issues](https://github.com/internetWei/LLDynamicLaunchScreen/issues/18) 中留言。

功能
==============

- 不更新APP修改启动图(`支持从网络下载图片`)。
- 自动修复启动图黑屏/白屏。
- 自动修复启动图在横屏状态下可能显示异常。
- 更新APP版本后自动迁移上个版本数据，无需开发者手动处理。
- 对迁移数据的精确控制，可控制哪张启动图需要迁移，哪张不需要。
- 任何公开API均支持子线程调用，以提高性能。

演示
==============
| 修改启动图  | 自动修复异常 |
| :-------------: | :-------------: |
| ![demo1](https://s1.ax1x.com/2023/05/25/p9Hv4MT.gif) | ![demo2](https://s1.ax1x.com/2023/05/25/p9Hv7dJ.gif) |

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

如果你的项目使用的是 `LaunchScreen` 而非 `LaunchImage`，理论上没有最低版本限制；不过我只在iOS11.0及以上系统使用并测试过，如果你在低于iOS11.0的版本上使用并遇到了问题，请提交 [issues](https://gitee.com/internetWei/lldynamic-launch-screen/issues/new)。

注意事项
==============

如果你在项目中使用了1整张图片适配启动图(`或者大于屏幕90%区域`)的话，请你勿必在启动图的右下角添加1个1×1像素的辅助视图，并将视图的背景设置成 system color，具体细节请看：[LLDynamicLaunchScreen 设计思路](https://juejin.cn/post/6913163202851241998) 中关于《修改启动图》的内容。

已知问题
==============

1. 当用户修改了手机上的系统语言后，系统会清空APP所有启动图，并且在下次启动时不会一次性生成所有启动图，而只会生成当前模式下的1张启动图(`测试设备：iPhone 14, iOS 16.4.1`)；由于这种情况很少发生(`除了测试，一般情况下用户不会去修改手机上的首选语言`)，所以暂时不会处理。
2. 如果APP支持国际化的话，系统会根据首次打开时的语言选择启动图文件，即使后面修改系统语言，除非更新APP，否则还是会显示首次打开时的语言的启动图(`有点拗口，举个例子，首次打开APP时系统语言是简体中文，此时系统会选择简体中文的启动图文件，然后用户将系统语言修改成了英语，此时系统会清空所有启动图，当用户打开APP时，系统会重新生成启动图，但系统没有显示英语的启动图文件，而是显示第1次也就是简体中文的启动图文件，这应该是系统启动图BUG`)；一般用户也不会去修改手机上的系统语言，所以暂时不会处理。

支持
==============

如果你有任何更好的意见，请提交 [issue](https://gitee.com/internetWei/lldynamic-launch-screen/issues/new)。

如需支持，请发送电子邮件至 [internetwei@foxmail.com](internetwei@foxmail.com)。

致谢
==============

* [DynamicLaunchImage](https://github.com/iversonxh/DynamicLaunchImage)
* [iOS启动图异常修复方案](https://mp.weixin.qq.com/s/giXmBAC0ft-kRB3BloawzA)

许可证
==============

__LLDynamicLaunchScreen__ 使用 MIT 许可证，详情见 [LICENSE](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/LICENSE)。