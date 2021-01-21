LLDynamicLaunchScreen
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/llDark/blob/master/LICENSE)&nbsp; [![CocoaPods](https://img.shields.io/badge/pod-0.1.5-blue)](http://cocoapods.org/pods/LLDark)&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

解决iOS启动图显示异常的问题，并且支持动态更换启动图。
中国大陆用户可以访问[这个链接](https://gitee.com/internetWei/lldynamic-launch-screen)

特性
==============
- 使用简单，仅1行代码即可修改任意启动图。
- 功能强大，支持动态修改/修复任意启动图。
- 支持获取本地任意启动图对象。
- 兼容iOS13以下机型。

Demo
==============
![demo.gif](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/Demo/Resources/demo.gif)  ![demo1.gif](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/Demo/Resources/demo1.gif)

用法
==============
```objc
// 修复启动图显示异常的问题，不会丢失已修改的启动图。
[LLDynamicLaunchScreen repairException];

// 恢复所有启动图为默认启动图，会丢失已修改的启动图，请谨慎使用。
[LLDynamicLaunchScreen restoreAsBefore];

// 按照指定压缩比例，修改浅色竖屏启动图。
[LLDynamicLaunchScreen replaceLaunchImage:replaceImage type:LLLaunchImageTypeVerticalLight compressionQuality:0.8 customValidation:nil];

// 按照指定压缩比例，并且由自己判断是否需要修改启动图。
[LLDynamicLaunchScreen replaceLaunchImage:selectedImage type:LLLaunchImageTypeVerticalLight compressionQuality:0.8 customValidation:^BOOL(UIImage * _Nonnull originImage, UIImage * _Nonnull replaceImage) {
    // 在这里编写逻辑判断是否需要替换启动图
}];

// 自定义暗黑图片判断逻辑。
LLDynamicLaunchScreen.hasDarkImageBlock = ^BOOL(UIImage * _Nonnull image) {
    // 在这里实现逻辑，判断该图片是否是深色系图片。
    // 默认情况下，LLDynamicLaunchScreen会获取图片右上角1×1像素点的RGB来判断是不是深色系图片。
};

// 获取本地竖屏浅色启动图对象。
[LLDynamicLaunchScreen launchImageFromType:LLLaunchImageTypeVerticalLight];
```

安装
==============
### CocoaPods
1. 在 Podfile 中添加 pod 'LLDynamicLaunchScreen'。
2. 执行 pod install --repo-update。
3. 导入 <LLDynamicLaunchScreen/LLDynamicLaunchScreen.h>。

### 手动安装
1. 下载 LLDynamicLaunchScreen 文件夹内的所有内容。
2. 将LLDynamicLaunchScreen文件夹添加(拖放)到你的工程。
3. 导入 "LLDynamicLaunchScreen.h"。

系统要求
==============
该项目最低支持iOS9.0和Xcode10.0，如果想在更低系统上使用可以联系作者。

注意点
==============
* 替换图片尺寸建议和屏幕物理分辨率保持一致。
* APP更新版本后，第一次打开APP会显示默认启动图。这是系统限制，暂时没办法解决。

联系作者
==============
如果你有更好的改进，please pull reqeust me

如果你有任何更好的意见，请创建一个[Issue](https://gitee.com/internetWei/lldynamic-launch-screen/issues)

可以通过此邮箱联系作者`internetwei@foxmail.com`

许可证
==============
LLDynamicLaunchScreen 使用 MIT 许可证，详情见 LICENSE 文件。
