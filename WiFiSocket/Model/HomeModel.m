//
//  WiFiModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/1.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "HomeModel.h"
#import "UDPSocket.h"

//typedef NS_ENUM(NSInteger,WiFiLoginType){
//  phoneLogin = 0,
//  emailLogin = 1,
//};

@interface HomeModel ()<WKScriptMessageHandler,StartaiClientDelegate>

@property (nonatomic, strong) UDPSocket *udpSocket;
@property (nonatomic, strong) NSMutableArray *deviceArr;
@property (nonatomic, strong) NSMutableDictionary *deviceDic;
@property (nonatomic, strong) NSMutableArray *lanArr;


@property (nonatomic, copy) NSString *json;
@end

@implementation HomeModel

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
        _deviceDic = [[NSMutableDictionary alloc] init];
        _deviceArr = [NSMutableArray array];
        _lanArr = [NSMutableArray array];
    }
    return self;
}

-(NSArray *)funcArr
{
    return @[
             @"errorHandlerRequest",
             @"systemLanguageRequest",           //查询系统语言
             @"setSystemLanguageRequest",        //设置系统语言
             @"deviceListRequest",               //获取设备列表
             @"controlDeviceRequest",             //进入设备控制界面
             @"relieveControlDeviceRequest",        //解除设备控制
             @"unbundlingDeviceRequest",           //解绑设备
             @"wifiPowerSwitchRequest",            //设备列表界面开关控制
             @"wifiPowerSwitchStatusRequest",       //设备列表界面开关状态查询
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"errorHandlerRequest":@"errorHandlerRequest:",//报错警告
             @"systemLanguageRequest":@"systemLanguageRequest:",    //查询系统语言
             @"setSystemLanguageRequest":@"setSystemLanguageRequest:", //设置系统语言
             @"deviceListRequest":@"deviceListRequest:",    ///获取设备列表
             @"controlDeviceRequest":@"controlDeviceRequest:",  //进入设备控制界面
             @"relieveControlDeviceRequest":@"relieveControlDeviceRequest:",        //解除设备控制
             @"unbundlingDeviceRequest":@"unbundlingDeviceRequest:",            //解绑设备
             @"wifiPowerSwitchRequest":@"wifiPowerSwitchRequest:",            //设备列表界面开关控制
             @"wifiPowerSwitchStatusRequest":@"wifiPowerSwitchStatusRequest:",       //设备列表界面开关状态查询
             };
}

#pragma mark 捕获异常
- (void)errorHandlerRequest:(NSDictionary *)object
{
    DDLog(@"................error.............>%@",object);
}

#pragma mark 获取当前语言
- (void)systemLanguageRequest:(NSDictionary *)object
{
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

    NSString *jsCode = [NSString stringWithFormat:@"systemLanguageResponse('%@')",lan];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

#pragma mark 设置当前语言
- (void)setSystemLanguageRequest:(NSDictionary *)object
{
    NSString *language;
    language = [object objectForKey:@"language"];
    if (language.length) {
        [[NSUserDefaults standardUserDefaults] setObject:language forKey:LangauageType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSString *jsCode = [NSString stringWithFormat:@"setSystemLanguageResponse(%d,'%@')",true,language];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {

    }];
}


#pragma mark 刷新设备列表
- (void)deviceListRequest:(NSDictionary *)object
{
    self.currentMac = nil;
    DDLog(@"deviceListRequest..........................");
    @weakify(self);
    if (!_udpSocket) {
        _udpSocket = [UDPSocket shareInstance];
        _udpSocket.connectedStausHandler = ^(BOOL staus) {
            if (staus) {
                [weak_self calibrationTimeWithDeviceMac:weak_self.currentMac];
                NSString *jsCode = [NSString stringWithFormat:@"controlDeviceResponse(%d,'%@')",true,weak_self.json];
                [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                    
                }];
            }
        };
    }
   
    if ([MqMessageResponseModel shareInstance].isConnect) {
        [[MqttClientManager shareInstance].client getBindListWithType:1 completionHandler:^(StartAIResultState res) {
            [weak_self errorCodeResponse:res];
        }];
    }

    NSString *bindListPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"BindFloder"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",[MqttClientManager shareInstance].client.userid]];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:bindListPath];
//    NSMutableArray *muArr = [NSMutableArray array];
    _deviceArr = [NSMutableArray array];
    if (data.length) {
        _deviceArr = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    //    for (NSDictionary *dict in _deviceArr) {
    //            if (dict[@"id"]) {
    //                [muArr addObject:dict];
    //            }
    //        }
    }
    if (self.deviceArrhandler) {
        self.deviceArrhandler(_deviceArr);
    }
    
    [UDPSocket shareInstance].deviceInfoArr = [NSMutableArray arrayWithArray:_deviceArr];
    [[UDPSocket shareInstance] startFindDevice];
}

#pragma mark 控制请求
- (void)controlDeviceRequest:(NSDictionary *)object
{
    [[UDPSocket shareInstance] stopFindDevice];
    self.json = object[@"data"];
    NSData *data = [self.json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    NSString *ip = [dic objectForKey:@"ip"];
    NSString *mac = [dic objectForKey:@"mac"];
    self.currentMac = mac;
//    if ([dic[@"isBinding"] integerValue] == 0) {
//        if (self.wifiBindDeviceHandler) {
//            self.wifiBindDeviceHandler(dic);
//        }
//    }else{
        if (ip.length && mac.length) {
            [self.udpSocket connectToHost:ip onPort:9222 mac:mac];
        }
    [self calibrationTimeWithDeviceMac:mac];
//    }
    [self performSelector:@selector(delayControl:) withObject:self.json afterDelay:3];
//    [self delayControl:self.json];
    
}

- (void)delayControl:(NSString *)json
{
    if (!self.udpSocket.isConnected) {
        NSString *jsCode = [NSString stringWithFormat:@"controlDeviceResponse(%d,'%@')",true,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 解除设备控制
- (void)relieveControlDeviceRequest:(NSDictionary *)object
{
    [[UDPSocket shareInstance] requestLanConnectionSleep];
}

#pragma mark 设备列表界面控制继电器开关控制
- (void)wifiPowerSwitchRequest:(NSDictionary *)object
{
    if (self.wifiPowerSwitchRequestHandler) {
        self.wifiPowerSwitchRequestHandler(object);
    }
}

#pragma mark 设备列表界面继电器开关状态查询
- (void)wifiPowerSwitchStatusRequest:(NSDictionary *)object
{
//    if (self.wifiPowerSwitchStatusRequestHandler) {
//        self.wifiPowerSwitchStatusRequestHandler(object);
//    }
}

#pragma mark 广域网解绑设备
- (void)unbundlingDeviceRequest:(NSDictionary *)obejct
{
    NSString *mac = [obejct objectForKey:@"mac"];
    NSString *bindListPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"BindFloder"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",[MqttClientManager shareInstance].client.userid]];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:bindListPath];
    if (data) {
        _deviceArr = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    }
    @weakify(self);
    for (NSDictionary *dic in _deviceArr) {
        if ([dic[@"mac"] isEqualToString:mac]) {
            NSString *sn = [ToolHandle fillNullString:dic[@"id"] ];
//            [_deviceArr removeObject:dic];
            if (sn.length) {
                [[MqttClientManager shareInstance].client beUnbindid:sn completionHandler:^(StartAIResultState res) {
                    [weak_self errorCodeResponse:res];
                }];
            }
            break;
        }
    }
//    if (self.deviceArrhandler) {
//        self.deviceArrhandler(_deviceArr);
//    }
//    NSData *data1 = [NSJSONSerialization dataWithJSONObject:_deviceArr options:NSJSONWritingPrettyPrinted error:nil];
//    [[NSFileManager defaultManager] createFileAtPath:bindListPath contents:data1 attributes:nil];
    
    [self unbind:mac];
}


#pragma mark 局域网解绑设备
- (void)unbind:(NSString *)mac
{
    DDLog(@"unbind.........");
    
    NSString *host = [[UDPSocket shareInstance].deviceDic objectForKey:mac];
    if (!host) {
        return;
    }
    [UDPSocket shareInstance].isBinding = true;
    [[UDPSocket shareInstance] connectToHost:host onPort:9222 mac:mac];
    
    
    uint8_t type= 0x01;
    uint8_t cmd = 0x05;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    NSString *name = [[MqttClientManager shareInstance].client userid];
    NSData *data1 = [name dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:data1];
    
    for (NSInteger i=0; i<32-data1.length; i++) {
        uint8_t zero = 0x00;
        [data appendBytes:&zero length:1];
    }
    
    [data appendData: [self getData:0x00]];
    
    NSString *psw = @"";
    NSData *data2 = [psw dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:data2];
    for (NSInteger i=0; i<32-data2.length; i++) {
        uint8_t zero = 0x00;
        [data appendBytes:&zero length:1];
    }
    
    data = [ToolHandle getPacketData:data];
    
    [[HandlingDataModel shareInstance] regegistDelegate:self];
    NSDictionary *dic = @{
                          @"mac":mac,
                          @"data":data,
                          };
    [self performSelector:@selector(sendUnBindData:) withObject:dic afterDelay:1];
  
}

- (void)sendUnBindData:(NSDictionary *)dic
{
    NSMutableData *data = [NSMutableData dataWithData:(NSData *)dic[@"data"]];
    NSString *mac = dic[@"mac"];
    [[UDPSocket shareInstance] sendDataWithoutConnect:data mac:mac];
}


- (void)updateDeviceInfoWithMac:(NSString *)mac
{
    DDLog(@"updateDeviceInfoWithMac.................");
    [self getDeviceName:mac];
    [self getDeviceWifiSSDI:mac];
    [self getDeviceSwitchStauts:mac];
}

#pragma mark 获取设备名称
- (void)getDeviceName:(NSString *)mac
{
//    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type = 0x01;
    uint8_t cmd = 0x0d;
 
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendDataWithMac:mac data:data];
}

#pragma mark 获取wifi名称
- (void)getDeviceWifiSSDI:(NSString *)mac
{
//    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type = 0x01;
    uint8_t cmd = 0x3D;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendDataWithMac:mac data:data];
}

#pragma mark 获取设备开关状态
- (void)getDeviceSwitchStauts:(NSString *)mac
{
    if (self.wifiPowerSwitchStatusRequestHandler) {
        self.wifiPowerSwitchStatusRequestHandler(@{@"mac":mac});
    }
}


#pragma mark 校准时间
- (void)calibrationTimeWithDeviceMac:(NSString *)deviceMac
{
    DDLog(@"calibrationTime......................");
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger real = [comps weekday] - 1;
    if (real == 0) {
        real = 7;
    }
    
    uint8_t type= 0x02;
    uint8_t cmd = 0x03;
    uint8_t year = (uint8_t)([comps year]-2000);
    uint8_t week = (uint8_t)real;
    uint8_t month = (uint8_t)[comps month];
    uint8_t day = (uint8_t)[comps day];
    uint8_t hour = (uint8_t)[comps hour];
    uint8_t min = (uint8_t)[comps minute];
    uint8_t sec = (uint8_t)[comps second];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:year]];
    [data appendData:[self getData:week]];
    [data appendData:[self getData:month]];
    [data appendData:[self getData:day]];
    [data appendData:[self getData:hour]];
    [data appendData:[self getData:min]];
    [data appendData:[self getData:sec]];
    
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:deviceMac data:data];
    
}


-(void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    @weakify(self);
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weak_self) strongSelf = weak_self;
        [strongSelf.web.configuration.userContentController addScriptMessageHandler:self name:obj];
//        [strongSelf.methodArr removeObject:obj];
    }];
}

#pragma mark H5调用原生
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funcDic.allKeys containsObject:message.name]) {
        DDLog(@"%@...................................",message.name);
        SEL sel = NSSelectorFromString([self.funcDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
            [[HandlingDataModel shareInstance]regegistDelegate:self];
            [self performSelector:sel withObject:message.body];
           
        }
    }
}

- (void)errorCodeResponse:(StartAIResultState)res
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *jsCode = [NSString stringWithFormat:@"errorCodeResponse('%@')",@(res)];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        if (res) {
            DDLog(@"消息未发送出去...%@...........................",NSStringFromClass([self class]));
        }
    });
}

@end
