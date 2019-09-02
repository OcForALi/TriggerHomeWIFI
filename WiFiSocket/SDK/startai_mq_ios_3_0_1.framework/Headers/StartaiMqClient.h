//
//  StartaiMqClient.h
//  startai-mq-ios-3.0.1
//
//  Created by Mac on 2018/7/30.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StartaiClientDelegate.h"

#pragma mark - MQTT Client


@interface StartaiMqClient : NSObject

@property (nonatomic, assign) unsigned short keepAlive;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, assign) NSInteger repeatTimes;
@property (nonatomic, copy) NSString *tlsCafile;
@property (nonatomic, strong) dispatch_queue_t customQueue; //定义消息回调线程 默认主线程
@property (readonly, assign) BOOL isActive;
@property (readonly, copy) NSString *sn;
@property (readonly, copy) NSString *userid;
@property (readonly, copy) NSString *apptype;
@property (readonly, copy) NSString *appid;
@property (readonly, copy) NSString *domain;
@property (readonly, copy) NSString *m_ver;
@property (nonatomic, copy) NSString *appointUserid;


- (void)registDelegate:(id)obj;

- (void)unRegistDelegate:(id)obj;


#pragma mark - Publish

- (void)publisthMsgEntity:(StartaiMqMessage *)msgEntity
        completionHandler:(void (^)(StartAIResultState res))completionHandler;

#pragma mark - Subscribe or Unsubscribe

- (void)subscribe:(NSString *)topic completionHandler:(void (^)(StartAIResultState res))completionHandler;

- (void)unsubscribe: (NSString *)topic completionHandler:(void (^)(StartAIResultState res))completionHandler;

#pragma mark Business code
/**
 * 初始化
 * @param initialEntity 激活参数实体
 * @completionHandler
 */
- (void)initializationWithInitialEntity:(StartAIInitialEntity *)initialEntity
     completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  第三方硬件激活
 */
- (void)hardwareActivateWithInitialEntity:(StartAIInitialEntity *)initialEntity
                        completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  登出
 */
- (void)logout:(void (^)(StartAIResultState res))completionHandler;

/**
 *  注销激活
 */
- (void)unActiviteWithSN:(NSString *)sn completionHandler:(void (^)(StartAIResultState res))completionHandler;

@end
