//
//  MQTTMessageEntity.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "MQTTMessageEntity.h"

@implementation MQTTMessageEntity

@end

@implementation MQTTMessageContentEntity

@end


@implementation MQTTFirmwareEntity

- (NSDictionary *)changeMyself
{
    return @{
             @"sysVersion":self.sysVersion.length?self.sysVersion:@"",
             @"firmwareVersion":self.firmwareVersion.length?self.firmwareVersion:@"",
             @"iNetMac":self.iNetMac.length?self.iNetMac:@"",
             @"wifiMac":self.wifiMac.length?self.wifiMac:@"",
             @"bluetoothMac":self.bluetoothMac.length?self.bluetoothMac:@"",
             @"product":self.product.length?self.product:@"",
             @"modelNumber":self.modelNumber.length?self.modelNumber:@"",
             @"imei":self.imei.length?self.imei:@"",
             @"sn":self.sn.length?self.sn:@"",
             @"screenSize":self.screenSize.length?self.screenSize:@"",
             @"cpuSerial":self.cpuSerial.length?self.cpuSerial:@"",
             @"os":self.os.length?self.os:@"",
             };
}

@end

@implementation MQTTStatusEntity

- (NSDictionary *)changeMyself
{
    return @{
             @"romStatus":self.romStatus,
             @"ramStatus":self.ramStatus,
             @"innerIP":self.innerIP,
             @"netWorkType":self.netWorkType,
             @"ssid":self.ssid,
             @"bssid":self.bssid,
             @"a_ver":self.a_ver,
             @"lat":self.lat,
             @"lng":self.lng,
             };
}

@end
