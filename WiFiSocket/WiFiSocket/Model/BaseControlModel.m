//
//  BaseControlModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseControlModel.h"
#import "StoreLocal.h"
#import "QueryHistoryModel.h"
#import "BaseControlModel+ConstantTemperature.h"

@interface BaseControlModel ()<WKScriptMessageHandler>

@property (nonatomic, strong) NSMutableDictionary *reportDic;
@property (nonatomic, strong) NSMutableDictionary *temperAndHumiDic;
@property (nonatomic, strong) NSMutableDictionary *powerAndCostDic;

@property (nonatomic, strong) NSMutableArray *timerArr1;
@property (nonatomic, strong) NSMutableArray *timerArr2;

@property (nonatomic, copy) NSString *historyPath;

@property (nonatomic ,strong) NSDictionary *operationDic;

@end

@implementation BaseControlModel

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
        self.temperAndHumiDic = [[NSMutableDictionary alloc] init];
        [self.temperAndHumiDic setObject:@{
                                           @"currentValue": @(0),
                                           @"hotAlarmValue": @(0),
                                           @"hotAlarmSwitch": @(false),
                                           @"codeAlarmValue": @(0),
                                           @"codeAlarmSwitch": @(false)
                                           } forKey:@"temperature"];
        self.powerAndCostDic = [[NSMutableDictionary alloc] init];
        self.reportDic = [[NSMutableDictionary alloc] init];
        self.timerArr1 = [NSMutableArray array];
        self.timerArr2 = [NSMutableArray array];
        
    }
    return self;
}

- (NSArray *)funArr
{
    return @[
             @"setStatusBarRequest",
             @"socketStatusRequest", //插座状态数据
             @"powerSwitchStatusRequest", //插座电源开关状态
             @"powerSwitchRequest", //插座电源开关控制
             @"commonPatternListDataRequest", //定时列表数据
             @"commonPatternNewTimingRequest", //普通模式新建定时
             @"commonPatternEditTimingRequest", //普通模式编辑定时
             @"commonPatternDeleteTimingRequest", //删除定时
             @"countdownDataRequest", //倒计时页面数据
             @"powerSwitchCountdownRequest", //设置电源开关倒计时
             @"temperatureAndHumidityDataRequest", //温湿度页面数据
             @"alarmTemperatureValueRequest", //设置告警温度值
             @"alarmHumidityValueRequest", //设置告警湿度值
             @"spendingCountdownDataRequest",//查询定量定费
             @"spendingCountdownAlarmRequest",//设置定量定费
             @"queryElectricityByTimeRequest",//按时间查询已用电量电费请求
             @"alarmTimingAndTemperatureValueRequest",  //设置高级定时温度
             @"timingAndTemperatureDataRequest",    //定时温度列表数据
             @"temperatureSensorStateRequest",  //温度传感器状态查询
             @"selectSevenStatusRequest",       //查询插座7种状态请求
             @"timingConstTemperatureDataRequest",  //温度-恒温模式列表数据查询
             @"timingConstTemperatureDataSet",  //温度-恒温模式设置 新建/编辑
             @"timingConstTemperatureDataDelete",   //温度-恒温模式删除
             ];
}

- (NSDictionary *)funDic
{
    return @{
             @"setStatusBarRequest":@"setStatusBarRequest:",
             @"powerSwitchStatusRequest":@"powerSwitchStatusRequest:",//插座开关状态
             @"powerSwitchRequest":@"powerSwitchRequest:",//插座开关控制
             @"commonPatternListDataRequest":@"commonPatternListDataRequest:",//定时列表数据
             @"commonPatternNewTimingRequest":@"commonPatternNewTimingRequest:",//新建定时
             @"commonPatternEditTimingRequest":@"commonPatternEditTimingRequest:",//编辑定时
             @"commonPatternDeleteTimingRequest":@"commonPatternDeleteTimingRequest:",//删除定时
             @"countdownDataRequest":@"countdownDataRequest:",//倒计时页面数据
             @"temperatureAndHumidityDataRequest":@"temperatureAndHumidityDataRequest:",//查询定温湿度
             @"powerSwitchCountdownRequest":@"powerSwitchCountdownRequest:",//开关倒计时
             @"alarmTemperatureValueRequest":@"alarmTemperatureValueRequest:",//设置温度警告值
             @"alarmHumidityValueRequest":@"alarmHumidityValueRequest:",//设置湿度警告值
             @"spendingCountdownDataRequest":@"spendingCountdownDataRequest:",//查询定量定费
             @"spendingCountdownAlarmRequest":@"spendingCountdownAlarmRequest:",//设置定量定费
             @"queryElectricityByTimeRequest":@"queryElectricityByTimeRequest:",//按时间查询已用电量电费
             @"queryTemperatureUnitRequest":@"queryTemperatureUnitRequest:",//查询温度单位
             @"alarmTimingAndTemperatureValueRequest":@"alarmTimingAndTemperatureValueRequest:",  //设置高级定时温度
             @"timingAndTemperatureDataRequest":@"timingAndTemperatureDataRequest:",    //定时温度列表数据
             @"temperatureSensorStateRequest":@"temperatureSensorStateRequest:",  //温度传感器状态查询
             @"selectSevenStatusRequest":@"selectSevenStatusRequest:",  //查询插座7种状态请求
             @"timingConstTemperatureDataRequest":@"timingConstTemperatureDataRequest:",  //温度-恒温模式列表数据查询
             @"timingConstTemperatureDataSet":@"timingConstTemperatureDataSet:",  //温度-恒温模式设置 新建/编辑
             @"timingConstTemperatureDataDelete":@"timingConstTemperatureDataDelete:",   //温度-恒温模式删除
             };
}


- (void)setStatusBarRequest:(NSDictionary *)object
{
    
}

#pragma mark 状态界面数据

#pragma mark 请求插座实时状态数据
- (void)socketStatusRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    BOOL recevie = [[object objectForKey:@"receive"] boolValue];
    if (recevie) {
        NSDictionary *dic =[[NSDictionary alloc] initWithDictionary:[self.reportDic objectForKey:mac]];
        NSString *json = [ToolHandle toJsonString:dic];
        NSString *jsCode = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",mac,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 上报插座实时状态数据
- (void)ReportingRealTimeData:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{

    DDLog(@"上报温湿度电压电流功率数据........");
    NSMutableDictionary *muDic =[[NSMutableDictionary alloc] initWithDictionary:[self.reportDic objectForKey:deviceMac]];
    for (NSString *key in object.allKeys) {
        NSDictionary *dic = [object objectForKey:key];
        [muDic setObject:dic forKey:key];
    }
    [self.reportDic setValue:muDic forKey:deviceMac];
    NSString *json = [ToolHandle toJsonString:muDic];
    NSString *jsCode = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}


#pragma mark 插座继电器（开关）状态请求
- (void)powerWIFISwitchStatusRequest:(NSDictionary *)object
{
    
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type= 0x01;
    int8_t cmd = 0x37;

    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    
    [[UDPSocket shareInstance] sendDataWithoutConnect:data mac:mac];
    [[HandlingDataModel shareInstance] regegistDelegate:self];
}

#pragma mark 插座继电器（开关）控制
- (void)powerWIFISwitchRequest:(NSDictionary *)object
{
    BOOL state = [[object objectForKey:@"status"] boolValue];
    NSString *mac = [object objectForKey:@"mac"];

    int8_t type= 0x01;
    int8_t cmd = 0x35;
    int8_t mode = 0x01;
    int8_t relayswitch = (state == true)? 0x01:0x00;

    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:relayswitch]];

    [[UDPSocket shareInstance] sendDataWithoutConnect:data mac:mac];
    [[HandlingDataModel shareInstance] regegistDelegate:self];
}

#pragma mark 插座继电器（开关）状态请求
- (void)powerSwitchStatusRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type= 0x02;
    int8_t cmd = 0x0b;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    
    [self sendData:data mac:mac];
}

#pragma mark 插座继电器（开关）控制
- (void)powerSwitchRequest:(NSDictionary *)object
{
    BOOL state = [[object objectForKey:@"status"] boolValue];
    NSString *mac = [object objectForKey:@"mac"];
//    int8_t type= 0x01;
//    int8_t cmd = 0x35;
    int8_t type= 0x02;
    int8_t cmd = 0x01;
    int8_t mode = 0x01;
    int8_t relayswitch = (state == true)? 0x01:0x00;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:relayswitch]];

    [self sendData:data mac:mac];
}

#pragma mark 继电器控制返回
- (void)powerSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"state"] boolValue];
    
    DDLog(@"powerSwitchResponse..灯的开关状态...%d.....",state);
    
    NSString *jsCode = [[NSString alloc] initWithFormat:@"powerSwitchResponse('%@',%d)",deviceMac,state];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {

    }];
    
    NSString *jsCode1 = [[NSString alloc] initWithFormat:@"wifiPowerSwitchResponse('%@',%d)",deviceMac,state];
    [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
//    [StoreLocal storeLocalSevenState:PowerSwitchState Mac:deviceMac State:state];
    
    if (self.updateDeviceListSwitchStausHandler) {
        self.updateDeviceListSwitchStausHandler(@{@"switch":@(state),@"mac":deviceMac});
    }
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:object];
//    [dic setObject:deviceMac forKey:@"mac"];
//    [self temperatureAndHumidityDataRequest:dic];
    
}

#pragma mark 查询定时列表数据
- (void)commonPatternListDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t mode = (uint8_t)[[object objectForKey:@"mode"] integerValue];
    if (mode==0) {
        [self queryCommonPatternList:0x01 mac:mac];
//        [StoreLocal storeLocalSevenState:CommonState Mac:mac State:NO];
    }else{
        [self queryCommonPatternList:mode mac:mac];
//        [StoreLocal storeLocalSevenState:CommonState Mac:mac State:YES];
    }
    
}

- (void)queryCommonPatternList:(uint8_t)mode mac:(NSString *)mac
{
    
    int8_t type= 0x02;
    int8_t cmd = 0x13;
    
    NSLog(@"查询定时模式%d",mode);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
        
    [self sendData:data mac:mac];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        NSMutableData *data1 = [[NSMutableData alloc] init];
//        [data1 appendData:[self getData:type]];
//        [data1 appendData:[self getData:cmd]];
//        [data1 appendData:[self getData:0x02]];
//
//        [self sendData:data1 mac:mac];
//
//    });
    
}

#pragma mark 定时列表数据返回
- (void)commonPatternListDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"commonPatternListDataResponse..........定时列表数据返回");
    NSData *data = [object objectForKey:@"data"];
    uint8_t reserve = 8;
    uint8_t timeLoc = 3+reserve+2+1+1;
    NSMutableData *timeData = [NSMutableData data];
    [timeData appendData:[data subdataWithRange:NSMakeRange(timeLoc, data.length-timeLoc-2)]];
    Byte *byte = (Byte *)[timeData bytes];
    NSData *modelDa =  [data subdataWithRange:NSMakeRange(3+reserve+3, 1)];
    Byte model[1];
    [modelDa getBytes:&model length:1];
    
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    if (model[0] == 1) {
        NSInteger timeLength = 6;
        if (timeData.length>timeLength-1 && timeData.length%timeLength == 0) {
            NSInteger length = timeData.length/timeLength;
            for (NSInteger i= 0; i<length; i++) {
                NSInteger index = i*timeLength;
                NSInteger ID = byte[index];
                BOOL swit = (BOOL)byte[index+1];
                NSInteger week = byte[index+2];
                NSInteger hour = byte[index+3];
                NSInteger minute = byte[index+4];
                BOOL state = byte[index+5] == 0x01?true:false;
                NSString *time = [NSString stringWithFormat:@"%ld:%ld",hour,minute];
                NSDictionary *dic = @{
                                      @"switch":@(swit),
                                      @"time":time,
                                      @"id":@(ID),
                                      @"state":@(state),
                                      @"week":@(week),
                                      };
                [arr1 addObject:dic];
                self.timerArr1 = arr1;
            }
        }else{
            self.timerArr1 = [NSMutableArray array];
        }
    }else if (model[0] == 2){
        NSInteger timeLength = 12;
        if (timeData.length>timeLength-1 && timeData.length%timeLength == 0) {
            NSInteger length = timeData.length/timeLength;
            for (NSInteger i= 0; i<length; i++) {
                NSInteger index = i*timeLength;
                NSInteger ID = byte[index];
                NSInteger startHour = byte[index+1];
                NSInteger startMinute = byte[index+2];
                NSInteger endHour = byte[index+3];
                NSInteger endMinute = byte[index+4];
                BOOL firstSwitch = byte[index+5];
                NSInteger powerStartHour = byte[index+6];
                NSInteger powerStartMinute = byte[index+7];
                NSInteger powerEndHour = byte[index+8];
                NSInteger powerEndMinute = byte[index+9];
                BOOL state = byte[index+10] == 0x01?true:false;
                NSInteger week = byte[index+11];
                NSString *time = [NSString stringWithFormat:@"%ld:%ld",startHour,startMinute];
                NSString *time2 = [NSString stringWithFormat:@"%ld:%ld",endHour,endMinute];
                NSDictionary *dic = @{
                                      @"switch":@(firstSwitch),
                                      @"time":time,
                                      @"time2":time2,
                                      @"id":@(ID),
                                      @"state":@(state),
                                      @"week":@(week),
                                      @"onCycle":[NSString stringWithFormat:@"%ld:%ld",powerStartHour,powerStartMinute],
                                      @"offCycle":[NSString stringWithFormat:@"%ld:%ld",powerEndHour,powerEndMinute],
                                      };
                [arr2 addObject:dic];
                self.timerArr2 = arr2;
            }
        }else{
            self.timerArr2 = [NSMutableArray array];
        }
    }
    
    NSString *json = [ToolHandle toJsonString:self.timerArr1];
    NSString *json1 = [ToolHandle toJsonString:self.timerArr2];
    
    DDLog(@"普通模式 定时列表%@ ------ 进阶模式·定时列表%@",json,json1);
    
    NSString *jsCode = [NSString stringWithFormat:@"commonPatternListDataResponse('%@','%@','%@')",deviceMac,json,json1];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    if (!self.timerArr2.count && data.length>20) {
        DDLog(@"\n...........time2...................%ld",data.length);
    }
//    if (!self.timerArr1.count && data.length>20) {
//        DDLog(@"\n...........time...................%ld",data.length);
//    }
}

#pragma mark 新建定时
- (void)commonPatternNewTimingRequest:(NSDictionary *)object
{
    self.operationDic = [[NSDictionary alloc] initWithDictionary:object];
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x01];
}

#pragma mark 编辑定时
- (void)commonPatternEditTimingRequest:(NSDictionary *)object
{
     self.operationDic = [[NSDictionary alloc] initWithDictionary:object];
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x01];
}

#pragma mark 删除定时
- (void)commonPatternDeleteTimingRequest:(NSDictionary *)object
{
     self.operationDic = [[NSDictionary alloc] initWithDictionary:object];
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x02];
}

-  (void)timingOperation:(NSDictionary *)object mode:(int8_t)mode confirm:(int8_t)confirm
{
    if (mode == 0x01) {
        NSString *mac = [object objectForKey:@"mac"];
        NSString *time = [[object objectForKey:@"time"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *times = [time componentsSeparatedByString:@":"];
        NSInteger ids = [[object objectForKey:@"ID"] integerValue];
        
        int8_t type= 0x02;
        int8_t cmd = 0x05;
        //    int8_t mode = 0x01;//0x01普通 0x02 进阶
        int8_t ID = (int8_t)(ids==0?0xff:ids);//定时唯一标识
        //    int8_t state = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;//0x01启动 0x02结束
        int8_t switc = [[object objectForKey:@"switchtab"] boolValue] ? 0x01 : 0x00;//开机关机
        int8_t weak= (int8_t)[[object objectForKey:@"week"] intValue];
        int8_t hour = (int8_t)[[times firstObject] intValue];
        int8_t minute = (int8_t)[[times lastObject] intValue];
        int8_t confirma  = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;
        
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:[self getData:type]];
        [data appendData:[self getData:cmd]];
        [data appendData:[self getData:mode]];
        [data appendData:[self getData:ID]];
        [data appendData:[self getData:confirm]];
        [data appendData:[self getData:switc]];
        [data appendData:[self getData:weak]];
        [data appendData:[self getData:hour]];
        [data appendData:[self getData:minute]];
        [data appendData:[self getData:confirma]];
        
        [self sendData:data mac:mac];;
    }else if (mode == 0x02){
        NSString *mac = [object objectForKey:@"mac"];
        NSString *time = [[object objectForKey:@"time"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *times = [time componentsSeparatedByString:@":"];
        NSInteger ids = [[object objectForKey:@"ID"] integerValue];
        NSString *time2 = [[object objectForKey:@"endtime"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *times2 = [time2 componentsSeparatedByString:@":"];
//        NSString *ontime = [[object objectForKey:@"onTime"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *ontime = [@"0 : 0" stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *ontimes = [ontime componentsSeparatedByString:@":"];
        NSString *offtime = [[object objectForKey:@"offTime"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *offtimes = [offtime componentsSeparatedByString:@":"];
//
        int8_t type= 0x02;
        int8_t cmd = 0x05;
        //    int8_t mode = 0x01;//0x01普通 0x02 进阶
        int8_t ID = (int8_t)(ids==0?0xff:ids);//定时唯一标识
        //    int8_t state = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;//0x01启动 0x02结束
        int8_t switc = [[object objectForKey:@"switchtab"] boolValue] ? 0x01 : 0x00;//开机关机
        int8_t weak= (int8_t)[[object objectForKey:@"week"] intValue];
        int8_t confirma  = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;
        
        uint8_t startHour = [[times firstObject] integerValue];
        uint8_t startminute = [[times lastObject] integerValue];
        uint8_t endHour= [[times2 firstObject] integerValue];
        uint8_t endMinute = [[times2 lastObject] integerValue];
        
        uint8_t ontimeHour = [[ontimes firstObject] integerValue];
        uint8_t ontimeMinute = [[ontimes lastObject] integerValue];
        
        uint8_t offtimeHour = [[offtimes firstObject] integerValue];
        uint8_t offtimeMinute = [[offtimes lastObject] integerValue];
        
        
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:[self getData:type]];
        [data appendData:[self getData:cmd]];
        [data appendData:[self getData:mode]];
        [data appendData:[self getData:ID]];
        [data appendData:[self getData:confirm]];
        [data appendData:[self getData:startHour]];
        [data appendData:[self getData:startminute]];
        [data appendData:[self getData:endHour]];
        [data appendData:[self getData:endMinute]];
        [data appendData:[self getData:switc]];
        [data appendData:[self getData:ontimeHour]];
        [data appendData:[self getData:ontimeMinute]];
        [data appendData:[self getData:offtimeHour]];
        [data appendData:[self getData:offtimeMinute]];
        [data appendData:[self getData:confirma]];
        [data appendData:[self getData:weak]];
        
        [self sendData:data mac:mac];
    }

}

#pragma mark 新建/编辑/删除定时操作返回
- (void)commonPatternTimingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"commonPatternTimingResponse..........定时操作返回");
    BOOL state = [[object objectForKey:@"result"] boolValue];
    BOOL switchBool = [self.operationDic[@"state"] integerValue];
    NSInteger idInteger = [self.operationDic[@"ID"] integerValue];
    NSInteger modeInteger = [self.operationDic[@"mode"] integerValue];
    
    NSString *jsCode = [NSString stringWithFormat:@"commonPatternTimingResponse('%@',%d,%d,%ld,%ld)",deviceMac,state,switchBool,(long)idInteger,modeInteger];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 上报定时结束
- (void)reportendoftime:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    [self powerSwitchStatusRequest:@{@"mac":deviceMac}];
    [self commonPatternListDataRequest:@{@"mac":deviceMac}];
    DDLog(@"reportendoftime..........上报定时结束返回");
    NSString *jsCode = [[NSString alloc] initWithFormat:@"powerSwitchResponse('%@',%d)",deviceMac,[[object objectForKey:@"state"] boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 倒计时页面数据
- (void)countdownDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x0d;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];

    [self sendData:data mac:mac];;
}

#pragma mark 倒计时页面数据返回
- (void)CountdownResult:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    
    BOOL state = [object[@"state"] integerValue] == 1?true :false;
    BOOL switc = [object[@"switch"] integerValue] == 1? true :false;
    BOOL update = [object[@"updateSwitch"] boolValue];
    NSInteger hour = [object[@"hour"] integerValue];
    NSInteger mintute = [object[@"minute"] integerValue];
    NSInteger allTime = [object[@"realHour"] integerValue];
    NSInteger seconds = [object[@"seconds"] integerValue];
    
    if (allTime > 0) {
        allTime = allTime * 60;
    }else{
        allTime = [object[@"realMinute"] integerValue];
    }
    
//    if (allTime == 0 && seconds == 0 && hour == 0 && mintute == 0) {
//        state = false;
//    }
    
    NSDictionary *dic = @{
                          @"hour":@(hour),
                          @"minute":@(mintute),
                          @"Switchgear":@(switc),//开关机
                          @"countdownSwitch":@(state),//启动结束
                          @"allTime":@(allTime),
                          @"seconds":@(seconds)
                          };
    if (state == false && update) {
        [self powerSwitchStatusRequest:@{@"mac":deviceMac}];
    }
    
    DDLog(@"countdownDataResponse..........倒计时返回  ---- dict %@",dic);
    
    NSString *json = [ToolHandle toJsonString:dic];
    NSString *jsonCode = [NSString stringWithFormat:@"countdownDataResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    NSMutableDictionary *muDic =[[NSMutableDictionary alloc] initWithDictionary:[self.reportDic objectForKey:deviceMac]];
    [muDic setObject:@((hour*60+mintute)*60*1000) forKey:@"time"];
    [self.reportDic setValue:muDic forKey:deviceMac];
    NSString *json1 = [ToolHandle toJsonString:muDic];
    NSString *jsCode1 = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",deviceMac,json1];
    [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置电源开关倒计时
- (void)powerSwitchCountdownRequest:(NSDictionary *)object
{
    BOOL state = [[object objectForKey:@"state"] boolValue];    //启动结束
    BOOL swit = [[object objectForKey:@"Switchgear"] boolValue]; //开机关机
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x07;
    int8_t confirm = (state == true)? 0x01:0x02;
    int8_t switchs = (swit == true)? 0x01:0x00;
    int8_t hour = (int8_t)[[object objectForKey:@"hour"] integerValue];
    int8_t minute = (int8_t)[[object objectForKey:@"minute"] integerValue];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:switchs]];
    [data appendData:[self getData:hour]];
    [data appendData:[self getData:minute]];

    [self sendData:data mac:mac];;
    
//    [self performSelector:@selector(countdownDataRequest:) withObject:object afterDelay:0.5];
}

#pragma mark  设置电源开关倒计时返回
- (void)powerSwitchCountdownResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"powerSwitchCountdownResponse..........电源开关返回");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    BOOL state = [[object objectForKey:@"state"] boolValue];
    BOOL switc = [[object objectForKey:@"switch"] boolValue];
    NSString *jsCode = [NSString stringWithFormat:@"powerSwitchCountdownResponse('%@','%d','%d')",deviceMac,state,result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    if (state == false) {
        // 上报倒计时结束
        NSDictionary *dic = @{
                              @"hour":@(0),
                              @"minute":@(0),
                              @"Switchgear":@(switc),//开关机
                              @"countdownSwitch":@(false),//启动结束
                              @"allTime":@(0),
                              };
        NSString *json = [ToolHandle toJsonString:dic];
        NSString *jsonCode = [NSString stringWithFormat:@"countdownDataResponse('%@','%@')",deviceMac,json];
        [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
    
}

#pragma mark 设置定时告警温度
- (void)alarmTimingAndTemperatureValueRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSArray *stimeArr = [object[@"stime"] componentsSeparatedByString:@":"];
    NSArray *etimeArr = [object[@"etime"] componentsSeparatedByString:@":"];
    
    
    int8_t type= 0x02;
    int8_t cmd = 0x2B;
//    int8_t model = 0x01 ;  //温度湿度
    int8_t ID = [[object objectForKey:@"ID"] intValue];
    int8_t save = [[object objectForKey:@"state"] intValue] == 1?0x01:0x02;
    int8_t startHour = [stimeArr[0] intValue];
    int8_t startMinute = [stimeArr[1] intValue];
    int8_t endHour = [etimeArr[0] intValue];
    int8_t endMinute = [etimeArr[1] intValue];
    int8_t firstSwitch = [[object objectForKey:@"switch"] boolValue];
    int8_t switchStartHour = 0;
    int8_t switchStartMinute = 0;
    int8_t switchEndHour = 0;
    int8_t switchEndMinute = 0;
    int8_t confrim = [[object objectForKey:@"state"] boolValue];
    int8_t week = [[object objectForKey:@"week"] intValue];
    int8_t value = [[object objectForKey:@"alarmValue"] intValue];
    int8_t model2 = [[object objectForKey:@"mode"] intValue];;  //制冷制热
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    [data appendData:[self getData:ID]];
    [data appendData:[self getData:save]];
    [data appendData:[self getData:startHour]];
    [data appendData:[self getData:startMinute]];
    [data appendData:[self getData:endHour]];
    [data appendData:[self getData:endMinute]];
    [data appendData:[self getData:firstSwitch]];
    [data appendData:[self getData:switchStartHour]];
    [data appendData:[self getData:switchStartMinute]];
    [data appendData:[self getData:switchEndHour]];
    [data appendData:[self getData:switchEndMinute]];
    [data appendData:[self getData:confrim]];
    [data appendData:[self getData:week]];
    [data appendData:[self getData:value]];
    [data appendData:[self getData:model2]];
    
    [self sendData:data mac:mac];;
}

#pragma mark 设置定时告警温度返回
- (void)alarmTimerAndTemperatureValueResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
 
    NSString *jsCode = [NSString stringWithFormat:@"alarmTimerAndTemperatureValueResponse('%@',%d,%d,%d)",deviceMac,[object[@"state"]boolValue],[object[@"mode"]intValue],[object[@"result"]boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询高级定时温度数据
- (void)timingAndTemperatureDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x2D;
    int8_t mode = [[object objectForKey:@"mode"] intValue];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    [data appendData:[self getData:mode]];
    
    [self sendData:data mac:mac];;
}

#pragma mark 查询定时温度列表数据返回
- (void)timingAndTemperatureDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSData *data = [object objectForKey:@"data"];
    NSUInteger resever = 3+8+2+1+2;
    if (data.length<resever+2) {
        return;
    }
    NSInteger mode = ((Byte *)[[data subdataWithRange:NSMakeRange(resever, 1)] bytes])[0];
    NSMutableData *listData = [[NSMutableData alloc]init];
    [listData appendData:[data subdataWithRange:NSMakeRange(resever, data.length-resever-2)]];
    Byte *listByte = (Byte *)[listData bytes];
    NSInteger len = 16;
    NSMutableArray *arr = [NSMutableArray array];
    if (listData.length%len == 0) {
        for (NSInteger i=0; i<listData.length/len; i++) {
            int8_t ID = listByte[i*len+1];
            int8_t save = listByte[i*len+2];
            int8_t startHour = listByte[i*len+3];
            int8_t startMinute = listByte[i*len+4];
            int8_t endHour = listByte[i*len+5];
            int8_t endMinute = listByte[i*len+6];
            int8_t firstSwitch = listByte[i*len+7];
            int8_t switchStartHour = listByte[i*len+8];
            int8_t switchStartMinute = listByte[i*len+9];
            int8_t switchEndHour = listByte[i*len+10];
            int8_t switchEndMinute = listByte[i*len+11];
            BOOL confrim = listByte[i*len+12] == 0x01?true:false;
            int8_t week = listByte[i*len+13];
            int8_t value = listByte[i*len+14];
            int8_t model2 = listByte[i*len+15];
            
            NSDictionary *dic = @{
                                  @"time": [NSString stringWithFormat:@"%d:%d",startHour,startMinute],
                                  @"time2": [NSString stringWithFormat:@"%d:%d",endHour,endMinute],
                                  @"id": @(ID), // day  2 night
                                  @"state": @(confrim), //  true启动
                                  @"week": @(week),   // 10进制转换成二进制00000101表示
                                  // 周三、周一
                                  @"onCycle": [NSString stringWithFormat:@"%d:%d",switchStartHour,switchStartMinute], // 开机时间间隔
                                  @"offCycle": [NSString stringWithFormat:@"%d:%d",switchEndHour,switchEndMinute],
                                  @"alarmValue": @(value), // 目标温度
                                  @"currentValue": @(20), // 实时温度,
                                  @"model": @(model2) // 制热 2 制冷
                                  };
            [arr addObject:dic];
        }
    }
    NSString *json = [ToolHandle toJsonString:arr];
    NSString *jsCode = [NSString stringWithFormat:@"timingAndTemperatureDataResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询定温湿度值
- (void)temperatureAndHumidityDataRequest:(NSDictionary *)object
{
    [self queryTemperatureValueAndHumidityValue:0x01 object:object];
    [self queryTemperatureValueAndHumidityValue:0x02 object:object];
}

- (void)queryTemperatureValueAndHumidityValue:(int8_t)switchs object:(NSDictionary *)object
{
    DDLog(@"queryTemperatureValueAndHumidityValue..........");
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x11;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    [data appendData:[self getData:switchs]];

    [self sendData:data mac:mac];;
}

#pragma mark 查询定温湿度结果回调
- (void)temperatureAndHumidityDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
//    DDLog(@"temperatureAndHumidityDataResponse..........查询定温湿度返回");
    NSInteger model = [[object objectForKey:@"mode"] integerValue];
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    if (model == 1) {
        NSMutableDictionary *temp;
        if (self.temperAndHumiDic.allKeys.count) {
            temp  = [NSMutableDictionary dictionaryWithDictionary:[self.temperAndHumiDic objectForKey:@"temperature"] ];
        }else{
            temp = [[NSMutableDictionary alloc] init];
        }
        if (type == 1) {
            
            [temp setObject:@([object[@"currentValue"] floatValue]) forKey:@"currentValue"];
            
            if ([object objectForKey:@"state"]) {
                
                [temp setObject:@([object[@"state"] boolValue]) forKey:@"hotAlarmSwitch"];
                [QXUserDefaults setObject:@([object[@"state"] boolValue]) forKey:HotAlarmSwitch];
                
            }else{
                
                if (![QXUserDefaults objectForKey:HotAlarmSwitch]) {
                    [temp setObject:@([object[@"state"] boolValue]) forKey:@"hotAlarmSwitch"];
                    [QXUserDefaults setObject:@([object[@"state"] boolValue]) forKey:HotAlarmSwitch];
                }else{
                    [temp setObject:[QXUserDefaults objectForKey:HotAlarmSwitch] forKey:@"hotAlarmSwitch"];
                }
                
            }

            if ([QXUserDefaults objectForKey:HotAlarmValue] != nil) {
                [temp setObject:[QXUserDefaults objectForKey:HotAlarmValue] forKey:@"hotAlarmValue"];
            }else{
                [temp setObject:@([object[@"alarmValue"] floatValue]) forKey:@"hotAlarmValue"];
            }
            
        }else{
            
            [temp setObject:@([object[@"currentValue"] floatValue])  forKey:@"currentValue"];
            [temp setObject:@([object[@"state"] boolValue]) forKey:@"codeAlarmSwitch"];
            
            if ([object objectForKey:@"state"]) {
                
                [temp setObject:@([object[@"state"] boolValue]) forKey:@"codeAlarmSwitch"];
                [QXUserDefaults setObject:@([object[@"state"] boolValue]) forKey:CodeAlarmSwitch];
                
            }else{
                
                if (![QXUserDefaults objectForKey:CodeAlarmSwitch]) {
                    [temp setObject:@([object[@"state"] boolValue]) forKey:@"codeAlarmSwitch"];
                    [QXUserDefaults setObject:@([object[@"state"] boolValue]) forKey:CodeAlarmSwitch];
                }else{
                    [temp setObject:[QXUserDefaults objectForKey:CodeAlarmSwitch] forKey:@"codeAlarmSwitch"];
                }
                
            }
            
            if ([QXUserDefaults objectForKey:CodeAlarmValue] != nil) {
                [temp setObject:[QXUserDefaults objectForKey:CodeAlarmValue] forKey:@"codeAlarmValue"];
            }else{
                [temp setObject:@([object[@"alarmValue"] floatValue]) forKey:@"codeAlarmValue"];
            }
            
        }
        [self.temperAndHumiDic setObject:temp forKey:@"temperature"];
        
    }else{
        [self.temperAndHumiDic setObject:@{
                                           @"currentValue":@([object[@"currentValue"] floatValue]) ,
                                           @"alarmValue":@([object[@"alarmValue"] floatValue]),
                                           @"alarmSwitch":@([object[@"state"]boolValue]),
                                           } forKey:@"humidity"];
    }
    
    NSString *json = [ToolHandle toJsonString:self.temperAndHumiDic];
    NSString *jsonCode = [NSString stringWithFormat:@"temperatureAndHumidityDataResponse('%@','%@')",deviceMac,json];
    NSLog(@"temperatureAndHumidityDataResponse --- %@",jsonCode);
    DDLog(@"temperatureAndHumidityDataResponse..........查询定温湿度返回 %@",object);
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];

}

#pragma mark 设置告警温度值
- (void)alarmTemperatureValueRequest:(NSDictionary *)object
{
    [self alarmHumidityAndTemperatureValueRequest:object mode:0x01];
}
#pragma mark 设置告警湿度值
- (void)alarmHumidityValueRequest:(NSDictionary *)object
{
//        [self alarmHumidityAndTemperatureValueRequest:object mode:0x02];
}

- (void)alarmHumidityAndTemperatureValueRequest:(NSDictionary *)object mode:(int8_t)mode
{
    
    NSString *mac = [object objectForKey:@"mac"];
    BOOL state = [[object objectForKey:@"state"] boolValue];
    NSInteger temp = [[object objectForKey:@"alarmValue"] floatValue]*100;
    
    if ([[object objectForKey:@"mode"] integerValue] == 1) {
        [QXUserDefaults setObject:@([[object objectForKey:@"alarmValue"] floatValue]) forKey:HotAlarmValue];
    }else if ([[object objectForKey:@"mode"] integerValue] == 2){
        [QXUserDefaults setObject:@([[object objectForKey:@"alarmValue"] floatValue]) forKey:CodeAlarmValue];
    }
    
//    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:[self.temperAndHumiDic objectForKey:@"temperature"] ];
    
//    if ([object[@"mode"] integerValue] == 1) {
//        [tempDict setObject:@([object[@"alarmValue"] floatValue]) forKey:@"hotAlarmValue"];
//    }else{
//        [tempDict setObject:@([object[@"alarmValue"] floatValue]) forKey:@"codeAlarmValue"];
//    }
//
//    [self.temperAndHumiDic setObject:tempDict forKey:@"temperature"];
    
    int8_t type = 0x02;
    int8_t cmd = 0x09;
    int8_t confirm = (state == true)? 0x01:0x02;
    int8_t switc = (int8_t)[[object objectForKey:@"mode"] integerValue];//0x01 0x02(上下限)
    int8_t temp_int = (int8_t)(temp/100);
    int8_t temp_deci = (int8_t)(temp%100);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:switc]];
    [data appendData:[self getData:temp_int]];
    [data appendData:[self getData:temp_deci]];
    
    [self sendData:data mac:mac];
    
}

#pragma mark 设置告警温度值返回
- (void)alarmTemperatureValueResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"alarmTemperatureValueResponse..........设置告警温湿度返回");
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    NSInteger mode = [[object objectForKey:@"mode"] integerValue];
    BOOL result = [[object objectForKey:@"result"] boolValue];
    BOOL state = ([[object objectForKey:@"state"] integerValue] == 1)?true:false;
    NSString *jsCode;
    if (mode == 1) {
        //温度
        jsCode = [NSString stringWithFormat:@"alarmTemperatureValueResponse('%@',%d,%ld,%d)",deviceMac,state,type,result];
        
        NSMutableDictionary *temp;
        if (self.temperAndHumiDic.allKeys.count) {
            temp  = [NSMutableDictionary dictionaryWithDictionary:[self.temperAndHumiDic objectForKey:@"temperature"] ];
        }else{
            temp = [[NSMutableDictionary alloc] init];
        }
        if (type == 1) {
            [temp setObject:@(state) forKey:@"hotAlarmSwitch"];
        }else{
            [temp setObject:@(state) forKey:@"codeAlarmSwitch"];
        }
        [self.temperAndHumiDic setObject:temp forKey:@"temperature"];
        
    }else if (mode == 2){
        //湿度
        jsCode = [NSString stringWithFormat:@"alarmHumidityValueResponse('%@',%d,%d)",deviceMac,state,result];
    }
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    [self temperatureAndHumidityDataRequest:@{@"mac":deviceMac}];
}

#pragma mark 定量定费查询
- (void)spendingCountdownDataRequest:(NSDictionary *)object
{
    [self spendingCountdownDataRequest:object model:0x01];
    [self spendingCountdownDataRequest:object model:0x02];
}
- (void)spendingCountdownDataRequest:(NSDictionary *)object model:(int8_t)mode
{

    int8_t type= 0x02;
    int8_t cmd = 0x17;
    
    NSMutableData *data = [[NSMutableData alloc] init];

    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];
}

#pragma mark 查询定电定费返回
- (void)spendingCountdownDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"spendingCountdownDataResponse................查询定电定费返回");
    Byte *byte = (Byte *)[[object objectForKey:@"data"] bytes];
    uint8_t reserve = 8;
    uint8_t resultLoc = 3+reserve+2;
    BOOL result = !byte[resultLoc];
    BOOL confirm = byte[resultLoc+1] == 0x01 ? true : false;
    NSInteger mode = (NSInteger)byte[resultLoc+2];
    NSInteger year = byte[resultLoc+3] + 2000;
    NSInteger month = byte[resultLoc+4];
    NSInteger day = byte[resultLoc+5];
    uint32_t jing = (byte[resultLoc + 6]<<24) | (byte[resultLoc + 7]<<16) | (byte[resultLoc + 8]<<8) | byte[resultLoc + 9];
    uint32_t use = (byte[resultLoc + 10]<<24) | (byte[resultLoc + 11]<<16) | (byte[resultLoc + 12]<<8) | byte[resultLoc + 13];
    
    NSDictionary *dic = @{
                          @"currentValue": @(use),
                          @"alarmValue": @(jing),
                          @"alarmSwitch": @(confirm),
                          @"year": @(year),
                          @"month": @(month),
                          @"day": @(day)
                          };
    if (mode == 1) {
        [self.powerAndCostDic setObject:dic forKey:@"power"];
    }else{
        [self.powerAndCostDic setObject:dic forKey:@"cost"];
    }
    NSString *json = [ToolHandle toJsonString:self.powerAndCostDic];
    NSString *jsonCode = [NSString stringWithFormat:@"spendingCountdownDataResponse('%@',%d,'%@')",deviceMac,result,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置定电定费
- (void)spendingCountdownAlarmRequest:(NSDictionary *)object
{
//    uint16_t alarm = [[object objectForKey:@"alarmValue"]integerValue] / 1000;

    uint32_t alarm = [[object objectForKey:@"alarmValue"] intValue];
    
    int8_t type= 0x02;
    int8_t cmd = 0x15;
    int8_t confirm = [[object objectForKey:@"alarmSwitch"]boolValue] == true? 0x01:0x02;
    int8_t mode = (int8_t)[[object objectForKey:@"mode"]integerValue];
    int8_t year = (int8_t)([[object objectForKey:@"year"]integerValue] - 2000);
    int8_t month = (int8_t)[[object objectForKey:@"month"]integerValue];
    int8_t day = (int8_t)[[object objectForKey:@"day"]integerValue];
    int8_t jing = (int8_t)(alarm >> 24);
    int8_t jing1 = (int8_t)(alarm >> 16);
    int8_t jing2 = (int8_t)(alarm >> 8);
    int8_t jing3 = (int8_t)(alarm);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:year]];
    [data appendData:[self getData:month]];
    [data appendData:[self getData:day]];
    [data appendData:[self getData:jing]];
    [data appendData:[self getData:jing1]];
    [data appendData:[self getData:jing2]];
    [data appendData:[self getData:jing3]];
    
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置定电定费返回
-(void)spendingCountdownAlarmResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"spendingCountdownAlarmResponse...................设置定电定费返回");
    BOOL result = [[object objectForKey:@"result"]boolValue];
    BOOL state = [[object objectForKey:@"state"]integerValue] == 1?true:false;
    NSInteger mode = [[object objectForKey:@"mode"]integerValue];
    NSString *jsonCode = [NSString stringWithFormat:@"spendingCountdownAlarmResponse('%@',%ld,%d,%d)",deviceMac,mode,state,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    [self spendingCountdownDataRequest:@{@"mac":deviceMac}];
}

#pragma mark 按时间查询已用电量电费请求
- (void)queryElectricityByTimeRequest:(NSDictionary *)object{
    
    NSString *startTime = [NSString stringWithFormat:@"%@/%@/%@",object[@"y"],object[@"m"],object[@"d"]];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];//创建一个日期格式化器
    int days = 1;    // n天后的天数
    NSTimeInterval oneDay = 24 * 60 * 60;  // 一天一共有多少秒
    date = [date initWithTimeIntervalSinceNow: (oneDay * days)];
    dateFormatter.dateFormat = @"yyyy-MM-dd";//指定转date得日期格式化形式
    
    NSString *endTime = [dateFormatter stringFromDate:date];
    endTime = [endTime stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
    NSDictionary *dict = @{@"endTime":endTime,
                           @"interval":@"99",
                           @"mac":object[@"mac"],
                           @"startTime":startTime,
                           @"mode":object[@"mode"]
                           };
    
    [[QueryHistoryModel shareInstance] deviceHistoryDataRequest:dict];
    
}

//#pragma mark 按时间查询已用电量电费返回
//- (void)queryElectricityByTimeResponse:(NSDictionary *)object dviceMac:(NSString *)deviceMac{
//
//}

#pragma mark 温度传感器查询
- (void)temperatureSensorStateRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type = 0x02;
    int8_t cmd = 0x39;
    int8_t mode = 0x01; //0X01温度传感器 0X02电量传感器 0X03蓝牙设备
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    
    [self sendData:data mac:mac];
}

#pragma mark 温度传感器查询返回
- (void)temperatureSensorStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"status"] integerValue] == 1?true:false;
    NSString *jsonCode = [NSString stringWithFormat:@"temperatureSensorStateResponse('%@',%d)",deviceMac,state];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    if (!state) {
        [self addLocalNotificationForOldVersion];
    }
}

#pragma mark 温度传感器上报返回
- (void)temperatureSensorReportStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"status"] integerValue] == 1?true:false;
    NSString *jsonCode = [NSString stringWithFormat:@"temperatureSensorReportStateResponse('%@',%d)",deviceMac,state];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    if (!state) {
        [self addLocalNotificationForOldVersion];
    }
}

- (void)addLocalNotificationForOldVersion {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *lan ;
    
    if ([defaults objectForKey:LangauageType]) {
        lan = [defaults objectForKey:LangauageType];
    }else{
        NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
        NSString * preferredLang = [allLanguages objectAtIndex:0];
        if ([preferredLang hasPrefix:@"zh"]) {
            lan = @"zh";
        }else{
            lan = @"en";
        }
    }
    
    NSString *title;
    NSString *subTitle;
    if ([lan isEqualToString:@"zh"]) {
        title = @"温度检测异常！";
        subTitle = @"请确保温度传感器已正确插入！";
    }else{
        title = @"Abnormal temperature detection";
        subTitle = @"Please make sure temperature sensor is properly plugged on";
    }
    
    if (@available(iOS 10.0, *)) {
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        center.delegate = self;
//        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//        content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
//        content.body = [NSString localizedUserNotificationStringForKey:subTitle arguments:nil];
//        content.sound = [UNNotificationSound defaultSound];
//
//        //    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alertTime repeats:NO];
//        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"OXNotification" content:content trigger:nil];
//        
//        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
//            NSLog(@"成功添加推送");
//        }];
        
    } else {
        
        //        定义本地通知对象
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        //设置调用时间
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        notification.repeatInterval = 0;
        notification.repeatCalendar=[NSCalendar currentCalendar];
        
        //设置通知属性
        notification.alertBody = subTitle;
        notification.applicationIconBadgeNumber += 1;
        notification.alertAction = @"打开应用";
        notification.alertLaunchImage = @"Default";
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        //调用通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark 查询插座7种状态请求
- (void)selectSevenStatusRequest:(NSDictionary *)dict{
    
    NSString *mac = [dict objectForKey:@"mac"];
    int8_t type = 0x02;
    int8_t cmd = 0x3F;
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendData:data mac:mac];
    
}

#pragma mark 查询插座7种状态返回
- (void)selectSevenStatusResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac
{
 
    NSString *json = [ToolHandle toJsonString:dict];
    NSString *jsonCode = [NSString stringWithFormat:@"selectSevenStatusResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

#pragma rmark 消息组包发送
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
        SEL sel = NSSelectorFromString(self.funDic[message.name]);
        if ([self respondsToSelector:sel]) {
            DDLog(@"%@...................................",message.name);
            [[HandlingDataModel shareInstance] regegistDelegate:self];
            [self performSelector:sel withObject:message.body];
        }
    }
}

@end
