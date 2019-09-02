//
//  BaseDataAcquisition.m
//  Demo
//
//  Created by Mac on 2017/7/19.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import "BasicInfoCollection.h"

#import <sys/sysctl.h>
#import <mach/mach.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <objc/runtime.h>
#import<CommonCrypto/CommonDigest.h>

#include "dlfcn.h"

@implementation BasicInfoCollection

#pragma mark 获取mac地址

+ (nonnull NSString *) md5:(NSString *)str
{
//    const char *cStr = [str UTF8String];
//    unsigned char result[16];
//    CC_MD5( cStr, strlen(cStr), result );
//    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//                      result[0], result[1], result[2], result[3],
//                         result[4], result[5], result[6], result[7],
//                         result[8], result[9], result[10], result[11],
//                         result[12], result[13], result[14], result[15]];
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return  output;
 }

+ (nullable NSString*)getCurrentLocalIP
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    if(!address) return @"";
    return address;
}

+ (nullable NSString *)getCurreWiFiSsid
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    if (!info) return @"";
    
    return [(NSDictionary*)info objectForKey:@"SSID"];
//    return (NSDictionary *)info;
}

+ (nullable NSString *)getCurreWiFiBSsid
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    if (!info) return @"";
    return [(NSDictionary*)info objectForKey:@"BSSID"];
}

#pragma mark 电池电量
+ (CGFloat)getBatteryQuantity
{
    return [[UIDevice currentDevice] batteryLevel];
}

/**
 电池状态(UIDeviceBatteryState为枚举类型)
 */
+ (UIDeviceBatteryState)getBatteryStauts
{
    return [UIDevice currentDevice].batteryState;
}

+ (int)getCurrentBatteryLevel
{
    
    UIApplication *app = [UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateActive||app.applicationState==UIApplicationStateInactive
        || app.applicationState == UIApplicationStateBackground) {
        Ivar ivar=  class_getInstanceVariable([app class],"_statusBar");
        id status  = object_getIvar(app, ivar);
        for (id aview in [status subviews]) {
            int batteryLevel = 0;
            for (id bview in [aview subviews]) {
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame&&[[[UIDevice currentDevice] systemVersion] floatValue] >=6.0)
                {
                    
                    Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                    if(ivar)
                    {
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                        //这种方式也可以
                        /*ptrdiff_t offset = ivar_getOffset(ivar);
                         unsigned char *stuffBytes = (unsigned char *)(__bridge void *)bview;
                         batteryLevel = * ((int *)(stuffBytes + offset));*/
                        NSLog(@"电池电量:%d",batteryLevel);
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            return batteryLevel;
                            
                        } else {
                            return 0;
                        }
                    }
                    
                }
                
            }
        }
    }
    
    return 0;
}

#pragma mark host名称
+ (NSString *) hostname

{
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    NSLog(@"basehostname = %@",[NSString stringWithFormat:@"%s", baseHostName]);
    
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s", baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
    
}


BOOL memoryInfo(vm_statistics_data_t *vmStats) {
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)vmStats,
                                               &infoCount);
    
    return kernReturn == KERN_SUCCESS;
}

void logMemoryInfo() {
    vm_statistics_data_t vmStats;
    
    if (memoryInfo(&vmStats)) {
        NSLog(@"free: %lu\nactive: %lu\ninactive: %lu\nwire: %lu\nzero fill: %lu\nreactivations: %lu\npageins: %lu\npageouts: %lu\nfaults: %u\ncow_faults: %u\nlookups: %u\nhits: %u",
              vmStats.free_count * vm_page_size,
              vmStats.active_count * vm_page_size,
              vmStats.inactive_count * vm_page_size,
              vmStats.wire_count * vm_page_size,
              vmStats.zero_fill_count * vm_page_size,
              vmStats.reactivations * vm_page_size,
              vmStats.pageins * vm_page_size,
              vmStats.pageouts * vm_page_size,
              vmStats.faults,
              
              vmStats.cow_faults,
              vmStats.lookups,
              vmStats.hits
              );
    }
}

#pragma mark 获取设备运行内存
+ (NSInteger)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return (NSInteger)(((vm_page_size * vmStats.free_count)) / 1024.0) / 1024.0;
}

#pragma mark 获取设备总内存

+ (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

+(NSInteger)getTotalMemorySize
{
    return (NSInteger)[NSProcessInfo processInfo].physicalMemory/1024.0/1024.0;

}


#pragma mark 总的磁盘空间
+ (float)getTotalDiskspace{
    
    float totalSpace;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    } else {
        totalSpace = 0;
    }
    
    return totalSpace *1024;
    
}

#pragma mark 可用磁盘空间
+ (float)getFreeDiskspace{
    
    float freeSpace;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        freeSpace = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
        
    } else {
        freeSpace = 0;
    }
    
    return freeSpace *1024;
    
}


+ (NSDictionary *)networkingStatesFromStatebar {
    
//    return @{@"state":@"wifi",
//             @"strength":@(3)};
    
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    
    int type = 0;
    int signalStrength = 0;
    for (id child in children) {
        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            signalStrength = [[child valueForKey:@"_wifiStrengthBars"] intValue];
            NSLog(@"signal %d", signalStrength);
            break;
        }
    }
    
    NSString *stateString = @"notReachable";
    
    switch (type) {
        case 0:
            stateString = @"notReachable";
            break;
            
        case 1:
            stateString = @"2G";
            break;
            
        case 2:
            stateString = @"3G";
            break;
            
        case 3:
            stateString = @"4G";
            break;
            
        case 4:
            stateString = @"LTE";
            break;
            
        case 5:
            stateString = @"wifi";
            break;
            
        default:
            break;
    }
    
    return @{@"state":stateString,
             @"strength":@(signalStrength)};
}


@end
