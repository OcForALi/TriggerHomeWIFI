//
//  ScanCodeViewController.m
//  Demo
//
//  Created by Mac on 2017/8/8.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import "ScanCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ScanCodeView.h"

#define QRCodeWidth  480/2.0  //正方形二维码的边长

@interface ScanCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIWebViewDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic, strong) ScanCodeView *scanView;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, copy) NSString *url;
@end

@implementation ScanCodeViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = false;
    self.navigationController.navigationBar.translucent = false;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = true;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    [self.view addSubview:self.scanView];
    [self initCarmera];
    [self initButton];
}


- (void)initCarmera
{
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        UIAlertController * alertC = [UIAlertController  alertControllerWithTitle:@"摄像头访问受限" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertC animated:YES completion:nil];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        [alertC addAction:action];
    }else{
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
        _output = [[AVCaptureMetadataOutput alloc] init];
        _session = [[AVCaptureSession alloc] init];
        
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        
        
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
        }
        
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        
        _preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _preview.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.preview atIndex:0];
        
        
        [self.session startRunning];
    }
}

- (void)initButton
{
    [self.view addSubview:self.flashBtn];
//    [self.view addSubview:self.photoBtn];
     UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(photo)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (ScanCodeView *)scanView
{
    if (!_scanView) {
        _scanView = [[ScanCodeView alloc] initWithFrame:self.view.bounds];
    }
    return _scanView;
}

- (UIButton *)flashBtn
{
    if (!_flashBtn) {
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashBtn.frame = CGRectMake((SCREEN_WITDH-35)/2.0, (SCREEN_HEIGHT-QRCodeWidth-NavBarHeight)/3.0+QRCodeWidth-50, 35, 35);
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:UIControlStateNormal];
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:UIControlStateSelected];
        _flashBtn.selected = false;
        [_flashBtn addTarget:self action:@selector(flash) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn;
}

- (UIButton *)photoBtn
{
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _photoBtn.frame = CGRectMake(250, 500, 50, 30);
//        [_photoBtn setTitle:@"photo" forState:UIControlStateNormal];
        [_photoBtn addTarget:self action:@selector(photo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *str ;
    @weakify(self);
    if ([metadataObjects count]) {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        str = metadataObject.stringValue;

        [weak_self.navigationController popViewControllerAnimated:true];
        if (weak_self.ScanCodeCallBack) {
            weak_self.ScanCodeCallBack(metadataObject.stringValue);
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{

    @weakify(self);
    NSData *data = UIImageJPEGRepresentation(image, 1);
    CIImage *ciImage = [CIImage imageWithData:data];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    NSArray *arr = [detector featuresInImage:ciImage];
    if (arr.count>0) {
        CIQRCodeFeature *feature = arr[0];
//        self.url = feature.messageString;

        [self dismissViewControllerAnimated:true completion:^{
            if (weak_self.ScanCodeCallBack) {
                weak_self.ScanCodeCallBack(feature.messageString);
            }
            [weak_self.navigationController popViewControllerAnimated:true];
        }];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"未发现二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        [self dismissViewControllerAnimated:true completion:^{
            
        }];
    }
}

- (void)flash
{
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:true];
        });
    });
    self.flashBtn.selected = !self.flashBtn.selected;
    if (self.flashBtn.selected) {
        [self openFlashLight];
    }else{
        [self closeFlashLight];
    }
}

- (void)photo
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        // 实例化UIImagePickerController控制器
        UIImagePickerController * imagePickerVC = [[UIImagePickerController alloc] init];
        // 设置资源来源（相册、相机、图库之一）
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 设置可用的媒体类型、默认只包含kUTTypeImage，如果想选择视频，请添加kUTTypeMovie
        // 如果选择的是视屏，允许的视屏时长为20秒
        imagePickerVC.videoMaximumDuration = 20;
        // 允许的视屏质量（如果质量选取的质量过高，会自动降低质量）
        imagePickerVC.videoQuality = UIImagePickerControllerQualityTypeHigh;
        imagePickerVC.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
        // 设置代理，遵守UINavigationControllerDelegate, UIImagePickerControllerDelegate 协议
        imagePickerVC.delegate = self;
        // 是否允许编辑（YES：图片选择完成进入编辑模式）
        imagePickerVC.allowsEditing = YES;
        // model出控制器
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

//开启闪光灯
- (void)openFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if ([backCamera hasTorch]) {
        NSError *error = nil;
        BOOL locked = [backCamera lockForConfiguration:&error];
        if (locked) {
            backCamera.torchMode = AVCaptureTorchModeOn;
            [backCamera unlockForConfiguration];
        }
    }
}
//关闭闪光灯
- (void)closeFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if ([backCamera hasTorch]) {
        NSError *error = nil;
        BOOL locked = [backCamera lockForConfiguration:&error];
        if (locked) {
            backCamera.torchMode = AVCaptureTorchModeOff;
            [backCamera unlockForConfiguration];
        }
    }
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    //    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
    //    return device;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
    
}

- (void)setUrl:(NSString *)url
{
    UIWebView *web = [[UIWebView alloc] initWithFrame:self.view.bounds];
    web.delegate = self;
    web.scrollView.bounces = false;
    [self.view addSubview:web];

    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [web loadRequest:req];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
