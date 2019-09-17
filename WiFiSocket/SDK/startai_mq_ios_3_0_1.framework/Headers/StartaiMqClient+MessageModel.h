//
//  StartaiMqClient+MessageModel.h
//  startai-mq-ios-3.0.1
//
//  Created by Mac on 2019/2/27.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import <startai_mq_ios_3_0_1/startai_mq_ios_3_0_1.h>
#import "StartAIEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface StartaiMqClient (MessageModel)

#pragma mark Business code


/**
 * 注册
 * @param username      邮箱或手机号
 * @param password      密码
 * @param type          1表示邮箱加密码（激活邮件）
 2表示手机号加密码
 3表示手机号加验证码
 4表示邮箱加密码（邮箱验证码）
 * @completionHandler
 */
- (void)registWithUsername:(NSString *)username
                  password:(NSString *)password
                      type:(NSInteger)type
         completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  登陆
 * @param username        邮箱或手机号
 * @param password        密码
 * @param identifyCode    验证码
 * @param type            1表示邮箱加密码
 2表示手机号加密码
 3表示手机号加验证码
 4表示用户名加密码
 5.双重认证 手机号+验证码+密码
 10:微信登录
 11:支付宝登录
 12:QQ登录
 13:谷歌登录
 14:推特登录
 15:亚马逊登录
 16:脸书登录
 17:小米
 * @completionHandler
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
             identifyCode:(NSString *)identifyCode
                     type:(NSInteger)type
        completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 * 第三方登陆
 * @param code       授权code
 * @param type       10:微信登录
 11:支付宝登录
 12:QQ登录
 13:谷歌登录
 14:推特登录
 15:亚马逊登录
 16:脸书登录
 17:小米
 */
- (void)thirdLoginWithCode:(NSString *)code
                      type:(NSInteger)type
           thirdUserEntity:(StartAIThirdUserInfoEntity *)userInfoEntity
         completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 * 获取验证码
 * @param mobile    手机号
 * @param type      1表示用户登录
 2表示修改登录密码
 3表示用户注册
 
 * @completionHandler
 */
- (void)getIdentifyCodeWithMobile:(NSString *)mobile
                             type:(NSInteger)type
                completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  校验验证码
 * @param account       手机号/邮箱
 * @param identifyCode 验证码
 * @param type          1表示校验快捷登录验证码（M）
 2表示重置登录密码(M)
 3表示用户注册(M)
 4第三方音响快捷登录(M)
 5绑定/更改手机号(M)
 6校验邮箱注册验证码(E)
 7校验重置密码验证码(E)
 8校验更换/添加邮箱验证码（E）
 * @completionHandler
 */
- (void)checkIdentifyCodeWithAccount:(NSString *)account
                           checkCode:(NSString *)identifyCode
                                type:(NSInteger)type
                   completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 * 绑定设备
 * @param bebind  对端sn/userid
 * @completionHandler
 */
- (void)beBind:(NSString *)bebind
completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  解绑设备
 * @param beUnbindid  对端sn/userid
 * @completionHandler
 */
- (void)beUnbindid:(NSString *)beUnbindid
 completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  查询绑定关系
 * @param type 1.查询用户绑定的设备
 *             2.查询设备的用户列表
 *             3.查询用户的用户好友
 *             4.查询设备的设备列表
 *             5.查询用户的手机列表
 *             6.查询手机的用户好友
 *             7.查询所有
 
 */
- (void)getBindListWithType:(NSInteger)type
          completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  查询绑定关系
 * @param type 1.查询用户绑定的设备
 *             2.查询设备的用户列表
 *             3.查询用户的用户好友
 *             4.查询设备的设备列表
 *             5.查询用户的手机列表
 *             6.查询手机的用户好友
 *             7.查询所有
 * @param page 页数
 * @param count 一页多少个
 */
- (void)pagingGetBindListWithType:(NSInteger)type
                             page:(NSInteger)page
                            count:(NSInteger)count
                completionHandler:(void (^)(StartAIResultState res))completionHandler;


/**
 *  更新用户信息
 * @param userInfoEntity 用户更新信息的实体
 * @completionHandler
 */
- (void)updateUserInfoWithUserInfoEntity:(StartAIUserInfoEntity *)userInfoEntity
                       completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  查询用户信息
 @param loginType 登录类型
 1表示邮箱加密码
 2表示手机号加密码
 3表示手机号加验证码
 4表示用户名加密码
 5双重认证 手机号+验证码+密码
 10:微信登录
 11:支付宝登录
 12:QQ登录
 13:谷歌登录
 14:推特登录
 15:亚马逊登录
 16:脸书登录
 17:小米
 18:微信小程序登录
 * @completionHandler
 */
- (void)getUserInfoByLoginType:(NSInteger)loginType
             completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  获取最新软件版本
 * @param os 系统类型 ios linux
 * @param packageName 包名 （固件可不填写）
 * @completionHandler
 */
- (void)getLatestVersionWithOS:(NSString *)os
                   packageName:(NSString *)packageName
             completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  修改用户登录密码
 * @param oldPwd 旧密码
 * @param newPwd 新密码
 * @completionHandler
 */
- (void)updateUserPwdWithOldPwd:(NSString *)oldPwd
                         newPwd:(NSString *)newPwd
              completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  忘记密码
 * @param account 手机号/邮箱
 * @param pwd 新密码
 * @completionHandler
 */
- (void)forgetUserPwdWithAccount:(NSString *)account
                             pwd:(NSString *)pwd
               completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  请求发送邮件
 * @param email 邮箱名称
 * @param type  类型  1 为重新发送激活邮件
 2 为发送忘记密码邮件
 6 为发送注册验证码邮件
 7 为发送重置密码验证码邮件
 8 为发送更换/添加绑定邮箱验证码邮件
 * @completionHandler
 */
- (void)sendEmail:(NSString *)email
             type:(NSInteger)type
completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  修改好友|设备 备注名
 * @param fid 用户id
 * @param remark 重命名名称
 * @completionHandler
 */
- (void)updateRemarkWithFid:(NSString *)fid
                     remark:(NSString *)remark
          completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  生成预付单
 * @param platform 平台类型     1、微信  2、支付宝 4、马来币支付
 * @param description 商品描述
 * @param feeType   货币类型
 * @param totalFee  总消费
 * @param orderNum  订单号
 * @completionHandler
 */
- (void)createAdvancedOrderWithPlatform:(NSInteger)platform
                            description:(NSString *)description
                                feeType:(NSString *)feeType
                               totalFee:(NSInteger)totalFee
                               orderNum:(NSString *)orderNum
                      completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  获取支付宝登陆密钥
 * @param type 是登录还是授权
 */
- (void)getAlipayKeyType:(NSString *)type completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  查询支付结果
 * @param orderNum  订单号
 * @completionHandler
 */
- (void)queryOrderPayResultWithOrderNum:(NSString *)orderNum
                      completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  绑定/更换手机号
 * @param mobile 手机号
 * @completionHandler
 */
- (void)bindMobile:(NSString *)mobile completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  绑定/更换邮箱
 */
- (void)bindEmail:(NSString *)email completionHandler:(void (^)(StartAIResultState res))completionHandler;
/**
 *  获取温度及空气指数
 */
- (void)queryTemperatureAndAirQualityWithLat:(NSString *)lat
                                         lng:(NSString *)lng
                           completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  解绑第三方应用账号
 *  @param type 绑定第三方账号类型
 10:绑定微信账号
 11:绑定支付宝账号
 12:绑定QQ账号
 13:绑定谷歌账号
 14:绑定推特账号
 15:绑定亚马逊账号
 16:绑定脸书账号
 17:绑定小米账号
 */
- (void)unbindThirdAPPWithPlatformType:(NSInteger)type
                     completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  绑定第三方应用账号
 *  @param type 绑定第三方账号类型
 10:绑定微信账号
 11:绑定支付宝账号
 12:绑定QQ账号
 13:绑定谷歌账号
 14:绑定推特账号
 15:绑定亚马逊账号
 16:绑定脸书账号
 17:绑定小米账号
 *  @param code 授权码
 */

- (void)bindThirdAPPWithPlatformCode:(NSString *)code
                                type:(NSInteger)type
                   completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  消息透传
 * @param toid 对端的userid或sn
 * @param data 透传的数据
 * @completionHandler
 */
- (void)passthrough:(NSString *)toid
               data:(NSString *)data
  completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  租借或归还充电宝
 * @param imei 充电宝机柜imei
 * @completionHandler
 */
- (void)rentAndgiveBackDeviceWithImei:(NSString *)imei
                    completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  查询网点信息
 * @param merchantId 网点id
 *  @param lng 经度
 *  @param lat 纬度
 * @completionHandler
 */
- (void)queryDotInfoWithMerchantId:(NSInteger)merchantId
                               lng:(NSString *)lng
                               lat:(NSString *)lat
                 completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  查询机柜信息
 * @param imei 机柜imei
 * @completionHandler
 */
- (void)queryCabinetInfoWithImei:(NSString *)imei
               completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  查询费率
 * @completionHandler
 */
- (void)queryConsumptionCompletionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP请求充值，支付模块生成订单
 * @param fee 充值费用
 * @prarm platform 支付渠道平台 1、微信 2、支付宝
 * @param type 1、余额充值 2、押金充值
 * @completionHandler
 */
- (void)requestRechargeWithFee:(NSInteger)fee
                      paltform:(NSInteger)platform
                          type:(NSInteger)type
             completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP查询用户余额和押金
 * @completionHandler
 */
- (void)queryUserBalanceAndDepositCompletionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 * 查询用户订单列表
 * @param page 页码
 * @param count 一页显示数量
 * @param type 订单类型 1：充电宝，2：座充，3：充电宝+座充
 * @completionHandler
 */
- (void)queryUserOrderListWithPage:(NSInteger)page
                             count:(NSInteger)count
                              type:(NSInteger)type
                 completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP查询单个订单详情
 *  @param OrderNumber 订单号
 *  @completionHandler
 */
- (void)queryOrderWithOrderNumber:(NSString *)OrderNumber
                completionHandler:(void (^)(StartAIResultState res))completionHandler;


/**
 *  APP用余额支付未支付订单
 *  @param OrderNumber 订单号
 *  @completionHandler
 */
- (void)payForOrderByBalanceWithOrderNumber:(NSString *)OrderNumber
                          completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP 获取指定坐标（2km）附近的店铺信息
 *  @param lng 经度
 *  @param lat 纬度
 *  @completionHandler
 */
- (void)getStoreListByAppointLocationWithLng:(NSString *)lng
                                         lat:(NSString *)lat
                           completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP查询门店分类
 *  @param deviceType 设备类型 1、全部 2、充电宝 3、座充
 *  @param region 区域
 *  @param lng 经度
 *  @param lat 纬度
 *  @param page 当前页码
 *  @param count 一页的数量
 *  @completionHandler
 */
- (void)queryStoreClassificationWithDeviceType:(NSInteger)deviceType
                                        region:(NSString *)region
                                           lng:(NSString *)lng
                                           lat:(NSString *)lat
                                          page:(NSInteger)page
                                         count:(NSInteger)count
                             completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP 查询用户交易明细
 *  @param transactionType 交易类型 1、充值 2、消费 3、提现
 *  @param page 当前页码
 *  @param count 一页的数量
 *  @completionHandler
 */
- (void)queryUserTransactionDetailsWithTransactionType:(NSInteger)transactionType
                                                  page:(NSInteger)page
                                                 count:(NSInteger)count
                                     completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP查询是否存在借出单
 *  @completionHandler
 */
- (void)queryUserExistenceOrderCompletionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP查询机柜费率
 *  @param imei 机柜id
 *  @completionHandler
 */
- (void)queryCabinetRateWithImei:(NSString *)imei
               completionHandler:(void (^)(StartAIResultState res))completionHandler;

/**
 *  APP查询押金费率
 *  @completionHandler
 */
- (void)queryDepositRateCompletionHandler:(void (^)(StartAIResultState res))completionHandler;


@end

NS_ASSUME_NONNULL_END
