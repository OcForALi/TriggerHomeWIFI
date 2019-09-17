//
//  LoginModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/10/16.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "LoginModel.h"
#import "UserInfoModel.h"
#import <GoogleSignIn/GIDSignIn.h>
#import "UDPSocket.h"

@interface LoginModel()<WKScriptMessageHandler>
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) WiFiLoginType loginType;
@end

@implementation LoginModel


+ (instancetype)shareInstace
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSArray *)funcArr
{
    return @[
             @"isLoginRequest",                 //是否登陆
             @"thirdPartyLoginRequest",          //第三方登陆
             @"wechatLoginRequest",              //微信登陆f
             @"alipayLoginRequest",              //支付宝登陆
             @"getMobilePhoneCodeRequest",        //获取手机验证码
             @"mobileLoginRequest",              //手机号登陆
             @"emailLoginRequest",               //邮箱登陆
             @"emailSignupRequest",              //邮箱注册
             @"emailForgotRequest",              //邮箱找回密码
             @"reSendemailRequest",              //重发邮件
             @"logoutUserRequest",               //登出
             @"bindThirdPartyAccountRequest",    //绑定第三方账号
             @"untiedThirdPartyRequest",         //解绑第三方账号
             ];
}

- (NSDictionary *)funcDic
{
    return @{

             @"isLoginRequest":@"isLoginRequest:",  //是否登陆
             @"thirdPartyLoginRequest":@"thirdPartyLoginRequest:",  //第三方登陆
             @"wechatLoginRequest":@"wechatLoginRequest:",         //微信登陆
             @"alipayLoginRequest":@"alipayLoginRequest:",              //支付宝登陆
             @"mobileLoginRequest":@"mobileLoginRequest:",  //手机号登陆
             @"getMobilePhoneCodeRequest":@"getMobilePhoneCodeRequest:", //获取手机验证码
             @"emailLoginRequest":@"emailLoginRequest:",           //邮箱登陆
             @"emailSignupRequest":@"emailSignupRequest:",     //邮箱注册
             @"emailForgotRequest":@"emailForgotRequest:",    //邮箱找回密码
             @"reSendemailRequest":@"reSendemailRequest:",  //重发邮件
             @"logoutUserRequest":@"logoutUserRequest:",    //登出
             @"bindThirdPartyAccountRequest":@"bindThirdPartyAccountRequest:",   //绑定第三方账号
             @"untiedThirdPartyRequest":@"untiedThirdPartyRequest:",         //解绑第三方账号
             
             };
}

#pragma mark 是否登陆
- (void)isLoginRequest:(NSDictionary *)object
{
    BOOL result = false;
    if ([MqttClientManager shareInstance].client.userid.length) {
        result = true;
        [[UDPSocket shareInstance] electricQuantity];
    }
    
    NSString *jsCode = [NSString stringWithFormat:@"isLoginResponse(%d)",result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    NSString *clientid = [MqttClientManager shareInstance].client.userid;
    if (result && [[NSUserDefaults standardUserDefaults] objectForKey:clientid]) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:clientid];
        NSString *json = [ToolHandle toJsonString:dic];
        NSString *jsCode = [NSString stringWithFormat:@"userInformationResponse(%d,'%@')",true,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}


#pragma mark 第三方登陆
- (void)thirdPartyLoginRequest:(NSDictionary *)object
{
    NSString *type = [object objectForKey:@"type"];
    if (self.loginHandler) {
        self.loginHandler(type,0);
    }
}

#pragma mark 微信登陆
- (void)wechatLoginRequest:(NSDictionary *)object
{
    
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *auth = [[SendAuthReq alloc] init];
        auth.scope = @"snsapi_userinfo";
        auth.state = @"123";
        [WXApi sendReq:auth];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *jsCode = [NSString stringWithFormat:@"errorCodeResponse('%@')",@"0x830398"];
            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
            
        });
    }
    
}

- (void)wxLoginState:(SendAuthResp *)resp
{
    @weakify(self);
    BOOL res;
    if (resp.errCode == 0) {
        res = true;
        if (self.isBindWx) {
            self.isBindWx = false;
            
            [[MqttClientManager shareInstance].client bindThirdAPPWithPlatformCode:resp.code type:10 completionHandler:^(StartAIResultState res) {
                [weak_self errorCodeResponse:res];
            }];
        }else{

            [[MqttClientManager shareInstance].client thirdLoginWithCode:resp.code type:10 thirdUserEntity:nil completionHandler:^(StartAIResultState res) {
                [weak_self errorCodeResponse:res];
            }];
        }
    }else{
        res = false;
        NSString *jsCode = [NSString stringWithFormat:@"wechatLoginResponse(%d)",res];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 支付宝登陆
- (void)alipayLoginRequest:(NSDictionary *)object
{
    @weakify(self);
    NSString *login = [NSString stringWithFormat:@"Login%lld",[ToolHandle getNowTime]];
    [[MqttClientManager shareInstance].client getAlipayKeyType:login completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
}

- (void)aliPayLoginState:(NSDictionary *)resultDic
{
    NSString *result = resultDic[@"result"];
    NSString *authCode = nil;
    if (result.length>0) {
        NSArray *resultArr = [result componentsSeparatedByString:@"&"];
        for (NSString *subResult in resultArr) {
            if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                authCode = [subResult substringFromIndex:10];
                break;
            }
        }
    }
    
    @weakify(self);
    BOOL res;
    if (authCode) {
        res = true;
        if (self.isBindAlipay) {
            self.isBindAlipay = false;
            [[MqttClientManager shareInstance].client bindThirdAPPWithPlatformCode:authCode type:11 completionHandler:^(StartAIResultState res) {
                [weak_self errorCodeResponse:res];
            }];
        }else{
            [[MqttClientManager shareInstance].client thirdLoginWithCode:authCode type:11 thirdUserEntity:nil completionHandler:^(StartAIResultState res) {
                [weak_self errorCodeResponse:res];
            }];
        }

    }else{
        res = false;
        NSString *jsCode = [NSString stringWithFormat:@"alipayLoginResponse(%d)",res];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }

    NSLog(@"支付宝授权结果 authCode = %@", authCode?:@"");
}

#pragma mark 获取验证码
- (void)getMobilePhoneCodeRequest:(NSDictionary *)object
{
    @weakify(self);
    self.phone = object[@"phone"];
    
    [[MqttClientManager shareInstance].client getIdentifyCodeWithMobile:[ToolHandle toJsonString:object[@"phone"]] type:1 completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
}

#pragma mark 手机号登陆
- (void)mobileLoginRequest:(NSDictionary *)object
{
    if (object[@"phone"]) {
        self.phone = object[@"phone"];
    }
    self.loginType = phoneLogin;
    self.code = object[@"code"];
    @weakify(self);

    [[MqttClientManager shareInstance].client loginWithUsername:self.phone password:@"" identifyCode:self.code type:3 completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    
}

#pragma mark 邮箱登陆
- (void)emailLoginRequest:(NSDictionary *)object
{
    self.loginType = emailLogin;
    [MqMessageResponseModel shareInstance].loginType = emailLogin;
    NSString *username = [object objectForKey:@"email"];
    NSString *password = [object objectForKey:@"password"];
    @weakify(self);
    
    [[MqttClientManager shareInstance].client loginWithUsername:username password:password identifyCode:@"" type:1 completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    
}

#pragma mark 邮箱注册
- (void)emailSignupRequest:(NSDictionary *)object
{
    NSString *username = [object objectForKey:@"email"];
    NSString *password = [object objectForKey:@"password"];
    @weakify(self);
    
    [[MqttClientManager shareInstance].client registWithUsername:username password:password type:1 completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    
}

#pragma mark 邮箱找回密码·
- (void)emailForgotRequest:(NSDictionary *)object
{
    NSString *username = [object objectForKey:@"email"];
    @weakify(self);
    [[MqttClientManager shareInstance].client sendEmail:username type:2 completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    
}

#pragma mark 重发邮件
- (void)reSendemailRequest:(NSDictionary *)object{
    
    NSString *username = [object objectForKey:@"email"];
    
    @weakify(self);
    [[MqttClientManager shareInstance].client sendEmail:username type:1 completionHandler:^(StartAIResultState res) {
        
        if (res == StartAIResultState_SUCCESS) {
            
            NSString *jsCode = [NSString stringWithFormat:@"reSendemailResponse(%d)",true];
            [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
            
        }
        
        [weak_self errorCodeResponse:res];
    }];
    
}

#pragma mark 注销用户
- (void)logoutUserRequest:(NSDictionary *)object
{
    
    [[UserInfoModel shareInstance] updateUserInfoDic:@{}];
    
    NSString *clientid = [MqttClientManager shareInstance].client.userid;
    NSString *bindListPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"BindFloder"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",[MqttClientManager shareInstance].client.userid]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:clientid];
    [[NSFileManager defaultManager] removeItemAtPath:bindListPath error:nil];
    [[UDPSocket shareInstance].deviceInfoArr removeAllObjects];
    
    [[UDPSocket shareInstance] closed];
    [[MqttClientManager shareInstance].client logout:^(StartAIResultState res) {
        
    }];
    NSString *jsCode = [NSString stringWithFormat:@"logoutUserResponse(%d)",true];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    NSString *json = [ToolHandle toJsonString:[UDPSocket shareInstance].deviceInfoArr];
    jsCode = [NSString stringWithFormat:@"deviceListResponse('%@')",json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    @weakify(self);
    NSString *newTopic = [NSString stringWithFormat:@"Q/client/%@/#",[[MqttClientManager shareInstance].client userid]];
    [[MqttClientManager shareInstance].client unsubscribe:newTopic completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    
    NSString *topic = [NSString stringWithFormat:@"Q/client/%@/#",[[MqttClientManager shareInstance].client sn]];
    [[MqttClientManager shareInstance].client subscribe:topic completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    

    
}

#pragma mark 绑定第三方账号
- (void)bindThirdPartyAccountRequest:(NSDictionary *)object{

    NSString *type = [object objectForKey:@"type"];
    if (self.loginHandler) {
        self.loginHandler(type,1);
    }
    
}

#pragma mark 解绑第三方账号
- (void)untiedThirdPartyRequest:(NSDictionary *)object{
    
    NSString *type = [object objectForKey:@"type"];

    if ([type isEqualToString:@"Google"]) {
        [[MqttClientManager shareInstance].client unbindThirdAPPWithPlatformType:13 completionHandler:^(StartAIResultState res) {
            
        } ];
    }else if ([type isEqualToString:@"Facebook"]){
        [[MqttClientManager shareInstance].client unbindThirdAPPWithPlatformType:16 completionHandler:^(StartAIResultState res) {
            
        } ];
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
