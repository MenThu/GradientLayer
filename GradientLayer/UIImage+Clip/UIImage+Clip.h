//
//  UIImage+Clip.h
//  GradientLayer
//
//  Created by MenThu on 2017/12/13.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Clip)

- (UIImage *)clipPath:(CGPathRef)path;

- (UIImage *)resizeImage:(CGSize)newSize;

@end
