//
//  MQTTMessageEntity.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQTTMessageEntity : NSObject

//事件发生类型
@property (nonatomic, copy) NSString *msgcw;
//消息类型
@property (nonatomic, copy) NSString *msgtype;

@property (nonatomic, copy) NSString *msgid;
//发送端clientId
@property (nonatomic, copy) NSString *fromId;
//接收方clientId
@property (nonatomic, copy) NSString *toId;
//
@property (nonatomic, copy) NSString *a_ver;
//
@property (nonatomic, copy) NSString *apptype;

@property (nonatomic, copy) NSString *appid;

@property (nonatomic, copy) NSString *domain;

@property (nonatomic, copy) NSString *m_ver;
//content
@property (nonatomic, strong) id content;
//result
@property (nonatomic, copy) NSString *result;

@property (nonatomic, assign) CGFloat lat;

@property (nonatomic, assign) CGFloat lng;



@end

@interface MQTTMessageContentEntity : NSObject

//手机号
@property (nonatomic, copy) NSString *mobile;
//密码
@property (nonatomic, copy) NSString *passwd;
//sn
@property (nonatomic, copy) NSString *sn;
// 验证码
@property (nonatomic, copy) NSString *checkCode;

@end

@interface MQTTFirmwareEntity : NSObject

@property (nonatomic, copy) NSString *sysVersion;
@property (nonatomic, copy) NSString *firmwareVersion;
@property (nonatomic, copy) NSString *iNetMac;
@property (nonatomic, copy) NSString *wifiMac;
@property (nonatomic, copy) NSString *bluetoothMac;
@property (nonatomic, copy) NSString *product;
@property (nonatomic, copy) NSString *modelNumber;
@property (nonatomic, copy) NSString *imei;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *screenSize;
@property (nonatomic, copy) NSString *cpuSerial;
@property (nonatomic, copy) NSString *os;

- (NSDictionary *)changeMyself;

@end

@interface MQTTStatusEntity : NSObject

@property (nonatomic, copy) NSString *romStatus;
@property (nonatomic, copy) NSString *ramStatus;
@property (nonatomic, copy) NSString *innerIP;
@property (nonatomic, copy) NSString *netWorkType;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *bssid;
@property (nonatomic, copy) NSString *a_ver;
@property (nonatomic, copy) NSString *lat;
@property (nonatomic, copy) NSString *lng;

- (NSDictionary *)changeMyself;

@end
