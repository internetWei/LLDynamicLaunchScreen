//
//  UIImage+Category.m
//  Tests
//
//  Created by xl on 2023/5/6.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

+ (nullable instancetype)imageFileNamed:(NSString *)name {
    NSString *path = [NSBundle.mainBundle pathForResource:name ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
}

@end
