//
//  StartaiClientDelegate.h
//  startai-mq-ios-3.0.1
//
//  Created by Mac on 2018/11/26.
//  Copyright © 2018 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StartAIEntity.h"

NS_ASSUME_NONNULL_BEGIN

@protocol StartaiClientDelegate <NSObject>


@optional
/**
 * 连接回调
 */
- (void)connectedCallback:(StartAIResultState)res;
/**
 * 断开连接回调
 */
- (void)disconnectedCallback:(StartAIResultState)res;
/**
 * 消息回调
 */
- (void)receviceMessage:(StartaiMqMessage *)message;

/**
 * SDK初始化结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 */
- (void)onActiviteResult:(BOOL)result
               errorCode:(NSString *)errorCode
                errorMsg:(NSString *)errorMsg;

/**
 *  注册结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param registInfo 注册成功回调信息
 */
- (void)onRegisterResult:(BOOL)result
               errorCode:(NSString *)errorCode
                errorMsg:(NSString *)errorMsg
              registInfo:(NSDictionary *)registInfo;
/**
 *  登陆结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 */
- (void)onLoginResult:(BOOL)result
            errorCode:(NSString *)errorCode
             errorMsg:(NSString *)errorMsg;

/**
 *  第三方登陆结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content  返回内容
 */
- (void)onThirdLoginResult:(BOOL)result
                 errorCode:(NSString *)errorCode
                  errorMsg:(NSString *)errorMsg
                   content:(id)content;


/**
 *  绑定结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param beBindInfo 绑定端信息
 */
- (void)onBindResult:(BOOL)result
           errorCode:(NSString *)errorCode
            errorMsg:(NSString *)errorMsg
          beBindInfo:(NSDictionary *)beBindInfo;
/**
 *  解绑结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param contet 解绑设备信息
 */
- (void)onUnBindResult:(BOOL)result
             errorCode:(NSString *)errorCode
              errorMsg:(NSString *)errorMsg
         unBindContent:(id )contet;
/**
 *  获取验证码结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 */
- (void)onGetIdentifyCodeResult:(BOOL)result
                      errorCode:(NSString *)errorCode
                       errorMsg:(NSString *)errorMsg;
/**
 *  检验验证码结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 */
- (void)onCheckIdetifyResult:(BOOL)result
                   errorCode:(NSString *)errorCode
                    errorMsg:(NSString *)errorMsg;
/**
 *  获取绑定关系回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param bindList 绑定列表
 */
- (void)onGetBindListResult:(BOOL)result
                  errorCode:(NSString *)errorCode
                   errorMsg:(NSString *)errorMsg
                   bindList:(NSArray *)bindList;


/**
 *  获取分页绑定关系回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param bindList 绑定列表
 */
- (void)onPageingGetBindListResult:(BOOL)result
                  errorCode:(NSString *)errorCode
                   errorMsg:(NSString *)errorMsg
                   bindList:(NSArray *)bindList;

/**
 *  注销结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 */
- (void)onUnActiviteResult:(BOOL)result
                 errorCode:(NSString *)errorCode
                  errorMsg:(NSString *)errorMsg;
/**
 *  消息透传结果回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param object 透传内容返回
 */
- (void)onPassthroughResult:(BOOL)result
                  errorCode:(NSString *)errorCode
                   errorMsg:(NSString *)errorMsg
                     fromid:(NSString *)fromid
                     object:(id)object;

/**
 *  第三方代激活回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 代激活内容回调
 */
- (void)onHardwareActivateResult:(BOOL)result
                       errorCode:(NSString *)errorCode
                        errorMsg:(NSString *)errorMsg
                         content:(id)content;

/**
 *  查询用户信息回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 *  @param userInfo 用户信息
 */
- (void)onGetUserInfoResult:(BOOL)result
                  errorCode:(NSString *)errorCode
                   errorMsg:(NSString *)errorMsg
                   userInfo:(id)userInfo;

/**
 *  更新用户回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param userInfo 用户信息
 */
- (void)onUpdateUserInfoResult:(BOOL)result
                     errorCode:(NSString *)errorCode
                      errorMsg:(NSString *)errorMsg
                      userInfo:(id)userInfo;

/**
 * 设备连接状态回调
 * @param userid 接受消息的userid
 * @param status 设备状态 1 上线 0 下线
 * @param sn 设备sn
 */
- (void)onDeviceConnectStatusChange:(NSString *)userid
                             status:(BOOL)status
                                 sn:(NSString *)sn;

/**
 *  查询最新版本软件结果
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param versionInfo 版本信息
 */
- (void)onGetLatestVersionResult:(BOOL)result
                       errorCode:(NSString *)errorCode
                        errorMsg:(NSString *)errorMsg
                     versionInfo:(id)versionInfo;


/**
 *  更新用户密码返回
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 密码修改信息
 */
- (void)onUpdateUserPwdResult:(BOOL)result
                    errorCode:(NSString *)errorCode
                     errorMsg:(NSString *)errorMsg
                   content:(id)content;

/**
 *  忘记用户密码返回
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 密码修改信息
 */
- (void)onForgetUserPwdResult:(BOOL)result
                    errorCode:(NSString *)errorCode
                     errorMsg:(NSString *)errorMsg
                   content:(id)content;

/**
 *  发送邮件回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param emailContent 邮件信息
 */
- (void)onSendEmailResult:(BOOL)result
                errorCode:(NSString *)errorCode
                 errorMsg:(NSString *)errorMsg
             emailContent:(id)emailContent;

/**
 * 修改备注名回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onUpdateRemarkResult:(BOOL)result
                   errorCode:(NSString *)errorCode
                    errorMsg:(NSString *)errorMsg
                     content:(id)content;

/**
 * 生成预付单回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onCreateAdvancedOrderResult:(BOOL)result
                          errorCode:(NSString *)errorCode
                           errorMsg:(NSString *)errorMsg
                            content:(id)content;

/**
 * 订单支付成功回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onQueryOrderPayResult:(BOOL)result
                    errorCode:(NSString *)errorCode
                     errorMsg:(NSString *)errorMsg
                      content:(id)content;

/**
 * 主动推送订单支付成功
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onPushOrderPayResult:(BOOL)result
                    errorCode:(NSString *)errorCode
                     errorMsg:(NSString *)errorMsg
                      content:(id)content;

/**
 * 绑定手机号返回
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onBindMobileResult:(BOOL)result
               errorCode:(NSString *)errorCode
                errorMsg:(NSString *)errorMsg
                 content:(id)content;

/**
 * 绑定邮箱返回
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onBindEmailResult:(BOOL)result
                errorCode:(NSString *)errorCode
                 errorMsg:(NSString *)errorMsg
                  content:(id)content;


/**
 * 获取温度或空气指数返回
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onQueryTemperatureAndAirQualityResult:(BOOL)result
                                    errorCode:(NSString *)errorCode
                                     errorMsg:(NSString *)errorMsg
                                      content:(id)content;

/**
 * 解绑第三方绑定回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onUnbindThirdAPPResult:(BOOL)result
                     errorCode:(NSString *)errorCode
                      errorMsg:(NSString *)errorMsg
                       content:(id)content;

/**
 * 第三方绑定回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onBindThirdAPPResult:(BOOL)result
                   errorCode:(NSString *)errorCode
                    errorMsg:(NSString *)errorMsg
                     content:(id)content;

/**
 * 获取支付宝密钥回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content   返回内容
 */
- (void)onGetAlipayKeyResult:(BOOL)result
                   errorCode:(NSString *)errorCode
                    errorMsg:(NSString *)errorMsg
                     content:(id)content;

/**
 *  租借或者充电宝回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onRentAndGiveBackDeviceResult:(BOOL)result
                 errorCode:(NSString *)errorCode
                  errorMsg:(NSString *)errorMsg
                   content:(id)content;
//- (void)onRentDeviceResult:(BOOL)result
//                 errorCode:(NSString *)errorCode
//                  errorMsg:(NSString *)errorMsg
//                   content:(id)content;

/**
 *  归还充电宝回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
//- (void)onGiveBackDeviceResult:(BOOL)result
//                     errorCode:(NSString *)errorCode
//                      errorMsg:(NSString *)errorMsg
//                       content:(id)content;

/**
 *  查询网点信息回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryDotInfoResult:(BOOL)result
                   errorCode:(NSString *)errorCode
                    errorMsg:(NSString *)errorMsg
                     content:(id)content;

/**
 *  查询机柜信息回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryCabinetInfoResult:(BOOL)result
                       errorCode:(NSString *)errorCode
                        errorMsg:(NSString *)errorMsg
                         content:(id)content;

/**
 *  查询费率回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryConsumptionResult:(BOOL)result
                       errorCode:(NSString *)errorCode
                        errorMsg:(NSString *)errorMsg
                         content:(id)content;

/**
 *  APP请求充值，支付模块生成订单回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onRequestRechargeResult:(BOOL)result
                      errorCode:(NSString *)errorCode
                       errorMsg:(NSString *)errorMsg
                        content:(id)content;

/**
 *  APP查询用户余额和押金回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryUserBalanceAndDepositResult:(BOOL)result
                                 errorCode:(NSString *)errorCode
                                  errorMsg:(NSString *)errorMsg
                                   content:(id)content;

/**
 * 查询用户订单列表回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryUserOrderListResult:(BOOL)result
                         errorCode:(NSString *)errorCode
                          errorMsg:(NSString *)errorMsg
                           content:(id)content;

/**
 *  APP查询单个订单详情回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryOrderWithOrderNumberResult:(BOOL)result
                                errorCode:(NSString *)errorCode
                                 errorMsg:(NSString *)errorMsg
                                  content:(id)content;


/**
 *  APP用余额支付未支付订单回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onPayForOrderWithBalanceResult:(BOOL)result
                             errorCode:(NSString *)errorCode
                              errorMsg:(NSString *)errorMsg
                               content:(id)content;
/**
 *  APP 获取指定坐标（2km）附近的店铺信息回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onGetStoreListByAppointLocationResult:(BOOL)result
                                    errorCode:(NSString *)errorCode
                                     errorMsg:(NSString *)errorMsg
                                      content:(id)content;

/**
 *  APP查询门店分类回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryStoreClassificationResult:(BOOL)result
                             errorCode:(NSString *)errorCode
                              errorMsg:(NSString *)errorMsg
                               content:(id)content;

/**
 *  APP 查询用户交易明细回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryUserTransactionDetailsResult:(BOOL)result
                                errorCode:(NSString *)errorCode
                                 errorMsg:(NSString *)errorMsg
                                  content:(id)content;

/**
 *  APP查询是否存在借出单回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryUserExistenceOrderResult:(BOOL)result
                            errorCode:(NSString *)errorCode
                             errorMsg:(NSString *)errorMsg
                              content:(id)content;

/**
 *  APP查询机柜费率回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryCabinetRateResult:(BOOL)result
                     errorCode:(NSString *)errorCode
                      errorMsg:(NSString *)errorMsg
                       content:(id)content;

/**
 *  APP查询押金费率回调
 * @param result    1 成功 0失败
 * @param errorCode 失败时的异常码
 * @param errorMsg  失败异常码描述
 * @param content 返回内容
 */
- (void)onQueryDepositRateResult:(BOOL)result
                     errorCode:(NSString *)errorCode
                      errorMsg:(NSString *)errorMsg
                       content:(id)content;



@end

NS_ASSUME_NONNULL_END
