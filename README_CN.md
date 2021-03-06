LLDynamicLaunchScreen
==============
[![LLDynamicLaunchScreen CI](https://github.com/internetWei/LLDynamicLaunchScreen/workflows/LLDynamicLaunchScreen%20CI/badge.svg)](https://github.com/internetWei/LLDynamicLaunchScreen/actions)&nbsp;&nbsp; [![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/LICENSE)&nbsp;&nbsp; [![Carthage](https://img.shields.io/badge/Carthage-compatible-blue)](https://github.com/Carthage/Carthage)&nbsp; &nbsp;[![CocoaPods](https://img.shields.io/badge/pod-0.2.2-blue)](http://cocoapods.org/pods/LLDynamicLaunchScreen)&nbsp;&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

自动修复iPhone启动图显示异常，1行代码修改启动图

特性
==============
- 自动修复启动图显示异常
- 1行代码修改启动图
- 兼容iOS13以下系统

Demo
==============
| 动态修改启动图  | 修复启动图异常 |
| :-------------: | :-------------: |
| ![demo.gif](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/Resources/demo.gif)  | ![repair.gif](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/Resources/Repair.gif)  |

用法
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

安装
==============
### CocoaPods
1. 在 Podfile 中添加 pod 'LLDynamicLaunchScreen'
2. 执行 pod install --repo-update
3. 导入 \<LLDynamicLaunchScreen/LLDynamicLaunchScreen.h\>

### Carthage
1. 在 Cartfile 中添加 `github "internetWei/LLDynamicLaunchScreen"`
2. 执行 `carthage update --platform ios` 并将生成的 framework 添加到你的工程
3. 导入 \<LLDynamicLaunchScreen/LLDynamicLaunchScreen.h\>

### 手动安装
1. 下载 LLDynamicLaunchScreen 文件夹内的所有内容
2. 将LLDynamicLaunchScreen文件夹添加(拖放)到你的工程
3. 导入 "LLDynamicLaunchScreen.h"

系统要求
==============
该项目最低支持iOS9.0和Xcode10.0，如果想在更低系统上使用可以联系作者

注意点
==============
* 替换图片的尺寸建议和屏幕物理分辨率保持一致
* APP更新版本后，第一次打开APP会显示默认启动图，这是系统限制，暂时没办法解决
* 可以修改iPad启动图，但是并不完美，后续版本会适配

联系作者
==============
如果你有更好的改进，please pull reqeust me

如果你有任何更好的意见，请创建一个[Issue](https://gitee.com/internetWei/lldynamic-launch-screen/issues)

可以通过此邮箱联系作者`internetwei@foxmail.com`

[LLDynamicLaunchScreen设计思路](https://internetwei.github.io/2021/03/02/LLDynamicLaunchScreen%20%E8%AE%BE%E8%AE%A1%E6%80%9D%E8%B7%AF/)


待办事项
==============
* [ ] 完善iPad的启动图修复与替换

许可证
==============
LLDynamicLaunchScreen 使用 MIT 许可证，详情见 LICENSE 文件
