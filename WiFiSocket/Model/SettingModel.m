//
//  SettingModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "SettingModel.h"

@interface SettingModel ()<WKScriptMessageHandler>
{
    uint8_t type;
}

@end

@implementation SettingModel

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
    if (self = [super init]) {
        type = 0x04;
    }
    return self;
}

- (NSArray *)funArr
{
    return @[
             @"disableGoBackRequest",
             @"goBackRequest",
             @"reNameRequest",  //设备重命名
             @"systemSetupRequest", //点击设置
             @"settingAlarmVoltageRequest", //设置电压告警值
             @"queryAlarmVoltageRequest", //查询电压告警值
             @"settingAlarmCurrentRequest",//设置电流告警值
             @"queryAlarmCurrentRequest",//查询电流告警值
             @"settingAlarmPowerRequest",//设置功率告警值
             @"queryAlarmPowerRequest",//查询功率告警值
             @"queryTemperatureUnitRequest",//查询温度单位
             @"settingTemperatureUnitRequest",//设置温度单位
             @"settingMonetarytUnitRequest",//设置货币单位
             @"queryMonetarytUnitRequest",//查询货币单位
             @"settingLocalElectricityRequest",//设置本地电价
             @"queryLocalElectricityRequest",//查询本地电价
             @"settingResumeSetupRequest",//恢复出厂设置
             @"BackupTimeAndDirectoryRequest",//备份时间目录查询
             @"BackupDataRequest",//备份数据到手机
             @"BackupRecoveryDataRequest",//备份中恢复数据
             @"indicatorLightStateRequest", //查询指示灯开关状态
             @"indicatorLightSwitchRequest",    //控制指示灯开关状态
             @"deviceLabelRequest",     //查询设备标签请求
             @"setDeviceLabelRequest",     //设置设备标签
             ];
}

- (NSDictionary *)funDic
{
    return @{
             @"disableGoBackRequest":@"disableGoBackRequest:",
             @"goBackRequest":@"goBackRequest:",
             @"reNameRequest":@"reNameRequest:", //重命名
             @"systemSetupRequest":@"systemSetupRequest:",  //点击设置
             @"deviceHistoryDataRequest":@"deviceHistoryDataRequest:",   //查询设备历史数据
             @"deviceAccumulationParameterRequest":@"deviceAccumulationParameterRequest:", //查询设备累计参数
             @"deviceRateRequest":@"deviceRateRequest:",   //查询设备费率
             @"settingAlarmVoltageRequest":@"settingAlarmVoltageRequest:", //设置电压告警值
             @"queryAlarmVoltageRequest":@"queryAlarmVoltageRequest:", //查询电压告警值
             @"settingAlarmCurrentRequest":@"settingAlarmCurrentRequest:",//设置电流告警值
             @"queryAlarmCurrentRequest":@"queryAlarmCurrentRequest:",//查询电流告警值
             @"settingAlarmPowerRequest":@"settingAlarmPowerRequest:",//设置功率告警值
             @"queryAlarmPowerRequest":@"queryAlarmPowerRequest:",//查询功率告警值
             @"settingTemperatureUnitRequest":@"settingTemperatureUnitRequest:",//设置温度单位
             @"settingMonetarytUnitRequest":@"settingMonetarytUnitRequest:",//设置货币单位
             @"queryMonetarytUnitRequest":@"queryMonetarytUnitRequest:",//查询货币单位
             @"settingLocalElectricityRequest":@"settingLocalElectricityRequest:",//设置本地电价
             @"queryLocalElectricityRequest":@"queryLocalElectricityRequest:",//查询本地电价
             @"settingResumeSetupRequest":@"settingResumeSetupRequest:",//恢复出厂设置
             @"BackupTimeAndDirectoryRequest":@"BackupTimeAndDirectoryRequest:",//备份时间目录查询
             @"BackupDataRequest":@"BackupDataRequest:",//备份数据到手机
             @"BackupRecoveryDataRequest":@"BackupRecoveryDataRequest:",//备份中恢复数据
             @"indicatorLightStateRequest":@"indicatorLightStateRequest:", //查询指示灯开关状态
             @"indicatorLightSwitchRequest":@"indicatorLightSwitchRequest:",    //控制指示灯开关状态
             @"deviceLabelRequest":@"deviceLabelRequest:",
             @"setDeviceLabelRequest":@"setDeviceLabelRequest:",
             };
}

#pragma mark

- (void)disableGoBackRequest:(NSDictionary *)object
{
    
}

- (void)goBackRequest:(NSDictionary *)object
{
    
}

#pragma mark 设置界面数据
#pragma mark 重命名设备名称
- (void)reNameRequest:(NSDictionary *)object
{
    NSData *name = [[object objectForKey:@"newname"] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *mac = [object objectForKey:@"mac"];
    
    uint8_t type= 0x01;
    uint8_t cmd = 0x0b;

    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:name];
    for (NSInteger i=0; i<32-name.length; i++) {
        [data appendData:[self getData:0x00]];
    }

    [self sendData:data mac:mac];

}

- (void)reNameResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"reNameResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"reNameResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 点击设置
- (void)systemSetupRequest:(NSDictionary *)object
{
    
}

#pragma mark 设置电压告警值
- (void)settingAlarmVoltageRequest:(NSDictionary *)object
{
    uint16_t voltage = (uint16_t)[[object objectForKey:@"voltage"] integerValue];
    NSString *mac = [object objectForKey:@"mac"];

    uint8_t cmd = 0x0f;
    uint8_t big = voltage>>8;
    uint8_t small = voltage;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:big]];
    [data appendData:[self getData:small]];
    
    [self sendData:data mac:mac];
}

#pragma mark 设置电压警告值返回
- (void)settingAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"settingAlarmVoltageResponse..........设置电压警告值返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingAlarmVoltageResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询电压告警值
- (void)queryAlarmVoltageRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];

    uint8_t cmd = 0x11;
    
    NSMutableData *data = [[NSMutableData alloc] init];

    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];

    [self sendData:data mac:mac];;
}

#pragma mark 查询电压警告值返回
- (void)queryAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"queryAlarmVoltageResponse..........查询电压警告值返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat Voltage = [[object objectForKey:@"Voltage"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryAlarmVoltageResponse('%@',%d,%.2f)",deviceMac,result,Voltage];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置电流警告值
- (void)settingAlarmCurrentRequest:(NSDictionary *)object
{
    uint8_t currentBig = (uint8_t)(([[object objectForKey:@"current"] integerValue]*100)>>8);
    uint8_t currentSmall = (uint8_t)([[object objectForKey:@"current"] integerValue]*100);
    NSString *mac = [object objectForKey:@"mac"];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x13;
    
    NSMutableData *data = [[NSMutableData alloc] init];

    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:currentBig]];
    [data appendData:[self getData:currentSmall]];

    [self sendData:data mac:mac];
}

#pragma mark 设置电流警告值返回
-(void)settingAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"settingAlarmCurrentResponse..........设置电流警告值返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingAlarmCurrentResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询电流警告值
- (void)queryAlarmCurrentRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x15;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];

    [self sendData:data mac:mac];;
}

#pragma mark 查询电流警告值返回
- (void)queryAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"queryAlarmCurrentResponse..........查询电流警告值返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat electricity = [[object objectForKey:@"electricity"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryAlarmCurrentResponse('%@',%d,%.2f)",deviceMac,result,electricity];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置功率告警值
- (void)settingAlarmPowerRequest:(NSDictionary *)object
{
    uint16_t power = (uint16_t)[[object objectForKey:@"power"] integerValue];
    NSString *mac = [object objectForKey:@"mac"];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x17;
    uint8_t big = power>>8;
    uint8_t small = power;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:big]];
    [data appendData:[self getData:small]];

    [self sendData:data mac:mac];;
}

#pragma mark 设置功率告警值返回
- (void)settingAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"settingAlarmPowerResponse..........设置功率告警值返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingAlarmPowerResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询功率告警值
- (void)queryAlarmPowerRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x19;
    
    NSMutableData *data = [[NSMutableData alloc] init];

    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];

    [self sendData:data mac:mac];;
}

#pragma mark 查询功率告警值返回
- (void)queryAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"queryAlarmPowerResponse..........查询功率告警值返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat power = [[object objectForKey:@"power"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryAlarmPowerResponse('%@',%d,%.2f)",deviceMac,result,power];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询温度单位
- (void)queryTemperatureUnitRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    
    //    uint8_t type= 0x04;
    uint8_t cmd = 0x1d;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendData:data mac:mac];;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self performSelector:@selector(queryTemperatureUnitRequest:) withObject:nil afterDelay:3];
    });
}

#pragma mark 查询温度单位返回
- (void)queryTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"queryTemperatureUnitResponse..........查询温度单位返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryTemperatureUnitResponse('%@',%d,%ld)",deviceMac,result,type];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}


#pragma mark 设置温度单位
- (void)settingTemperatureUnitRequest:(NSDictionary *)object
{
    uint8_t meter = (uint8_t)[[object objectForKey:@"type"] integerValue];
    NSString *mac = [object objectForKey:@"mac"];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x1b;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:meter]];
    
    [self sendData:data mac:mac];;
}

#pragma mark 设置温度单位返回
-(void)settingTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"settingTemperatureUnitResponse..........设置温度单位返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingTemperatureUnitResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置货币单位
- (void)settingMonetarytUnitRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t meter = (uint8_t)[[object objectForKey:@"type"] integerValue];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x1f;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:meter]];

    [self sendData:data mac:mac];;
}

#pragma mark 设置货币单位返回
- (void)settingMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac{
    DDLog(@"settingMonetarytUnitResponse..........设置货币单位返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingMonetarytUnitResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询货币单位
- (void)queryMonetarytUnitRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x21;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];

    [self sendData:data mac:mac];;
}

#pragma mark 查询货币单位返回
- (void)queryMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"queryMonetarytUnitResponse..........查询货币单位返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryMonetarytUnitResponse('%@',%d,%ld)",deviceMac,result,type];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置本地电价
- (void)settingLocalElectricityRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint16_t price = [[object objectForKey:@"num"]integerValue];

//    uint8_t type= 0x04;
    uint8_t cmd = 0x23;
    uint8_t big = (uint8_t)(price>>8);
    uint8_t small = (uint8_t)price;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:big]];
    [data appendData:[self getData:small]];
    
    [self sendData:data mac:mac];
}

#pragma mark 设置本地电价返回
- (void)settingLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac{
    DDLog(@"settingLocalElectricityResponse..........设置本地电价返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingLocalElectricityResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询本地电价
- (void)queryLocalElectricityRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];

    uint8_t cmd = 0x25;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];

    [self sendData:data mac:mac];;
}

#pragma mark 查询本地电价返回
- (void)queryLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"queryLocalElectricityResponse..........查询本地电价返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat price = [[object objectForKey:@"price"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryLocalElectricityResponse('%@',%d,%.2f)",deviceMac,result,price];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 恢复出厂设置
- (void)settingResumeSetupRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];

    uint8_t type= 0x01;
    uint8_t cmd = 0x27;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];

    [self sendData:data mac:mac];;
}

#pragma mark 恢复出厂设置返回
- (void)settingResumeSetupResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"settingResumeSetupResponse..........恢复出厂设置返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingResumeSetupResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 获取备份路径
- (void)BackupTimeAndDirectoryRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *root = [docu stringByAppendingPathComponent:mac];
    NSString *floder = [root stringByAppendingPathComponent:@"cacheData.txt"];
    long long time = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:floder]) {
        NSDate *data = [[[NSFileManager defaultManager] attributesOfItemAtPath:floder error:nil] objectForKey:NSFileModificationDate];
        time = [data timeIntervalSince1970]*1000;
    }
    NSString *jsonCode = [NSString stringWithFormat:@"BackupTimeAndDirectoryResponse('%@',%lld,'%@')",mac,time,floder];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 备份数据到手机
- (void)BackupDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *root = [docu stringByAppendingPathComponent:mac];
    if (![[NSFileManager defaultManager] fileExistsAtPath:root]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:root withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSString *floder = [root stringByAppendingPathComponent:@"cacheData.txt"];
    BOOL res = false;
    NSString *json = [object objectForKey:@"data"];
    if (json.length) {
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        res = [[NSFileManager defaultManager] createFileAtPath:floder contents:data attributes:nil];
    }
    NSString *jsonCode = [NSString stringWithFormat:@"BackupDataResponse('%@',%d,)",mac,res];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 从手机恢复备份数据
- (void)BackupRecoveryDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *root = [docu stringByAppendingPathComponent:mac];
    NSString *floder = [root stringByAppendingPathComponent:@"cacheData.txt"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:floder];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *json = [ToolHandle toJsonString:dic];
    
    NSString *jsonCode = [NSString stringWithFormat:@"BackupRecoveryDataResponse('%@','%@',)",mac,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询指示灯
- (void)indicatorLightStateRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type = 0x02;
    int8_t cmd = 0x3D;
    int8_t seq = 0xFF; //温度传感器
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:seq]];
    
    [self sendData:data mac:mac];
}

#pragma mark 控制指示灯
- (void)indicatorLightSwitchRequest:(NSDictionary *)object
{
    
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type = 0x02;
    int8_t cmd = 0x3B;
    int8_t seq = 0xFF; //温度传感器
    int8_t state = (int8_t)[object[@"state"] boolValue];
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:seq]];
    [data appendData:[self getData:state]];
    
    [self sendData:data mac:mac];
}

#pragma mark 查询指示灯返回
- (void)indicatorLightStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"state"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"indicatorLightStateResponse('%@',%d,)",deviceMac,state];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询设备标签
- (void)deviceLabelRequest:(NSDictionary *)object{
    
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type = 0x01;
    int8_t cmd = 0x43;
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendData:data mac:mac];
    
}

///查询设备标签 0x44
- (void)queryDeviceLabelResponse:(NSDictionary *)dict deviceMac:(NSString *)dviceMac{
    
    
    NSString *jsonCode = [NSString stringWithFormat:@"deviceLabelResponse('%@',)",dviceMac];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

#pragma mark 设置设备标签
- (void)setDeviceLabelRequest:(NSDictionary *)object{
    
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type = 0x02;
    int8_t cmd = 0x41;
    
    NSData *name = [object[@"label"] dataUsingEncoding:NSUTF8StringEncoding];
    name = [self replaceNoUtf8:name];
    NSString *nameStr = [NSString stringWithUTF8String:[name bytes]];
    if ([nameStr hasPrefix:@"*"]) {
        nameStr = [nameStr substringWithRange:NSMakeRange(1, nameStr.length-1)];
    }
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:name];
    
    [self sendData:data mac:mac];
    
}

///设置设备标签 0x42
- (void)settingDeviceLabelResponse:(NSDictionary *)dict deviceMac:(NSString *)dviceMac{
    
    NSString *jsonCode = [NSString stringWithFormat:@"setDeviceLabelResponse('%@',)",dviceMac];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

#pragma mark 消息组包发送
- (void)sendData:(NSMutableData *)data mac:(NSString *)mac
{
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:mac data:data];
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    __weak typeof(self) weakSelf = self;
    [self.funArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[weakSelf.web configuration].userContentController addScriptMessageHandler:self name:obj];
        [weakSelf.methodArr removeObject:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funDic.allKeys containsObject:message.name]) {
        SEL sel = NSSelectorFromString([self.funDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
            DDLog(@"%@...................................",message.name);
            [self performSelector:sel withObject:message.body];
            [[HandlingDataModel shareInstance] regegistDelegate:self];
        }
    }
}

- (NSData *)replaceNoUtf8:(NSData *)data
{
    char aa[] = {'*','*','*','*','*','*'};                      //utf8最多6个字符，当前方法未使用
    NSMutableData *md = [NSMutableData dataWithData:data];
    int loc = 0;
    while(loc < [md length])
    {
        char buffer;
        [md getBytes:&buffer range:NSMakeRange(loc, 1)];
        if((buffer & 0x80) == 0)
        {
            loc++;
            continue;
        }
        else if((buffer & 0xE0) == 0xC0)
        {
            loc++;
            if (loc>=data.length) {
                continue;
            }
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                continue;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else if((buffer & 0xF0) == 0xE0)
        {
            loc++;
            if (loc>=data.length) {
                continue;
            }
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                [md getBytes:&buffer range:NSMakeRange(loc, 1)];
                if((buffer & 0xC0) == 0x80)
                {
                    loc++;
                    continue;
                }
                loc--;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else
        {
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
    }
    
    return md;
}

@end
