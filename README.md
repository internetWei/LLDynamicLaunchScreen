LLDynamicLaunchScreen
==============
[![LLDynamicLaunchScreen CI](https://github.com/internetWei/LLDynamicLaunchScreen/workflows/LLDynamicLaunchScreen%20CI/badge.svg)](https://github.com/internetWei/LLDynamicLaunchScreen/actions)&nbsp;&nbsp; [![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/LICENSE)&nbsp;&nbsp; [![Carthage](https://img.shields.io/badge/Carthage-compatible-blue)](https://github.com/Carthage/Carthage)&nbsp; &nbsp;[![CocoaPods](https://img.shields.io/badge/pod-0.2.2-blue)](http://cocoapods.org/pods/LLDynamicLaunchScreen)&nbsp;&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![blog](https://img.shields.io/badge/blog-budo-blue)](https://internetwei.github.io/)

自动修复iPhone启动图显示异常，1行代码修改任意启动图。

[Swift版本](https://github.com/internetWei/LLaunchScreen)(建议使用OC版本，如果您是Swift工程，也可以使用该框架，Swift框架后续将不会再更新维护)

特性
==============
- 自动修复启动图显示异常
- 1行代码修改任意启动图
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

说明
==============
理论上没有最低系统限制，不过我只在iOS9及以上机型测试过没问题，但是工程必须要使用storyboard作为启动图。

注意事项
==============
* 替换图片的尺寸建议和屏幕物理分辨率保持一致。
* APP更新版本后，第一次打开APP会显示默认启动图，这是系统限制，暂时没办法解决。
* 建议不要在iPad上使用，因为iPad相对于iPhone有10种不同的启动图，该框架暂时还没有适配。

联系作者
==============
如果你有更好的改进，please pull reqeust me

如果你有任何更好的意见，请创建一个[issue](https://github.com/internetWei/lldynamic-launch-screen/issues)

或者直接联系作者`internetwei@foxmail.com`

[LLDynamicLaunchScreen的设计思路](https://internetwei.github.io/2021/03/07/LLDynamicLaunchScreen%E7%9A%84%E8%AE%BE%E8%AE%A1%E6%80%9D%E8%B7%AF/)

更新记录
==============
- 0.2.2 将英文注释替换为了中文，增加了如下API:

```
1. launchImageBackupPath(用于自定义系统启动图的备份路径，方便开发人员管理工程的文件结构)。
2. replaceLaunchImageBackupPath(用于自定义用户替换启动图的备份路径)。
```

许可证
==============
LLDynamicLaunchScreen 使用 MIT 许可证，详情见 LICENSE 文件
