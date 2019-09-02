//
//  UIColor+HexColor.h
//  BTMate
//
//  Created by Mac on 2017/8/22.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

+ (UIColor *)colorWithHexColorString:(NSString *)hex withAlpha:(CGFloat)alpha;

+ (UIColor *)colorWithHexColorString:(NSString *)hex;

+ (NSString*)toHexColorByUIColor:(UIColor *)color;

+ (NSString *)toHexColorByColorArr:(NSArray *)arr;

+ (NSArray *)toRGBcolorByHexColorString:(NSString *)hex;


@end
