//
//  UIView+ColorSelect.m
//  Test
//
//  Created by Mac on 2017/11/3.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import "UIView+ColorSelect.h"

@implementation UIView (ColorSelect)

- (NSArray *)colorAtPixel:(CGPoint)point {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
//    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    CGFloat red   = (CGFloat)pixel[0];
    CGFloat green = (CGFloat)pixel[1];
    CGFloat blue  = (CGFloat)pixel[2];
    CGFloat alpha = (CGFloat)pixel[3];
    
    return @[@(red),@(green),@(blue),@(alpha)];
}
@end
