//
//  FirmwareUpdateModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/10/24.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "FirmwareUpdateModel.h"

@interface FirmwareUpdateModel ()<WKScriptMessageHandler>


@end

@implementation FirmwareUpdateModel

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
             @"checkFirmwareVersionRequest",
             @"firmwareUpgradeRequest",
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"checkFirmwareVersionRequest":@"checkFirmwareVersionRequest:",
             @"firmwareUpgradeRequest":@"firmwareUpgradeRequest:",
             };
}

#pragma mark 检查固件是否可以更新
- (void)checkFirmwareVersionRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type = 0x01;
    uint8_t cmd = 0x09;
    uint8_t mode = 0x02;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:mac data:data];
}

#pragma mark 固件更新
- (void)firmwareUpgradeRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type = 0x01;
    uint8_t cmd = 0x09;
    uint8_t mode = 0x01;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:mac data:data];
}

- (void)FirmwareOperationResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSInteger type = [object[@"type"] integerValue];
    if (type == 2) {
        NSString *current = [ToolHandle fillNullString:object[@"currentVersion"]];
        NSString *new = [ToolHandle fillNullString:object[@"newVersion"]];
        BOOL res = [new floatValue]>[current floatValue];
        NSString *jsCode = [NSString stringWithFormat:@"checkFirmwareVersionResponse('%@',%d,'%@')",deviceMac,res,new];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        
        if (self.updateDeviceListVersionHandler) {
            self.updateDeviceListVersionHandler(@{@"mac":deviceMac,@"version":current});
        }
        
    }else if (type == 1){
        NSString *jsCode = [NSString stringWithFormat:@"firmwareUpgradeResponse('%@','%@',%d)",deviceMac,deviceMac,[object[@"result"] boolValue]];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
    
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    @weakify(self);
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weak_self) strongSelf = weak_self;
        [strongSelf.web.configuration.userContentController addScriptMessageHandler:self name:obj];
        [strongSelf.methodArr removeObject:obj];
    }];
}



- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funcDic.allKeys containsObject:message.name]) {
        DDLog(@"%@...................................",message.name);
        SEL sel = NSSelectorFromString([self.funcDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel withObject:message.body];
            [[HandlingDataModel shareInstance] regegistDelegate:self];
        }
    }
}

@end
