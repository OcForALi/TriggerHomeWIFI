//
//  ConfigWiFiModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/7/18.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"

@interface ConfigWiFiModel : BaseModel<HandlingDataModelDelegate>

//保存局域网绑定成功后的设备sn
@property (nonatomic, copy) void(^bindDeviceSucess)(NSDictionary *snDic);

@property (nonatomic, copy) void(^jumpScanCodeHandler)(void);

- (void)addDeviceConnectedByRouterRequest:(NSDictionary *)object;

@end
