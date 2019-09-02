//
//  MqttClientManager.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/6.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "MqttClientManager.h"

@interface MqttClientManager ()


@end

@implementation MqttClientManager

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)SSLConnected
{
    _client = [[StartaiMqClient alloc] init];
//    _client.customQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _client.repeatTimes = 1;
//    _client.appointUserid = @"1234567890ABCDEF";
    _client.tlsCafile = [[NSBundle mainBundle] pathForResource:@"service" ofType:@"crt"];
}

- (long long)getNowTime
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    long long time = a;
    
    return time;
}

@end
