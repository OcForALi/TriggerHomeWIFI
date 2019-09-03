//
//  MqttClientManager.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/6.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <startai_mq_ios_3_0_1/StartaiMqClient.h>
#import <startai_mq_ios_3_0_1/StartAIEntity.h>
#import <startai_mq_ios_3_0_1/StartaiMqClient+MessageModel.h>

@interface MqttClientManager : NSObject

@property (nonatomic, strong) StartaiMqClient *client;

+ (instancetype)shareInstance;

- (void)SSLConnected;


@end
