//
//  WeatherRequestModel.m
//  WiFiSocket
//
//  Created by Mac on 2019/1/14.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import "WeatherRequestModel.h"
#import "LocationInformation.h"

@interface WeatherRequestModel ()<WKScriptMessageHandler>

@property (nonatomic, strong) LocationInformation *locationModel;

@end

@implementation WeatherRequestModel

- (NSArray *)funcArr
{
    return @[
             @"localWeatherRequest",   //天气状态请求
             @"positioningSwitchStatusRequest",     //查询定位开关状态
             @"positioningSwitchControlRequest",    //打开定位请求
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"localWeatherRequest":@"localWeatherRequest:",   //天气状态请求
             @"positioningSwitchStatusRequest":@"positioningSwitchStatusRequest:",     //查询定位开关状态
             @"positioningSwitchControlRequest":@"positioningSwitchControlRequest:",    //打开定位请求
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


- (LocationInformation *)locationModel
{
    @weakify(self);
    if (!_locationModel) {
        _locationModel = [LocationInformation shareInstance];
//        _locationModel.getLocationJurisdictionHandler = ^(BOOL res) {
//            NSString *jsCode = [NSString stringWithFormat:@"positioningSwitchStatusResponse(%d,%d)",true,res];
//            [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//            }];
//        };
        _locationModel.getLoactionHandler = ^(NSString *lat, NSString *longitude) {
//            [[MqttClientManager shareInstance].client queryTemperatureAndAirQualityWithLat:lat lng:longitude completionHandler:^(StartAIResultState res) {
//                [weak_self errorCodeResponse:res];
//            }];
            [weak_self localWeatherRequest:@{}];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"tishi" message:weak_self.locationModel.city delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
        };
    }
    return _locationModel;
}

- (void)localWeatherRequest:(NSDictionary *)object
{
    if ([self.locationModel.longitude isEqualToString:@"获取失败"]) {
        [self.locationModel startLoaction];
    }else{
        @weakify(self);
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:self.locationModel.city];
        if (dict) {
            NSInteger time = [[dict objectForKey:@"gettime"] integerValue];
            if (labs([ToolHandle getNowTime]-time)>=3600*8) {
                [[MqttClientManager shareInstance].client queryTemperatureAndAirQualityWithLat:self.locationModel.latitude lng:self.locationModel.longitude completionHandler:^(StartAIResultState res) {
                    [weak_self errorCodeResponse:res];
                }];
            }else{
                NSString *json = [ToolHandle toJsonString:dict];
                NSString *jsCode = [NSString stringWithFormat:@"localWeatherResponse(%d,'%@')",true,json];
                [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                    
                }];
            }
        }else{
            [[MqttClientManager shareInstance].client queryTemperatureAndAirQualityWithLat:self.locationModel.latitude lng:self.locationModel.longitude completionHandler:^(StartAIResultState res) {
                [weak_self errorCodeResponse:res];
            }];
        }
    }
}

- (void)positioningSwitchStatusRequest:(NSDictionary *)object
{
    BOOL res = [self.locationModel getLocationJurisdiction];
    NSString *jsCode = [NSString stringWithFormat:@"positioningSwitchStatusResponse(%d,%d)",true,res];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

- (void)positioningSwitchControlRequest:(NSDictionary *)object
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if( [[UIApplication sharedApplication]canOpenURL:url] ) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    @weakify(self);
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[weak_self.web configuration].userContentController addScriptMessageHandler:self name:obj];
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
