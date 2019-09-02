//
//  UserInfoModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/8/28.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "UserInfoModel.h"
#import "LoginModel.h"

@interface UserInfoModel ()<WKScriptMessageHandler>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *surename;
@property (nonatomic, strong) NSMutableDictionary *userDic;

@end

@implementation UserInfoModel

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
        _userDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)funcArr
{
    return @[
             @"takePhotoRequest",   //手机拍照
             @"localPhotoRequest",  //本地照片
             @"changePasswordRequest",  //修改密码
             @"inspectversionUpdateRequest",    //检查版本是否有更新
             @"versionUpdateRequest",   //版本更新
             @"cancelVersionUpdateRequest",  //取消版本更新
             @"versionNumberRequest",   //版本号请求
             @"userInformationRequest", //查询用户信息
             @"modifyUsernameRequest",  //修改用户名
             @"modifyNicknameRequest",  //修改昵称
             @"bindMobilePhoneRequest", //绑定手机号
             @"bindingWeChatRequest",   //绑定微信
             @"bindingAlipayRequest",   //绑定支付宝
             @"untiedMobilePhoneRequest",   //解绑手机号
             @"untiedWechatRequest",   //解绑微信
             @"untiedAlipayRequest",   //解绑支付宝
             @"submitFeedbackRequest",  //提交已经反馈
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"takePhotoRequest":@"takePhotoRequest:",   //手机拍照
             @"localPhotoRequest":@"localPhotoRequest:",  //本地照片
             @"changePasswordRequest":@"changePasswordRequest:",  //修改密码
             @"inspectversionUpdateRequest":@"inspectversionUpdateRequest:",    //检查版本是否有更新
             @"versionUpdateRequest":@"versionUpdateRequest:",   //版本更新
             @"cancelVersionUpdateRequest":@"cancelVersionUpdateRequest:",  //取消版本更新
             @"versionNumberRequest":@"versionNumberRequest:",   //版本号请求
             @"userInformationRequest":@"userInformationRequest:", //查询用户信息
             @"modifyUsernameRequest":@"modifyUsernameRequest:",  //修改用户名
             @"modifyNicknameRequest":@"modifyNicknameRequest:",  //修改昵称
             @"bindMobilePhoneRequest":@"bindMobilePhoneRequest:", //绑定手机号
             @"bindingWeChatRequest":@"bindingWeChatRequest:",   //绑定微信
             @"bindingAlipayRequest":@"bindingAlipayRequest:",   //绑定支付宝
             @"untiedMobilePhoneRequest":@"untiedMobilePhoneRequest:",   //解绑手机号
             @"untiedWechatRequest":@"untiedWechatRequest:",   //解绑微信
             @"untiedAlipayRequest":@"untiedAlipayRequest:",   //解绑支付宝
             @"submitFeedbackRequest":@"submitFeedbackRequest:",  //提交已经反馈
             };
}

#pragma mark 查询用户信息
- (void)userInformationRequest:(NSDictionary *)object
{
    NSString *clientid = [MqttClientManager shareInstance].client.userid;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:clientid]) {
        self.userDic = [[NSUserDefaults standardUserDefaults] objectForKey:clientid];
        NSString *json = [ToolHandle toJsonString:self.userDic];
        NSString *jsCode = [NSString stringWithFormat:@"userInformationResponse(%d,'%@')",true,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
    
    @weakify(self);
    NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:QXLoginStore];
    [[MqttClientManager shareInstance].client getUserInfoByLoginType:type completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
}

#pragma mark 手机拍照
- (void)takePhotoRequest:(NSDictionary *)object
{
    if (self.jumpPhotoController) {
        self.jumpPhotoController(1);
    }
}

#pragma mark 本地照片
- (void)localPhotoRequest:(NSDictionary *)object
{
    if (self.jumpPhotoController) {
        self.jumpPhotoController(2);
    }
}

#pragma mark 头像返回
- (void)getPhotoResponse:(NSString *)imgUrl result:(BOOL)result
{
//    NSData *imgData = UIImageJPEGRepresentation(img, 1);
//    NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@",[imgData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];

    if (self.userDic && imgUrl.length) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.userDic];
        [dic setObject:imgUrl forKey:@"headPic"];
        NSString *json = [ToolHandle toJsonString:dic];
        NSString *jsCode1 = [NSString stringWithFormat:@"userInformationResponse(%d,'%@')",true,json];
        [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {

        }];
        NSString *clientid = [MqttClientManager shareInstance].client.userid;
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:clientid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *nickName = [ToolHandle fillNullString:self.userDic[@"nickName"]];
        [self modifyNicknameRequest:@{@"name":nickName,@"headPic":imgUrl}];
    }else{
        NSString *jsCode = [NSString stringWithFormat:@"modifyUserInformationResponse(%d,'%@')",result,@""];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
    
    NSString *jsCode = [NSString stringWithFormat:@"modifyAvatarSendedResponse(%d)",result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma makr 修改密码
- (void)changePasswordRequest:(NSDictionary *)object
{
    NSString *oldPassword = [object objectForKey:@"oldPassword"];
    NSString *newPassword = [object objectForKey:@"newPassword"];
    
    @weakify(self);
    [[MqttClientManager shareInstance].client updateUserPwdWithOldPwd:oldPassword newPwd:newPassword completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
}

#pragma mark 检查版本是否更新
- (void)inspectversionUpdateRequest:(NSDictionary *)object
{
    @weakify(self);
//    [[MqttClientManager shareInstance].client getLatestVersionWithOS:@"" packageName:@"" completionHandler:^(StartAIResultState res) {
//
//    }];
//    @"http://itunes.apple.com/lookup?id=1432400374"   获取商店app信息 蓝牙插座
//    http://itunes.apple.com/lookup?id=1444573076      musik

//    return;
    NSString *packageIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
//    NSString *url = [NSString stringWithFormat:@"http://api.fir.im/apps/latest/%@?api_token=6853beb999dd05896960cd49fdfdaa7f&type=ios",packageIdentifier];
    NSString *packID;
    if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
        packID = @"1444573076";
    }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
        packID = @"";
    }else if([packID isEqualToString:WanLondonSocket]){
        packID = @"";
    }else if ([packID isEqualToString:NBSocket]){
        packID = @"";
    }else{
        packID = @"";
    }
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",packID];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id object = responseObject;
        if ([responseObject isKindOfClass:[NSData class]]) {
             object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        }
//        if ([object isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//            NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
//            NSString *version = object[@"version"];
//            if ([version floatValue]-[app_build floatValue]>0.099) {
//                NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%.1f)",true,@"",[object[@"version"]floatValue]];
//                [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//                }];
//            }else{
//                NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%d)",true,@"0x801604",0];
//                [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//                }];
//            }
//
//        }
        if (object[@"results"] && [object[@"results"] isKindOfClass:[NSArray class]]) {
            NSArray *arr = object[@"results"];
            if ([[arr firstObject] isKindOfClass: [NSDictionary class]]) {
                NSDictionary *resultsDic = [arr firstObject];
                CGFloat version = [resultsDic[@"version"] floatValue];
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                CGFloat app_build = [[infoDictionary objectForKey:@"CFBundleVersion"] floatValue];
                CGFloat app_version = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];
                if (version-app_version>0.09) {
                    NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%.1f)",true,@"",version];
                    [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {

                    }];
                }else{
                    NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%d)",true,@"0x801604",0];
                    [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {

                    }];
                }
            }else{
                NSString *jsCode = [NSString stringWithFormat:@"inspectVersionUpdateResponse(%d,'%@',%d)",true,@"0x801604",0];
                [weak_self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                    
                }];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}

#pragma mark 版本更新
- (void)versionUpdateRequest:(NSDictionary *)object
{
    
//      跳转商店app
    NSString *packageIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *packID;
    if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
        packID = @"1444573076";
    }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
        packID = @"";
    }else if([packID isEqualToString:WanLondonSocket]){
        packID = @"";
    }else if ([packID isEqualToString:NBSocket]){
        packID = @"";
    }else{
        packID = @"";
    }
    NSURL *storeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/%@",packID]];
    [[UIApplication sharedApplication] openURL:storeUrl];
    return;
    if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
        //自研插座
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"https://fir.im/startaiMUSIC"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://fir.im/startaiMUSIC"]];
        }
    }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
        //万总wifi插座
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"https://fir.im/miniWiFi"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://fir.im/miniWiFi"]];
        }
    }else if ([packageIdentifier isEqualToString:WanLondonSocket]){
        //英国插座
    }else if ([packageIdentifier isEqualToString:NBSocket]){
        //NBSocket
    }
}

#pragma mark 取消版本更新
- (void)cancelVersionUpdateRequest:(NSDictionary *)object
{
    
}

#pragma mark 版本号请求
- (void)versionNumberRequest:(NSDictionary *)object
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app正式版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString *jsCode = [NSString stringWithFormat:@"versionNumberResponse('%@')",app_Version];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 修改用户名
- (void)modifyUsernameRequest:(NSDictionary *)object
{
//    self.name = [ToolHandle fillNullString:self.userDic[@"firstName"]];
//    self.surename = [ToolHandle fillNullString:self.userDic[@"lastName"]];
//    NSString *type = [ToolHandle fillNullString: object[@"type"] ];
//    if ([type isEqualToString:@"name"]) {
//        self.name = [ToolHandle fillNullString:object[@"value"]];
//    }else{
//        self.surename = [ToolHandle fillNullString:object[@"value"]];
//    }
//    NSString *headPic = [ToolHandle fillNullString:object[@"headPic"]];
//    if (!headPic.length) {
//        headPic = [ToolHandle fillNullString:self.userDic[@"headPic"]];
//    }
//
//    StartAIUserInfoEntity *entity = [[StartAIUserInfoEntity alloc] init];
//    entity.userid = [MqttClientManager shareInstance].client.userid;
//    entity.userName = @"";
//    entity.firstName = self.name;
//    entity.lastName = self.surename;
//    entity.birthday = @"1999-9-9";
//    entity.province = @"广东";
//    entity.city = @"广州";
//    entity.town = @"广州";
//    entity.address = @"广州";
//    entity.nickName = @"昵称";
//    entity.headPic = headPic;
//    entity.sex = @"0";
    
    
//    @weakify(self);
//    [[MqttClientManager shareInstance].client updateUserInfoWithUserInfoEntity:entity completionHandler:^(StartAIResultState res) {
//        [weak_self errorCodeResponse:res];
//    }];
}

#pragma mark 修改昵称
- (void)modifyNicknameRequest:(NSDictionary *)object
{
    
    NSString *headPic = [ToolHandle fillNullString:object[@"headPic"]];
    if (!headPic.length) {
        headPic = [ToolHandle fillNullString:self.userDic[@"headPic"]];
    }
    
    StartAIUserInfoEntity *entity = [[StartAIUserInfoEntity alloc] init];
    entity.userid = [MqttClientManager shareInstance].client.userid;
    entity.userName = [ToolHandle fillNullString:self.userDic[@"username"]];
    entity.firstName = [ToolHandle fillNullString:self.userDic[@"firstName"]];
    entity.lastName = [ToolHandle fillNullString:self.userDic[@"lastName"]];
    entity.birthday = [ToolHandle fillNullString:self.userDic[@"birthday"]];
    entity.province = [ToolHandle fillNullString:self.userDic[@"province"]];
    entity.city = [ToolHandle fillNullString:self.userDic[@"city"]];
    entity.town = [ToolHandle fillNullString:self.userDic[@"town"]];
    entity.address = [ToolHandle fillNullString:self.userDic[@"address"]];
    entity.nickName = [ToolHandle toJsonString:[object objectForKey:@"name"] ];
    entity.headPic = headPic;
    entity.sex = @"0";
//    modifyUserInformationResponse
    @weakify(self);
    [[MqttClientManager shareInstance].client updateUserInfoWithUserInfoEntity:entity completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    
    NSString *jsCode = [NSString stringWithFormat:@"modifyUserInformationResponse(%d,'%@')",true,entity.nickName];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

#pragma mark 绑定手机号
- (void)bindMobilePhoneRequest:(NSDictionary *)object
{
    @weakify(self);
    NSString *phone = [ToolHandle toJsonString:object[@"phone"]];
    [[MqttClientManager shareInstance].client bindMobile:phone completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
}

#pragma mark 绑定微信
- (void)bindingWeChatRequest:(NSDictionary *)object
{
    if ([WXApi isWXAppInstalled]) {
        [LoginModel shareInstace].isBindWx = true;
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

#pragma mark 绑定支付宝
- (void)bindingAlipayRequest:(NSDictionary *)object
{

    @weakify(self);
    [LoginModel shareInstace].isBindAlipay = true;
    NSString *thirdBind = [NSString stringWithFormat:@"thirdBind%lld",[ToolHandle getNowTime]];
    [[MqttClientManager shareInstance].client getAlipayKeyType:thirdBind completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
    
}

#pragma mark 解绑手机号
- (void)untiedMobilePhoneRequest:(NSDictionary *)object
{
    [[MqttClientManager shareInstance].client bindMobile:@"" completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 解绑微信
- (void)untiedWechatRequest:(NSDictionary *)object
{
    @weakify(self);
    [[MqttClientManager shareInstance].client unbindThirdAPPWithPlatformType:10 completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
}

#pragma mark 解绑支付宝
- (void)untiedAlipayRequest:(NSDictionary *)object
{
    @weakify(self);
    [[MqttClientManager shareInstance].client unbindThirdAPPWithPlatformType:11 completionHandler:^(StartAIResultState res) {
        [weak_self errorCodeResponse:res];
    }];
}


#pragma mark 提交意见反馈
- (void)submitFeedbackRequest:(NSDictionary *)object
{
    
}


- (void)updateUserInfoDic:(NSDictionary *)dic
{
    NSString *clientid = [MqttClientManager shareInstance].client.userid;
    self.userDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:clientid];
}

-(void)registFunctionWithWeb:(WKWebView *)web
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
