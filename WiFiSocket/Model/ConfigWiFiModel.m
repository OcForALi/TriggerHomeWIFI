//
//  ConfigWiFiModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/7/18.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "ConfigWiFiModel.h"
#import "JMAirKiss.h"
#import "SmartConfigWifi.h"

@interface ConfigWiFiModel ()<WKScriptMessageHandler,StartaiClientDelegate>

@property (nonatomic, strong) SmartConfigWifi *smartConfig;
@property (nonatomic, strong) JMAirKissConnection *airKissConnection;
@property (nonatomic, assign) BOOL isBinding;

@end

@implementation ConfigWiFiModel

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


-(NSArray *)funcArr
{
    return @[
             @"isConnectToWiFiRequest",          //是否连接wif
             @"WiFiNameRequest",                //获取wifi名称
             @"WiFiConfigRequest",               //开始配网
             @"stopConnectionNetworkRequest",      //停止配网
             @"openDeviceScanningRequest",         //开始扫描设备
             @"closeDeviceScanningRequest",         //关闭扫描设备
             @"addDeviceConnectedByRouterRequest",  //添加路由器的连接设备
             @"callThePhoneScanRequest",            //调用二维码扫描
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"isConnectToWiFiRequest":@"isConnectToWiFiRequest:",  //是否连接wifi
             @"WiFiNameRequest":@"WiFiNameRequest:",    //获取wifi名称
             @"WiFiConfigRequest":@"WiFiConfigRequest:", //开始配网
             @"stopConnectionNetworkRequest":@"stopConnectionNetworkRequest:", //停止配网
             @"openDeviceScanningRequest":@"openDeviceScanningRequest:",    //开始扫描设备
             @"closeDeviceScanningRequest":@"closeDeviceScanningRequest:",  //关闭扫描设备
             @"addDeviceConnectedByRouterRequest":@"addDeviceConnectedByRouterRequest:",    //添加路由器扫描设备
             @"callThePhoneScanRequest":@"callThePhoneScanRequest:",        //调用二维码扫描
             };
}


#pragma mark 调用二维码扫描接口
- (void)callThePhoneScanRequest:(NSDictionary *)object
{
    
}

#pragma mark 手机是否wifi
- (void)isConnectToWiFiRequest:(NSDictionary *)object
{
    BOOL result = false;
    if ([BasicInfoCollection getCurreWiFiSsid].length) {
        result = true;
    }
    NSString *jsCode = [NSString stringWithFormat:@"isConnectToWiFiResponse(%d)",result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 获取wifi名称
- (void)WiFiNameRequest:(NSDictionary *)object
{
    NSString *jsCode = [NSString stringWithFormat:@"WiFiNameResponse('%@')",[BasicInfoCollection getCurreWiFiSsid]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 开始配网
- (void)WiFiConfigRequest:(NSDictionary *)obejct
{
    [[UDPSocket shareInstance] stopFindDevice];
    __weak typeof(self) weakSelf = self;
    self.smartConfig = [[SmartConfigWifi alloc] initWithApSsid:[BasicInfoCollection getCurreWiFiSsid] andApBssid:[BasicInfoCollection getCurreWiFiBSsid] andApPwd:[obejct objectForKey:@"password"] andAES:nil];
    self.smartConfig.configFailHandler = ^{
        DDLog(@"配网失败。。。。。。。。。。。。。");
        [weakSelf connectionNetworkResponse:false];
    };
    self.smartConfig.configSucessHandler = ^{
        DDLog(@"配网成功。。。。。。。。。。。。。");
        [weakSelf connectionNetworkResponse:true];
    };
    
    NSString *jsCode = [NSString stringWithFormat:@"WiFiConfigResponse(%d)",true];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 停止配网
- (void)stopConnectionNetworkRequest:(NSDictionary *)object
{
    if (self.smartConfig != nil)
    {
        [self.smartConfig interrupt];
        self.smartConfig = nil;
    }
}

#pragma mark 配网回调
- (void)connectionNetworkResponse:(BOOL)result
{
    self.smartConfig = nil;
    NSString *jsCode = [NSString stringWithFormat:@"connectionNetworkResponse(%d)",result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 开始扫描设备

- (void)openDeviceScanningRequest:(NSDictionary *)object
{
    [[UDPSocket shareInstance] startFindDevice];
    [MqMessageResponseModel shareInstance].lanArr = [NSMutableArray array];
}

#pragma mark 关闭扫描设备
- (void)closeDeviceScanningRequest:(NSDictionary *)object
{
    [[UDPSocket shareInstance] stopFindDevice];
}

#pragma mark 局域网绑定设备
- (void)addDeviceConnectedByRouterRequest:(NSDictionary *)object
{

    DDLog(@"addDeviceConnectedByRouterRequest.........");
    NSString *mac = [object objectForKey:@"mac"];

    NSString *host = [[UDPSocket shareInstance].deviceDic objectForKey:mac];
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
    
    [data appendData: [self getData:0x03]];
    
    NSString *psw = [object objectForKey:@"password"];
    NSData *data2 = [psw dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:data2];
    for (NSInteger i=0; i<32-data2.length; i++) {
        uint8_t zero = 0x00;
        [data appendBytes:&zero length:1];
    }
    
    [[HandlingDataModel shareInstance] regegistDelegate:self];
    self.isBinding = true;
    NSDictionary *dic = @{
                          @"mac":mac,
                          @"data":data,
                          };
    [self performSelector:@selector(sendBindData:) withObject:dic afterDelay:1.0];
    [self performSelector:@selector(addDeviceConnectedByRouterResponse:) withObject:false afterDelay:5.0];
}

- (void)sendBindData:(NSDictionary *)dic
{
    NSMutableData *data = [NSMutableData dataWithData:(NSData *)dic[@"data"]];
    NSString *mac = dic[@"mac"];
    [[UDPSocket shareInstance] sendDataWithoutConnect:data mac:mac];
}

#pragma mark 局域网设备绑定返回
- (void)bindDeviceResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
//    __weak typeof(self) weakSelf = self;
    BOOL result = [[object objectForKey:@"result"] boolValue];
    [self addDeviceConnectedByRouterResponse:result];

    NSData *sn = [object objectForKey:@"sn"];
    NSData *mac = [object objectForKey:@"mac"];
    NSMutableData *data = [NSMutableData data];
    uint8_t zero = 0x00;
    for (NSInteger i=0; i<sn.length; i++) {
        NSData *da = [sn subdataWithRange:NSMakeRange(i, 1)];
        if ([da isEqualToData:[ToolHandle getData:zero]]) {
            break;
        }
        [data appendData:da];
    }
    
    NSString *snStr = [[NSString alloc] initWithBytes:(Byte *)[data bytes] length:data.length encoding:NSUTF8StringEncoding];
    if (!snStr.length) {
        DDLog(@"解析设备SN失败。。。。。。。。。");
        if (!snStr.length) {
            return;
        }
    }
    Byte *macByte = (Byte *)[mac bytes];
    NSMutableString *macStr = [[NSMutableString alloc] init];
    for (NSInteger i=0; i<6; i++) {
        NSString *str;
        if (macByte[i] < 16) {
            str = [NSString stringWithFormat:@"0%x:",macByte[i]];
        }else{
            str = [NSString stringWithFormat:@"%x:",macByte[i]];
        }
        str = [str uppercaseString];
        [macStr appendString:str];
    }

    @weakify(self);
    [macStr replaceCharactersInRange:NSMakeRange(macStr.length-1, 1) withString:@""];
    [[MqttClientManager shareInstance].client beBind:snStr completionHandler:^(StartAIResultState res) {
        if (res != StartAIResultState_SUCCESS) {
            [weak_self errorCodeResponse:res];
        }
    }];
    if (self.bindDeviceSucess) {
        self.bindDeviceSucess(@{@"mac":macStr,@"id":snStr});
    }
}

#pragma mark 解绑设备返回
- (void)unBindDeviceResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL result = [object[@"result"] boolValue];
    NSString *jsCode = [NSString stringWithFormat:@"unbundlingDeviceResponse(%d,'%@')",result,deviceMac];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 添加设备回调
- (void)addDeviceConnectedByRouterResponse:(BOOL)result
{
    
    if (self.isBinding) {
        self.isBinding = false;
        NSString *jsCode = [NSString stringWithFormat:@"addDeviceConnectedByRouterResponse(%d)",result];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }

}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    __weak typeof(self) weakSelf = self;
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[weakSelf.web.configuration userContentController] addScriptMessageHandler:self name:obj];
        [weakSelf.methodArr removeObject:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funcDic.allKeys containsObject:message.name]) {
        SEL sel = NSSelectorFromString([self.funcDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
            DDLog(@"%@...................................",message.name);
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
