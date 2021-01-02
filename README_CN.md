LLDynamicLaunchScreen
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/llDark/blob/master/LICENSE)&nbsp; [![CocoaPods](https://img.shields.io/badge/pod-0.1.0-blue)](http://cocoapods.org/pods/LLDark)&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

解决iOS启动图空白等异常问题，并且支持动态更换启动图。
中国大陆用户可以访问[这个链接](https://gitee.com/internetWei/lldynamic-launch-screen)

特性
==============
- 使用简单，只需要1行代码即可修改启动图。
- 功能强大，支持动态修改任意类型启动图。
- 兼容iOS13以下机型。

Demo
==============
![Manual.gif](https://gitee.com/internetWei/llDark/raw/master/Demo/Resouces/manual.gif) ![System.gif](https://gitee.com/internetWei/llDark/raw/master/Demo/Resouces/followSystem.gif) ![Screen.gif](https://gitee.com/internetWei/llDark/raw/master/Demo/Resouces/screenSplace.gif) ![LightVertical.gif](https://gitee.com/internetWei/llDark/raw/master/Demo/Resouces/lightVerticalImage.gif)

用法
==============

### 前提
配置深色资源：
在工程任意NSObject分类(建议单独新建一个主题分类)中创建`+ (NSDictionary<id, id> *)llDarkTheme`类方法，字典的key表示浅色主题下的颜色/图片名称/图片地址，字典的value表示深色主题下的颜色/图片名称/图片地址。可参考样例代码：
```Objc
+ (NSDictionary<id, id> *)llDarkTheme {
    return @{
             UIColor.whiteColor : kColorRGB(27, 27, 27),
             kColorRGB(240, 238, 245) : kColorRGB(39, 39, 39),
             [UIColor colorWithRed:14.0 / 255.0 green:255.0 / 255.0 blue:0.0 alpha:1.0] : [UIColor colorWithRed:0.0 green:14.0 / 255.0 blue:255.0 / 255.0 alpha:1.0],
             @"background_light" : @"background_dark",
             @"~/path/background_light.png" : @"~/path/background_dark.png",
    };
}
```
Tips:
`1.不必把所有情况下的颜色/图片都填写进去，对于偶尔或少数使用到的深色颜色可以参考高级用法单独适配。
2.图片名称不用考虑倍图关系；如果填写的是图片路径一定要填写完整的图片路径(包含后缀)。`

### 基本用法
UIColor和CGColor只需要追加.themeColor(nil)即可。
UIImage只需要将imageNamed或imageWithContentsOfFile替换为themeImage即可。
```objc
// UIColor
UIColor.redColor; // 之前的用法
UIColor.redColor.themeColor(nil); // 现在的用法

// CGColor
UIColor.redColor.CGColor; // 之前的用法
UIColor.redColor.themeCGColor(nil); // 现在的用法

// UIImage
[UIImage imageNamed:@"lightImageName"]; // 之前的用法
[UIImage themeImage:@"lightImageName"]; // 现在的用法
```

Tips:
`1.themeImage适配了imageNamed和imageWithContentsOfFile两个方法，可以传递图片名称，也可以传递图片路径。
2.只有适配过的Color和Image在主题切换时才会刷新。
`

### 高级用法
```Objc
1. themeColor()里面的参数如果是具体的Color对象，深色主题则会使用指定的Color对象刷新,
如果是nil则会返回llDarkTheme中配置的深色颜色刷新，
如果llDarkTheme未配置则会返回浅色主题下的颜色。

2. themeCGColor()参数的作用和themeColor()参数作用一样。

3. themeImage()有2个参数，参数可以是图片名称，也可以是图片地址,
第1个参数表示浅色主题下使用的图片(必填)，
第2个参数表示深色主题下使用的图片(可以为空)，
第2个参数为空的话和themeColor()为空的处理方式一样。

4. appearanceBindUpdater，所有继承自UIView的对象都拥有这个属性，
对象需要刷新时会调用它，可以在这里实现自己的刷新逻辑。
仅在需要刷新时会调用，主题更改不一定需要刷新UI。

5. userInterfaceStyle，类似iOS13系统的overrideUserInterfaceStyle方法，
但是功能比overrideUserInterfaceStyle更加强大，
它支持所有的对象，例如CALayer。
它支持iOS13以下的系统使用。

6. themeDidChange，所有对象都拥有这个属性，作用和ThemeDidChangeNotification一样，
themeDidChange会在对象释放时被释放掉，
可以在多个地方使用，不保证回调顺序，
不同于appearanceBindUpdater，只要主题发生改变就会调用themeDidChange。

7. systemThemeDidChange，所有对象都拥有这个属性，作用和SystemThemeDidChangeNotification一样，
释放时机和themeDidChange一样，
可以在多个地方使用，不保证回调顺序，
只要系统主题发生改变就会调用systemThemeDidChange。

8. darkStyle，所有UIImageView对象都拥有这个方法，用于适配没有深色图片的图片对象，例如网络图片。
darkStyle有3个参数，第1个参数决定如何适配深色主题，目前有LLDarkStyleSaturation和LLDarkStyleMask两种，
LLDarkStyleMask使用蒙层适配，LLDarkStyleSaturation通过降低原图饱合度适配。
第2个参数决定蒙层透明度/饱合度值，具体使用可看源码注释。
第3个参数可以为nil，使用LLDarkStyleSaturation时需要传递一个唯一字符串当做标识符，通常是图片的url。
样例代码：
UIImageView *imageView = [[UIImageView alloc] init];
NSString *url = @"图片URL";
imageView.darkStyle(LLDarkStyleSaturation, 0.2, url);
// imageView.darkStyle(LLDarkStyleMask, 0.5, nil);

9. updateDarkTheme:，如果需要运行时修改深色主题配置信息，或者需要从网络上获取深色主题配置信息，可以使用updateDarkTheme:来达到目的。
请确保在第1个UI对象加载前配置好深色主题信息，否则会无效。
样例代码:
NSDictionary *darkTheme = @{
    UIColor.whiteColor : kColorRGB(27, 27, 27),
    kColorRGB(240, 238, 245) : kColorRGB(39, 39, 39),
    [UIColor colorWithRed:14.0 / 255.0 green:255.0 / 255.0 blue:0.0 alpha:1.0] : [UIColor colorWithRed:0.0 green:14.0 / 255.0 blue:255.0 /  255.0 alpha:1.0],
    @"background_light" : @"background_dark",
    @"~/path/background_light.png" : @"~/path/background_dark.png",
};
[LLDarkSource updateDarkTheme:darkTheme];

10. thirdControlClassName，如果需要支持第3方控件的刷新方法，可以在appearanceBindUpdater中单独实现刷新逻辑，也可以按照如下方法实现刷新逻辑，更加推荐如下方法。
首先需要实现thirdControlClassName这个类方法，并返回一个数组，数组包含第3方控件的类名字符串。
然后实现refresh+类名字符串的对象方法，在方法里实现第3方控件的刷新逻辑，可以参考LLThird.m文件中已经实现的YYLabel的刷新逻辑。
详情可以下载工程查看Demo了解具体实现。

11. 如果需要在iOS13以下系统支持适配深色启动图，请将深色图片按照指定规则命名并放置在工程任意目录下。
命名规则：launchImage_<屏幕宽度>_<屏幕高度>。
例如：launchImage_414_736，此深色启动图将会在iOS13以下系统并且屏幕宽高为414×736的机型切换至深色模式后出现。
如果想适配横图只需要将宽高位置互换即可，例如：launchImage_736_414。
具体效果可以在iOS13以下系统运行Demo并切换至深色模式查看。
具体命名可以参考Demo工程中LaunchImage文件夹下的图片命名方式，它包含了所有iOS13以下机型的深色启动图(包括横屏，不包括iPhone6之前的机型)命名。

12. LLLaunchScreen提供了一些类方法，合理的使用这些类方法可以完美替换APP的任意启动图，包含“深色竖屏启动图”、“深色横屏启动图”、“浅色竖屏启动图”、“浅色横屏启动图”。
具体方法请查阅LLLaunchScreen.h文件。
使用方法可参考Demo。
```
高级用法中第8条darkStyle方法的样例图(为了突出效果特意将饱合度和透明度调整的很低)：
![137a9000178656346577e](https://pic.downk.cc/item/5fc60802d590d4788ab3a29b.png) 

快速适配
==============
仅需要3步即可快速完美适配深色主题模式：
1. 配置深色主题资源，可参考`前提`，也可以参考`高级方法9`从网络获取主题资源。
2. 将需要适配的Color和Image适配为主题Color和主题Image，适配方法可参考`基础用法`和`高级用法`。
3. 运行工程，检查完整性。

Tips:
1. 如果您需要适配`WKWebView`，可以[点击链接](https://www.jianshu.com/p/be578117f84c)参考文章进行适配。
2.默认情况下iOS13及以上系统自动适配启动图跟随APP主题模式变化，如果想在iOS13以下系统
也支持此功能，可以参考`高级用法11`和`高级用法12`。

安装
==============
### CocoaPods
1. 将 cocoapods 更新至最新版本。
2. 在 Podfile 中添加 pod 'LLDark'。
3. 执行 pod install 或 pod update。
4. 导入 <LLDark/LLDark.h>。

### 手动安装
1. 下载 LLDark 文件夹内的所有内容。
2. 将LLDark文件夹添加(拖放)到你的工程。
3. 导入 "LLDark.h"。

系统要求
==============
该项目最低支持iOS9.0和Xcode10.0，如果想在更低系统上使用可以联系作者。

注意点
==============
1. LLDark不会修改状态栏样式，需要自己监听主题模式修改状态栏样式。
2. 由于系统限制，需要适配深色的图片尽量不要放在Assets.xcassets中，
   某些时候会获取到错误的主题图片。如果需要适配iOS13以下系统则不能将图片
   放置在Assets.xcassets中。

已知问题
==============
* 暂时不支持其他主题模式，后续会支持多种主题自由搭配。

联系作者
==============
如果你有更好的改进，please pull reqeust me

如果你有任何更好的意见，请创建一个[Issue](https://github.com/internetWei/llDark/issues)

可以通过此邮箱联系作者`internetwei@foxmail.com`

许可证
==============
LLDark 使用 MIT 许可证，详情见 LICENSE 文件。
