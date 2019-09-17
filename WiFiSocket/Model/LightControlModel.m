//
//  LightControlModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/10/30.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "LightControlModel.h"


@interface LightControlModel ()<WKScriptMessageHandler>

@property (nonatomic, strong) NSMutableDictionary *colorObject;

@end

@implementation LightControlModel

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (NSArray *)funcArr
{
    return @[
             @"shakeItNightLightDataRequest",   //查询摇一摇小夜灯数据
             @"shakeItNightLightRequest",       //摇一摇小夜灯开关
             @"ordinaryNightLightDataRequest",  //查询小夜灯开关,
             @"ordinaryNightLightRequest",      //设置小夜灯开关
             @"nightLightSettingRequest",       //查询小夜灯设置数据
             @"nightLightSwitchRequest",        //智能夜灯开关
             @"timingNightLightRequest",        //定时夜灯
             @"colourLampSettingRequest",       //彩灯设置数据
             @"colourLampSwitchStateRequest",   //查询彩灯开关
             @"colourLampSwitchRequest",        //彩灯开关
             @"colourLampControlRequest",       //彩灯控制
             @"colourLampQueryRequest",         //彩灯颜色
             @"colourLampModeQueryRequest",     //彩灯当前模式
             @"colourLampModeListQueryRequest", //彩灯列表查询
             @"newColourLampModeRequest",       //新建彩灯模式
             @"deleteColourLampModeRequest",    //删除彩灯模式
             @"USBSwitchStateRequest",          //查询USB开关
             @"USBSwitchRequest",               //USB开关控制
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"shakeItNightLightDataRequest":@"shakeItNightLightDataRequest:",   //查询摇一摇小夜灯数据
             @"shakeItNightLightRequest":@"shakeItNightLightRequest:",       //摇一摇小夜灯开关
             @"ordinaryNightLightDataRequest":@"ordinaryNightLightDataRequest:",  //查询小夜灯开关,
             @"ordinaryNightLightRequest":@"ordinaryNightLightRequest:",      //设置小夜灯开关
             @"nightLightSettingRequest":@"nightLightSettingRequest:",       //查询小夜灯设置数据
             @"nightLightSwitchRequest":@"nightLightSwitchRequest:",        //智能夜灯开关
             @"timingNightLightRequest":@"timingNightLightRequest:",        //定时夜灯
             @"colourLampSettingRequest":@"colourLampSettingRequest:",       //彩灯设置数据
             @"colourLampSwitchRequest":@"colourLampSwitchRequest:",        //彩灯开关
             @"colourLampSwitchStateRequest":@"colourLampSwitchStateRequest:",   //查询彩灯开关
             @"colourLampControlRequest":@"colourLampControlRequest:",       //彩灯控制
             @"colourLampQueryRequest":@"colourLampQueryRequest:",         //彩灯颜色
             @"colourLampModeQueryRequest":@"colourLampModeQueryRequest:",     //彩灯当前模式
             @"colourLampModeListQueryRequest":@"colourLampModeListQueryRequest:", //彩灯列表查询
             @"newColourLampModeRequest":@"newColourLampModeRequest:",       //新建彩灯模式
             @"deleteColourLampModeRequest":@"deleteColourLampModeRequest:",    //删除彩灯模式
             @"USBSwitchStateRequest":@"USBSwitchStateRequest:",          //查询USB开关
             @"USBSwitchRequest":@"USBSwitchRequest:",               //USB开关控制
             };
}

#pragma mark 查询摇一摇小夜灯数据
- (void)shakeItNightLightDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSString * status = [NSString stringWithFormat:@"%@-%@",mac,[MqttClientManager shareInstance].client.userid];
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:status];
    NSString *jsCode = [NSString stringWithFormat:@"shakeItNightLightResponse('%@',%d)",mac,state];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 摇一摇设置小夜灯开关
- (void)shakeItNightLightRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    BOOL state = [[object objectForKey:@"state"] boolValue];
    NSString * status = [NSString stringWithFormat:@"%@-%@",mac,[MqttClientManager shareInstance].client.userid];
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:status];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *jsCode = [NSString stringWithFormat:@"shakeItNightLightResponse('%@',%d)",mac,state];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}


#pragma mark 普通小夜灯查询
- (void)ordinaryNightLightDataRequest:(NSDictionary *)object
{
    DDLog(@"ordinaryNightLightDataRequest..........");
    NSString *mac = [object objectForKey:@"mac"];
    
//    int8_t type= 0x01;
//    int8_t cmd = 0x37;
//    int8_t type= 0x02;
//    int8_t cmd = 0x0b;
//
//    NSMutableData *data = [[NSMutableData alloc] init];
//    [data appendData:[self getData:type]];
//    [data appendData:[self getData:cmd]];
//    [data appendData:[self getData:0x05]];
//
//    [self sendData:data mac:mac];
    
    int8_t type= 0x02;
    int8_t cmd = 0x29;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    [data appendData:[self getData:0x02]];  //0x01彩灯 0x02黄灯
    [self sendData:data mac:mac];
}

#pragma mark 普通小夜灯控制
- (void)ordinaryNightLightRequest:(NSDictionary *)object
{
    BOOL state = [[object objectForKey:@"state"] boolValue];
    NSString *mac = [object objectForKey:@"mac"];
    
//    int8_t type= 0x02;
//    int8_t cmd = 0x01;
//    int8_t mode = 0x05;
//    int8_t relayswitch = (state == true)? 0x01:0x00;
    
//    NSMutableData *data = [[NSMutableData alloc] init];
//    [data appendData:[self getData:type]];
//    [data appendData:[self getData:cmd]];
//    [data appendData:[self getData:mode]];
//    [data appendData:[self getData:relayswitch]];
    
    int8_t type= 0x02;
    int8_t cmd = 0x25;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x00]];  //seq
    if (state) {
        [data appendData:[self getData:0xff]];
        [data appendData:[self getData:0xff]];
        [data appendData:[self getData:0x00]];
    }else{
        [data appendData:[self getData:0x00]];
        [data appendData:[self getData:0x00]];
        [data appendData:[self getData:0x00]];
    }
    
    [data appendData:[self getData:0x02]];
    
    [self sendData:data mac:mac];
}

#pragma mark 普通小夜灯返回
- (void)ordinaryNightLightResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"ordinaryNightLightResponse..........普通小夜灯智能开关返回");
    self.smallLightState = [[object objectForKey:@"state"] integerValue] == 1?true:false;
    NSString *jsCode = [[NSString alloc] initWithFormat:@"ordinaryNightLightResponse('%@',%d)",deviceMac,self.smallLightState];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询小夜灯设置数据
- (void)nightLightSettingRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type= 0x02;
    int8_t cmd = 0x37;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0xff]];
    
    [self sendData:data mac:mac];
}

#pragma mark 智能夜灯开关
- (void)nightLightSwitchRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    
//    int8_t type= 0x02;
//    int8_t cmd = 0x35;
//    int8_t ID = [[object objectForKey:@"id"] integerValue];
    int8_t state = [[object objectForKey:@"state"] boolValue] == true?0x01:0x02;
//
//    NSMutableData *data = [[NSMutableData alloc] init];
//    [data appendData:[self getData:type]];
//    [data appendData:[self getData:cmd]];
//    [data appendData:[self getData:ID]];
//    [data appendData:[self getData:state]];
//    [data appendData:[self getData:0]];
//    [data appendData:[self getData:0]];
//    [data appendData:[self getData:23]];
//    [data appendData:[self getData:59]];

    int8_t type= 0x02;
    int8_t cmd = 0x25;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x00]];  //seq
    if (state) {
        [data appendData:[self getData:0xff]];
        [data appendData:[self getData:0xff]];
        [data appendData:[self getData:0x00]];
    }else{
        [data appendData:[self getData:0x00]];
        [data appendData:[self getData:0x00]];
        [data appendData:[self getData:0x00]];
    }

    [data appendData:[self getData:0x02]];
    
    [self sendData:data mac:mac];
}

#pragma mark 定时夜灯
- (void)timingNightLightRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSArray *startArr = [object[@"startTime"] componentsSeparatedByString:@":"];
    NSArray *endArr = [object[@"endTime"] componentsSeparatedByString:@":"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x35;
    int8_t ID = [[object objectForKey:@"id"] integerValue];
    int8_t state = [[object objectForKey:@"state"] boolValue] == true?0x01:0x02;
    int8_t startHour = [[startArr firstObject] integerValue];
    int8_t startMinute = [[startArr lastObject] integerValue];
    int8_t endHour = [[endArr firstObject] integerValue];
    int8_t endMinute = [[endArr lastObject] integerValue];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:ID]];
    [data appendData:[self getData:state]];
    [data appendData:[self getData:startHour]];
    [data appendData:[self getData:startMinute]];
    [data appendData:[self getData:endHour]];
    [data appendData:[self getData:endMinute]];
    
    [self sendData:data mac:mac];
}

#pragma mark 查询小夜灯设置数据返回
- (void)nightLightSettingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"nightLightSettingResponse..........查询小夜灯数据返回");
    NSString *json = [ToolHandle toJsonString:object];
    NSString *jsCode = [NSString stringWithFormat:@"nightLightSettingResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 智能夜灯开关返回
- (void)nightLightSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"nightLightSwitchResponse..........查询小夜灯智能开关返回");
    NSDictionary *dic = @{@"id":@(1),@"state":@([[object objectForKey:@"state"] boolValue])};
    NSString *json = [ToolHandle toJsonString:dic];
    NSString *jsCode = [[NSString alloc] initWithFormat:@"nightLightSettingResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}



#pragma mark 彩灯设置数据
- (void)colourLampSettingRequest:(NSDictionary *)object
{
    
}

#pragma mark 彩灯设置数据返回
- (void)colourLampSettingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    
}

#pragma mark 查询彩灯开关
- (void)colourLampSwitchStateRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];

    int8_t type= 0x02;
    int8_t cmd = 0x0b;

    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x03]];

//    [self sendData:data mac:mac];
    
    [self colourLampQueryRequest:object];
}

#pragma mark 彩灯开关
- (void)colourLampSwitchRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    BOOL state = [[object objectForKey:@"state"] boolValue];

    if (state == false) {
        [self colourLampControlRequest:@{@"mac":mac,@"id":@"1",@"r":@(0),@"g":@(0),@"b":@(0)}];
        return;
    }else{
        if (self.colorObject) {
            [self.colorObject setObject:mac forKey:@"mac"];
            [self.colorObject setObject:@(1) forKey:@"id"];
            [self colourLampControlRequest:self.colorObject];
        }else{
            [self colourLampControlRequest:@{@"mac":mac,@"id":@"1",@"r":@(93),@"g":@(138),@"b":@(168)}];
        }
    }
}

#pragma mark 彩灯开关返回
- (void)colourLampSwivvtchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"colourLampSwivvtchResponse..........");
    NSString *jsCode = [[NSString alloc] initWithFormat:@"colourLampSwitchStateResponse('%@',%d)",deviceMac,[[object objectForKey:@"state"] boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 彩灯颜色控制
- (void)colourLampControlRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t mode = (uint8_t)[[object objectForKey:@"id"] integerValue];
    uint8_t red = (uint8_t)[[object objectForKey:@"r"] integerValue];
    uint8_t green = (uint8_t)[[object objectForKey:@"g"] integerValue];
    uint8_t blue = (uint8_t)[[object objectForKey:@"b"] integerValue];
    
    int8_t type= 0x02;
    int8_t cmd = 0x25;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x00]];  //seq
    [data appendData:[self getData:red]];
    [data appendData:[self getData:green]];
    [data appendData:[self getData:blue]];
    [data appendData:[self getData:0x01]];
    
    [self sendData:data mac:mac];
    
}

#pragma mark 彩灯颜色控制返回
- (void)colourLampControlResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{

    DDLog(@"colourLampControlResponse..................彩灯颜色返回");
    NSInteger ID = [object[@"id"] integerValue];
    NSInteger r = [object[@"r"]integerValue];
    NSInteger g = [object[@"g"]integerValue];
    NSInteger b = [object[@"b"]integerValue];
    NSInteger w = [object[@"w"]integerValue];
    
    
    if (w == 2) {
        self.smallLightState = r>0  ?true:false;
        NSString *jsCode = [[NSString alloc] initWithFormat:@"ordinaryNightLightResponse('%@',%d,%ld,%ld,%ld,%ld)",deviceMac,self.smallLightState,ID,r,g,b];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }else if(w == 1) {
        if (r == 0 && g ==0 && b ==0) {
            NSString *jsCode = [[NSString alloc] initWithFormat:@"colourLampSwitchStateResponse('%@',%d)",deviceMac,false];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
            
//            NSString *jsCode1 = [[NSString alloc] initWithFormat:@"colourLampSwitchStateResponse('%@',%d)",deviceMac,false];
//            [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//            }];
        }else{
            self.colorObject = [NSMutableDictionary dictionaryWithDictionary:object];
            NSString *jsCode = [[NSString alloc] initWithFormat:@"colourLampSwitchStateResponse('%@',%d)",deviceMac,true];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
            
//            NSString *jsCode1 = [[NSString alloc] initWithFormat:@"colourLampSwitchStateResponse('%@',%d)",deviceMac,true];
//            [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//                
//            }];
            
        }
        NSString *jsCode = [NSString stringWithFormat:@"colourLampControlResponse('%@',%ld,%ld,%ld,%ld)",deviceMac,ID,r,g,b];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 彩灯颜色查询
- (void)colourLampQueryRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type= 0x02;
    int8_t cmd = 0x29;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    [data appendData:[self getData:0x01]];  //0x01彩灯 0x02黄灯
    [self sendData:data mac:mac];
}

#pragma mark 彩灯颜色查询返回
- (void)colourLampControlResponse:(NSDictionary *)object
{
    
}


#pragma mark 彩灯当前模式查询
- (void)colourLampModeQueryRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type = 0x02;
    uint8_t cmd = 0x2F;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0xff]];
    [self sendData:data mac:mac];
}

#pragma mark 彩灯当前模式返回
- (void)colourLampModeQueryResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    
}

#pragma mark 彩灯模式列表查询
- (void)colourLampModeListQueryRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type = 0x02;
    uint8_t cmd = 0x33;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [self sendData:data mac:mac];
}

#pragma mark 彩灯模式列表查询返回
- (void)colourLampModeListQueryResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    
}

#pragma mark 新建彩灯模式
- (void)newColourLampModeRequest:(NSDictionary *)object
{
    NSString *dataJson = object[@"data"];
    NSDictionary *dic = [ToolHandle dictionaryWithJsonString:dataJson];
    
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type = 0x02;
    uint8_t cmd = 0x31;
    uint8_t ID = (uint8_t)[dic[@"modeID"] integerValue];
    uint8_t interval = 255;
    uint8_t num = 10;
    uint8_t seq = 1;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [self sendData:data mac:mac];
}

#pragma mark 删除彩灯模式
- (void)deleteColourLampModeRequest:(NSDictionary *)object
{
    
}

#pragma mark 查询USB开关状态
- (void)USBSwitchStateRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x0b;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x04]];
    
    [self sendData:data mac:mac];
}

#pragma mark USB开关控制
- (void)USBSwitchRequest:(NSDictionary *)object
{
    DDLog(@"nightLightSwitchRequest..........");
    BOOL state = [[object objectForKey:@"state"] boolValue];
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x01;
    int8_t mode = 0x04;
    int8_t relayswitch = (state == true)? 0x01:0x00;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:relayswitch]];
    
    [self sendData:data mac:mac];
}

#pragma mark USB开关返回
- (void)USBSwitchStateRequest:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSString *jsCode = [[NSString alloc] initWithFormat:@"USBSwitchResponse('%@',%d)",deviceMac,[[object objectForKey:@"state"] boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
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
    @weakify(self);
    self.web = web;
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weak_self) strongSelf = weak_self;
        [strongSelf.web.configuration.userContentController addScriptMessageHandler:self name:obj];
        [strongSelf.methodArr removeObject:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funcDic.allKeys containsObject:message.name]) {
        SEL sel = NSSelectorFromString([self.funcDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
            DDLog(@"%@...................................",message.name);
            [self performSelector:sel withObject:message.body];
            [[HandlingDataModel shareInstance] regegistDelegate:self];
        }
    }
}

@end
