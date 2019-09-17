//
//  AppDelegate.h
//  WiFiSocket
//
//  Created by Mac on 2018/4/10.
//  Copyright © 2018年 QiXing. All rights reserved.
//

/**
 *  切换皮肤步骤
 *  1、修改项目bundle id、 app名称、 app图标和启动页，URL type更新
 *  2、修改AppDelegate 第三方平台appid信息 与激活实体 （MqMessageResponseModel）激活失败后重新激活激活实体
 *  3、替换webview加载路径，头像上传appid更新
 *  4、修改组包协议中的 custom_h和custom_l 字段 （SpecialConstant.h）
 *  5、修改测试包版本更新填写信息 （UserInfoModel）
 *  6、获取支付宝密钥需要替换当前应用的scheme ()
 */


/**
 *  自研插座 MUSIK  com.miniSocket
 */

//自研插座 MUSIK  微信第三方登录 审核已经通过
//微信开发者信息
//AppID  : wx437231624c76739a
//AppSecret : 9e55e990268e5461fbbb0c904077a602
//支付宝开发者信息
//AppID  : 2018122562676695
//PID : 2088821252690232
//谷歌登陆：845798326395-5iiapoh70v44ms2oqput5lul21l4g3tu.apps.googleusercontent.com
//Facebook登陆：
////<key>CFBundleURLTypes</key> <array> <dict> <key>CFBundleURLSchemes</key> <array> <string>fb842701156094657</string> </array> </dict> </array> <key>FacebookAppID</key> <string>842701156094657</string> <key>FacebookDisplayName</key> <string>MUSIK</string>
////<key>LSApplicationQueriesSchemes</key> <array> <string>fbapi</string> <string>fb-messenger-share-api</string> <string>fbauth2</string> <string>fbshareextension</string> </array>
//应用Scheme = @"StartAIMUSIK";


/**
 *  wifi插座 TriggerHome  com.WifiSocket
 */

//WIFI插座 的 微信第三方登录 审核已经通过 微信平台开发者信息如下
//appid : wx83c620b25ed78545
//appSecret : dce3b336470ae028d4b76db39203cd3d
//支付宝开发者信息
//AppID  : 2018103161935597
//PID : 2088821252690232
//谷歌登陆：153381950980-r421kq7s3rjheeleh5c04opl0si21lb8.apps.googleusercontent.com
//Facebook登陆：
////<key>CFBundleURLTypes</key> <array> <dict> <key>CFBundleURLSchemes</key> <array> <string>fb566338630551328</string> </array> </dict> </array> <key>FacebookAppID</key> <string>566338630551328</string> <key>FacebookDisplayName</key> <string>TriggerHome</string>
// 应用Scheme = @"WanWifiTriggerHome";

/**
 *  英国插座  英国插座  com.LondonSocket
 */

//名称 ： TriggerHome
//appid : 11111111111
//appSecret : 111111111111
//应用Scheme = @"WanLondonSocket";

/**
 *  nb项目 @"com.Okaylight.NBSocket"
 */

//名称 ： NBSocket
//WeChatID:wx002f27d00923b2a2
//appid : 11111111111
//appSecret : 111111111111
//应用Scheme = @"WanNBSocket";


#import <UIKit/UIKit.h>

@interface WiFiSocketAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString *appid;

@end

