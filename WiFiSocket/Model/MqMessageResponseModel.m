//
//  MqMessageResponseModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/9/17.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "MqMessageResponseModel.h"
#import "LoginModel.h"


@interface MqMessageResponseModel ()<StartaiClientDelegate>

@property (nonatomic, copy) NSString *bindListPath;


@end

@implementation MqMessageResponseModel

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
        _lanArr = [NSMutableArray array];
        _deviceArr = [NSMutableArray array];
    }
    return self;
}

-(void)registFunctionWithWeb:(WKWebView *)web
{
    [[MqttClientManager shareInstance].client registDelegate:self];
    self.web = web;
}

#pragma mark MQTT连接
- (void)connectedCallback:(StartAIResultState)res
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[MqttClientManager shareInstance].client subscribe:[NSString stringWithFormat:@"Q/client/%@/#",[MqttClientManager shareInstance].client.sn] completionHandler:^(StartAIResultState res) {
            
        }];
        if ([MqttClientManager shareInstance].client.userid.length) {
            NSString *usertopic = [NSString stringWithFormat:@"Q/client/%@/#",[MqttClientManager shareInstance].client.userid];
            [[MqttClientManager shareInstance].client subscribe:usertopic completionHandler:^(StartAIResultState res) {
                
            }];
        }
    });
    self.isConnect = true;
    [self networkStatusResponse];

}

#pragma mark MQTT断开
- (void)disconnectedCallback:(StartAIResultState)res
{
    self.isConnect = false;
    [self networkStatusResponse];
}

- (void)networkStatusResponse
{
    DDLog(@"=======================MQTT状态:%d==========================",self.isConnect);
    NSString *jsCode = [NSString stringWithFormat:@"networkStatusResponse('%@',%d,'%@')",@"wideNetwork",self.isConnect,@""];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 局域网扫描到设备（设备信息整合）
- (void)setDeviceDic:(NSDictionary *)deviceDic
{
    @synchronized (self.deviceArr) {
        BOOL exist = false;
        NSInteger index = -1;
        NSMutableDictionary *device = [NSMutableDictionary dictionary];     //合并设备信息
        for (NSDictionary *dict in _deviceArr) {
            index ++;
            if ([dict[@"mac"] isEqualToString:deviceDic[@"mac"]]) {
                exist = true;
                device = [NSMutableDictionary dictionaryWithDictionary:dict];
                [_deviceArr removeObject:dict];
                break;
            }
        }
        //局域网可以搜索到的设备都是在线
        [device setObject:@(true) forKey:@"state"];
//        [device setObject:@(false) forKey:@"isBinding"];
        if (exist) {
            if ((![deviceDic[@"ip"] isEqualToString:device[@"ip"]] || ![deviceDic[@"name"] isEqualToString:device[@"name"]] || deviceDic.allKeys.count==2)) {
                [device setValuesForKeysWithDictionary:deviceDic];
//                if (device[@"id"]) {
//                    [device setObject:@(true) forKey:@"isBinding"];
//                }
                [_deviceArr insertObject:device atIndex:index];

                NSData *data = [NSJSONSerialization dataWithJSONObject:_deviceArr options:NSJSONWritingPrettyPrinted error:nil];
                [[NSFileManager defaultManager] createFileAtPath:self.bindListPath contents:data attributes:nil];
            }else{
                [device setValuesForKeysWithDictionary:deviceDic];
//                if (device[@"id"]) {
//                    [device setObject:@(true) forKey:@"isBinding"];
//                }
                [_deviceArr insertObject:device atIndex:index];
            }
        }else if (deviceDic[@"ip"]) {
            [device setValuesForKeysWithDictionary:deviceDic];
            [_deviceArr addObject:device];
            if ([device[@"isBinding"] boolValue]) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:_deviceArr options:NSJSONWritingPrettyPrinted error:nil];
                [[NSFileManager defaultManager] createFileAtPath:self.bindListPath contents:data attributes:nil];
            }
        }
        
        NSInteger idx = -1;
        BOOL res = false;
        for (NSDictionary *dict in _lanArr) {
            idx++;
            if ([dict[@"mac"] isEqualToString:deviceDic[@"mac"]] && dict) {
//                [_lanArr removeObject:dict];
                res = true;
                break;
            }
        }
//        if (res && deviceDic[@"ip"]) {
//            [_lanArr insertObject:deviceDic atIndex:idx];
//        }else{
            if (deviceDic[@"ip"] && !res) {
                [_lanArr addObject:device];
            }
//        }
        [self refreshDeviceListWithLAN:!res];
    }

}

#pragma mark 缓存设备
- (void)setDeviceArr:(NSMutableArray *)deviceArr
{
    _deviceArr = deviceArr;
    [self refreshDeviceListWithLAN:false];

}

#pragma mark 传递设备列表到H5
- (void)refreshDeviceListWithLAN:(BOOL)res
{
    NSMutableArray *muArr = [NSMutableArray array];
    for (NSDictionary *dic in _deviceArr) {
        if (dic[@"id"] || (dic[@"isBinding"] && [dic[@"isBinding"] integerValue])) {
            [muArr addObject:dic];
        }
//        if (dic[@"id"]) {
//            [muArr addObject:dic];
//        }
    }
    
    for (NSDictionary *dic in _lanArr) {
        if (dic[@"mac"] && dic[@"ip"]) {
            [[UDPSocket shareInstance].deviceDic setObject:dic[@"ip"] forKey:dic[@"mac"]];
        }
    }
    NSString *json = [ToolHandle toJsonString:muArr];
    NSString *jsCode = [NSString stringWithFormat:@"deviceListResponse('%@')",json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    if (res) {
        //局域网发现的设备列表
        NSString *json1 = [ToolHandle toJsonString:_lanArr];
        NSString *jsCode1 = [NSString stringWithFormat:@"deviceConnectedByRouterResponse(%d,'%@')",true,json1];
        [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
    [UDPSocket shareInstance].deviceInfoArr = _deviceArr;
    [UDPSocket shareInstance].lanArr = _lanArr;
    [HandlingDataModel shareInstance].deviceArr = _deviceArr;
}


#pragma mark 设备激活回调
- (void)onActiviteResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg
{
    if (!result && self.isConnect) {
        
        NSString *packageIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
        StartAIInitialEntity *entity = [[StartAIInitialEntity alloc] init];
        if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
            //     自研插座 MUSIC
            entity.domain = @"startai";
            entity.appid = @"aebb4dddadc34dcaa95a077254366731";
            entity.apptype = @"smartOlWifi/controll/ios";
            entity.m_ver = @"Json_1.1.4_8.1";
        }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
            // miniWIFI插座
            entity.domain = @"okaylight";
            entity.appid = @"2e76e2a2631e2dd61ef4989c15ed6443";
            entity.apptype = @"smartOlWifi/controll/ios";
            entity.m_ver = @"Json_1.1.4_8.1";
        }else if ([packageIdentifier isEqualToString:WanLondonSocket]){
            //英国插座
            
            entity.domain = @"okaylight";
            entity.appid = @"qx114c11a3a94f4e21";
            entity.apptype = @"smartOlWifi/controll/ios";
            entity.m_ver = @"Json_1.1.4_8.1";
        }else if ([packageIdentifier isEqualToString:NBSocket]){
            //NBSocket
            
            entity.domain = @"okaylight";
            entity.appid = @"qxb050edbace01cbd8";
            entity.apptype = @"smartOlWifi/controll/android";
            entity.m_ver = @"Json_1.2.4_9.2.1";
        } else{
            DDLog(@"获取bundleid失败 或者bundleid不正确");
        }
        
        [[MqttClientManager shareInstance].client initializationWithInitialEntity:entity completionHandler:^(StartAIResultState res) {
       
        }];
    }else{

    }
}

#pragma mark 获取验证码
- (void)onGetIdentifyCodeResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg
{
    NSString *jsCode = [NSString stringWithFormat:@"getMobilePhoneCodeResponse(%d)",result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 注册回调
- (void)onRegisterResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg registInfo:(NSDictionary *)registInfo
{
    NSString *jsCode = [NSString stringWithFormat:@"emailSignupResponse(%d,'%@')",result,errorCode];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 登陆回调
- (void)onLoginResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg
{
    
    if (self.loginType == phoneLogin ) {
        NSString *jsCode = [NSString stringWithFormat:@"mobileLoginResponse(%d,'%@')",result,errorCode];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        if (result) {
            [[NSUserDefaults standardUserDefaults] setInteger:QXPhoneAndCodeLogin forKey:QXLoginStore];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    }else if (self.loginType == emailLogin){
        NSString *jsCode = [NSString stringWithFormat:@"emailLoginResponse(%d,'%@')",result,errorCode];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        if (result) {
            [[NSUserDefaults standardUserDefaults] setInteger:QXLoginEmailAndPwd forKey:QXLoginStore];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    }
    
    if (result) {

        NSString *newTopic = [NSString stringWithFormat:@"Q/client/%@/#",[[MqttClientManager shareInstance].client userid]];
        [[MqttClientManager shareInstance].client subscribe:newTopic completionHandler:^(StartAIResultState res) {
            
        }];
        
        NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:QXLoginStore];
        [[MqttClientManager shareInstance].client getUserInfoByLoginType:type completionHandler:^(StartAIResultState res) {
            
        }];
    }
}

#pragma mark 第三方登陆回调
- (void)onThirdLoginResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg content:(id)content
{
    if (result) {
        NSInteger type = [content[@"type"] integerValue];
        if (type == QXWechatLogin) {
            NSString *jsonCode = [NSString stringWithFormat:@"wechatLoginResponse(%d)",result];
            [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];

        }else if (type == QXAliPayLogin){
            NSString *jsCode = [NSString stringWithFormat:@"alipayLoginResponse(%d)",result];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }else{
            if (type == QXGoogleLogin) {
                
            }else if (type == QXTwitterLogin){
                
            }else if (type == QXFacebookLogin){
                
            }
            NSDictionary *dic = @{
                                  @"userID": @"",   // 用户ID
                                  @"firstName": @"",      // 名字（教名）
                                  @"middleName": @"",           // 本人名
                                  @"lastName": @"",           // 姓氏
                                  @"name": @"",       // 全名
                                  @"linkURL": @"",
                                  @"refreshDate": @"",  // 更新时间
                                  };
            NSString *json = [ToolHandle toJsonString:dic];
            NSString *jsonCode = [NSString stringWithFormat:@"thirdPartyLoginResponse(%d,'%@')",true,json];
            [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];

        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:type forKey:QXLoginStore];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *newTopic = [NSString stringWithFormat:@"Q/client/%@/#",[[MqttClientManager shareInstance].client userid]];
        [[MqttClientManager shareInstance].client subscribe:newTopic completionHandler:^(StartAIResultState res) {
            
        }];
        
        [[MqttClientManager shareInstance].client getUserInfoByLoginType:type completionHandler:^(StartAIResultState res) {
            
        }];
    }else{
        NSInteger type = [content[@"errcontent"][@"type"] integerValue];
        if (type == 10) {
            NSString *jsonCode = [NSString stringWithFormat:@"wechatLoginResponse(%d)",false];
            [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }else{
            NSString *jsonCode = [NSString stringWithFormat:@"thirdPartyLoginResponse(%d,'%@')",false,@""];
            [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            }];
        }
    }
}

#pragma mark 绑定列表
- (void)onGetBindListResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg bindList:(NSArray *)bindList
{
    
    @synchronized (self.deviceArr) {
        NSMutableArray *muArr = [NSMutableArray array];
        //取消订阅
        for (NSDictionary *dic in _deviceArr) {
            if (dic[@"id"]) {
                NSString *realTopic = [NSString stringWithFormat:@"Q/client/will/+/%@",dic[@"id"]];
                [[MqttClientManager shareInstance].client unsubscribe:realTopic completionHandler:^(StartAIResultState res) {
                    
                }];
                
                NSString *newTopicArr = [NSString stringWithFormat:@"Q/client/%@-A",dic[@"id"]];
                [[MqttClientManager shareInstance].client unsubscribe:newTopicArr completionHandler:^(StartAIResultState res) {
                    
                }];
            }
        }
        
//        ===============================以局域网绑定为标准=====================================
//        添加云端设备
        for (NSDictionary *bindDic in bindList) {
            BOOL res = false;
            //重新订阅
            NSString *realTopic = [NSString stringWithFormat:@"Q/client/will/+/%@",bindDic[@"id"]];
            [[MqttClientManager shareInstance].client subscribe:realTopic completionHandler:^(StartAIResultState res) {
                
            }];
            
            NSString *newTopicArr = [NSString stringWithFormat:@"Q/client/%@-A",bindDic[@"id"]];
            [[MqttClientManager shareInstance].client subscribe:newTopicArr completionHandler:^(StartAIResultState res) {
                
            }];
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:bindDic];
            for (NSDictionary *dict in _deviceArr) {
                if ([dict[@"mac"] isEqualToString:bindDic[@"mac"]]) {
                    [muDic setValuesForKeysWithDictionary:dict];
                    // 以云端的设备状态为准
                    BOOL state = [bindDic[@"connstatus"]boolValue];
                    
                    [muDic setObject:@(state) forKey:@"state"];
                    
                    if ([ToolHandle toJsonString:[bindDic objectForKey:@"alias"]].length>0){
                        [muDic setObject:bindDic[@"alias"] forKey:@"name"];
                    }
                    
                    if ([ToolHandle toJsonString:[muDic objectForKey:@"alias"]].length>0) {
                        [muDic setObject:muDic[@"alias"] forKey:@"name"];
                    }
                    res = true;
                }
            }
                [muArr addObject:muDic];
        }
        
//         添加局域网已绑定的设备
        for (NSDictionary *dic in _deviceArr) {
            //加入局域网已绑定的设备
            BOOL res = false;
            for (NSDictionary *bindDict in bindList) {
                if ([bindDict[@"mac"] isEqualToString:dic[@"mac"]]) {
                    res = true;
                }
            }
            if (!res && !dic[@"bindingtime"] && [dic[@"isBinding"] boolValue]) {
                [muArr addObject:dic];
            }
        }
        
        for (NSDictionary *dict in _deviceArr) {
            BOOL res = false;
            for (NSDictionary *dic in muArr) {
                if ([dic[@"mac"] isEqualToString:dict[@"mac"]]) {
                    res = true;
                }
            }
            if (!res) {
                NSString *jsCode = [NSString stringWithFormat:@"unbundlingDeviceResponse(%d,'%@')",true,dict[@"mac"]];
                [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {

                }];
            }
        }
        
//===============================以广域网绑定为标准=====================================
        
//        for (NSDictionary *dict in _deviceArr) {
//            BOOL res = false;
//            //重新订阅
//            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dict];
//            for (NSDictionary *bindDic in bindList) {
//                if ([dict[@"mac"] isEqualToString:bindDic[@"mac"]]) {
//                    [muDic setValuesForKeysWithDictionary:bindDic];
//                    // 以云端的设备状态为准
//                    BOOL state = [bindDic[@"connstatus"]boolValue];
//                    [muDic setObject:@(state) forKey:@"state"];
//                    res = true;
//
//                    NSString *realTopic = [NSString stringWithFormat:@"Q/client/will/+/%@",dict[@"id"]];
//                    [[MqttClientManager shareInstance].client subscribe:realTopic completionHandler:^(StartAIResultState res) {
//
//                    }];
//
//                    NSString *newTopicArr = [NSString stringWithFormat:@"Q/client/%@-A",dict[@"id"]];
//                    [[MqttClientManager shareInstance].client subscribe:newTopicArr completionHandler:^(StartAIResultState res) {
//
//                    }];
//
//                    [muArr addObject:muDic];
//
//                }
//            }
//
//            if (!res && dict[@"id"]) {
//                NSString *jsCode = [NSString stringWithFormat:@"unbundlingDeviceResponse(%d,'%@')",true,dict[@"mac"]];
//                [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//                }];
//            }
//        }
        
//        for (NSDictionary *dict in bindList) {
//            BOOL res = false;
//            for (NSDictionary *dict2 in muArr) {
//                if ([dict[@"id"] isEqualToString:dict2[@"id"]]) {
//                    res = true;
//                }
//            }
//            if (!res) {
//                [muArr addObject:dict];
//            }
//        }
        
        _deviceArr = muArr;
        NSData *data = [NSJSONSerialization dataWithJSONObject:_deviceArr options:NSJSONWritingPrettyPrinted error:nil];
        [[NSFileManager defaultManager] createFileAtPath:self.bindListPath
                                                contents:data
                                              attributes:nil];
        
        [self refreshDeviceListWithLAN:false];
        
        for (NSDictionary *dic in _deviceArr) {
            if (self.updateDeviceInfo) {
                self.updateDeviceInfo(dic[@"mac"]);
            }
        }
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        for (NSDictionary *dic in _deviceArr) {
            if (dic[@"id"] && !dic[@"connstatus"]) {
                [[MqttClientManager shareInstance].client beBind:dic[@"id"] completionHandler:^(StartAIResultState res) {
                    
                }];
            }
        }
    });
}

#pragma mark 绑定设备
- (void)onBindResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg beBindInfo:(NSDictionary *)beBindInfo
{
    
    NSLog(@"onBindResult %d  - %@  - %@ --- %@",result,errorCode,errorMsg,beBindInfo);
    
    NSString *sn = [beBindInfo objectForKey:@"id"];
    NSString *topic = [NSString stringWithFormat:@"Q/client/will/+/%@",sn];
    if (result) {
        [[MqttClientManager shareInstance].client subscribe:topic completionHandler:^(StartAIResultState res) {
            
        }];
        [[MqttClientManager shareInstance].client getBindListWithType:1 completionHandler:^(StartAIResultState res) {
            
        }];
    }
}

#pragma mark 解绑设备
- (void)onUnBindResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg unBindContent:(id)contet
{
    
    NSLog(@"onUnBindResult %d  - %@  - %@ --- %@",result,errorCode,errorMsg,contet);
    
    if (result == true) {
        NSString *id1 = contet[@"beunbindingid"];
        NSString *id2 = contet[@"unbindingid"];
        NSString *unBindId;
        NSString *mac = @"";
        
        @synchronized (self.deviceArr) {
            for (NSDictionary *dic in self.deviceArr) {
                if ([dic[@"id"] isEqualToString:id1] ) {
                    unBindId = id1;
                    mac = dic[@"mac"];
                    [self.deviceArr removeObject:dic];
                    break;
                }else if ([dic[@"id"] isEqualToString:id2]){
                    unBindId = id2;
                    mac = dic[@"mac"];
                    [self.deviceArr removeObject:dic];
                    break;
                }
            }
        }
        
        NSString *jsCode = [NSString stringWithFormat:@"unbundlingDeviceResponse(%d,'%@')",result,mac];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        
        [[MqttClientManager shareInstance].client getBindListWithType:1 completionHandler:^(StartAIResultState res) {

        }];
        
        NSString *topic = [NSString stringWithFormat:@"Q/client/will/+/%@",unBindId];
        [[MqttClientManager shareInstance].client unsubscribe:topic completionHandler:^(StartAIResultState res) {
            
        }];
        
        NSString *newTopicArr = [NSString stringWithFormat:@"Q/client/%@-A",unBindId];
        [[MqttClientManager shareInstance].client unsubscribe:newTopicArr completionHandler:^(StartAIResultState res) {
            
        }];
        
    }
}

#pragma mark 获取用户信息
- (void)onGetUserInfoResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg userInfo:(id)userInfo
{
    NSString *json = [ToolHandle toJsonString:userInfo];
    NSString *jsCode = [NSString stringWithFormat:@"userInformationResponse(%d,'%@')",result,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    if (result) {
        if (self.userInfoHandler) {
            self.userInfoHandler(userInfo);
        }
    }
}

#pragma mark 修改用户信息
- (void)onUpdateUserInfoResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg userInfo:(id)userInfo
{

    NSString *json = [ToolHandle toJsonString:userInfo];
    NSString *jsCode = [NSString stringWithFormat:@"modifyUserInformationResponse(%d,'%@')",result,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    if (result) {
        NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:QXLoginStore];
        [[MqttClientManager shareInstance].client getUserInfoByLoginType:type completionHandler:^(StartAIResultState res) {
            
        }];
    }
}

#pragma mark 修改密码
- (void)onUpdateUserPwdResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg pwdContent:(id)pwdContent
{
    NSString *jsCode = [NSString stringWithFormat:@"changePasswordResponse(%d,'%@')",result,errorCode];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 忘记密码
- (void)onSendEmailResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg emailContent:(id)emailContent
{
    NSString *jsCode = [NSString stringWithFormat:@"emailForgotResponse(%d,'%@')",result,errorCode];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 获取最新版本
- (void)onGetLatestVersionResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg versionInfo:(id)versionInfo
{
    if (result) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        CGFloat app_Version = [[info objectForKey:@"CFBundleShortVersionString"] floatValue];
        CGFloat version = [versionInfo[@"version"]floatValue];
//        NSString *app_build = [info objectForKey:@"CFBundleVersion"];
        if (version > app_Version) {
            NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%.1f)",true,@"",version];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }else{
            NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%d)",true,errorCode,0];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }
    }else{
        NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%d)",true,errorCode,0];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 获取支付宝密钥
- (void)onGetAlipayKeyResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg content:(id)content
{
    if (result) {
        NSString *packageIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *scheme;
        if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
            scheme = StartAIMUSIKScheme;
        }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
            scheme = WanWifiSocketScheme;
        }else if ([packageIdentifier isEqualToString:WanLondonSocket]){
            scheme = WanLondonSocketScheme;
        }else if ([packageIdentifier isEqualToString:NBSocket]){
            scheme = NBSocketScheme;
        }
//        NSString *authTargetId = content[@"authTargetId"];
        NSString *aliPayAuthInfo = content[@"aliPayAuthInfo"];

        [[AlipaySDK defaultService] auth_V2WithInfo:aliPayAuthInfo fromScheme:scheme callback:^(NSDictionary *resultDic) {
            NSLog(@"支付宝授权-----------------------result = %@",resultDic);
            [[LoginModel shareInstace] aliPayLoginState:resultDic];
        }];
    }else{
        [self errorCodeResponse:errorCode];
    }
}


#pragma mark 绑定手机号
- (void)onBindMobileResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg content:(id)content
{
    if (result) {
        [[MqttClientManager shareInstance].client getUserInfoByLoginType:1 completionHandler:^(StartAIResultState res) {
            
        }];
    }else{
        [self errorCodeResponse:errorCode];
    }
    
}

#pragma mark 绑定第三方账号
- (void)onBindThirdAPPResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg content:(id)content
{
    if (result) {
        [[MqttClientManager shareInstance].client getUserInfoByLoginType:1 completionHandler:^(StartAIResultState res) {
            
        }];
    }else{
        [self errorCodeResponse:errorCode];
    }
    NSString *jsCode = [NSString stringWithFormat:@"modifyUserInformationResponse(%d,'%@')",result,@""];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 解绑第三方账号
- (void)onUnbindThirdAPPResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg content:(id)content
{
    if (result) {
        [[MqttClientManager shareInstance].client getUserInfoByLoginType:1 completionHandler:^(StartAIResultState res) {
            
        }];
        NSInteger type = [content[@"type"] integerValue];
        if (type == 10) {
            NSString *jsCode = [NSString stringWithFormat:@"untiedWechatResponse(%d)",result];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }else if (type == 11){
            NSString *jsCode = [NSString stringWithFormat:@"untiedAlipayResponse(%d)",result];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }
    }else{
        [self errorCodeResponse:errorCode];
    }

}

#pragma mark 透传消息
- (void)onPassthroughResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg fromid:(NSString *)fromid object:(id)object
{
    @synchronized (self.deviceArr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *string = object;
            if (string.length %2 ==0 ) {
                NSMutableData *data = [[NSMutableData alloc] init];
                for (NSInteger i=0; i<string.length; i+=2) {
                    NSString *str = [string substringWithRange:NSMakeRange(i, 2)];
                    NSScanner *scanner = [NSScanner scannerWithString:str];
                    unsigned int value ;
                    [scanner scanHexInt:&value];
                    [data appendBytes:&value length:1];
                }
                [[HandlingDataModel shareInstance] handlingRecevieData:data deviceIdentifiy:fromid fromAddress:nil];
            }
        });
    }
}
#pragma mark 查询当地天气
- (void)onQueryTemperatureAndAirQualityResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg content:(id)content
{
    if (result) {
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:content];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm"];
        
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
        [formatter setTimeZone:timeZone];
        
        NSString *pubTime = [ToolHandle toJsonString:content[@"pubtime"]];
        NSDate* date = [formatter dateFromString:pubTime]; //------------将字符串按formatter转成nsdate
        NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
        
        if ( labs(([ToolHandle getNowTime] - timeSp)) <= 3600*8) {
            [muDic setObject:@(timeSp) forKey:@"gettime"];
        }else{
            [muDic setObject:@([ToolHandle getNowTime]) forKey:@"gettime"];
        }
        
        NSString *json = [ToolHandle toJsonString:muDic];
        NSString *jsCode = [NSString stringWithFormat:@"localWeatherResponse(%d,'%@')",true,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        
        NSString *key = [NSString stringWithFormat:@"%@",[ToolHandle toJsonString:content[@"city"]]];
        if (![key containsString:@"市"]) {
            key = [NSString stringWithFormat:@"%@市",key];
        }
        [[NSUserDefaults standardUserDefaults] setObject:muDic forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSString *jsCode = [NSString stringWithFormat:@"localWeatherResponse(%d,'%@')",false,@""];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 所有消息回调
- (void)receviceMessage:(StartaiMqMessage *)message
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message.msg options:NSJSONReadingAllowFragments error:nil];
    NSString *msgtype = dic[@"msgtype"];
    
        if ([msgtype isEqualToString:@"0x9998"] || [msgtype isEqualToString:@"0x9999"]) {
            NSDictionary * content = dic[@"content"];
            NSString *sn = content[@"sn"];
            NSString *client = content[@"clientid"];
            if (!client) {
                client = sn;
            }
            @synchronized (self.deviceArr) {
                BOOL state = false;
                if ([msgtype isEqualToString:@"0x9998"]){
                    state = true;
                }
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (NSDictionary *dic in _deviceArr) {
                    if (dic[@"id"] && [dic[@"id"] isEqualToString:client]) {
                        [dict setValuesForKeysWithDictionary:dic];
                        [_deviceArr removeObject:dic];
                        break;
                    }
                }
                if (dict.allKeys.count) {
                    [dict setObject:@(state) forKey:@"state"];
                    [_deviceArr addObject:dict];
                    NSData *data = [NSJSONSerialization dataWithJSONObject:_deviceArr options:NSJSONWritingPrettyPrinted error:nil];
                    [[NSFileManager defaultManager] createFileAtPath:self.bindListPath contents:data attributes:nil];
                }
            }
            [self refreshDeviceListWithLAN:false];
            [[UDPSocket shareInstance] startFindDevice];
        }
    
    DDLog(@"MQTTKit收到消息...................%@",dic);
}

#pragma mark 设备列表缓存路径
- (NSString *)bindListPath
{
//    if (!_bindListPath) {
        NSString *floderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"BindFloder"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:floderPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:floderPath withIntermediateDirectories:true attributes:nil error:nil];
        }
        _bindListPath = [floderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",[MqttClientManager shareInstance].client.userid]];
//    }
    return _bindListPath;
}

- (void)errorCodeResponse:(NSString *)errCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *jsCode = [NSString stringWithFormat:@"errorCodeResponse('%@')",errCode];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];

    });
}

@end
