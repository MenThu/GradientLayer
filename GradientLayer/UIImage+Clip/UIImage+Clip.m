//
//  UIImage+Clip.m
//  GradientLayer
//
//  Created by MenThu on 2017/12/13.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#import "UIImage+Clip.h"

@implementation UIImage (Clip)

- (UIImage *)resizeImage:(CGSize)newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newSizeImage;
}

- (UIImage *)clipPath:(CGPathRef)path{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextAddRect(context, CGContextGetClipBoundingBox(context));
    CGContextEOClip(context);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGContextRestoreGState(context);
    
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return clipImage;
}

@end
