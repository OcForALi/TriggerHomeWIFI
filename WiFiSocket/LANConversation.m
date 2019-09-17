//
//  LANConversation.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "LANConversation.h"
#import "GCDAsyncSocket.h"


@interface LANConversation ()<GCDAsyncSocketDelegate>

@property (nonatomic, copy) id<LANConversationDelegate>delegate;
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, strong) NSMutableData *recevieData;

@end

@implementation LANConversation

- (void)regeistDelegate:(id)delegate
{
    self.delegate = delegate;
}

- (void)unRegeistDelegate:(id)delegate
{
    self.delegate = nil;
}

- (void)connectToHost:(NSString *)host port:(uint16_t)port
{
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err;
    [_asyncSocket connectToHost:host onPort:port error:&err];
}

- (void)connectToAddress:(NSData *)remoteAddr withTimeout:(NSTimeInterval)timeout error:(NSError *__autoreleasing *)errPtr
{
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_asyncSocket connectToAddress:remoteAddr withTimeout:-1 error:nil];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    self.connected = true;
    
}

//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//{
//    NSString *deviceMac;
//    NSLog(@"------------特征值更新----------%@",data);
//    Byte type = 0x00;
//    Byte cmd = 0x00;
//    [self.recevieData appendData:data];
//    Byte *testByte = (Byte*)[self.recevieData bytes];//得到data1中bytes的指针。
//    if (testByte[0] != 0xff || testByte[self.recevieData.length-1] != 0xee) {
//        return;
//    }
//    for(int i = 0;i<[self.recevieData length];i++){
//        if (i==5) {
//            type = testByte[i];
//        }else if (i==6){
//            cmd =testByte[i];
//        }
//    }
//    if (type == 0x01) {
//        BOOL reslut = (BOOL)testByte[7];
//        reslut = !reslut;
//        if (cmd == 0x0c) {
//            //重命名设备名称
//            if ([self.delegate respondsToSelector:@selector(reNameResponse:deviceMac:)]) {
//                [self.delegate reNameResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x10) {
//            //设置电压告警值回复
//            if ([self.delegate respondsToSelector:@selector(settingAlarmVoltageResponse:deviceMac:)]) {
//                [self.delegate settingAlarmVoltageResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x12){
//            NSString *Voltage = [NSString stringWithFormat:@"%d",(testByte[8]<<8)+testByte[9]];
//            //查询电压告警值回复
//            if ([self.delegate respondsToSelector:@selector(queryAlarmVoltageResponse:deviceMac:)]) {
//                [self.delegate queryAlarmVoltageResponse:@{@"result":@(reslut),@"Voltage":Voltage} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x14){
//            //设置电流警告值回复
//            if ([self.delegate respondsToSelector:@selector(settingAlarmCurrentResponse:deviceMac:)]) {
//                [self.delegate settingAlarmCurrentResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x16){
//            //查询电流警告值回复
//            if ([self.delegate respondsToSelector:@selector(queryAlarmCurrentResponse:deviceMac:)]) {
//                [self.delegate queryAlarmCurrentResponse:@{@"result":@(reslut),@"electricity":@(testByte[8])} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x18){
//            //设置功率警告值回复
//            if ([self.delegate respondsToSelector:@selector(settingAlarmPowerResponse:deviceMac:)]) {
//                [self.delegate settingAlarmPowerResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x1a){
//            //查询设置功率警告值回复
//            NSString *power = [NSString stringWithFormat:@"%d",(testByte[8]<<8)+testByte[9]];
//            if ([self.delegate respondsToSelector:@selector(queryAlarmPowerResponse:deviceMac:)]) {
//                [self.delegate queryAlarmPowerResponse:@{@"result":@(reslut),@"power":power} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x1c){
//            //设置温度单位回复
//            if ([self.delegate respondsToSelector:@selector(settingTemperatureUnitResponse:deviceMac:)]) {
//                [self.delegate settingTemperatureUnitResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x1e){
//            //查询温度单位回复
//            if ([self.delegate respondsToSelector:@selector(queryTemperatureUnitResponse:deviceMac:)]) {
//                [self.delegate queryTemperatureUnitResponse:@{@"result":@(reslut),@"type":@(testByte[8])} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x20){
//            //设置货币单位回复
//            if ([self.delegate respondsToSelector:@selector(settingMonetarytUnitResponse:deviceMac:)]) {
//                [self.delegate settingMonetarytUnitResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x22){
//            //查询货币单位回复
//            if ([self.delegate respondsToSelector:@selector(queryMonetarytUnitResponse:deviceMac:)]) {
//                [self.delegate queryMonetarytUnitResponse:@{@"result":@(reslut),@"type":@(testByte[8])} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x24){
//            //设置本地电价回复
//            if ([self.delegate respondsToSelector:@selector(settingLocalElectricityResponse:deviceMac:)]) {
//                [self.delegate settingLocalElectricityResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x26){
//            //查询本地电价回复
//            NSString *price = [NSString stringWithFormat:@"%d",(testByte[8]<<8)+testByte[9]];
//            if ([self.delegate respondsToSelector:@selector(queryLocalElectricityResponse:deviceMac:)]) {
//                [self.delegate queryLocalElectricityResponse:@{@"result":@(reslut),@"price":price} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x28){
//            //恢复出厂设置回复
//            if ([self.delegate respondsToSelector:@selector(settingResumeSetupResponse:deviceMac:)]) {
//                [self.delegate settingResumeSetupResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }
//    }else if (type == 0x02) {
//        BOOL reslut = (BOOL)testByte[7];
//        reslut = !reslut;
//        BOOL state = (BOOL)testByte[8];
//        if (cmd == 0x02) {
//            //设置电源开关回复
//            if ([self.delegate respondsToSelector:@selector(powerSwitchResponse:deviceMac:)]) {
//                [self.delegate powerSwitchResponse:@{@"state":@(state),
//                                                     @"result":@(reslut),
//                                                     } deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x04){
//            //时间校准回复
//        }else if (cmd == 0x06){
//            //设置定时回复
//            if ([self.delegate respondsToSelector:@selector(commonPatternTimingResponse:deviceMac:)]) {
//                [self.delegate commonPatternTimingResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if(cmd == 0x08){
//            //设置倒计时回复
//            BOOL switc = (testByte[8] == 0x01)?true:false;
//            if ([self.delegate respondsToSelector:@selector(powerSwitchCountdownResponse:deviceMac:)]) {
//                [self.delegate powerSwitchCountdownResponse:@{@"state":@(switc),
//                                                              @"result":@(reslut),
//                                                              } deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x0a){
//            //设置定温湿度回复
//            if ([self.delegate respondsToSelector:@selector(alarmHumidityAndTemperatureValue:deviceMac:)]){
//                [self.delegate alarmHumidityAndTemperatureValue:
//                 @{@"result":@(reslut),@"state":@(testByte[8]),@"mode":@(testByte[9]),@"type":@(testByte[10])} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x0c){
//            //查询开关状态回复
//            if ([self.delegate respondsToSelector:@selector(powerSwitchResponse:deviceMac:)]) {
//                [self.delegate powerSwitchResponse:@{@"state":@(state),
//                                                     @"result":@(reslut),
//                                                     } deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x0e){
//            //查询倒计时回复
//            if ([self.delegate respondsToSelector:@selector(CountdownResult:deviceMac:)]) {
//                [self.delegate CountdownResult:@{@"result":@(reslut),
//                                                 @"state":@(testByte[8]),
//                                                 @"switch":@(testByte[9]),
//                                                 @"hour":@(testByte[10]),
//                                                 @"minute":@(testByte[11]),
//                                                 } deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x10){
//            //查询当前时间回复
//            //                NSInteger year = (NSInteger)testByte[8]+2000;
//            //                NSInteger week = (NSInteger)testByte[9];
//            //                NSInteger month = (NSInteger)testByte[10];
//            //                NSInteger day = (NSInteger)testByte[11];
//            //                NSInteger hour = (NSInteger)testByte[12];
//            //                NSInteger min = (NSInteger)testByte[13];
//            //                NSInteger sec = (NSInteger)testByte[14];
//            if ([self.delegate respondsToSelector:@selector(calibrationTimeResponse:deviceMac:)]) {
//                [self.delegate calibrationTimeResponse:@{@"result":@(reslut)} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x12){
//            //查询定温湿度返回
//            NSString *ding = [[NSString alloc] initWithFormat:@"%d.%d",testByte[11],testByte[12]];
//            NSString *curr = [[NSString alloc] initWithFormat:@"%d.%d",testByte[13],testByte[14]];
//            BOOL state = testByte[8] == 0x01 ? true : false;
//            if ([self.delegate respondsToSelector:@selector(temperatureAndHumidityDataResponse:deviceMac:)]) {
//                [self.delegate temperatureAndHumidityDataResponse:@{@"result":@(reslut),@"state":@(state), @"mode":@(testByte[9]),@"currentValue":curr,@"alarmValue":ding,@"type":@(testByte[10])} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x14){
//            //查询定时回复
//            NSInteger model = (NSInteger)testByte[8];
//            if ([self.delegate respondsToSelector:@selector(commonPatternListDataResponse:deviceMac:)]) {
//                [self.delegate commonPatternListDataResponse:@{@"data":self.recevieData} deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x16){
//            //设置定电定量回复
//            if ([self.delegate respondsToSelector:@selector(spendingCountdownAlarmResponse:deviceMac:)]) {
//                [self.delegate spendingCountdownAlarmResponse:@{@"result":@(reslut),@"mode":@(testByte[9]),@"state":@(testByte[8])} deviceMac:deviceMac];
//            }
//        } else if (cmd == 0x18){
//            //查询定量定电
//            if ([self.delegate respondsToSelector:@selector(spendingCountdownDataResponse:deviceMac:)]) {
//                [self.delegate spendingCountdownDataResponse:@{@"data":self.recevieData} deviceMac:deviceMac];
//            }
//        }
//    }else if (type == 3) {
//        if (cmd == 0x01) {
//            //上报温湿度
//            NSString *lower = [[NSString alloc] initWithFormat:@"%d.%d",testByte[7],testByte[8]];
//            NSString *humidity = [[NSString alloc] initWithFormat:@"%d.%d",testByte[9],testByte[10]];
//            NSDictionary *dic = @{
//                                  @"temperature":@{
//                                          @"value" : @([lower floatValue]),
//                                          @"alarmVal" : @(100),
//                                          },
//                                  @"humidity":@{
//                                          @"value" : @([humidity floatValue]),
//                                          @"alarmVal" : @(100),
//                                          },
//                                  };
//            if ([self.delegate respondsToSelector:@selector(ReportingRealTimeData:deviceMac:)]) {
//                [self.delegate ReportingRealTimeData:dic deviceMac:deviceMac];
//            }
//
//        }else if (cmd == 0x02){
//            //上报温湿度回复
//        }else if (cmd == 0x03){
//            //上报功率电压
//            NSString *gonglv = [[NSString alloc] initWithFormat:@"%d",(testByte[7]<<8)+testByte[8]];
//            NSString *averagelv = [[NSString alloc] initWithFormat:@"%d",((testByte[9]<<8))+testByte[10]];
//            NSString *maxlv = [[NSString alloc] initWithFormat:@"%d",((testByte[11]<<8))+testByte[12]];
//            NSString *frequency = [[NSString alloc] initWithFormat:@"%d.%d",testByte[13],testByte[14]];
//            NSString *dianya = [[NSString alloc] initWithFormat:@"%d.%d",(testByte[15]<<8)+testByte[16],testByte[17]];
//            NSString *dianliu = [[NSString alloc] initWithFormat:@"%d.%d",testByte[18],testByte[19]];
//            NSDictionary *dic = @{
//                                  @"power":@{
//                                          @"value":gonglv,
//                                          @"averageValue":averagelv,
//                                          @"maximumValue":maxlv
//                                          },
//                                  @"voltage" : dianya,
//                                  @"electricity" : dianliu,
//                                  @"frequency" : frequency,
//                                  };
//            if ([self.delegate respondsToSelector:@selector(ReportingRealTimeData:deviceMac:)]) {
//                [self.delegate ReportingRealTimeData:dic deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x04){
//            //上报功率电压回复
//        }else if (cmd == 0x07){
//            //上报倒计时
//            if ([self.delegate respondsToSelector:@selector(CountdownResult:deviceMac:)]) {
//                [self.delegate CountdownResult:@{@"result":@(true),
//                                                 @"state":@(testByte[7]),
//                                                 @"switch":@(testByte[8]),
//                                                 @"hour":@(testByte[9]),
//                                                 @"minute":@(testByte[10]),
//                                                 } deviceMac:deviceMac];
//            }
//        }else if (cmd == 0x09){
//            //上报定时结束
//            if ([self.delegate respondsToSelector:@selector(reportendoftime:deviceMac:)]) {
//                [self.delegate reportendoftime:@{} deviceMac:deviceMac];
//            }
//        }
//    }else{
//
//    }
//    if (testByte[0] == 0xff && testByte[self.recevieData.length-1] == 0xee) {
//        self.recevieData = [NSMutableData data];
//    }
//
//    [self.asyncSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:-1];
//}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self.asyncSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:-1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    self.connected = false;
}

- (void)sendMessageData:(NSMutableData *)data
{
    [self.asyncSocket writeData:data withTimeout:-1 tag:-1];
    [self.asyncSocket readDataWithTimeout:-1 tag:-1];
}

@end
