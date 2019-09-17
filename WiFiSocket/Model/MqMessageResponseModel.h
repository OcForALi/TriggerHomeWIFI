//
//  MqMessageResponseModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/9/17.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

typedef NS_ENUM(NSInteger, QXLoginType){
    QXLoginEmailAndPwd = 1,
    QXPhoneAndPwdLoigin = 2,
    QXPhoneAndCodeLogin = 3,
    QXUsernameAndPwdLogin = 4,
    QXPhoneAndCoedAndPwdLogin = 5,
    QXWechatLogin = 10,
    QXAliPayLogin = 11,
    QXQQLogin = 12,
    QXGoogleLogin = 13,
    QXTwitterLogin = 14,
    QXAmazonLogin= 15,
    QXFacebookLogin = 16,
    QXXiaomiLogin = 17,
    QXWechatSmallProgram = 18,
};


typedef NS_ENUM(NSInteger,WiFiLoginType){
    phoneLogin = 0,
    emailLogin = 1,
};

@interface MqMessageResponseModel : BaseModel

@property (nonatomic, assign) WiFiLoginType loginType;
@property (nonatomic, strong) NSMutableArray *deviceArr;    //所有设备
@property (nonatomic, strong) NSMutableArray *lanArr;      //局域网搜索设备
@property (nonatomic, strong) NSDictionary *deviceDic;  //设备信息整合
@property (nonatomic, assign) BOOL isConnect;
@property (nonatomic, copy) void(^updateDeviceInfo)(NSString *mac); //主动刷新设备属性

@property (nonatomic, strong) void(^userInfoHandler)(NSDictionary *dic);

//+ (instancetype)shareInstance;

- (void)networkStatusResponse;

@end
