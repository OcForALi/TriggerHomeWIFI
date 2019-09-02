//
//  UIColor+HexColor.m
//  BTMate
//
//  Created by Mac on 2017/8/22.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

+ (UIColor *)colorWithHexColorString:(NSString *)hex withAlpha:(CGFloat)alpha
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
   
//    NSArray *arr = [self toRGBcolorByHexColorString:hex];
//    return [UIColor colorWithRed:[arr[0] integerValue] green:[arr[1] integerValue] blue:[arr[2] integerValue] alpha:alpha];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

+ (NSMutableArray *)getColor3DotStringFrom1:(NSString *)tmp_color_string
{
    NSMutableArray * tmparr =[[NSMutableArray alloc] init];
    if(tmp_color_string==nil)
    {
        [tmparr  addObject:[NSNumber numberWithInt:0]];
        [tmparr  addObject:[NSNumber numberWithInt:0]];
        [tmparr  addObject:[NSNumber numberWithInt:0]];
        
        return tmparr;
    }
    
    const char *tmp_color = [tmp_color_string UTF8String];
    long int tmp_color_int = strtoul(tmp_color, NULL, 16);
    [tmparr  addObject:[NSNumber numberWithInt:(tmp_color_int & 0xff0000) >> 16]];
    [tmparr  addObject:[NSNumber numberWithInt:(tmp_color_int & 0x00ff00) >> 8]];
    [tmparr  addObject:[NSNumber numberWithInt:(tmp_color_int & 0x0000ff) >> 0]];
    return   tmparr;
}

+ (UIColor *)colorWithHexColorString:(NSString *)hex
{
    return [self colorWithHexColorString:hex withAlpha:1.0];
}

+ (NSArray *)toRGBcolorByHexColorString:(NSString *)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return @[@(0),@(0),@(0)];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return @[@(r),@(g),@(b)];
}


+ (NSString *)ToHex:(NSInteger)tmpid
{
        NSString *nLetterValue = @"";
        NSString *value = @"";
        NSInteger ttmpig=tmpid % 16;
        NSInteger tt= tmpid / 16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%ld",ttmpig];
                
        }
        switch (tt)
        {
            case 10:
                value =@"A";break;
            case 11:
                value =@"B";break;
            case 12:
                value =@"C";break;
            case 13:
                value =@"D";break;
            case 14:
                value =@"E";break;
            case 15:
                value =@"F";break;
            default:
                value = [NSString stringWithFormat:@"%ld",tt];
                
        }
    
    return [NSString stringWithFormat:@"%@%@",value,nLetterValue];
}

+ (NSString *)toHexColorByColorArr:(NSArray *)arr
{
    return [NSString stringWithFormat:@"%@%@%@",[self ToHex: [arr[0] integerValue]],[self ToHex: [arr[1] integerValue]],[self ToHex: [arr[2] integerValue]]];
}

+ (NSString*)toHexColorByUIColor:(UIColor*)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int) r<<16 | (int) g <<8 | (int) b <<0;
    NSString *rgbStr = [NSString stringWithFormat:@"%06x", rgb];
    return [rgbStr substringToIndex:6];
}

@end
