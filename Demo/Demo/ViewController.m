//
//  ViewController.m
//  LLLaunchScreen
//
//  Created by LL on 2020/12/28.
//

#import "ViewController.h"

#import "LLDynamicLaunchScreen.h"
#import "Masonry.h"
#import "UIView+HUD.h"
#import "UIImage+Category.h"
#import <CoreServices/CoreServices.h>


@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImagePickerController *pickerController;

@property (nonatomic, assign) LLLaunchImageType selectType;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.pickerController.delegate = self;
    self.pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    
    BOOL isDarkMode = ({
        BOOL isDarkMode = NO;
        if (@available(iOS 12.0, *)) {
            isDarkMode = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
        }
        isDarkMode;
    });
    
    BOOL isPortrait = CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds);
    
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView = backgroundImageView;
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    backgroundImageView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:backgroundImageView];
    
    if (isDarkMode) {
        if (@available(iOS 13.0, *)) {
            if (isPortrait) {
                backgroundImageView.image = [LLDynamicLaunchScreen getLaunchImageWithType:LLLaunchImageTypeVerticalDark];
            } else {
                backgroundImageView.image = [LLDynamicLaunchScreen getLaunchImageWithType:LLLaunchImageTypeHorizontalDark].byRotateRight90;
            }
        }
    } else {
        if (isPortrait) {
            backgroundImageView.image = [LLDynamicLaunchScreen getLaunchImageWithType:LLLaunchImageTypeVerticalLight];
        } else {
            backgroundImageView.image = [LLDynamicLaunchScreen getLaunchImageWithType:LLLaunchImageTypeHorizontalLight].byRotateRight90;
        }
    }

    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];

    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:contentView];

    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(30.0);
        make.centerY.mas_equalTo(0);
    }];

    CGFloat spacing = 30.0;

    UIView *functionView1 = [self createViewWithTitle:@"修改启动图" tip:@"打开相册，选择你喜欢的图片并设置为启动图"];
    [functionView1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(function1Event)]];
    [contentView addSubview:functionView1];

    [functionView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60.0);
    }];
    
    UIView *functionView2 = [self createViewWithTitle:@"随机启动图" tip:@"从网络上随机获取1张图片设置为启动图"];
    [functionView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(function2Event)]];
    [contentView addSubview:functionView2];

    [functionView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView1.mas_bottom).offset(spacing);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(functionView1);
    }];

    UIView *functionView3 = [self createViewWithTitle:@"还原启动图" tip:@"选择你要还原的启动图类型"];
    [functionView3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(function3Event)]];
    [contentView addSubview:functionView3];

    [functionView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView2.mas_bottom).offset(spacing);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(functionView1);
    }];

    UIView *functionView4 = [self createViewWithTitle:@"获取启动图" tip:@"选择你要获取的启动图类型并设置成页面背景"];
    [functionView4 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(function4Event)]];
    [contentView addSubview:functionView4];

    [functionView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView3.mas_bottom).offset(spacing);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(functionView1);
    }];

    UIView *functionView5 = [self createViewWithTitle:@"获取系统启动图" tip:@"选择你要获取的启动图类型并设置成页面背景"];
    [functionView5 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(function5Event)]];
    [contentView addSubview:functionView5];

    [functionView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView4.mas_bottom).offset(spacing);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(functionView1);
        make.bottom.mas_equalTo(0);
    }];
}

- (UIView *)createViewWithTitle:(NSString *)title tip:(NSString *)tip {
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor colorWithRed:229.0 / 255.0 green:125.0 / 255.0 blue:34.0 / 255.0 alpha:0.85];
    contentView.layer.cornerRadius = 6.0;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:CGRectGetWidth(UIScreen.mainScreen.bounds) * 0.043257];
    titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.87];
    [contentView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5.0);
        make.left.mas_equalTo(10.0);
    }];
    
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = tip;
    tipsLabel.textAlignment = NSTextAlignmentRight;
    tipsLabel.font = [UIFont boldSystemFontOfSize:CGRectGetWidth(UIScreen.mainScreen.bounds) * 0.03562341];
    tipsLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    [tipsLabel sizeToFit];
    [contentView addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.0);
        make.right.mas_equalTo(-10.0);
        make.bottom.mas_equalTo(-5.0);
    }];
    
    return contentView;
}


- (void)function1Event {
    [self showAlertViewWithTitle:@"请选择你要修改的启动图类型" handler:^(LLLaunchImageType type) {
        self.selectType = type;
        [self presentViewController:self.pickerController animated:YES completion:nil];
    }];
}


- (void)function2Event {
    NSInteger width = CGRectGetWidth(self.view.bounds);
    NSInteger height = CGRectGetHeight(self.view.bounds);
    
    [self showAlertViewWithTitle:@"请选择你要修改的启动图类型" handler:^(LLLaunchImageType type) {
        NSString *url = nil;
        BOOL isVertical = NO;
        switch (type) {
            case LLLaunchImageTypeVerticalLight:
            case LLLaunchImageTypeVerticalDark: {
                url = [NSString stringWithFormat:@"https://picsum.photos/%ld/%ld", width, height];
                isVertical = YES;
            } break;
            case LLLaunchImageTypeHorizontalLight:
            case LLLaunchImageTypeHorizontalDark: {
                url = [NSString stringWithFormat:@"https://picsum.photos/%ld/%ld", height, width];
                isVertical = NO;
            } break;
        }
        
        [self getNetworkImageFromUrl:url handler:^(UIImage *image) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BOOL result = [LLDynamicLaunchScreen replaceLaunchImage:image type:type];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result) {
                        if (isVertical) {
                            self.backgroundImageView.image = image;
                        } else {
                            self.backgroundImageView.image = image.byRotateRight90;
                        }
                        [self success];
                    } else {
                        [self.view showPromptFromText:@"图片获取失败，请稍候再试"];
                    }
                });
            });
        }];
    }];
}


- (void)getNetworkImageFromUrl:(NSString *)url handler:(void(^)(UIImage *image))handler {
    MBProgressHUD *hud = [self.view showLoading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            if (image == nil) {
                [self.view showPromptFromText:@"图片获取失败，请稍候重试"];
            } else {
                !handler ?: handler(image);
            }
        });
    });
}


- (void)function3Event {
    [self showAlertViewWithTitle:@"请选择你要还原的启动图类型" handler:^(LLLaunchImageType type) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            BOOL result = [LLDynamicLaunchScreen replaceLaunchImage:nil type:type];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    [self success];
                } else {
                    [self.view showPromptFromText:@"操作失败，请联系作者:internetwei@foxmail.com"];
                }
            });
        });
    }];
}


- (void)function4Event {
    [self showAlertViewWithTitle:@"请选择你要获取的启动图类型" handler:^(LLLaunchImageType type) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = [LLDynamicLaunchScreen getLaunchImageWithType:type];
            switch (type) {
                case LLLaunchImageTypeHorizontalLight:
                case LLLaunchImageTypeHorizontalDark: {
                    image = image.byRotateRight90;
                }
                default: break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundImageView.image = image;
            });
        });
    }];
}


- (void)function5Event {
    [self showAlertViewWithTitle:@"请选择你要获取的启动图类型" handler:^(LLLaunchImageType type) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = [LLDynamicLaunchScreen getSystemLaunchImageWithType:type];
            switch (type) {
                case LLLaunchImageTypeHorizontalLight:
                case LLLaunchImageTypeHorizontalDark: {
                    image = image.byRotateRight90;
                }
                default: break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundImageView.image = image;
            });
        });
    }];
}


- (void)showAlertViewWithTitle:(NSString *)title handler:(void (^)(LLLaunchImageType type))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"竖屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !handler ?: handler(LLLaunchImageTypeVerticalLight);
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"横屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !handler ?: handler(LLLaunchImageTypeHorizontalLight);
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    
    if (@available(iOS 13.0, *)) {
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"竖屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !handler ?: handler(LLLaunchImageTypeVerticalDark);
        }];
        UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"横屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !handler ?: handler(LLLaunchImageTypeHorizontalDark);
        }];
        
        [alert addAction:action3];
        [alert addAction:action4];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)success {
    __block NSInteger count = 3;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = [NSString stringWithFormat:@"操作成功，APP将在%ld秒后退出", count];
    hud.label.numberOfLines = 0;
    hud.label.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [hud showAnimated:YES];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        count -= 1;
        if (count == 0) { exit(0); }
        hud.label.text = [NSString stringWithFormat:@"操作成功，APP将在%ld秒后退出", count];
    }];
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image == nil) {
        [self.view showPromptFromText:@"这张图片有问题，请换一张"];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL result = [LLDynamicLaunchScreen replaceLaunchImage:image type:self.selectType];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                [self success];
            } else {
                [self.view showPromptFromText:@"操作失败，请联系作者:internetwei@foxmail.com"];
            }
        });
    });
}

@end
