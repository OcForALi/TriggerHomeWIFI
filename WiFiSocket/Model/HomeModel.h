//
//  WiFiModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/1.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface HomeModel : BaseModel<HandlingDataModelDelegate>

@property (nonatomic, copy) NSString *currentMac;
@property (nonatomic, copy) void(^deviceArrhandler)(NSMutableArray *arr);
@property (nonatomic, copy) void(^wifiPowerSwitchStatusRequestHandler)(NSDictionary *object);
@property (nonatomic, copy) void(^wifiPowerSwitchRequestHandler)(NSDictionary *object);
@property (nonatomic, copy) void(^wifiBindDeviceHandler)(NSDictionary *object);


- (void)updateDeviceInfoWithMac:(NSString *)mac;

@end
