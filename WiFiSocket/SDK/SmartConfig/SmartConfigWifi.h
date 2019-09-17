//
//  SmartConfigWifi.h
//  WiFiSocket
//
//  Created by Mac on 2018/7/13.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPAES.h"
@interface SmartConfigWifi : NSObject

@property (nonatomic, copy) void(^configSucessHandler)(void);

@property (nonatomic, copy) void(^configFailHandler)(void);

- (instancetype)initWithApSsid:(NSString *)apSsid andApBssid:(NSString *)apBssid andApPwd:(NSString *)apPwd andAES:(ESPAES *)aes;

- (void)interrupt;

@end
