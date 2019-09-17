//
//  UDPSocket.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UDPSocket : NSObject

@property (nonatomic, strong) NSMutableDictionary *deviceDic;   //局域网发现设备ip详细

@property (nonatomic, strong) NSMutableArray *deviceInfoArr;    //设备列表

@property (nonatomic, strong) NSMutableArray *lanArr;

@property (nonatomic, assign) BOOL isConnected;     //局域网通道连接

@property (nonatomic, assign) BOOL isBinding;       //是否在进行局域网绑定设备操作

@property (nonatomic, strong) NSMutableDictionary *sendMsgDic;  //记录发送消息的字典

@property (nonatomic, copy) void(^connectedStausHandler)(BOOL staus);

+ (instancetype)shareInstance;

//开始扫描局域网设备
- (void)startFindDevice;

//停止扫描局域网设备
- (void)stopFindDevice;

//局域网内握手连接 发送消息
- (void)sendMessageData:(NSMutableData *)data mac:(NSString *)mac;

// 不用进行局域网握手连接 设备列表开关 局域网绑定解绑设备使用此方法
- (void)sendDataWithoutConnect:(NSMutableData *)data mac:(NSString *)mac;

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port mac:(NSString *)mac;

- (void)closed;

- (void)requestToekn;

- (void)requestLANConnection:(NSString *)mac;

- (void)requestLanConnectionSleep;

- (void)startHeartBeatTiemr;

- (void)stopSendHeartBeat;

- (void)electricQuantity;

@end
