//
//  AppDelegate.m
//  WiFiSocket
//
//  Created by Mac on 2018/4/10.
//  Copyright © 2018年 QiXing. All rights reserved.
//



#import "WiFiSocketAppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
//#import <TwitterKit/TWTRTwitter.h>
#import "MainViewController.h"
#import "TestViewController.h"
#import "WXApi.h"
#import "LoginModel.h"
#import <Bugly/Bugly.h>

/**
 *  MUSIC
 */
//NSString *const wxAppID = @"wx437231624c76739a";
//NSString *const wxAppScrect = @"9e55e990268e5461fbbb0c904077a602";


/**
 *  wifi插座
 */
//NSString *const wxAppID =@"wx83c620b25ed78545";
//NSString *const wxAppScrect = @"dce3b336470ae028d4b76db39203cd3d";

@interface WiFiSocketAppDelegate ()<WXApiDelegate>
{
    NSString *wxAppID;
    NSString *wxAppScrect;
}
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskID;

@end

@implementation WiFiSocketAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    // Override point for customization after application launch.
//    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"MBHhRwJJ82sO4UzYKiqY0UT7j" consumerSecret:@"k1aAIZLYSVCgD4TmWwOvXi8c3vuiNPKTLwPufxZGIAUqxIGRV8"];
    NSString *packageIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
    StartAIInitialEntity *entity = [[StartAIInitialEntity alloc] init];
    if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
        //     自研插座 MUSIK
         [Bugly startWithAppId:@"8a9b040a25"];
        
        [QXUserDefaults setObject:@(0x08) forKey:CUSTOM_H];
        [QXUserDefaults setObject:@(0x08) forKey:CUSTOM_L];
        
        wxAppID = @"wx437231624c76739a";
        wxAppScrect = @"9e55e990268e5461fbbb0c904077a602";
        
        entity.domain = @"startai";
        entity.appid = @"aebb4dddadc34dcaa95a077254366731";
        entity.apptype = @"smartOlWifi/controll/ios";
        entity.m_ver = @"Json_1.1.4_8.1";
        
        [GIDSignIn sharedInstance].clientID =@"845798326395-5iiapoh70v44ms2oqput5lul21l4g3tu.apps.googleusercontent.com";
//        com.googleusercontent.apps.722882744656-82k8n43llotr23b2ksfqvk29avtuivg5
        
    }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
        // miniWIFI插座
        
        [Bugly startWithAppId:@"2622cc5f4a"];
        
        [QXUserDefaults setObject:@(0x00) forKey:CUSTOM_H];
        [QXUserDefaults setObject:@(0x02) forKey:CUSTOM_L];
        
        wxAppID =@"wx83c620b25ed78545";
        wxAppScrect = @"dce3b336470ae028d4b76db39203cd3d";
        
        entity.domain = @"okaylight";
        entity.appid = @"2e76e2a2631e2dd61ef4989c15ed6443";
        entity.apptype = @"smartOlWifi/controll/ios";
        entity.m_ver = @"Json_1.1.4_8.1";
        
        [GIDSignIn sharedInstance].clientID =@"153381950980-r421kq7s3rjheeleh5c04opl0si21lb8.apps.googleusercontent.com";
//        com.googleusercontent.apps.153381950980-r421kq7s3rjheeleh5c04opl0si21lb8
        
    }else if ([packageIdentifier isEqualToString:WanLondonSocket]){
        
        [QXUserDefaults setObject:@(0x00) forKey:CUSTOM_H];
        [QXUserDefaults setObject:@(0x06) forKey:CUSTOM_L];
        
        // 英国插座
        wxAppID =@"111111111";
        wxAppScrect = @"11111111111111";
        
        entity.domain = @"okaylight";
        entity.appid = @"qx114c11a3a94f4e21";
        entity.apptype = @"smartOlWifi/controll/ios";
        entity.m_ver = @"Json_1.1.4_8.1";
    }else if ([packageIdentifier isEqualToString:NBSocket]){
        
        [QXUserDefaults setObject:@(0x00) forKey:CUSTOM_H];
        [QXUserDefaults setObject:@(0x02) forKey:CUSTOM_L];
        
        wxAppID =@"wx002f27d00923b2a2";
        wxAppScrect = @"11111111111111";
        
        entity.domain = @"okaylight";
        entity.appid = @"qxb050edbace01cbd8";
        entity.apptype = @"smartOlWifi/controll/android";
        entity.m_ver = @"Json_1.2.4_9.2.1";
    } else{
        NSLog(@"获取bundleid失败 或者bundleid不正确");
    }
    
    self.appid = entity.appid;
    
    [[MqttClientManager shareInstance] SSLConnected];
    if (![MqttClientManager shareInstance].client.isActive || ![[MqttClientManager shareInstance].client.appid isEqualToString:entity.appid]) {
        [[MqttClientManager shareInstance].client initializationWithInitialEntity:entity completionHandler:^(StartAIResultState res) {
            
        }];
    }else{
        
    }

    MainViewController *vc = [[MainViewController alloc] init];
//    TestViewController *vc = [[TestViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [WXApi registerApp:wxAppID];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if (@available(iOS 9.0, *)) {
        [[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                    annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
         ];
    } else {
        // Fallback on earlier versions
    }

    if (@available(iOS 9.0, *)) {
        [[GIDSignIn sharedInstance] handleURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    } else {
        // Fallback on earlier versions
    }
    
    [WXApi handleOpenURL:url delegate:self];
    
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            [[LoginModel shareInstace] aliPayLoginState:resultDic];
        }];
    }
    
//    [[TWTRTwitter sharedInstance] application:application openURL:url options:options];
    
    return true;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
     [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
     [[GIDSignIn sharedInstance] handleURL:url
                                  sourceApplication:sourceApplication
                                         annotation:annotation];
    
    [WXApi handleOpenURL:url delegate:self];
    
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
             [[LoginModel shareInstace] aliPayLoginState:resultDic];
        }];
    }
    return true;
}


- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        [[LoginModel shareInstace] wxLoginState:authResp];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self requestBackground:application];
}

- (void)requestBackground:(UIApplication *)application
{
    self.bgTaskID = [application beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask:application];
    }];
    
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
    }
}

- (void) endBackgroundTask:(UIApplication *)application
{
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^(void) {
        if (self != nil){
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
            // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
            // 也就是要告诉应用程序：“好借好还”嘛。
            // 标记指定的后台任务完成
            [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskID];
            // 销毁后台任务标识符
            self.bgTaskID = UIBackgroundTaskInvalid;
        }
    });
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    if (self.bgTaskID != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.bgTaskID];
        self.bgTaskID = UIBackgroundTaskInvalid;
    }
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
