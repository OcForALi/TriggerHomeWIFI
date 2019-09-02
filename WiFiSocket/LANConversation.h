//
//  LANConversation.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LANConversationDelegate<NSObject>

///**
// *  告知刷新蓝牙列表
// */
//- (void)refreshPeripheralList:(NSMutableArray <CBPeripheral *>*)peripheralList;
//
///**
// *  告知连接蓝牙
// */
//- (void)connectedPeripheral:(CBPeripheral *)peripheral;
//
///**
// *  告知断开蓝牙
// */
//- (void)disconnectedPeripheral:(CBPeripheral *)peripheral;

/**
 *  告知上报数据
 */
- (void)ReportingRealTimeData:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  告知继电器开关状态
 */
- (void)powerSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询倒计时返回
 */
- (void)CountdownResult:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设置倒计时返回
 */
- (void)powerSwitchCountdownResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  定温湿度设置回复
 */
- (void)alarmHumidityAndTemperatureValue:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询定温湿度回复
 */
- (void)temperatureAndHumidityDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询定时列表数据回复
 */
- (void)commonPatternListDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  定时操作回复
 */
- (void)commonPatternTimingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  上报定时结束
 */
- (void)reportendoftime:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  校准时间回复
 */
- (void)calibrationTimeResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询定费数据返回
 */
- (void)spendingCountdownDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设置定量定费返回
 */
- (void)spendingCountdownAlarmResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设备重命名
 */
- (void)reNameResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设置电压警告值回复
 */
- (void)settingAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询电压警告值回复
 */
-(void)queryAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置电流告警值回复
 **/
-(void)settingAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询电流告警值回复
 **/
-(void)queryAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置功率告警值回复
 **/
-(void)settingAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询功率告警值回复
 **/
-(void)queryAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置温度单位回复
 **/
-(void)settingTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询温度单位回复
 **/
-(void)queryTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置货币单位告回复
 **/
-(void)settingMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询货币单位回复
 **/
-(void)queryMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置本地电价回复
 **/
-(void)settingLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询本地电价回复
 **/
-(void)queryLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  恢复出厂设置回复
 **/
-(void)settingResumeSetupResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

@end


@interface LANConversation : NSObject

//是否连接状态
@property (nonatomic, assign) BOOL connected;

@property (nonatomic, copy) NSString *mac;

- (void)connectToHost:(NSString *)host port:(uint16_t)port;

- (void)connectToAddress:(NSData *)remoteAddr withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;

- (void)sendMessageData:(NSMutableData *)data;

- (void)regeistDelegate:(id)delegate;

- (void)unRegeistDelegate:(id)delegate;

@end
