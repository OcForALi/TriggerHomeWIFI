//
//  TestViewController.m
//  WiFiSocket
//
//  Created by Mac on 2018/7/3.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "TestViewController.h"
#import "MqttClientManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>
#import "ScanCodeViewController.h"

@interface TestViewController ()<StartaiClientDelegate,CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIButton *activeBtn;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextFileld;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *identfiyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getIdentifyCodeBtn;

@property (weak, nonatomic) IBOutlet UIButton *registBtn;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *RecevieMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *useridTestfield;
@property (weak, nonatomic) IBOutlet UIScrollView *scollView;

@property (nonatomic, strong) CMMotionManager *motionManaer;

@end

@implementation TestViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.scollView.contentSize = CGSizeMake(SCREEN_WITDH, 1000);
        self.RecevieMessageLabel.frame = CGRectMake(0, 0, SCREEN_WITDH, 300);
        self.RecevieMessageLabel.numberOfLines = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[MqttClientManager shareInstance].client registDelegate:self];

    self.mobileTextFileld.keyboardType = 0 | 1;
    self.motionManaer = [[CMMotionManager alloc] init];
    self.motionManaer.accelerometerUpdateInterval = .1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // Do any additional setup after loading the view from its nib.
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.motionManaer stopAccelerometerUpdates];
}

- (void)connectedCallback:(StartAIResultState)res
{
    NSLog(@".....................MQTT连接..........%ld",(long)res);
}

- (void)disconnectedCallback:(StartAIResultState)res
{
    NSLog(@"...................MQTT断开连接...........%ld",(long)res);
}
- (void)onActiviteResult:(NSDictionary *)object
{
    
}

- (void)onRegisterResult:(NSDictionary *)object
{
    
}

- (void)onLoginResult:(NSDictionary *)object
{
    if ([object[@"result"] integerValue] == 1 && object[@"content"]) {
        NSDictionary *dic = object[@"content"];

    }
}

- (void)receviceMessage:(StartaiMqMessage *)message
{
    NSString *json = [[NSString alloc] initWithData:message.msg encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message.msg options:NSJSONReadingAllowFragments error:nil];
    NSString *msgtype = [dic objectForKey:@"msgtype"];
    NSLog(@"...............收到消息.................>%@",dic);
    if (![msgtype isEqualToString:@"0x8000"]) {
        dispatch_async(dispatch_get_main_queue(), ^{

            self.RecevieMessageLabel.text = json;
            self.RecevieMessageLabel.numberOfLines = 0;
            self.RecevieMessageLabel.textColor = [UIColor redColor];
        });
    }
}

- (IBAction)activeAction:(id)sender {
    StartAIInitialEntity *entity = [[StartAIInitialEntity alloc] init];
    entity.domain = @"okaylight";
    entity.appid = @"2e76e2a2631e2dd61ef4989c15ed6443";
    entity.apptype = @"smartOlWifi/controll/ios";
    entity.m_ver = @"Json_1.1.4_8.1";

    [[MqttClientManager shareInstance].client initializationWithInitialEntity:entity completionHandler:^(StartAIResultState res) {
        
    }];

}
- (IBAction)mobileEnd:(id)sender {
    
}

- (IBAction)passwordEnd:(id)sender {
    
}

- (IBAction)identfiyCodeEnd:(id)sender {
    
}

- (IBAction)useridEnd:(id)sender {
    
}


#pragma mark 校验验证码
- (IBAction)checkIdentfiyCode:(id)sender {
    [[MqttClientManager shareInstance].client checkIdentifyCodeWithAccount:self.mobileTextFileld.text checkCode:self.identfiyCodeTextField.text type:3 completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 获取验证码
- (IBAction)getIdentfiyCode:(id)sender {
//    NSInteger type ;
//    if (self.mobileTextFileld.text.length == 11) {
//        type = 2;
//    }else{
//        type = 1;
//    }

    [[MqttClientManager shareInstance].client getIdentifyCodeWithMobile:self.mobileTextFileld.text type:1 completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 注册
- (IBAction)registAction:(id)sender {
    NSInteger type ;
    if (self.mobileTextFileld.text.length == 11) {
        type = 2;
    }else{
        type = 1;
    }

    [[MqttClientManager shareInstance].client registWithUsername:self.mobileTextFileld.text password:self.passwordTextFiled.text type:type completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 注销
- (IBAction)cancelAccout:(id)sender {
    
    [[MqttClientManager shareInstance].client unActiviteWithSN:@"" completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma 登陆
- (IBAction)loginAction:(id)sender {
    NSInteger type = 0 ;
    if (self.mobileTextFileld.text.length == 11) {
        if (self.identfiyCodeTextField.text.length > 0 && self.passwordTextFiled.text.length>0) {
            type = 5;
        }else if (self.passwordTextFiled.text.length>0){
            type = 2;
        }else {
            type = 3;
        }
    }else{
        if ([self.mobileTextFileld.text containsString:@"com"] && [self.mobileTextFileld.text containsString:@"@"]) {
            type = 1;
        }else{
            type = 4;
        }
    }
    
    if (self.identfiyCodeTextField.text.length == 0) {
        self.identfiyCodeTextField.text = @"";
    }
    if (self.passwordTextFiled.text.length == 0) {
        self.passwordTextFiled.text = @"";
    }
    if (self.mobileTextFileld.text.length == 0) {
        self.mobileTextFileld.text = @"";
    }

    [[MqttClientManager shareInstance].client loginWithUsername:self.mobileTextFileld.text password:self.passwordTextFiled.text identifyCode:self.identfiyCodeTextField.text type:type completionHandler:^(StartAIResultState res) {
        
    }];
}

- (IBAction)changePassword:(id)sender {

    [[MqttClientManager shareInstance].client updateUserPwdWithOldPwd:self.passwordTextFiled newPwd:self.identfiyCodeTextField.text completionHandler:^(StartAIResultState res) {
        
    }];
}


#pragma mark 透传
- (IBAction)passthroughAnction:(id)sender {
    [[MqttClientManager shareInstance].client passthrough:self.useridTestfield.text data:self.useridTestfield.text completionHandler:^(StartAIResultState res) {
        NSLog(@"passthroughAnction.....................%ld",(long)res);
    }];
}

#pragma mark 更新设备信息
- (IBAction)deviceUpdate:(id)sender {
    
}

#pragma mark 更新用户信息
- (IBAction)userInfoUpdate:(id)sender {
    StartAIUserInfoEntity *entity = [[StartAIUserInfoEntity alloc] init];
//    @property (nonatomic, copy) NSString *userid;
//
//    @property (nonatomic, copy) NSString *userName;
//
//    @property (nonatomic, copy) NSString *birthday;
//
//    @property (nonatomic, copy) NSString *province;
//
//    @property (nonatomic, copy) NSString *city;
//
//    @property (nonatomic, copy) NSString *town;
//
//    @property (nonatomic, copy) NSString *address;
//
//    @property (nonatomic, copy) NSString *nickName;
//
//    @property (nonatomic, copy) NSString *headPic;
//
//    @property (nonatomic, copy) NSString *sex;
//
//    @property (nonatomic, copy) NSString *firstName;
//
//    @property (nonatomic, copy) NSString *lastName;
    entity.firstName = @"som";
    entity.lastName = @"bob";
    entity.userName = @"som bob";
    entity.userid = [MqttClientManager shareInstance].client.userid;
    entity.birthday = @"1999-9-9";
    entity.sex = @"1";
    entity.address = @"none";
    entity.nickName = @"nickname";
    entity.headPic = @"headpic";
    entity.town = @"none";
    entity.province = @"none";
    entity.city = @"none";
    
    [[MqttClientManager shareInstance].client updateUserInfoWithUserInfoEntity:entity completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 查询绑定关系
- (IBAction)queryBind:(id)sender {
    [[MqttClientManager shareInstance].client getBindListWithType:1 completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma 绑定
- (IBAction)bind:(id)sender {
    [[MqttClientManager shareInstance].client  beBind:self.useridTestfield.text completionHandler:^(StartAIResultState res) {
        NSLog(@"bind.....................%ld",(long)res);
    }];
}

#pragma 解绑
- (IBAction)unBind:(id)sender {
    [[MqttClientManager shareInstance].client beUnbindid:self.useridTestfield.text completionHandler:^(StartAIResultState res) {
        NSLog(@"unBind.....................%ld",(long)res);
    }];
}

#pragma 发送邮件
- (IBAction)sendEmailAction:(id)sender {
    
    [[MqttClientManager shareInstance].client sendEmail:self.mobileTextFileld.text type:1 completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 获取用户信息
- (IBAction)getUserInfoAction:(id)sender {
    NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:QXLoginStore];
    [[MqttClientManager shareInstance].client getUserInfoByLoginType:type completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 获取最新版本
- (IBAction)getLatestVersionAction:(id)sender {
    [[MqttClientManager shareInstance].client getLatestVersionWithOS:@"ios" packageName:@"" completionHandler:^(StartAIResultState res) {
        
    }];
}

#pragma mark 备注
- (IBAction)remarkAction:(id)sender {
    [[MqttClientManager shareInstance].client updateRemarkWithFid:self.useridTestfield.text remark:@"remark" completionHandler:^(StartAIResultState res) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}

- (IBAction)shakeAndshake:(id)sender {
//    [self startAccelerometer];
    @weakify(self);
    ScanCodeViewController *vc =  [[ScanCodeViewController alloc] init];
    vc.ScanCodeCallBack = ^(NSString *sn) {
        NSArray *arr = [sn componentsSeparatedByString:@"?"];
        if (arr.count>1) {
            weak_self.useridTestfield.text  = arr[1];
        }
    };
    [self.navigationController pushViewController:vc animated:true];
}

////系统使用，如电量低，突然来
//-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"触摸取消");
//}
//
//
////一摇开始
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
//    NSLog(@"摇一摇开始");
//    self.view.backgroundColor = [UIColor colorWithRed:arc4random()%256 / 255.0 green:arc4random()%256 / 255.0 blue:arc4random()%256 / 255.0 alpha:1.0];
//}
//
//
////摇一摇结束
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
//    NSLog(@"摇一摇结束");
//    self.view.backgroundColor = [UIColor whiteColor];
//    [self shakeshake];
//}
//
//
////摇一摇取消
//- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
//    NSLog(@"摇一摇取消");
//}
//

-(void)receiveNotification:(NSNotification *)notification
{
    if ([notification.name
         isEqualToString:UIApplicationDidEnterBackgroundNotification])
    {
        [self.motionManaer stopAccelerometerUpdates];
    }else{
        [self startAccelerometer];
    }
}

- (void)startAccelerometer
{
    [self.motionManaer startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        [self outputAccelertionData:accelerometerData.acceleration ];
        if (error) {
            NSLog(@"motion error:%@",error);
        }
    }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    //综合3个方向的加速度
    double accelerameter =sqrt( pow( acceleration.x , 2 ) + pow( acceleration.y , 2 )
                               + pow( acceleration.z , 2) );
    //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
    if (accelerameter>6.3f) {
        //立即停止更新加速仪（很重要！）
        [self.motionManaer stopAccelerometerUpdates];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //UI线程必须在此block内执行，例如摇一摇动画、UIAlertView之类
            [self shakeshake];
            NSLog(@"..........摇一摇");
        });
    }
}


- (void)animation {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(100, 50)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(100, 500)];

    anim.removedOnCompletion = NO;
    anim.duration = 1.0f;
    anim.fillMode = kCAFillModeForwards;
    anim.delegate = self;
    //  随便拖过来的一个label测试效果
    [self.mobileTextFileld.layer addAnimation:anim forKey:nil];
}

//  摇动结束后执行震动
- (void)shakeshake {
    　　// 震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


- (void)onBindResult:(BOOL)result errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg beBindInfo:(NSDictionary *)beBindInfo
{
    NSString *sn = [beBindInfo objectForKey:@"id"];
    NSString *topic = [NSString stringWithFormat:@"Q/client/will/+/%@",sn];
    [[MqttClientManager shareInstance].client subscribe:topic completionHandler:^(StartAIResultState res) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
