//
//  UDPSocket.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "UDPSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "QueryHistoryModel.h"

static uint8_t sequence = 0;    //消息序号
static NSInteger delayTime = 200;

NSInteger devicePort = 9222;

NSInteger normalMsgTag = 100;
NSInteger findMsgTag = 101;
NSInteger requestTokenTag = 102;
NSInteger requestConnectTag = 103;
NSInteger requestSleepTag = 104;
NSInteger heartTag = 105;

@interface UDPSocket () <GCDAsyncUdpSocketDelegate,HandlingDataModelDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, copy) NSString *deviceMac;
@property (nonatomic, strong) NSTimer *findTimer;   //发现包定时器
@property (nonatomic, strong) NSTimer *hearTimer;   //心跳包定时器
@property (nonatomic, assign) NSInteger requestNum; //token及连接请求计数

@property (nonatomic, assign) BOOL shouldConnect;   //当需要在断开当前的局域网通道建立新的通道标志
@property (nonatomic, assign) BOOL closeBySelf;     //是否主动断开局域网连接
@property (nonatomic, assign) BOOL shouldResendRequestConnect;
@property (nonatomic, assign) BOOL shouldResendRequestToken;

@property (nonatomic, assign) long long latestTime;
@property (nonatomic, assign) long long currentTime;

@end

@implementation UDPSocket

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self == [super init]) {
        _deviceDic = [[NSMutableDictionary alloc] init];
        _sendMsgDic = [[NSMutableDictionary alloc] init];
        _lanArr = [NSMutableArray array];
    }
    return self;
}

- (GCDAsyncUdpSocket *)udpSocket
{
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error;
        [_udpSocket enableBroadcast:true error:&error];
        [_udpSocket beginReceiving:&error];
    }
    return _udpSocket;
}


#pragma mark 建立长连接
- (void)connectToHost:(NSString *)host onPort:(uint16_t)port mac:(NSString *)mac
{
    if (![BasicInfoCollection getCurreWiFiSsid].length) {
        // 未连接wifi不进行局域网连接
        return;
    }
    
    self.requestNum = 0;    //每次连接局域网通道时初始化token及连接请求计数
    self.deviceMac = mac;
    self.closeBySelf = false;
    self.host = host;

    if (!self.udpSocket.connectedHost.length) {
        [self.udpSocket connectToHost:host onPort:port error:nil];
    }else{
        if (![self.udpSocket.connectedHost isEqualToString:host]) {
            [self closed];
            self.isConnected = false;
            self.shouldConnect = true;  //断开了socket以后再进行连接操作
        }else{
            
        }
    }
}

#pragma mark 未经过token验证建立连接 在局域网内发送消息
- (void)sendDataWithoutConnect:(NSMutableData *)data mac:(NSString *)mac
{
    data = [self getPacketData:data mac:mac];
    if([mac isEqualToString:self.deviceMac] && self.udpSocket.connectedHost.length){
        //绑定解绑消息不用进行token获取校验连接 局域网连接可直接发送
        [self.udpSocket sendData:data withTimeout:-1 tag:normalMsgTag];
    }else if (mac && self.deviceDic[mac]) {
        //设备列表开关控制不用局域网建立连接通道 指定ip发送 确定当前局域网设备当中是有此设备
 
        long long times = [self getSendMessageTime];
        NSString *ip = self.deviceDic[mac]?self.deviceDic[mac]:@"";
        [self MessageTimeDelayed:@{@"data":data,@"mac":mac,@"time":@(times),@"ip":ip}];
    }else{
        long long times = [self getSendMessageTime];
        [self MessageTimeDelayed:@{@"data":data,@"mac":mac,@"time":@(times)}];
    }
}

#pragma mark 发送消息
- (void)sendMessageData:(NSMutableData *)data mac:(NSString *)mac
{
    data = [self getPacketData:data mac:mac];
    if (mac) {
        long long times = [self getSendMessageTime];
        [self MessageTimeDelayed:@{@"data":data,@"mac":mac,@"time":@(times)}];
        
    }else{
        DDLog(@"向空设备发送消息失败....................");
    }
}

#pragma mark 设定发送消息时间
- (long long)getSendMessageTime
{
    long long time = self.latestTime-self.currentTime;
    
    if (time<0) {
        self.latestTime = self.currentTime+0.1;
    }else if (time>0 && time<delayTime){
        self.latestTime = self.latestTime + (delayTime- time);
    }else{
        self.latestTime = self.latestTime+delayTime;
    }
    return self.latestTime;
}

- (void)MessageTimeDelayed:(NSDictionary *)object
{
    long long time = [object[@"time"] longLongValue];
    CGFloat delay = (time-self.currentTime)/1000.0;
    if (delay<0 || delay>10) {
        //防止用户中途修改时间导致消息发送不出去
        delay = 0;
    }
    [self performSelector:@selector(delaySendMessage:) withObject:object afterDelay:delay];
}

- (void)delaySendMessage:(NSDictionary *)object
{
    
    NSMutableData *data = [NSMutableData dataWithData:object[@"data"]];
    NSString *mac = object[@"mac"];
    uint8_t type = ((Byte*)[[data subdataWithRange:NSMakeRange(11, 1)] bytes])[0];
    uint8_t cmd = ((Byte*)[[data subdataWithRange:NSMakeRange(12, 1)] bytes])[0];
    NSString *key = [NSString stringWithFormat:@"%@-%d-%d",mac,type,cmd];
    [self.sendMsgDic setObject:data forKey:key];
    [self performSelector:@selector(sendMessage:) withObject:key afterDelay:3.0];
    
    if (self.isConnected && [mac isEqualToString:self.deviceMac]) {
        [self.udpSocket sendData:data withTimeout:-1 tag:normalMsgTag];
        DDLog(@"局域网发送消息..................Mac%@ ---- data%@",mac,data);
    }else if(object[@"ip"] && [ToolHandle isSameLan:self.deviceDic[mac] ip2:[BasicInfoCollection getCurrentLocalIP]]){
        [self.udpSocket sendData:data toHost:object[@"ip"] port:devicePort withTimeout:-1 tag:normalMsgTag];
    }else{
        [self MQMessageSendingData:data mac:mac];
        DDLog(@"广域网发送消息.................. Mac%@ ---- data%@",mac,data);
    }
}

- (void)sendMessage:(NSString *)key
{
    if ([self.sendMsgDic.allKeys containsObject:key]) {
        NSArray *arr = [key componentsSeparatedByString:@"-"];
        NSString *mac = arr[0];
        NSMutableData *data = [NSMutableData dataWithData:(NSData *)self.sendMsgDic[key]];
        [self.sendMsgDic removeObjectForKey:key];
        
        if (self.isConnected && [mac isEqualToString:self.deviceMac]) {
            [self.udpSocket sendData:data withTimeout:-1 tag:normalMsgTag];
            DDLog(@"局域网重新发送消息..................%@",data);
        }else{
            [self MQMessageSendingData:data mac:mac];
            DDLog(@"广域网重新发送消息..................%@",data);
        }
    }
}

#pragma mark MQ云端发消息
- (void)MQMessageSendingData:(NSMutableData *)data mac:(NSString *)mac
{
    
    if ([self.deviceInfoArr isKindOfClass:[NSArray class]] && self.deviceInfoArr.count > 0) {
        
        NSLog(@"设备列表 ---- %@",self.deviceInfoArr);
        
        for (NSDictionary *dic in self.deviceInfoArr) {
            if ([dic[@"mac"] isEqualToString:mac]) {
                NSString *sn = dic[@"id"];
                if (sn.length) {
                    Byte *byte = (Byte *)[data bytes];
                    NSMutableString *muStr = [[NSMutableString alloc] init];
                    for (NSInteger i=0; i<data.length; i++) {
                        NSString *str;
                        if (byte[i] < 16) {
                            str = [NSString stringWithFormat:@"0%x",byte[i]];
                        }else{
                            str = [NSString stringWithFormat:@"%x",byte[i]];
                        }
                        str = [str uppercaseString];
                        [muStr appendString:str];
                    }
                    [[MqttClientManager shareInstance].client passthrough:sn data:muStr completionHandler:^(StartAIResultState res) {
                        
                    }];
                    break;
                }else{
                    DDLog(@"广域网发送消息失败 该设备没有sn..................");
                }
            }
        }
        
    }
    
}

#pragma mark 关闭socket
- (void)closed
{
    DDLog(@"主动关闭局域网渠道.........................");
    self.closeBySelf = true;
    [self.udpSocket close];
    _udpSocket = nil;
}

#pragma mark 广播查询设备
- (void)startFindDevice
{
    if (self.udpSocket.connectedHost.length) {
        [self closed];
        [self performSelector:@selector(startFindDevice) withObject:nil afterDelay:1.0];
        return;
    }
    [self sendFindDevice];
    [self startFindTimer];
}

- (void)startFindTimer
{
    if (!_findTimer) {
        _findTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sendFindDevice) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:_findTimer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark 停止查询设备
- (void)stopFindDevice
{
    if (_findTimer) {
        [_findTimer invalidate];
        _findTimer = nil;
    }
}

#pragma mark 发送心跳包定时器
- (void)startHeartBeatTiemr
{
    if (!_hearTimer) {
        _hearTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(heartBeat) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:_hearTimer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark 停止发送心跳包
- (void)stopSendHeartBeat
{
    if (_hearTimer) {
        [_hearTimer invalidate];
        _hearTimer = nil;
    }
}

#pragma mark 停用定时器
- (void)stopTimer
{
    if (_findTimer) {
        [_findTimer invalidate];
        _findTimer = nil;
    }
    if (_hearTimer) {
        [_hearTimer invalidate];
        _hearTimer = nil;
    }
}

#pragma mark 代理方法
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    DDLog(@"局域网建立连接.........................");
    if (!self.isBinding) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(requestLANConnection:) withObject:self.deviceMac afterDelay:0.3];
        });
    }
    self.isBinding = false;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
//    if (self.connectedStausHandler) {
//        self.connectedStausHandler(false);
//    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    if (tag == normalMsgTag) {
        DDLog(@"普通消息发送失败.................");
    }else if (tag == findMsgTag){
        DDLog(@"发现包发送失败...................");
    }else if (tag == requestTokenTag){
        DDLog(@"请求token发送失败....................");
    }else if (tag == requestConnectTag){
        DDLog(@"请求局域网连接发送握手失败................");
    }else if (tag == requestSleepTag){
        DDLog(@"局域网休眠发送失败.................");
    }else if (tag == heartTag){
        DDLog(@"心跳包发送失败....................");
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    NSString *deviceMac;
    for (NSString *key in self.deviceDic.allKeys) {
        if ([[self.deviceDic objectForKey:key] isEqualToString:ip]) {
            deviceMac = key;
        }
    }
    if (deviceMac == nil) {
        deviceMac = @"mac";
    }
//    DDLog(@"局域网收到消息....................：%@",data);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[HandlingDataModel shareInstance] handlingRecevieData:data deviceIdentifiy:deviceMac fromAddress:[GCDAsyncUdpSocket hostFromAddress:address]];
    });
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error;
{
    DDLog(@"局域网断开连接.......................");
    
    _udpSocket = nil;
    self.isConnected = false;
    [self stopTimer];

    if (self.shouldConnect) {
        self.shouldConnect = false;
        [self connectToHost:self.host onPort:devicePort mac:self.deviceMac];
    }else if (!self.closeBySelf && [BasicInfoCollection getCurreWiFiSsid].length){
        //如果中途意外断开从新连接一次
//        [self connectToHost:self.host onPort:devicePort mac:self.deviceMac];
        self.closeBySelf = true;
    }
    
}

#pragma mark 发现附近设备
- (void)sendFindDevice
{

    if (![BasicInfoCollection getCurreWiFiSsid].length) {
        return;
    }
    uint8_t type= 0x01;
    uint8_t cmd = 0x03;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[ToolHandle getData:type]];
    [data appendData:[ToolHandle getData:cmd]];
    
    NSData *userid = [[[MqttClientManager shareInstance].client userid] dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:userid];
    for (NSInteger i = 0; i<32-userid.length; i++) {
        uint8_t zero = 0x00;
        [data appendBytes:&zero length:1];
    }
    
    data = [self getPacketData:data mac:nil];
    [self.udpSocket sendData:data toHost:@"255.255.255.255" port:devicePort withTimeout:-1 tag:findMsgTag];
    
    DDLog(@"........................发送发现包.....................");
}

#pragma mark 心跳包
- (void)heartBeat
{
    uint8_t type= 0x01;
    uint8_t cmd = 0x01;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[ToolHandle getData:type]];
    [data appendData:[ToolHandle getData:cmd]];
    
    if ( self.deviceMac && [[NSUserDefaults standardUserDefaults]objectForKey:self.deviceMac]) {
        [data appendData:[[NSUserDefaults standardUserDefaults]objectForKey:self.deviceMac]];
    }else{
        [self requestToekn];
        return;
    }
    
    data = [self getPacketData:data mac:self.deviceMac];
    [self.udpSocket sendData:data withTimeout:-1 tag:heartTag];
    
    DDLog(@"........................发送心跳包.....................");
}

#pragma mark 获取局域网通信的token码
- (void)requestToekn
{
    if (!self.udpSocket.connectedHost) {
        DDLog(@"发送局域网token请求失败，局域网通道断开");
        return;
    }else if (self.isConnected){
         DDLog(@"已有局域网握手成功");
        return;
    }else if (self.requestNum>10){
        //在一条通道发送了超过十次的token和连接请求将不继续发送
        return;
    }
    
    self.requestNum++;
    uint8_t type= 0x01;
    uint8_t cmd = 0x2d;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[ToolHandle getData:type]];
    [data appendData:[ToolHandle getData:cmd]];
    NSData *userid = [[MqttClientManager shareInstance].client.userid dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:userid];
    
    for (NSInteger i=0; i<32-userid.length; i++) {
        [data appendData:[ToolHandle getData:0x00]];
    }
    
    uint32_t num = arc4random()%100;
    unsigned char fourNum[4];
    fourNum[0] = num & 0xff;
    fourNum[1] = (num & 0xff00) >>8;
    fourNum[2] = (num & 0xff0000) >> 16;
    fourNum[3] = (num & 0xff000000) >> 24;
    [data appendBytes:fourNum length:4];
    
    data = [self getPacketData:data mac:nil];
    [self.udpSocket sendData:data withTimeout:-1 tag:requestTokenTag];
    [[HandlingDataModel shareInstance] regegistDelegate:self];
    
    DDLog(@"请求局域网连接使用token...............................");
}

#pragma mark 请求局域网连接

- (void)requestLANConnection:(NSString *)mac
{

    if (!self.udpSocket.connectedHost) {
        DDLog(@"发送局域网连接失败，局域网通道未建立连接");
        return;
    }else if (self.isConnected){
        DDLog(@"已有局域网握手成功");
        return;
    }else if (self.requestNum>10){
        //在一条通道发送了超过十次的token和连接请求将不继续发送
        return;
    }
    self.requestNum++;
    
    uint8_t type= 0x01;
    uint8_t cmd = 0x2f;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[ToolHandle getData:type]];
    [data appendData:[ToolHandle getData:cmd]];
    NSData *userid = [[MqttClientManager shareInstance].client.userid dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:userid];
    for (NSInteger i=0; i<32-userid.length; i++) {
        [data appendData:[ToolHandle getData:0x00]];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:mac]) {
        [data appendData:[[NSUserDefaults standardUserDefaults]objectForKey:mac]];
    }else{
        [self requestToekn];
        return;
    }
    
    data = [self getPacketData:data mac:nil];
    [self.udpSocket sendData:data withTimeout:-1 tag:requestConnectTag];
    [[HandlingDataModel shareInstance] regegistDelegate:self];
    
    DDLog(@"........................发送局域网连接.....................");
}

#pragma mark 局域网连接休眠
-(void)requestLanConnectionSleep
{
    uint8_t type= 0x01;
    uint8_t cmd = 0x31;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[ToolHandle getData:type]];
    [data appendData:[ToolHandle getData:cmd]];
    NSData *userid = [[MqttClientManager shareInstance].client.userid dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:userid];
    
    for (NSInteger i=0; i<32-userid.length; i++) {
        [data appendData:[ToolHandle getData:0x00]];
    }
    
    uint32_t num = arc4random()%100;
    unsigned char fourNum[4];
    fourNum[0] = num & 0xff;
    fourNum[1] = (num & 0xff00) >>8;
    fourNum[2] = (num & 0xff0000) >> 16;
    fourNum[3] = (num & 0xff000000) >> 24;
    [data appendBytes:fourNum length:4];

    data = [self getPacketData:data mac:self.deviceMac];
    [self.udpSocket sendData:data withTimeout:-1 tag:requestSleepTag];
    [self stopSendHeartBeat];
    
    DDLog(@"........................发送局域网休眠.....................");
}


#pragma mark 获取token返回
- (void)requestTokenResonse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSData *tokenData = (NSData *)[object objectForKey:@"token"];
    if (result) {
        //缓存设备请求回来的token 下次局域网用此token进行连接
        [[NSUserDefaults standardUserDefaults] setObject:tokenData forKey:deviceMac];
        [[NSUserDefaults standardUserDefaults] synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(requestLANConnection:) withObject:deviceMac afterDelay:0.3];
        });
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:deviceMac];
    }
}

#pragma mark 局域网连接返回
- (void)requestLANConnectionResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL result = [[object objectForKey:@"result"] boolValue];
    if (!result) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:deviceMac];
//        [self requestToekn];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(requestToekn) withObject:nil afterDelay:0.3];
        });
        self.isConnected = false;
    }else{
        self.isConnected = true;
        [self startHeartBeatTiemr];
        if (self.connectedStausHandler) {
            self.connectedStausHandler(true);
        }
    }
}

#pragma mark 心跳包回复
- (void)heartBeatResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSInteger state = [[object objectForKey:@"state"] integerValue];
    if (state == 3) {
        self.isConnected = false;
        [self requestToekn];
    }    
}

- (NSMutableData *)getPacketData:(NSMutableData *)data mac:(NSString *)mac
{
    Byte *bytes = (Byte *)[data  bytes];
    NSMutableData *packetData = [[NSMutableData alloc] init];
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = data.length+8;
    uint8_t version = 1;
    //    uint8_t sequence = 1;
    uint8_t reserve4 = 0x00;
    uint8_t reserve3 = 0x00;
    uint8_t reserve2 = 0x00;
    uint8_t reserve1 = 0x00;
    
    uint8_t custome_h = [[QXUserDefaults objectForKey:CUSTOM_H] integerValue];
    uint8_t custome_l = [[QXUserDefaults objectForKey:CUSTOM_L] integerValue];
    
    int8_t ee = 0xee;
    
    [packetData appendData:[ToolHandle getData:header]];
    [packetData appendData:[ToolHandle getData:len_h]];
    [packetData appendData:[ToolHandle getData:len_l]];
    [packetData appendData:[ToolHandle getData:version]];
    [packetData appendData:[ToolHandle getData:sequence]];
//    if (mac && [[NSUserDefaults standardUserDefaults]objectForKey:mac]) {
    if (bytes[0] == 0x01 && (bytes[1] == 0x35 || bytes[1] == 0x37) && [[NSUserDefaults standardUserDefaults]objectForKey:mac]) {
        [packetData appendData:[[NSUserDefaults standardUserDefaults]objectForKey:mac]];
    }else{
        [packetData appendData:[ToolHandle getData:reserve4]];
        [packetData appendData:[ToolHandle getData:reserve3]];
        [packetData appendData:[ToolHandle getData:reserve2]];
        [packetData appendData:[ToolHandle getData:reserve1]];
    }

    [packetData appendData:[ToolHandle getData:custome_h]];
    [packetData appendData:[ToolHandle getData:custome_l]];
    [packetData appendData:data];
    
    Byte *byte = (Byte*)[packetData bytes];
    Byte b = myCRC8(byte, 3, (int)packetData.length);
    [packetData appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [packetData appendData:[ToolHandle getData:ee]];
    
    packetData = [ToolHandle checke55Data:packetData];
    packetData = [ToolHandle checkeffData:packetData];
    packetData = [ToolHandle checkeeeData:packetData];
    
    sequence = (sequence+1)&0xff;
    return packetData;
}

- (void)setIsConnected:(BOOL)isConnected
{
    _isConnected = isConnected;
    if (!_isConnected) {
        DDLog(@"局域网未连接......................");
    }
}


- (long long)currentTime
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    long long time = a;
    
    return time;
}

- (void)electricQuantity{
    
    //GCD延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSArray *array = self.deviceInfoArr;
 
        __block NSInteger time = array.count * 7;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 3 * NSEC_PER_SEC, 0); //每秒执行
        
        dispatch_source_set_event_handler(_timer, ^{
            time--;
            if (time <= 0) {
                dispatch_source_cancel(_timer);
            }else{

                NSInteger integer = time/7;
                
                if (integer > array.count - 1) {
                    return;
                }
                
                if (array.count <= 0) {
                    return ;
                }
                
                NSDictionary *deviceDict =  array[integer];
                
                NSDate *endDate = [NSDate date];
                NSDate *startTimeDate;    // 指定日期声明
                NSTimeInterval oneDay = 24 * 60 * 60;  // 一天一共有多少秒
                
                NSInteger day = time - integer * 7;
                
                startTimeDate = [endDate initWithTimeIntervalSinceNow: -(oneDay * day)];
                
                endDate = [endDate initWithTimeIntervalSinceNow: -(oneDay * (day - 1))];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                NSString *startTime = [[dateFormatter stringFromDate:startTimeDate] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                NSString *endTime = [[dateFormatter stringFromDate:endDate] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                
                NSDictionary *dict = @{@"startTime":startTime,@"mac":deviceDict[@"mac"],@"endTime":endTime,@"interval":@(1)};
                
                NSString *mac = dict[@"mac"];
                NSArray *startArr = [dict[@"startTime"] componentsSeparatedByString:@"/"];
                NSArray *endArr = [dict[@"endTime"] componentsSeparatedByString:@"/"];
                uint8_t type = 0x02;
                uint8_t cmd = 0x19;
                uint8_t startYear = [startArr[0] integerValue]-2000;
                uint8_t startMonth = [startArr[1] integerValue];
                uint8_t startDay = [startArr[2] integerValue];
                
                uint8_t endYear = [endArr[0] integerValue]-2000;
                uint8_t endMonth = [endArr[1] integerValue];
                uint8_t endDay = [endArr[2] integerValue];
                //    uint8_t interval = [object[@"interval"] integerValue];
                
                NSMutableData *data = [NSMutableData data];
                [data appendData:[self getData:type]];
                [data appendData:[self getData:cmd]];
                [data appendData:[self getData:startYear]];
                [data appendData:[self getData:startMonth]];
                [data appendData:[self getData:startDay]];
                [data appendData:[self getData:endYear]];
                [data appendData:[self getData:endMonth]];
                [data appendData:[self getData:endDay]];
                [data appendData:[self getData:0x01]];
                
                data = [self getPacketData:data mac:mac];
                
//                if (self.isConnected && [mac isEqualToString:self.deviceMac]) {
//                    [self.udpSocket sendData:data withTimeout:-1 tag:normalMsgTag];
//                    DDLog(@"局域网发送消息..................Mac%@ XXXXX- Data%@",mac,data);
//                }else{
//                    [self MQMessageSendingData:data mac:mac];
//                    DDLog(@"广域网发送消息.................. Mac%@ XXXXX- Data%@",mac,data);
//                }
                
            }
            
        });
            
        dispatch_resume(_timer);
        
    });
    
}

- (NSData *)getData:(uint8_t)da
{
    NSData *data = [[NSData alloc] initWithBytes:&da length:sizeof(da)];
    return data;
}

@end
