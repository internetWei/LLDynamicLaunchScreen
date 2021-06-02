//
//  ViewController.m
//  LLLaunchScreen
//
//  Created by LL on 2020/12/28.
//

#import "ViewController.h"

#import <PhotosUI/PHPicker.h>
#import "LLDynamicLaunchScreen.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, weak) UILabel *alertLabel;

@property (nonatomic, weak) UIImageView *launchImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    [self.view addSubview:scrollView];
    
    self.navigationItem.title = @"LLLaunchScreen";
    
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"选择相片" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:14.0 / 255.0 green:144.0 / 255.0 blue:1.0 alpha:1.0];
    [scrollView addSubview:button];
    button.frame = CGRectMake((screenWidth - 220) / 2.0, 100, 220, 80);
    [button addTarget:self action:@selector(buttonEvent) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setTitle:@"恢复如初" forState:UIControlStateNormal];
    [button1 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor colorWithRed:14.0 / 255.0 green:144.0 / 255.0 blue:1.0 alpha:1.0];
    [scrollView addSubview:button1];
    button1.frame = CGRectMake((screenWidth - 220) / 2.0, CGRectGetMaxY(button.frame) + 40.0, 220, 80);
    [button1 addTarget:self action:@selector(button1Event) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"恢复指定启动图" forState:UIControlStateNormal];
    [button2 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor colorWithRed:14.0 / 255.0 green:144.0 / 255.0 blue:1.0 alpha:1.0];
    button2.titleLabel.numberOfLines = 2;
    [scrollView addSubview:button2];
    button2.frame = CGRectMake((screenWidth - 220) / 2.0, CGRectGetMaxY(button1.frame) + 40.0, 220, 80);
    [button2 addTarget:self action:@selector(button2Event) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button3 setTitle:@"获取指定启动图" forState:UIControlStateNormal];
    [button3 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button3.backgroundColor = [UIColor colorWithRed:14.0 / 255.0 green:144.0 / 255.0 blue:1.0 alpha:1.0];
    button3.titleLabel.numberOfLines = 2;
    [scrollView addSubview:button3];
    button3.frame = CGRectMake((screenWidth - 220) / 2.0, CGRectGetMaxY(button2.frame) + 40.0, 220, 80);
    [button3 addTarget:self action:@selector(button3Event) forControlEvents:UIControlEventTouchUpInside];
    
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(button3.frame) + 20);
    
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.alertLabel = alertLabel;
    alertLabel.center = self.view.center;
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.backgroundColor = [UIColor blackColor];
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.layer.cornerRadius = 5.0;
    alertLabel.layer.masksToBounds = YES;
    alertLabel.numberOfLines = 0;
    [self.view addSubview:alertLabel];
    alertLabel.hidden = YES;
    
    UIImageView *launchImageView = [[UIImageView alloc] init];
    self.launchImageView = launchImageView;
    launchImageView.contentMode = UIViewContentModeScaleAspectFit;
    launchImageView.frame = CGRectMake(0, 0, screenWidth - 40, screenHeight - 150);
    launchImageView.hidden = YES;
    launchImageView.center = self.view.center;
    launchImageView.userInteractionEnabled = YES;
    [launchImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideLaunchImageView)]];
    [self.view addSubview:launchImageView];
}

- (void)buttonEvent {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)button1Event {
    [LLDynamicLaunchScreen restoreAsBefore];
    
    [self showAlertView:@"修改成功，APP即将退出"];
}

- (void)button2Event {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择图片类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"竖屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeVerticalLight compressionQuality:0.8 validation:nil];
        [self showAlertView:@"修改成功，APP即将退出"];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"横屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeHorizontalLight compressionQuality:0.8 validation:nil];
        [self showAlertView:@"修改成功，APP即将退出"];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"竖屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 13.0, *)) {
            [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeVerticalDark compressionQuality:0.8 validation:nil];
            [self showAlertView:@"修改成功，APP即将退出"];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"该功能仅支持iOS13及以上系统使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"横屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 13.0, *)) {
            [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeHorizontalDark compressionQuality:0.8 validation:nil];
            [self showAlertView:@"修改成功，APP即将退出"];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"该功能仅支持iOS13及以上系统使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:action4];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择图片类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"竖屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeVerticalLight compressionQuality:0.8 validation:nil];
            [self showAlertView:@"修改成功，APP即将退出"];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"横屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeHorizontalLight compressionQuality:0.8 validation:nil];
            [self showAlertView:@"修改成功，APP即将退出"];
        }];
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"竖屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 13.0, *)) {
                [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeVerticalDark compressionQuality:0.8 validation:nil];
                [self showAlertView:@"修改成功，APP即将退出"];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"该功能仅支持iOS13及以上系统使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"横屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 13.0, *)) {
                [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeHorizontalDark compressionQuality:0.8 validation:nil];
                [self showAlertView:@"修改成功，APP即将退出"];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"该功能仅支持iOS13及以上系统使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action1];
        [alert addAction:action2];
        [alert addAction:action3];
        [alert addAction:action4];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)button3Event {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择图片类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"竖屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImage *image = [LLDynamicLaunchScreen launchImageFromType:LLLaunchImageTypeVerticalLight];
        weakSelf.launchImageView.image = image;
        weakSelf.launchImageView.hidden = NO;
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"横屏浅色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImage *image = [LLDynamicLaunchScreen launchImageFromType:LLLaunchImageTypeHorizontalLight];
        weakSelf.launchImageView.image = image;
        weakSelf.launchImageView.hidden = NO;
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"竖屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 13.0, *)) {
            UIImage *image = [LLDynamicLaunchScreen launchImageFromType:LLLaunchImageTypeVerticalDark];
            weakSelf.launchImageView.image = image;
            weakSelf.launchImageView.hidden = NO;
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"该功能仅支持iOS13及以上系统使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"横屏深色启动图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 13.0, *)) {
            UIImage *image = [LLDynamicLaunchScreen launchImageFromType:LLLaunchImageTypeHorizontalDark];
            weakSelf.launchImageView.image = image;
            weakSelf.launchImageView.hidden = NO;
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"该功能仅支持iOS13及以上系统使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:action4];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)hideLaunchImageView {
    self.launchImageView.hidden = YES;
}

- (void)showAlertView:(NSString *)text {
    self.alertLabel.text = text;
    self.alertLabel.hidden = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

@end
