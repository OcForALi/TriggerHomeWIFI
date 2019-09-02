//
//  BaseDataAcquisition.h
//  Demo
//
//  Created by Mac on 2017/7/19.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BasicInfoCollection : NSObject

/**
 获取设备当前mac地址
 */
+ (nonnull NSString *)getMacAddress;

/**
 获取设备当前网络IP地址
 */
+ (nullable NSString*)getCurrentLocalIP;

+ (nullable NSString *)getCurreWiFiSsid;

+ (nullable NSString *)getCurreWiFiBSsid;
/**
 获取MD5
 */
+ (nonnull NSString *) md5:(nonnull NSString *)str;

/**
 电池电量
 */

+ (int)getCurrentBatteryLevel;

/**
 电池状态(UIDeviceBatteryState为枚举类型)
 */
+(UIDeviceBatteryState)getBatteryStauts;
/**
 获取设备名称
 */
+ (nonnull NSString *)hostname;

/**
 获取运行内存
 */
+ (NSInteger)availableMemory;

/**
 获取总内存大小
 */
+ (NSInteger)getTotalMemorySize;
/**
 获取可用磁盘大小
 */
+ (float)getFreeDiskspace;

/**
 获取总磁盘大小
 */
+ (float)getTotalDiskspace;

/**
 获取当前网络状态
 */
+ (nonnull NSDictionary *)networkingStatesFromStatebar;

+ (nonnull NSString *)getWifiStrengthFromStatebar;

@end
