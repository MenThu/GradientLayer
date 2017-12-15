//
//  UIColor+Extension.h
//  MeJob
//
//  Created by maopao-ios on 2017/8/28.
//  Copyright © 2017年 Mizhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)
+ (UIColor *)colorWithHexString:(NSString *)hexColorString;
+ (UIColor *)colorWithHexString:(NSString *)hexColorString alpha:(CGFloat)alpha;
@end
