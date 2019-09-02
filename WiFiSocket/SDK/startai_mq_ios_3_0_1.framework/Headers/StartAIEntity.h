//
//  StartAIEntity.h
//  MQTTClient
//
//  Created by Mac on 2018/7/3.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StartAIResultState){
    StartAIResultState_CONN_PENDING = -1,
    StartAIResultState_SUCCESS = 0,
    StartAIResultState_NOMEM = 1,
    StartAIResultState_PROTOCOL = 2,
    StartAIResultState_INVAL = 3, //4003        //未激活SDK
    StartAIResultState_CONN = 4,
    StartAIResultState_REFUSED = 5,
    StartAIResultState_NOT_FOUND = 6,
    StartAIResultState_CONN_LOST = 7,
    StartAIResultState_TLS = 8,
    StartAIResultState_PAYLOAD_SIZE = 9,
    StartAIResultState_NOT_SUPPORTED = 10,
    StartAIResultState_AUTH = 11,//4002
    StartAIResultState_ACL_DENIED = 12,
    StartAIResultState_UNKNOWN = 13,
    StartAIResultState_ERRNO = 14,
    StartAIResultState_EAI = 15,
    StartAIResultState_PROXY = 16,
    StartAIResultState_NOT_MOIF= 17,
    StartAIResultState_NOTSEND_NOCON = 5001,        //连接断开
    StartAIResultState_NOTSEND_ERROR = 5003,
    StartAIResultState_NOTSEND_BADNET = 5004,       //网络很差
    StartAIResultState_NOTSEND_NOLOGIN = 5006,      //未登录
    StartAIResultState_DIS = 6002,
    StartAIResultState_TIMEOUT = 6003,              //超时
    StartAIResultState_HEART_OUT = 6004,
    StartAIResultState_DIS_SELF = 6005,
    StartAIResultState_NULL_TOPIC = 7001,           //主题为空
};

#pragma mark - StartaiMqMessage Message

@interface StartaiMqMessage : NSObject

@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) NSData *msg;
@property (nonatomic, copy) NSString *msgtype;
@property (nonatomic, assign) NSInteger qos;
@property (nonatomic, copy) NSString *toid;
@property (nonatomic, copy) NSString *fromid;

-(id)initWithTopic:(NSString *)topic
               msg:(NSData *)msg
               qos:(NSInteger)qos
           msgtype:(NSString *)msgtype;

@end


@interface StartAIEntity : NSObject

@end

@interface StartAIInitialEntity : NSObject

@property (nonatomic, copy) NSString *domain;

@property (nonatomic, copy) NSString *appid;

@property (nonatomic, copy) NSString *apptype;

@property (nonatomic, copy) NSString *m_ver;

@property (nonatomic, copy) NSString *replaceActiveSN;

@end

@interface StartAIUserInfoEntity : NSObject

@property (nonatomic, copy) NSString *userid;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *birthday;

@property (nonatomic, copy) NSString *province;

@property (nonatomic, copy) NSString *city;

@property (nonatomic, copy) NSString *town;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *headPic;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, copy) NSString *firstName;

@property (nonatomic, copy) NSString *lastName;

@end

@interface StartAIThirdUserInfoEntity : NSObject

//Openid:用户账号对此开发者唯一ID
//Unionid: 用户账号对此开发平台唯一ID
//如果开发平台只有唯一id, Openid和Unionid俩个id填相同的值

@property (nonatomic, copy) NSString *openid;

@property (nonatomic, copy) NSString *unionid;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *province;

@property (nonatomic, copy) NSString *city;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *headImgUrl;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, copy) NSString *firstName;

@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *emali;

@property (nonatomic, copy) NSString *country;


@end
