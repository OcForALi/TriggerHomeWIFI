//
//  UIFont+Adjust.m
//  Test
//
//  Created by Mac on 2017/10/13.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import "UIFont+Adjust.h"

@implementation UIFont (Adjust)

+ (UIFont *)fontWithName:(NSString *)name fontSize:(CGFloat)fontSize
{
    if (IS_IPHONE_5) {
        return [UIFont fontWithName:name size:fontSize - 2];
    }
    return [UIFont fontWithName:name size:fontSize];
}

@end
