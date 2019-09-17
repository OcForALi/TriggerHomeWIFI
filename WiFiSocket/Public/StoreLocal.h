//
//  StoreLocal.h
//  WiFiSocket
//
//  Created by Mac on 2019/3/27.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoreLocal : NSObject

///存储7个状态(开关状态,定时器状态,倒计时状态，能源管理状态,睡眠灯状态，彩灯状态，USB状态)
+ (void)storeLocalSevenState:(NSString *)storeLocalName Mac:(NSString *)mac State:(BOOL)state;

@end

NS_ASSUME_NONNULL_END
