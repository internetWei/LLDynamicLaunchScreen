//
//  UIImage+LLPrivate.m
//  Demo
//
//  Created by XL on 2023/4/23.
//

#import <UIKit/UIKit.h>

typedef struct {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
} LLColor;

FOUNDATION_STATIC_INLINE BOOL colorEqualColor(LLColor color1, LLColor color2) {
    CGFloat threshold = 0.2f;
    
    if (fabs(color1.red - color2.red) > threshold ||
        fabs(color1.green - color2.green) > threshold ||
        fabs(color1.blue - color2.blue) > threshold ||
        fabs(color1.alpha - color2.alpha) > threshold) {
        return NO;
    }
    
    return YES;
}

@implementation UIImage (LLPrivate)

- (BOOL)ll_isVertical {
    return self.size.width < self.size.height;
}


- (nullable UIImage *)ll_imageByResizeToSize:(CGSize)size
                                 contentMode:(UIViewContentMode)contentMode {
    if (size.width <= 0 || size.height <= 0) return nil;
    
    if (@available(iOS 17.0, *)) {
        UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
        format.scale = self.scale;
        format.opaque = self.ll_isOpaque;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
        
        return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [self ll_drawInRect:(CGRect){.size = size} contentMode:contentMode];
        }];
    } else {
        UIGraphicsBeginImageContextWithOptions(size, self.ll_isOpaque, self.scale);
        [self ll_drawInRect:(CGRect){.size = size} contentMode:contentMode];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}


- (nullable UIImage *)ll_drawInRects:(NSArray<NSValue *> *)rects toColor:(UIColor *)color {
    if (@available(iOS 17.0, *)) {
        UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
        format.scale = self.scale;
        format.opaque = self.ll_isOpaque;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.size format:format];
        
        return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [self drawInRect:(CGRect){.size = self.size}];
            CGContextSetFillColorWithColor(context, color.CGColor);
            for (NSValue *value in rects) {
                CGContextFillRect(context, value.CGRectValue);
            }
        }];
    } else {
        UIGraphicsBeginImageContextWithOptions(self.size, self.ll_isOpaque, self.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self drawInRect:(CGRect){.size = self.size}];
        CGContextSetFillColorWithColor(context, color.CGColor);
        for (NSValue *value in rects) {
            CGContextFillRect(context, value.CGRectValue);
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}


- (BOOL)ll_isEqualToImage:(UIImage *)image {
    return [self ll_isEqualToImage:image ignoreAlpha:NO threshold:0.9];
}


- (BOOL)ll_isEqualToImage:(UIImage *)image ignoreAlpha:(BOOL)ignore threshold:(CGFloat)threshold {
    if (![image isKindOfClass:UIImage.class]) { return NO; }
    if (CGSizeEqualToSize(self.size, CGSizeZero) ||
        CGSizeEqualToSize(image.size, CGSizeZero)) { return NO; }
    
    UIImage *image1 = self;
    UIImage *image2 = image;
    
    CGSize size1 = image1.ll_pixelSize;
    CGSize size2 = image2.ll_pixelSize;
    
    // 如果尺寸不一样，把大图调整成小图尺寸。
    if (!CGSizeEqualToSize(size1, size2)) {
        BOOL isPortrait1 = image1.size.width < image1.size.height;
        BOOL isPortrait2 = image2.size.width < image2.size.height;
        
        // 判断图片比例是否一样，如果1张是竖图，另1张是横图的话则直接返回。
        if (isPortrait1 != isPortrait2) { return NO; }
        
        CGFloat scale1 = size1.width * size1.height;
        CGFloat scale2 = size2.width * size2.height;
        
        UIImage *bigImage = scale1 > scale2 ? self : image;
        UIImage *smallImage = scale1 < scale2 ? self : image;
        
        bigImage = [bigImage ll_resizeScale:1.0];
        image1 = [bigImage ll_imageByResizeToSize:scale1 < scale2 ? size1 : size2 contentMode:UIViewContentModeScaleToFill];
        image2 = smallImage;
    }
    
    CIImage *ciImage1 = [[CIImage alloc] initWithImage:image1];
    CIImage *ciImage2 = [[CIImage alloc] initWithImage:image2];

    CIContext *context = [CIContext contextWithOptions:nil];

    // 获取图片像素数据。
    CGRect imageExtent = ciImage1.extent;
    NSInteger bytesPerPixel = 4;
    NSInteger bytesPerRow = bytesPerPixel * imageExtent.size.width;
    NSInteger totalBytes = bytesPerRow * imageExtent.size.height;

    UInt8 *image1Data = malloc(totalBytes);
    UInt8 *image2Data = malloc(totalBytes);

    [context render:ciImage1 toBitmap:image1Data rowBytes:bytesPerRow bounds:imageExtent format:kCIFormatRGBA8 colorSpace:nil];
    [context render:ciImage2 toBitmap:image2Data rowBytes:bytesPerRow bounds:imageExtent format:kCIFormatRGBA8 colorSpace:nil];
    
    // 计算两张图片的相似度。
    NSUInteger ignoreCount = 0;
    NSUInteger samePixelCount = 0;
    for (NSUInteger i = 0; i < totalBytes; i += bytesPerPixel) {
        UInt8 r1 = image1Data[i];
        UInt8 g1 = image1Data[i+1];
        UInt8 b1 = image1Data[i+2];
        UInt8 a1 = image1Data[i+3];
        
        UInt8 r2 = image2Data[i];
        UInt8 g2 = image2Data[i+1];
        UInt8 b2 = image2Data[i+2];
        UInt8 a2 = image2Data[i+3];
        
        if (ignore) {
            // 忽略带透明的像素点。
            if (a1 != 0xff || a2 != 0xff) {
                ignoreCount += 1;
                continue;
            }
        }
        
        LLColor color1 = {r1 / 255.0, g1 / 255.0, b1 / 255.0, a1 / 255.0};
        LLColor color2 = {r2 / 255.0, g2 / 255.0, b2 / 255.0, a2 / 255.0};
        
        if (colorEqualColor(color1, color2)) {
            samePixelCount += 1;
        }
    }
    
    CGFloat similarity = (CGFloat)samePixelCount / (((CGFloat)totalBytes / bytesPerPixel) - ignoreCount);
    
    free(image1Data);
    free(image2Data);
    
    return (similarity >= threshold);
}


- (CGRect)ll_CGRectWithContentMode:(UIViewContentMode)mode viewSize:(CGSize)viewSize clipsToBounds:(BOOL)clips {
    CGSize imageSize = self.size;
    
    CGRect contentRect = CGRectZero;
    
    switch (mode) {
        case UIViewContentModeRedraw:
        case UIViewContentModeScaleToFill:
            contentRect = (CGRect){.size = viewSize };
            break;
        
        case UIViewContentModeScaleAspectFit: {
            CGFloat scale = fmin(viewSize.width / imageSize.width, viewSize.height / imageSize.height);
            CGFloat width = imageSize.width * scale;
            CGFloat height = imageSize.height * scale;
            contentRect = CGRectMake((viewSize.width - width) / 2.0, (viewSize.height - height) / 2.0, width, height);
            break;
        }
        
        case UIViewContentModeScaleAspectFill: {
            CGFloat scale = fmax(viewSize.width / imageSize.width, viewSize.height / imageSize.height);
            CGFloat width = imageSize.width * scale;
            CGFloat height = imageSize.height * scale;
            contentRect = CGRectMake((viewSize.width - width) / 2.0, (viewSize.height - height) / 2.0, width, height);
            break;
        }
        
        case UIViewContentModeCenter:
            contentRect = CGRectMake((viewSize.width - imageSize.width) / 2.0, (viewSize.height - imageSize.height) / 2.0, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeTop:
            contentRect = CGRectMake((viewSize.width - imageSize.width) / 2.0, 0, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeBottom:
            contentRect = CGRectMake((viewSize.width - imageSize.width) / 2.0, viewSize.height - imageSize.height, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeLeft:
            contentRect = CGRectMake(0, (viewSize.height - imageSize.height) / 2.0, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeRight:
            contentRect = CGRectMake(viewSize.width - imageSize.width, (viewSize.height - imageSize.height) / 2.0, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeTopLeft:
            contentRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeTopRight:
            contentRect = CGRectMake(viewSize.width - imageSize.width, 0, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeBottomLeft:
            contentRect = CGRectMake(0, viewSize.height - imageSize.height, imageSize.width, imageSize.height);
            break;
        
        case UIViewContentModeBottomRight:
            contentRect = CGRectMake(viewSize.width - imageSize.width, viewSize.height - imageSize.height, imageSize.width, imageSize.height);
            break;
    }
    
    if (clips) {
        CGFloat x = MAX(contentRect.origin.x, 0);
        CGFloat y = MAX(contentRect.origin.y, 0);
        CGFloat width = contentRect.size.width + MIN(contentRect.origin.x, 0);
        CGFloat height = contentRect.size.height + MIN(contentRect.origin.y, 0);
        CGFloat maxWidth = viewSize.width - MAX(contentRect.origin.x, 0);
        CGFloat maxHeight = viewSize.height - MAX(contentRect.origin.y, 0);
        width = width > maxWidth ? maxWidth : width;
        height = height > maxHeight ? maxHeight : height;
        
        return CGRectMake(x, y, width, height);
    } else { return contentRect; }
}


- (UIImage *)ll_resizeScale:(CGFloat)scale {
    if (self.scale == scale) { return self; }
    return [UIImage imageWithCGImage:self.CGImage scale:scale orientation:self.imageOrientation];
}


- (nullable UIImage *)ll_imageByCropToRect:(CGRect)rect {
    CGRect imageRect = (CGRect){.size = self.size };
    // 要裁剪的区域比自身大，不用裁剪直接返回自身。
    if (CGRectContainsRect(rect, imageRect)) { return self; }
    
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    if (rect.size.width <= 0 || rect.size.height <= 0) return nil;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}


- (UIColor *)ll_colorAtPoint:(CGPoint)point {
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *rawData = calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow,
                                                 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSInteger byteIndex = (bytesPerRow * point.y) + (point.x * bytesPerPixel);
    
    CGFloat red = (rawData[byteIndex] * 1.f) / 255.f;
    CGFloat green = (rawData[byteIndex + 1] * 1.f) / 255.f;
    CGFloat blue = (rawData[byteIndex + 2] * 1.f) / 255.f;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.f) / 255.f;
    
    free(rawData);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


- (CGSize)ll_pixelSize {
    CGImageRef imageRef = self.CGImage;
    return CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
}


- (BOOL)ll_isOpaque {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return (alphaInfo == kCGImageAlphaNoneSkipLast
            || alphaInfo == kCGImageAlphaNoneSkipFirst
            || alphaInfo == kCGImageAlphaNone);
}


- (void)ll_drawInRect:(CGRect)rect
          contentMode:(UIViewContentMode)contentMode {
    CGRect drawRect = [self ll_CGRectFitWithContentMode:contentMode size:self.size rect:rect];
    if (CGRectGetWidth(drawRect) == 0 || CGRectGetHeight(drawRect) == 0) return;
    [self drawInRect:drawRect];
}


- (CGRect)ll_CGRectFitWithContentMode:(UIViewContentMode)mode size:(CGSize)size rect:(CGRect)rect {
    rect = CGRectStandardize(rect);
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (mode) {
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (mode == UIViewContentModeScaleAspectFit) {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / size.height;
                    } else {
                        scale = rect.size.width / size.width;
                    }
                } else {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / size.width;
                    } else {
                        scale = rect.size.height / size.height;
                    }
                }
                size.width *= scale;
                size.height *= scale;
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
        } break;
        case UIViewContentModeCenter: {
            rect.size = size;
            rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
        } break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeTopLeft: {
            rect.size = size;
        } break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }
    return rect;
}


+ (nullable UIImage *)ll_snapshotImageForAView:(UIView *)aView {
    UIImage *snapshotImage;
    
    if (@available(iOS 17.0, *)) {
        UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
        format.opaque = aView.isOpaque;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:aView.bounds.size format:format];
        snapshotImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [aView drawViewHierarchyInRect:aView.bounds afterScreenUpdates:YES];
        }];
    } else {
        UIGraphicsBeginImageContextWithOptions(aView.bounds.size, aView.isOpaque, UIScreen.mainScreen.scale);
        [aView drawViewHierarchyInRect:aView.bounds afterScreenUpdates:YES];
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return snapshotImage;
}

@end
