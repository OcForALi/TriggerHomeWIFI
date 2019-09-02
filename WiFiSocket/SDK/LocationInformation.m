//
//  map.m
//  Demo
//
//  Created by Mac on 2017/8/7.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import "LocationInformation.h"
#import <MapKit/MapKit.h>
//#import "MQTTClientManager.h"
@interface LocationInformation ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManger;//定位管理
@property (nonatomic, assign) BOOL needResponse;    //监听定位权限不用告知UI

@end

@implementation LocationInformation

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (LocationInformation *)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.latitude = @"获取失败";
        self.longitude = @"获取失败";
        self.addr = @"获取失败";
        self.address = @"获取失败";
        self.country = @"获取失败";
        self.city = @"获取失败";
        self.province = @"获取失败";
        self.street = @"获取失败";
        self.town = @"获取失败";
        self.canGetLocation = false;
        self.needResponse = true;
        
//        self.locationManger = [[CLLocationManager alloc] init];
//        self.locationManger.delegate = self;
//        //精准度设置
//        self.locationManger.desiredAccuracy = kCLLocationAccuracyBest;
//        //多远更新一次距离
//        [self.locationManger setDistanceFilter:5.0f];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (CLLocationManager *)locationManger
{
    if (!_locationManger) {
        _locationManger = [[CLLocationManager alloc] init];
        _locationManger.delegate = self;
        //精准度设置
        _locationManger.desiredAccuracy = kCLLocationAccuracyBest;
        //多远更新一次距离
        [_locationManger setDistanceFilter:100000];
    }
    return _locationManger;
}

- (void)becomeActive
{
    self.needResponse = false;
    [self startLoaction];
}

- (BOOL)getLocationJurisdiction
{
    if ([CLLocationManager locationServicesEnabled]  //确定用户的位置服务启用
        &&[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusDenied)
        //位置服务是在设置中禁用
    {
        self.canGetLocation = true;
        return true;
        
    }else{
        self.canGetLocation = false;
        return false;
    }
}

- (void)startLoaction
{
    if ([CLLocationManager locationServicesEnabled]  //确定用户的位置服务启用
        &&[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusDenied)
        //位置服务是在设置中禁用
    {
        //开始定位
        [self.locationManger startUpdatingLocation];
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 7.999) {
            // 设置定位权限仅iOS8以上有意义,而且iOS8以上必须添加此行代码
            [self.locationManger requestWhenInUseAuthorization];//前台定位
            // [self.locationManager requestAlwaysAuthorization];//前后台同时定位
        }
        self.canGetLocation = true;
        if (self.needResponse) {
            if (self.getLocationJurisdictionHandler) {
                self.getLocationJurisdictionHandler(true);
            }
        }

    }else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请前往设置打开定位服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView show];
        self.canGetLocation = false;
        if (self.needResponse) {
            if (self.getLocationJurisdictionHandler) {
                self.getLocationJurisdictionHandler(false);
            }
        }
    }
    self.needResponse = true;
}

- (void)endLocation
{
    [self.locationManger stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

//地理位置更新回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    __weak typeof(self) weakSelf = self;
    //获取到位置信息之后停止更新地理位置
    [self.locationManger stopUpdatingLocation];
    
    //获取位置对象
    CLLocation *lastLoaction = [locations lastObject];
    //提取经纬度
    CLLocationCoordinate2D myLocation ;//= CLLocationCoordinate2DMake(23.134025, 113.379635);
    //纬度
    myLocation.latitude = [lastLoaction coordinate].latitude;
    //经度
    myLocation.longitude = [lastLoaction coordinate].longitude;
    
    self.longitude = [NSString stringWithFormat:@"%f", myLocation.longitude];
    self.latitude = [NSString stringWithFormat:@"%f", myLocation.latitude];
    NSLog(@"经度：%f,纬度：%f",myLocation.longitude,myLocation.latitude);
    
    //显示到地图定位
    //    MKCoordinateRegion resgion = MKCoordinateRegionMake(myLocation, MKCoordinateSpanMake(1.0, 1.0));
    //    [self.mapView setRegion:resgion animated:YES];
    
    CLLocation *lo = [[CLLocation alloc] initWithLatitude:myLocation.latitude longitude: myLocation.longitude];
    //地理反编码
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    __weak typeof(self) *weakself 
    [geocoder reverseGeocodeLocation:lo completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        if (error !=nil || placemarks.count==0) {
            @weakify(self);
            if (self.getLoactionHandler) {
                self.getLoactionHandler(weak_self.latitude, weak_self.longitude);
            }
            NSLog(@"%@",error);
            return ;
        }
        /**
         **第一次未获取到地理信息当获取到之后需重新登录一次
         */

        BOOL repeatLogo = [weakSelf.addr isEqualToString:@"获取失败"];
        
        //详细地理位置
        NSLog(@"%@",placemark.name);
//        weakSelf.addr = [self fillString:placemark.name ];
        //国家
        NSLog(@"%@",placemark.country);
        weakSelf.country = [self fillString:placemark.country ];
        //省
        NSLog(@"%@",placemark.administrativeArea);
        weakSelf.province = placemark.administrativeArea;
        //市
        NSLog(@"%@",placemark.locality);
        weakSelf.city = [self fillString:placemark.locality ];
        //区
        NSLog(@"%@",placemark.subLocality);
        weakSelf.town = [self fillString:placemark.subLocality ];
        //街道
        NSLog(@"%@",placemark.thoroughfare);
        weakSelf.street = [self fillString:placemark.thoroughfare];
        //子街道
        NSLog(@"%@",[self fillString:placemark.subThoroughfare ]);
        
        weakSelf.address = [NSString stringWithFormat:@"%@%@%@%@%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare];
        weakSelf.addr = weakSelf.address;
        
        @weakify(self);
        if (self.getLoactionHandler) {
            self.getLoactionHandler(weak_self.latitude, weak_self.longitude);
        }
        
    }];

}

- (NSString *)fillString:(NSString *)str
{
    if (str && str != NULL) {
        return str;
    }else{
        return @"";
    }
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

@end
