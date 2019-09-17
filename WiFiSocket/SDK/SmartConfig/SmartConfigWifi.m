//
//  SmartConfigWifi.m
//  WiFiSocket
//
//  Created by Mac on 2018/7/13.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "SmartConfigWifi.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"
#import <SystemConfiguration/CaptiveNetwork.h>

static const BOOL AES_ENABLE = NO;
static NSString * const AES_SECRET_KEY = @"1234567890123456"; // TODO modify your own key

@interface SmartConfigWifi ()<ESPTouchDelegate>

@property (nonatomic, strong) ESPTouchTask *esptouchTask;
@property (nonatomic, strong) NSCondition *condition;

@end

@implementation SmartConfigWifi

- (instancetype)initWithApSsid:(NSString *)apSsid andApBssid:(NSString *)apBssid andApPwd:(NSString *)apPwd andAES:(ESPAES *)aes
{
    if (self = [super init]) {
        self.condition = [[NSCondition alloc] init];
        [self.condition lock];
        self.esptouchTask = [[ESPTouchTask alloc] initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andAES:aes];
        [self.condition unlock];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *esptouchResuktArr = [self.esptouchTask executeForResults:1];
            ESPTouchResult *firstResult = [esptouchResuktArr firstObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!firstResult.isCancelled) {
                    if (firstResult.isSuc) {
                        if (self.configSucessHandler) {
                            self.configSucessHandler();
                        }
                    }else{
                        if (self.configFailHandler) {
                            self.configFailHandler();
                        }
                    }
                }
            });
        });

    }
    return self;
}


- (void)interrupt
{
    [self.condition lock];
    if (self.esptouchTask) {
        [self.esptouchTask interrupt];
    }
    [self.condition unlock];
//    if (self.configFailHandler) {
//        self.configFailHandler();
//    }
}
@end
