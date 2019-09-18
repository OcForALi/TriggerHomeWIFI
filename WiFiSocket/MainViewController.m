//
//  ViewController.m
//  WiFiSocket
//
//  Created by Mac on 2018/4/10.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "MainViewController.h"
#import <WebKit/WebKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "TwitterOAuthViewController.h"
//#import <TwitterKit/TWTRTwitter.h>
//#import <TwitterKit/TWTRUser.h>
#import "WiFiSocketAppDelegate.h"
#import "LoginModel.h"          //登陆管理
#import "HomeModel.h"           //设备主界面管理
#import "ConfigWiFiModel.h"     //配网管理
#import "BaseControlModel.h"    //设备基础任务管理
#import "SettingModel.h"        //设备进阶设置管理
#import "MallModel.h"           //商城管理model
#import "UserInfoModel.h"       //用户信息管理
#import "FirmwareUpdateModel.h" //固件升级管理
#import "MqMessageResponseModel.h"  //广域网消息处理
#import "LightControlModel.h"       //灯光管理
#import "QueryHistoryModel.h"       //查询设备历史记录
#import "WeatherRequestModel.h"     //查询天气状况
#import "DeviceStatusModel.h"       //查询插座工作时长

#import "MallViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <CoreTelephony/CTCellularData.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>

@interface MainViewController ()<WKNavigationDelegate,WKUIDelegate,GIDSignInDelegate,GIDSignInUIDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    MBProgressHUD *hud;
    UIImagePickerController *pickerCtrl;
    CGPoint keyboardPoint;  //记录H5在键盘弹起的时候视图偏移
    CMAcceleration lastAcceler;
    CGFloat lastX;
    CGFloat lastY;
    CGFloat lastZ;
    
    long long recordTime;
}
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *statusView;
@property (nonatomic, strong) LoginModel *loginModel;
@property (nonatomic, strong) HomeModel *homeModel;
@property (nonatomic, strong) ConfigWiFiModel *configWifiModel;
@property (nonatomic, strong) BaseControlModel *baseControlModel;
@property (nonatomic, strong) SettingModel *settingModel;
@property (nonatomic, strong) MallModel *mallModel;
@property (nonatomic, strong) UserInfoModel *userInfoModel;
@property (nonatomic, strong) FirmwareUpdateModel *firmwareModel;
@property (nonatomic, strong) LightControlModel *lightModel;
@property (nonatomic, strong) QueryHistoryModel *historyModel;
@property (nonatomic, strong) WeatherRequestModel *weatherModel;
@property (nonatomic, strong) MqMessageResponseModel *messageResponseModel;
@property (nonatomic, strong) DeviceStatusModel *deviceStatusModel;

@property (nonatomic, strong) HandlingDataModel *handlingModel;

@property (nonatomic, strong) TwitterOAuthViewController *twitterVC;

@property (nonatomic, strong) UIImageView *lanchView;
@property (nonatomic, strong) NSMutableArray *funcArr;

@property (nonatomic, strong) CMMotionManager *cmmotionManager;

@property (nonatomic, assign) NSInteger loginType;

@end

@implementation MainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = false; //设置摇一摇时是否支持redo和undo操作
    
    self.statusView  = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                       0,
                                                        SCREEN_WITDH,
                                                        SCREEN_HEIGHT)];
//    self.statusView.backgroundColor = [UIColor colorWithRed:78/255.0
//                                              green:163/255.0
//                                               blue:254/255.0
//                                              alpha:1];
    self.statusView.backgroundColor = [UIColor colorWithRed:53/255.0
                                                      green:54/255.0
                                                       blue:61/255.0
                                                      alpha:1];
    
    [self.view addSubview:self.statusView];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    //     根据需要去设置对应的属性
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0,
                                                      IPHONEFringe,
                                                      [UIScreen mainScreen].bounds.size.width,
                                                      [UIScreen mainScreen].bounds.size.height-IPHONEFringe-IPHONEBottom)
                                configuration:config];

    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.bounces = false;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.lanchView];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *folderPath;
    NSString *packageIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
        folderPath = [path stringByAppendingPathComponent:@"MusikDist"];
    }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
        folderPath = [path stringByAppendingPathComponent:@"MiNiWif_H5"];
    }else if ([packageIdentifier isEqualToString:WanLondonSocket]){
        folderPath = [path stringByAppendingPathComponent:@"LondonDist"];
    }else if ([packageIdentifier isEqualToString:NBSocket]){
        folderPath = [path stringByAppendingPathComponent:@"NBDist"];
    }
    
    NSString * htmlPath;
    htmlPath = [folderPath stringByAppendingPathComponent:@"index.html"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]];
    [self.webView loadRequest:request];
    
    self.loginModel.methodArr = self.funcArr;
    [self.loginModel registFunctionWithWeb:self.webView];
    
    self.homeModel.methodArr = self.funcArr;
    [self.homeModel registFunctionWithWeb:self.webView];
    
    self.configWifiModel.methodArr = self.funcArr;
    [self.configWifiModel registFunctionWithWeb:self.webView];
    
    self.baseControlModel.methodArr = self.funcArr;
    [self.baseControlModel registFunctionWithWeb:self.webView];
    
    self.settingModel.methodArr = self.funcArr;
    [self.settingModel registFunctionWithWeb:self.webView];
    
    self.mallModel.methodArr = self.funcArr;
    [self.mallModel registFunctionWithWeb:self.webView];
    
    self.userInfoModel.methodArr = self.funcArr;
    [self.userInfoModel registFunctionWithWeb:self.webView];
    
    self.firmwareModel.methodArr = self.funcArr;
    [self.firmwareModel registFunctionWithWeb:self.webView];
    
    self.historyModel.methodArr = self.funcArr;
    [self.historyModel registFunctionWithWeb:self.webView];
    
    self.lightModel.methodArr = self.funcArr;
    [self.lightModel registFunctionWithWeb:self.webView];
    
    self.weatherModel.methodArr = self.funcArr;
    [self.weatherModel registFunctionWithWeb:self.webView];
    
    self.deviceStatusModel.methodArr = self.funcArr;
    [self.deviceStatusModel registFunctionWithWeb:self.webView];
    
    [self.messageResponseModel registFunctionWithWeb:self.webView];
    [self.handlingModel regegistDelegate:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fbUserInfo:)
                                                 name:FBSDKProfileDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fbAccessTokenChanged:)
                                                 name:FBSDKAccessTokenDidChangeNotification
                                               object:nil];
    [self adjustmentBehavior:false];
    
    @weakify(self);
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [[UDPSocket shareInstance] startFindDevice];
            NSString *jsCode = [NSString stringWithFormat:@"switchNetworkResponse('%@',%d)",@"WIFI",1];
            [weak_self.webView evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }else if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown){
            NSString *jsCode = [NSString stringWithFormat:@"switchNetworkResponse('%@',%d)",@"NONE",3];
            [weak_self.webView evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            NSString *jsCode = [NSString stringWithFormat:@"switchNetworkResponse('%@',%d)",@"MOBILE",1];
            [weak_self.webView evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        }
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.cmmotionManager = [[CMMotionManager alloc] init];
    self.cmmotionManager.accelerometerUpdateInterval = 0.1;
    
    [self.cmmotionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        [weak_self outputAccelertionData:accelerometerData.acceleration];
        if (error) {

        }
    }];
    
    [[ NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutControllerSubViews:) name: UIApplicationDidChangeStatusBarFrameNotification object : nil ];
    
}


-(void)outputAccelertionData:(CMAcceleration)acceleration {
    
    //综合3个方向的加速度
    
    CGFloat alpha = 0.8;
    lastAcceler.x = alpha*lastAcceler.x + (1-alpha)*acceleration.x;
    lastAcceler.y = alpha*lastAcceler.y + (1-alpha)*acceleration.y;
    lastAcceler.z = alpha*lastAcceler.z + (1-alpha)*acceleration.z;
    
    CGFloat x = acceleration.x - lastAcceler.x;
    CGFloat y = acceleration.y - lastAcceler.y;
    CGFloat z = acceleration.z - lastAcceler.z;
    
    CGFloat deltaX = x-lastX;
    CGFloat deltaY = y-lastY;
    CGFloat deltaZ = z-lastZ;
    
    lastX = x;
    lastY = y;
    lastZ = z;
    
    double accelerameter =sqrt( pow( deltaX,2) + pow( deltaY,2) + pow( deltaZ,2) );
//    NSLog(@"...................加速度..........%f...........",accelerameter);
//   double accelerameter =sqrt( pow( acceleration.x,2) + pow( acceleration.y,2) + pow( acceleration.z,2) );
    
    if(accelerameter>3.2f) {
//        [self.cmmotionManager stopAccelerometerUpdates];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *mac = self.homeModel.currentMac;
            BOOL state = !self.lightModel.smallLightState;
            if (mac) {
                NSString *status = [NSString stringWithFormat:@"%@-%@",mac,[MqttClientManager shareInstance].client.userid];
                BOOL res = [[NSUserDefaults standardUserDefaults] boolForKey:status];
                long long time = [ToolHandle getNowTime];
                long long chazhi = time - recordTime;
                if (res && chazhi>0.5) {
                    recordTime = time;
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    [self.lightModel ordinaryNightLightRequest:@{@"mac":mac,@"state":@(state)}];
                }
            }
        });
        
    }
    
}

//当键盘出现
- (void)keyboardDidShow:(NSNotification *)notification
{
    //获取键盘出现偏移
    keyboardPoint = self.webView.scrollView.contentOffset;
//    DDLog(@"当键盘出现当键盘出现当键盘出现当键盘出现当键盘出现当键盘出现当键盘出现");
}

//当键退出
- (void)keyboardWillHide:(NSNotification *)notification
{
    //获取键盘回收偏移
    CGPoint point = self.webView.scrollView.contentOffset;
    if (point.y >= keyboardPoint.y) {
//        self.webView.scrollView.contentOffset = CGPointMake(point.x-keyboardPoint.x, point.y-keyboardPoint.y);
        self.webView.scrollView.contentOffset = CGPointMake(0, 0);
    }else{
        self.webView.scrollView.contentOffset = CGPointMake(0, 0);
    }
//    DDLog(@"当键退出当键退出当键退出当键退出当键退出当键退出当键退出当键退出");
}

- (UIImageView *)lanchView
{
    if (!_lanchView) {
        _lanchView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WITDH, SCREEN_HEIGHT)];
        _lanchView.backgroundColor = [UIColor whiteColor];
        NSString *packageIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
        if ([packageIdentifier isEqualToString:StartAIMUSIK]) {
            _lanchView.image = [UIImage imageNamed:@"StartaiMusikLaunch"];
        }else if ([packageIdentifier isEqualToString:WanWifiSocket]){
//            _lanchView.image = [UIImage imageNamed:@"StartaiMusikLaunch"];
        }else if ([packageIdentifier isEqualToString:WanLondonSocket]){
//            _lanchView.image = [UIImage imageNamed:@"StartaiMusikLaunch"];
        }
        _lanchView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _lanchView;
}

- (LoginModel *)loginModel
{
     __weak typeof(self) weakSelf = self;
    if (!_loginModel) {
        _loginModel = [LoginModel shareInstace];
        _loginModel.loginHandler = ^(NSString *type , NSInteger loginType){
            weakSelf.loginType = loginType;
            [weakSelf showLoadingWithTitle:nil];
            if ([type isEqualToString:@"Facebook"]) {
                [weakSelf faceBookLogin];
            }else if ([type isEqualToString:@"Google"]){
                [weakSelf googleLogin];
            }else{
                [weakSelf TwitterLogin];
            }
        };
    }
    return _loginModel;
}

- (HomeModel *)homeModel
{
    __weak typeof(self) weakSelf = self;
    if (!_homeModel) {
        _homeModel = [HomeModel shareInstance];
        _homeModel.deviceArrhandler = ^(NSMutableArray *arr) {
            weakSelf.messageResponseModel.deviceArr = arr;
        };
        _homeModel.wifiPowerSwitchStatusRequestHandler = ^(NSDictionary *object) {
            [weakSelf.baseControlModel powerWIFISwitchStatusRequest:object];
        };
        _homeModel.wifiPowerSwitchRequestHandler = ^(NSDictionary *object) {
            [weakSelf.baseControlModel powerWIFISwitchRequest:object];
        };
        _homeModel.wifiBindDeviceHandler = ^(NSDictionary *object) {
            [weakSelf.configWifiModel addDeviceConnectedByRouterRequest:object];
        };
    }
    return _homeModel;
}

- (ConfigWiFiModel *)configWifiModel
{
    __weak typeof(self) weakSelf = self;
    if (!_configWifiModel) {
        _configWifiModel = [ConfigWiFiModel shareInstance];
    }
    _configWifiModel.bindDeviceSucess = ^(NSDictionary *snDic) {
        weakSelf.messageResponseModel.deviceDic = snDic;
    };
    return _configWifiModel;
}

- (BaseControlModel *)baseControlModel
{
    @weakify(self);
    if (!_baseControlModel) {
        _baseControlModel = [BaseControlModel shareInstance];
        _baseControlModel.updateDeviceListSwitchStausHandler = ^(NSDictionary *dic) {
            weak_self.messageResponseModel.deviceDic = dic;
        };
    }
    return _baseControlModel;
}

- (SettingModel *)settingModel
{
    @weakify(self);
    if (!_settingModel) {
        _settingModel = [SettingModel shareInstance];

    }
    return _settingModel;
}

- (MallModel *)mallModel
{
    @weakify(self);
    if (!_mallModel) {
        _mallModel = [MallModel shareInstance];
        _mallModel.jumpMallHandler = ^(NSString * _Nonnull path) {
            MallViewController *vc = [[MallViewController alloc]init];
            vc.loadURL = path;
//            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
//            WKWebViewConfiguration *con = [[WKWebViewConfiguration alloc] init];
//            WKWebView *web = [[WKWebView alloc] initWithFrame:weak_self.view.bounds configuration:con];
//            [web loadRequest:req];
//            vc.view.backgroundColor = [UIColor whiteColor];
//            [vc.view addSubview:web];
            [weak_self.navigationController pushViewController:vc animated:true];
        };
    }
    return _mallModel;
}

- (UserInfoModel *)userInfoModel
{
    
    @weakify(self);
    if (!_userInfoModel) {
        _userInfoModel = [UserInfoModel shareInstance];
        _userInfoModel.jumpPhotoController = ^(NSInteger type) {
            [weak_self takePhotoType:type];
        };
    }
    return _userInfoModel;
}

-(FirmwareUpdateModel *)firmwareModel
{
    @weakify(self);
    if (!_firmwareModel) {
        _firmwareModel = [FirmwareUpdateModel shareInstance];
        _firmwareModel.updateDeviceListVersionHandler = ^(NSDictionary *dic) {
            weak_self.messageResponseModel.deviceDic = dic;
        };
    }
    return _firmwareModel;
}

- (LightControlModel *)lightModel
{
    @weakify(self);
    if (!_lightModel) {
        _lightModel = [LightControlModel shareInstance];
    }
    return _lightModel;
}

- (QueryHistoryModel *)historyModel
{
    @weakify(self);
    if (!_historyModel) {
        _historyModel = [QueryHistoryModel shareInstance];
    }
    return _historyModel;
}

- (WeatherRequestModel *)weatherModel
{
    if (!_weatherModel) {
        _weatherModel = [WeatherRequestModel shareInstance];
    }
    return _weatherModel;
}

- (MqMessageResponseModel *)messageResponseModel
{
    @weakify(self);
    if (!_messageResponseModel) {
        _messageResponseModel = [MqMessageResponseModel shareInstance];
        _messageResponseModel.userInfoHandler = ^(NSDictionary *dic) {
            [weak_self.userInfoModel updateUserInfoDic:dic];
        };
        _messageResponseModel.updateDeviceInfo = ^(NSString *mac) {
            __strong typeof(weak_self) strongSelf = weak_self;
            [strongSelf.homeModel updateDeviceInfoWithMac:mac];
            [strongSelf.firmwareModel checkFirmwareVersionRequest:@{@"mac":mac}];
        };
        
    }
    return _messageResponseModel;
}

- (HandlingDataModel *)handlingModel
{
    __weak typeof(self) weakSelf = self;
    if (!_handlingModel) {
        _handlingModel = [HandlingDataModel shareInstance];
    }
    _handlingModel.findDeviceHandler = ^(NSDictionary *dic, NSDictionary *macDic) {
        [[UDPSocket shareInstance].deviceDic setValuesForKeysWithDictionary:macDic];
        weakSelf.messageResponseModel.deviceDic = dic;
    };
    
    _handlingModel.reNameDeviceHandler = ^(NSDictionary *dic) {
        weakSelf.messageResponseModel.deviceDic = dic;
    };
    _handlingModel.updateWifiInfomation = ^(NSDictionary *dic) {
        weakSelf.messageResponseModel.deviceDic = dic;
    };
    _handlingModel.showToastHandler = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showLoadingWithTitle:@"设备已离线"];
        [strongSelf performSelector:@selector(hideHUD) withObject:nil afterDelay:1.0];
    };
    return _handlingModel;
}

#pragma mark 相机或者相册
- (void)takePhotoType:(NSInteger)type
{
    if (type == 2) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请前往设置打开相册权限" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }else{
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
       if (status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请前往设置打开相机权限" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    pickerCtrl = [[UIImagePickerController alloc] init];
    pickerCtrl.delegate = self;
    pickerCtrl.allowsEditing = true;
    if (type==2) {
        pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    }else{
        pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
        pickerCtrl.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        pickerCtrl.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    [self adjustmentBehavior:true];
    [self presentViewController:pickerCtrl animated:true completion:^{
        
    }];
    
}

- (void)loginTimeOut
{
    if (!hud.hidden) {
        hud.label.text = @"Time Out";
        [hud hideAnimated:true afterDelay:2.0];
    }
}

#pragma mark facebook登陆
- (void)faceBookLogin
{
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"facebook.plist"];
    FBSDKAccessToken *token = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (token) {
        [self fbLoginWithToken:token];
        return;
    }
    [self faceBookRealLogin];
}

- (void)faceBookRealLogin
{
    __weak typeof(self) weakSelf = self;
    [FBSDKProfile enableUpdatesOnAccessTokenChange:true];
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    [manager logInWithReadPermissions:@[@"public_profile",@"email"] fromViewController:weakSelf handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        NSLog(@"facebook login result.grantedPermissions = %@,error = %@",result.grantedPermissions,error);
        if (error) {
            hud.hidden = true;
            NSLog(@"Process error");
            NSLog(@"Cancelled");
            NSString *jsonCode = [NSString stringWithFormat:@"thirdPartyLoginResponse(%d,'%@')",false,@""];
            [weakSelf.webView evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        } else if (result.isCancelled) {
            NSLog(@"Cancelled");
            hud.hidden = true;
            NSString *jsonCode = [NSString stringWithFormat:@"thirdPartyLoginResponse(%d,'%@')",false,@""];
            [weakSelf.webView evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                
            }];
        } else {
            NSLog(@"Logged in");
            if (FBSDKProfile.currentProfile) {
                [weakSelf fbUserInfo:nil];
            }
        }
    }];
}

- (void)fbUserInfo:(NSNotification *)notification {
    hud.hidden = true;
    FBSDKProfile *profile =  FBSDKProfile.currentProfile;
    if (!profile) {
        return;
    }
    
    StartAIThirdUserInfoEntity *entity = [[StartAIThirdUserInfoEntity alloc] init];
    entity.openid = profile.userID;
    entity.unionid = profile.userID;
    entity.userName = @"";
    entity.emali = @"";
    entity.province = @"";
    entity.city = @"";
    entity.country = @"";
    entity.address = @"";
    entity.nickName = profile.name;
    entity.headImgUrl = profile.linkURL.path.length?[NSString stringWithFormat:@"%@",profile.linkURL]:@"";
    entity.sex = @"0";
    entity.firstName = profile.firstName.length?profile.firstName:@"";
    entity.lastName = profile.lastName.length?profile.lastName:@"";
    
    if (self.loginType == 0) {
        
        [[MqttClientManager shareInstance].client thirdLoginWithCode:profile.userID type:16 thirdUserEntity:entity completionHandler:^(StartAIResultState res) {
            
        }];
        
    }else{
        
        [[MqttClientManager shareInstance].client bindThirdAPPWithPlatformCode:profile.userID type:16 completionHandler:^(StartAIResultState res) {
            
        }];
        
    }
    
}

- (void)fbAccessTokenChanged:(NSNotification *)notification
{
    FBSDKAccessToken *token = notification.userInfo[@"FBSDKAccessToken"];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"facebook.plist"];
    [NSKeyedArchiver archiveRootObject:token toFile:path];
}

- (void)fbLoginWithToken:(FBSDKAccessToken *)token {
    [FBSDKAccessToken setCurrentAccessToken:token];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        //token过期，删除存储的token和profile
        if (error) {
            NSLog(@"The user token is no longer valid.");
            [FBSDKAccessToken setCurrentAccessToken:nil];
            [FBSDKProfile setCurrentProfile:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"facebook"];
            [self faceBookRealLogin];
        }
        //做登录完成的操作
        else {
            [self fbUserInfo:nil];
        }
    }];
}

#pragma mark 谷歌登陆
- (void)googleLogin
{
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signIn];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    hud.hidden = true;
    GIDProfileData *profile =  user.profile;
    if (!user) {
        return;
    }
    NSString *headUrl = @"";
    if (profile.hasImage) {
      headUrl  = [NSString stringWithFormat:@"%@", [profile imageURLWithDimension:1] ];
    }
    
    StartAIThirdUserInfoEntity *entity = [[StartAIThirdUserInfoEntity alloc] init];
    entity.openid = profile.email;
    entity.unionid = profile.email;
    entity.userName = @"";
    entity.emali = @"";
    entity.province = @"";
    entity.city = @"";
    entity.country = @"";
    entity.address = @"";
    entity.nickName = profile.name;
    entity.headImgUrl = headUrl;
    entity.sex = @"0";
    entity.firstName = profile.name.length?profile.name:@"";
    entity.lastName = profile.familyName.length?profile.familyName:@"";
    
    if (self.loginType == 0) {
        
        [[MqttClientManager shareInstance].client thirdLoginWithCode:profile.email type:13 thirdUserEntity:entity completionHandler:^(StartAIResultState res) {
            
        }];
        
    }else{
        
        [[MqttClientManager shareInstance].client bindThirdAPPWithPlatformCode:profile.email type:13 completionHandler:^(StartAIResultState res) {
            
        }];
        
    }

}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    hud.hidden = true;
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    hud.hidden = true;
}


#pragma mark twitter登陆

- (void)TwitterLogin
{
    __weak typeof(self) weakSelf = self;
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterkit-MBHhRwJJ82sO4UzYKiqY0UT7j"]]) {
//        [[TWTRTwitter sharedInstance] logInWithCompletion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
//            if (session) {
//                TWTRAPIClient  *client = [TWTRAPIClient clientWithCurrentUser];
//                [client loadUserWithID:client.userID completion:^(TWTRUser * _Nullable user, NSError * _Nullable error) {
//                    NSDictionary *dic = @{
//                                          @"userID": user.userID,   // 用户ID
//                                          @"firstName": user.name.length?user.name:@"",       // 名字（教名）
//                                          @"middleName": user.screenName.length?user.screenName:@"",           // 本人名
//                                          @"lastName": user.screenName.length?user.screenName:@"",           // 姓氏
//                                          @"name": user.name,       // 全名
//                                          @"linkURL": user.profileImageURL.length?user.profileImageURL:@"",
//                                          @"refreshDate": @"",  // 更新时间
//                                          };
//
//                    NSString *json = [ToolHandler toJsonString:dic];
//                    NSString *jsonCode = [NSString stringWithFormat:@"thirdPartyLoginResponse(%d,'%@')",true,json];
//                    [weakSelf.webView evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//                    }];
//
//                }];
//            }
//            hud.hidden = true;
//        }];
//    }else{
//        TwitterOAuthViewController *vc = [[TwitterOAuthViewController alloc] init];
//        [self presentViewController:vc animated:true completion:^{
//
//        }];
//    }
    
    if (!_twitterVC) {
        _twitterVC = [[TwitterOAuthViewController alloc] init];
        _twitterVC.userInfoHandler = ^(NSDictionary *user) {
            
            hud.hidden = true;
            [weakSelf.navigationController popViewControllerAnimated:true];
            if (!user && !user.allKeys.count) {
                return ;
            }
            NSLog(@".........%@",user);
            [weakSelf.navigationController popViewControllerAnimated:true];
            weakSelf.twitterVC = nil;
            
            StartAIThirdUserInfoEntity *entity = [[StartAIThirdUserInfoEntity alloc] init];
            entity.openid = user[@"userID"];
            entity.unionid = user[@"userID"];
            entity.userName = @"";
            entity.emali = @"";
            entity.province = @"";
            entity.city = @"";
            entity.country = @"";
            entity.address = @"";
            entity.nickName = user[@"screen_name"];
            entity.headImgUrl = user[@"profile_image_url"];
            entity.sex = @"0";
            entity.firstName = @"";
            entity.lastName = @"";
            
            [[MqttClientManager shareInstance].client thirdLoginWithCode:user[@"userID"] type:13 thirdUserEntity:entity completionHandler:^(StartAIResultState res) {
                
            }];
        };
    }
    
    [self.navigationController pushViewController:_twitterVC animated:true];

}

- (void)showLoadingWithTitle:(NSString *)title
{
    
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeText;//MBProgressHUDModeIndeterminate;
        hud.label.textColor = [UIColor blackColor];
        hud.label.font = [UIFont systemFontOfSize:19];

        [self.view addSubview:hud];
    }
    hud.label.text = title;
    if (!title.length) {
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Login Loading";
    }
    [hud showAnimated:true];
    hud.hidden = false;
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:10];
}

- (void)hideHUD
{
    hud.hidden = true;
}


#pragma mark webview加载代理方法
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.lanchView.hidden = true;
    NSString *localeLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if ([localeLanguageCode hasPrefix:@"zh"]) {
        
    }else{
        
    }
    [self.messageResponseModel performSelector:@selector(networkStatusResponse) withObject:nil afterDelay:1];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //    NSURLRequest *request = navigationAction.request;
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    actionPolicy = WKNavigationActionPolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    completionHandler(@"完成");
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertView *aletView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:nil, nil];
    [aletView show];
    completionHandler();
}

#pragma mark   状态栏 变化改变布局
- (void)layoutControllerSubViews:(NSNotification *)sender{
    
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];

    [UIView animateWithDuration:0.35 animations:^{
        
        if (!IS_IPHONE_X) {
            
            if (statusBarRect.size.height == 40) {

               [self.webView setFrame:CGRectMake(0, IPHONEFringe, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-IPHONEFringe-IPHONEBottom - 20)];
                
            }else{
                [self.webView setFrame:CGRectMake(0, IPHONEFringe, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-IPHONEFringe-IPHONEBottom)];
            }
            
        }else{
            
            [self.webView setFrame:CGRectMake(0, IPHONEFringe, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-IPHONEFringe-IPHONEBottom)];
            
        }
        
    }];
    
}

#pragma makr imagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    
}

#pragma mark 上传头像
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:true completion:^{
        pickerCtrl = nil;
    }];
    
    [self adjustmentBehavior:false];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(img, 0.1);//image为要上传的图片(UIImage)
    
    WiFiSocketAppDelegate *appDelegate = (WiFiSocketAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *postUrl = @"https://bs.startai.cn/user/v1.0/upload_profile_photo"; //@"http://47.98.166.119:8080/service/app/upload_profile_photo";//URL
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:postUrl parameters:@{@"appid":appDelegate.appid} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *fileName = [NSString stringWithFormat:@"%@.png",[formatter stringFromDate:[NSDate date]]];
        //二进制文件，接口key值，文件路径，图片格式
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            if (dic[@"status"] && [dic[@"status"] integerValue] == 200) {
                NSDictionary *dict = dic[@"data"];
                [self.userInfoModel getPhotoResponse:dict[@"headUrl"] result:true];
            }else{
                [self.userInfoModel getPhotoResponse:nil result:false];
            }
        }
        [manager.session finishTasksAndInvalidate];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.userInfoModel getPhotoResponse:nil result:false];
        [manager.session finishTasksAndInvalidate];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self adjustmentBehavior:false];
    [self dismissViewControllerAnimated:true completion:^{
        pickerCtrl = nil;
    }];
}

- (void)adjustmentBehavior:(BOOL)result
{
    if (result) {
        if (@available(iOS 11.0, *)) {
            UIScrollView.appearance.contentInsetAdjustmentBehavior= UIScrollViewContentInsetAdjustmentAutomatic;
        }else{
            self.automaticallyAdjustsScrollViewInsets = true;
        }
    }else{
        if (@available(iOS 11.0, *)) {
            UIScrollView.appearance.contentInsetAdjustmentBehavior= UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = false;
        }
    }
}

- (NSMutableArray *)funcArr
{
    if (_funcArr) {
        return _funcArr;
    }
    return _funcArr =  [NSMutableArray arrayWithArray:@[
                                                        @"errorHandlerRequest",
                                                        @"systemLanguageRequest",
                                                        @"setSystemLanguageRequest",
                                                        @"disableGoBackRequest",
                                                        @"goBackRequest",
                                                        @"isOpenBluetoothRequest",
                                                        @"isFirstBindingRequest",
                                                        @"deviceReconnectRequest",
                                                        @"addDeviceRequest",
                                                        @"closeSearchRequest",
                                                        @"turnOnBlueToothRequest",
                                                        @"equipmentSwitchRequest",
                                                        @"socketStatusRequest",
                                                        @"powerSwitchStatusRequest",
                                                        @"powerSwitchRequest",
                                                        @"systemSetupRequest",
                                                        @"commonPatternListDataRequest",
                                                        @"commonPatternNewTimingRequest",
                                                        @"commonPatternEditTimingRequest",
                                                        @"commonPatternDeleteTimingRequest",
                                                        @"countdownDataRequest",
                                                        @"powerSwitchCountdownRequest",
                                                        @"temperatureAndHumidityDataRequest",
                                                        @"alarmTemperatureValueRequest",
                                                        @"alarmHumidityValueRequest",
                                                        @"settingAlarmVoltageRequest",
                                                        @"queryAlarmVoltageRequest",
                                                        @"settingAlarmCurrentRequest",
                                                        @"queryAlarmCurrentRequest",
                                                        @"settingAlarmPowerRequest",
                                                        @"queryAlarmPowerRequest",
                                                        @"settingTemperatureUnitRequest",
                                                        @"queryTemperatureUnitRequest",
                                                        @"settingMonetarytUnitRequest",
                                                        @"queryMonetarytUnitRequest",
                                                        @"settingLocalElectricityRequest",
                                                        @"queryLocalElectricityRequest",
                                                        @"settingResumeSetupRequest",
                                                        @"BackupTimeAndDirectoryRequest",
                                                        @"BackupDataRequest",
                                                        @"BackupRecoveryDataRequest",
                                                        @"spendingCountdownDataRequest",
                                                        @"spendingCountdownAlarmRequest",
                                                        @"reNameRequest",
                                                        @"setStatusBarRequest",
                                                        @"isLoginRequest",
                                                        @"thirdPartyLoginRequest",
                                                        @"wechatLoginRequest",
                                                        @"alipayLoginRequest",
                                                        @"getMobilePhoneCodeRequest",
                                                        @"mobileLoginRequest",
                                                        @"emailLoginRequest",
                                                        @"emailSignupRequest",
                                                        @"emailForgotRequest",
                                                        @"logoutUserRequest",
                                                        @"isConnectToWiFiRequest",
                                                        @"WiFiNameRequest",
                                                        @"WiFiConfigRequest",
                                                        @"stopConnectionNetworkRequest",
                                                        @"openDeviceScanningRequest",
                                                        @"closeDeviceScanningRequest",
                                                        @"addDeviceConnectedByRouterRequest",
                                                        @"deviceListRequest",
                                                        @"controlDeviceRequest",
                                                        @"relieveControlDeviceRequest",
                                                        @"unbundlingDeviceRequest",
                                                        @"wifiPowerSwitchRequest",
                                                        @"wifiPowerSwitchStatusRequest",
                                                        @"deviceHistoryDataRequest",
                                                        @"deviceAccumulationParameterRequest",
                                                        @"deviceRateRequest",
                                                        @"userInformationRequest",
                                                        @"takePhotoRequest",
                                                        @"localPhotoRequest",
                                                        @"changePasswordRequest",
                                                        @"inspectversionUpdateRequest",
                                                        @"versionUpdateRequest",
                                                        @"cancelVersionUpdateRequest",
                                                        @"modifyUsernameRequest",
                                                        @"versionNumberRequest",
                                                        @"goToMallRequest",
                                                        @"checkFirmwareVersionRequest",
                                                        @"firmwareUpgradeRequest",
                                                        @"nightLightSettingRequest",
                                                        @"nightLightSwitchRequest",
                                                        @"timingNightLightRequest",
                                                        @"colourLampSwitchStateRequest",
                                                        @"colourLampSwitchRequest",
                                                        @"colourLampQueryRequest",
                                                        @"colourLampControlRequest",
                                                        @"colourLampModeQueryRequest",
                                                        @"colourLampModeListQueryRequest",
                                                        @"newColourLampModeRequest",
                                                        @"deleteColourLampModeRequest",
                                                        @"USBSwitchStateRequest",
                                                        @"USBSwitchRequest",
                                                        ]];
}

@end
