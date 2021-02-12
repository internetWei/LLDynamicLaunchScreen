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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"LLLaunchScreen";
    
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Select photo" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:14.0 / 255.0 green:144.0 / 255.0 blue:1.0 alpha:1.0];
    [self.view addSubview:button];
    button.frame = CGRectMake((screenWidth - 220) / 2.0, 150, 220, 80);
    [button addTarget:self action:@selector(buttonEvent) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setTitle:@"Reset All(恢复如初)" forState:UIControlStateNormal];
    [button1 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor colorWithRed:14.0 / 255.0 green:144.0 / 255.0 blue:1.0 alpha:1.0];
    [self.view addSubview:button1];
    button1.frame = CGRectMake((screenWidth - 220) / 2.0, CGRectGetMaxY(button.frame) + 40.0, 220, 80);
    [button1 addTarget:self action:@selector(button1Event) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"Reset specified(恢复指定启动图)" forState:UIControlStateNormal];
    [button2 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor colorWithRed:14.0 / 255.0 green:144.0 / 255.0 blue:1.0 alpha:1.0];
    [self.view addSubview:button2];
    button2.frame = CGRectMake((screenWidth - 220) / 2.0, CGRectGetMaxY(button1.frame) + 40.0, 220, 80);
    [button2 addTarget:self action:@selector(button2Event) forControlEvents:UIControlEventTouchUpInside];
    
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
}

- (void)buttonEvent {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)button1Event {
    [LLDynamicLaunchScreen restoreAsBefore];
    
    [self showAlertView:@"Success，APP is about to exit"];
}

- (void)button2Event {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select LLaunchScreenType" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"VerticalLight(竖屏浅色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeVerticalLight compressionQuality:0.8 validation:nil];
        [self showAlertView:@"Success，APP is about to exit"];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"HorizontalLight(横屏浅色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeHorizontalLight compressionQuality:0.8 validation:nil];
        [self showAlertView:@"Success，APP is about to exit"];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"VerticalDark(竖屏深色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 13.0, *)) {
            [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeVerticalDark compressionQuality:0.8 validation:nil];
            [self showAlertView:@"Success，APP is about to exit"];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This feature is not supported in systems below iOS13" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"HorizontalDark(横屏深色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 13.0, *)) {
            [LLDynamicLaunchScreen replaceLaunchImage:nil launchImageType:LLLaunchImageTypeHorizontalDark compressionQuality:0.8 validation:nil];
            [self showAlertView:@"Success，APP is about to exit"];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This feature is not supported in systems below iOS13" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select LLaunchScreenType" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"VerticalLight(竖屏浅色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeVerticalLight compressionQuality:0.8 validation:nil];
            [self showAlertView:@"Success，APP is about to exit"];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"HorizontalLight(横屏浅色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeHorizontalLight compressionQuality:0.8 validation:nil];
            [self showAlertView:@"Success，APP is about to exit"];
        }];
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"VerticalDark(竖屏深色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 13.0, *)) {
                [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeVerticalDark compressionQuality:0.8 validation:nil];
                [self showAlertView:@"Success，APP is about to exit"];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This feature is not supported in systems below iOS13" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"HorizontalDark(横屏深色启动图)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 13.0, *)) {
                [LLDynamicLaunchScreen replaceLaunchImage:selectedImage launchImageType:LLLaunchImageTypeHorizontalDark compressionQuality:0.8 validation:nil];
                [self showAlertView:@"Success，APP is about to exit"];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This feature is not supported in systems below iOS13" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action1];
        [alert addAction:action2];
        [alert addAction:action3];
        [alert addAction:action4];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)showAlertView:(NSString *)text {
    self.alertLabel.text = text;
    self.alertLabel.hidden = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

@end
