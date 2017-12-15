//
//  UIColor+Extension.m
//  MeJob
//
//  Created by maopao-ios on 2017/8/28.
//  Copyright © 2017年 Mizhi. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)
+ (UIColor *)colorWithHexString:(NSString *)hexColorString {
    return [self colorWithHexString:hexColorString alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexColorString alpha:(CGFloat)alpha {
    unsigned colorValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexColorString];
    if ([hexColorString rangeOfString:@"#"].location != NSNotFound) {
        [scanner setScanLocation:1];
    }
    [scanner scanHexInt:&colorValue];
    return [UIColor colorWithRed:((colorValue & 0xFF0000) >> 16) / 255.0 green:((colorValue & 0xFF00) >> 8) / 255.0 blue:((colorValue & 0xFF) >> 0) / 255.0 alpha:alpha];
}
@end
