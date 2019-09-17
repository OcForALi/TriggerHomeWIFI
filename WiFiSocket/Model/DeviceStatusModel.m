//
//  DeviceStatusModel.m
//  WiFiSocket
//
//  Created by Mac on 2019/9/12.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import "DeviceStatusModel.h"

@interface DeviceStatusModel ()<WKScriptMessageHandler>

@end

@implementation DeviceStatusModel

- (NSArray *)funcArr
{
    return @[
             @"runningTimeRequest",//查询插座工作时长 0x49
             @"runningTimeOnlineRequest",//查询插座网络工作时长 0x4B
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"runningTimeRequest":@"queryWorkingHoursSocketsRequest:",
             @"runningTimeOnlineRequest":@"queryWorkingNetWorkHoursSocketsRequest:",
             };
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    __weak typeof(self) weakSelf = self;
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[weakSelf.web configuration].userContentController addScriptMessageHandler:self name:obj];
        [weakSelf.methodArr removeObject:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funcDic.allKeys containsObject:message.name]) {
        DDLog(@"%@...................................",message.name);
        SEL sel = NSSelectorFromString([self.funcDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel withObject:message.body];
        }
    }
}

#pragma rmark 消息组包发送
- (void)sendData:(NSMutableData *)data mac:(NSString *)mac
{
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:mac data:data];
}


///查询插座工作时长查询 0x49
- (void)queryWorkingHoursSocketsRequest:(NSDictionary *)dict{
    
    int8_t type= 0x02;
    int8_t cmd = 0x49;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    NSString *mac = [dict objectForKey:@"mac"];
    [self sendData:data mac:mac];
    
    NSLog(@"查询插座工作时长查询 0x49 %@",data);
    
}

///查询插座工作时长 返回 0x4A
- (void)queryWorkingHoursSocketsResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac{
    
    unsigned int worktime = [dict[@"worktime"] unsignedIntValue];
    NSUInteger result = [[dict objectForKey:@"result"] integerValue];
    
    NSString *jsCode = [NSString stringWithFormat:@"runningTimeResponse('%@','%u','%ld')",deviceMac,worktime,result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

///查询插座网络工作时长 查询 0x4B
- (void)queryWorkingNetWorkHoursSocketsRequest:(NSDictionary *)dict{
    
    int8_t type= 0x02;
    int8_t cmd = 0x4B;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    NSString *mac = [dict objectForKey:@"mac"];
    [self sendData:data mac:mac];
    
    NSLog(@"查询插座网络工作时长 查询 0x4B %@",data);
    
}

///查询插座网络工作时长 返回 0x4C
- (void)queryWorkingNetWorkHoursSocketsResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac{
    
    unsigned int worknettime = [dict[@"worknettime"] unsignedIntValue];
    NSUInteger result = [[dict objectForKey:@"result"] integerValue];
    
    NSString *jsCode = [NSString stringWithFormat:@"runningTimeOnlineResponse('%@','%u','%ld')",deviceMac,worknettime,result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

@end
