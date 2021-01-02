LLDynamicLaunchScreen
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/llDark/blob/master/LICENSE)&nbsp; [![CocoaPods](https://img.shields.io/badge/pod-0.1.0-blue)](http://cocoapods.org/pods/LLDark)&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

A dark theme framework for iOS, quickly and easily adapting to dark mode.
Mainland China users can access[This link](https://gitee.com/internetWei/llDark)<br>
[中文介绍](https://github.com/internetWei/llDark/blob/master/README_CN.md)

Features
==============
- The integration is very simple, only a few changes are required and the project structure will not be destroyed.
- High performance, refresh the current page UI only when you need to refresh.
- Powerful, covering all usage scenarios of UIColor, UIImage, CGColor.
- Compatible with models below iOS13.
- Support to obtain dark theme configuration from the Internet.
- The automatic adaptation start-up picture is the current theme mode of the APP, and supports models below iOS13.
- Support dynamic modification of any type of startup diagram.

Demo
==============
![Manual.gif](https://github.com/internetWei/llDark/blob/master/Demo/Resouces/manual.gif) ![System.gif](https://github.com/internetWei/llDark/blob/master/Demo/Resouces/followSystem.gif) ![Screen.gif](https://github.com/internetWei/llDark/blob/master/Demo/Resouces/screenSplace.gif) ![LightVertical.gif](https://github.com/internetWei/llDark/blob/master/Demo/Resouces/lightVerticalImage.gif)

Usage
==============

### premise
Configure dark resources：
Create `+ (NSDictionary<id, id> *)llDarkTheme` class method in any NSObject category of the project (it is recommended to create a separate category). The key of the dictionary represents the color/picture name/picture address under the light theme, and the dictionary’s Value represents the color/picture name/picture address under the dark theme. You can refer to the sample code:
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
`1.It is not necessary to fill in all colors/pictures in all cases. For dark colors that are occasionally or rarely used, you can refer to the advanced usage to adapt them separately.
2.if the picture path is filled in, the complete picture path (including the suffix) must be filled in.`

### Basic usage
UIColor and CGColor only need to append .themeColor(nil).
UIImage only needs to replace imageNamed or imageWithContentsOfFile with themeImage.
```objc
// UIColor
UIColor.redColor; // Previous usage
UIColor.redColor.themeColor(nil); // Current usage

// CGColor
UIColor.redColor.CGColor; // Previous usage
UIColor.redColor.themeCGColor(nil); // Current usage

// UIImage
[UIImage imageNamed:@"lightImageName"]; // Previous usage
[UIImage themeImage:@"lightImageName"]; // Current usage
```

Tips:
`1.themeImage is adapted to two methods, imageNamed and imageWithContentsOfFile, which can pass the image name or the image path.
2.Only the adapted Color and Image will be refreshed when the theme is switched.
`

### Advanced usage
```Objc
1. If the parameter in themeColor() is a specific Color object, the dark theme will refresh with the specified Color object.
If it is nil, it will return to the dark color refresh configured in llDarkTheme,
If llDarkTheme is not configured, it will return the color under the light theme.

2. The function of the themeCGColor() parameter is the same as the function of the themeColor() parameter.

3. themeImage() has 2 parameters, the parameter can be the image name or the image address,
The first parameter represents the picture used under the light theme (required),
The second parameter represents the picture used under the dark theme (can be empty),
If the second parameter is empty, the treatment is the same as if themeColor() is empty.

4. appearanceBindUpdater，All objects inherited from UIView have this property,
It will be called when the object needs to be refreshed, and you can implement your own refresh logic here.
It is only called when a refresh is needed, and the theme change does not necessarily require refreshing the UI.

5. userInterfaceStyle，Similar to the overrideUserInterfaceStyle method of iOS13 system,
But the function is more powerful than overrideUserInterfaceStyle,
It supports all objects, such as CALayer.
It supports system usage below iOS13.

6. themeDidChange，All objects have this property, which is the same as ThemeDidChangeNotification.
themeDidChange will be released when the object is released,
Can be used in multiple places, the callback order is not guaranteed,
Unlike appearanceBindUpdater, themeDidChange is called whenever the theme changes.

7. systemThemeDidChange，All objects have this property, which is the same as SystemThemeDidChangeNotification.
The release timing is the same as themeDidChange,
Can be used in multiple places, the callback order is not guaranteed,
As long as the system theme changes, systemThemeDidChange will be called.

8. darkStyle，All UIImageView objects have this method to adapt to image objects without dark images, such as web images.
DarkStyle has 3 parameters. The first parameter determines how to adapt to the dark theme. There are currently two types: LLDarkStyleSaturation and LLDarkStyleMask.
LLDarkStyleMask uses mask adaptation, and LLDarkStyleSaturation adapts by reducing the saturation of the original image.
The second parameter determines the transparency/saturation value of the mask. For specific usage, please refer to the source code comments.
The third parameter can be nil. When using LLDarkStyleSaturation, you need to pass a unique string as an identifier, usually the url of the image.
Sample code:
UIImageView *imageView = [[UIImageView alloc] init];
NSString *url = @"Picture URL";
imageView.darkStyle(LLDarkStyleSaturation, 0.2, url);
// imageView.darkStyle(LLDarkStyleMask, 0.5, nil);

9. updateDarkTheme:，If you need to modify the dark theme configuration information at runtime, or need to obtain dark theme configuration information from the Internet, you can use updateDarkTheme: to achieve the goal.
Please ensure that the dark theme information is configured before the first UI object is loaded, otherwise it will be invalid.
Sample code:
NSDictionary *darkTheme = @{
    UIColor.whiteColor : kColorRGB(27, 27, 27),
    kColorRGB(240, 238, 245) : kColorRGB(39, 39, 39),
    [UIColor colorWithRed:14.0 / 255.0 green:255.0 / 255.0 blue:0.0 alpha:1.0] : [UIColor colorWithRed:0.0 green:14.0 / 255.0 blue:255.0 /  255.0 alpha:1.0],
    @"background_light" : @"background_dark",
    @"~/path/background_light.png" : @"~/path/background_dark.png",
};
[LLDarkSource updateDarkTheme:darkTheme];

10. thirdControlClassName，If you need to support the refresh method of the third-party control, you can implement the refresh logic separately in appearanceBindUpdater, or you can implement the refresh logic according to the following methods, and the following methods are more recommended.
First, you need to implement the thirdControlClassName class method and return an array containing the class name string of the third party control.
Then implement the refresh+class name string object method, and implement the refresh logic of the third-party control in the method. You can refer to the YYLabel refresh logic that has been implemented in the LLThird.m file.
For details, you can download the project and view the Demo to understand the specific implementation.

11. If you need to support the adaptation of the dark startup image in iOS13 or lower, please name the dark image according to the specified rules and place it in any directory of the project.
Naming rule: launchImage_<screen width>_<screen height>.
For example: launchImage_414_736, this dark launch image will appear after switching to dark mode on models with a screen width of 414×736 and systems below iOS13.
If you want to adapt the horizontal image, you only need to exchange the width and height positions, for example: launchImage_736_414.
The specific effect can be viewed by running Demo on the system below iOS13 and switching to dark mode.
For specific naming, please refer to the image naming method under the LaunchImage folder in the Demo project. It contains the dark launch image of all models below iOS 13 (including horizontal screen, excluding models before iPhone 6).

12. LLLaunchScreen provides some class methods, reasonable use of these class methods can perfectly replace any startup image of APP, including "dark vertical launch Image", "dark horizontal launch Image", "light vertical launch Image", "Light horizontal launch Image".
Please refer to the LLLaunchScreen.h file for specific methods.
For usage method, please refer to Demo.
```
The sample diagram of darkStyle method No. 8 in advanced usage (in order to highlight the effect, the saturation and transparency are adjusted very low):
![5fc91820394ac523788c48f4](https://pic.downk.cc/item/5fc91820394ac523788c48f4.png) 

Quick adaptation
==============
It only takes 3 steps to quickly and perfectly adapt to the dark theme mode. After testing, most of the projects can be adapted within 0.5 days.
1. To configure dark theme resources, refer to `Prerequisites`, or refer to `Advanced Method 9` to obtain resource adaptation from the network.
2. Adapt Color and Image that need to be adapted to theme Color and theme Image. For the adaptation method, please refer to `Basic Usage` and `Advanced Usage`.
3. Run the project and check for completeness.

Tips:
1. If you still need to adapt `WKWebView`, you can [click the link](https://www.jianshu.com/p/be578117f84c)Refer to the article for adaptation.
2. By default, iOS13 and above systems will automatically adapt Launch Image to follow the changes in APP theme mode, if you want to use the system below iOS13
    This function is also supported, please refer to `Advanced Usage 11` and `Advanced Usage 12`.

Installation
==============
### CocoaPods
1. Update cocoapods to the latest version.
2. Add pod 'LLDark' to your Podfile.
3. Run pod install or pod update.
4. Import <LLDark/LLDark.h>.

### Manually
1. Download all the files in the LLdark subdirectory.
2. Add (drag and drop) the LLDark folder to your project.
3. Import LLDark.h.

Requirements
==============
The project supports iOS 9.0 and Xcode 10.0 at least. If you want to use it on lower systems, please contact the author.

Note
==============
1. LLDark does not modify the style of the status bar, you need to monitor the theme mode to modify the style of the status bar.
2. Due to system limitations, dark pictures need to be adapted and try not to put them in Assets.xcassets.
    Sometimes the wrong theme image will be obtained.

Known issues
==============
* Other theme modes are not supported for the time being, and a variety of themes will be supported freely in the future.

Contact
==============
If you have better improvements, please pull reqeust me

If you have any better comments, please create one[Issue](https://github.com/internetWei/llDark/issues)

The author can be contacted by this email`internetwei@foxmail.com`

License
==============
LLDark is released under the MIT license. See LICENSE file for details.
