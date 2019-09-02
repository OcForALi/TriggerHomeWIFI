//
//  FirmwareUpdateModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/10/24.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"

@interface FirmwareUpdateModel : BaseModel<HandlingDataModelDelegate>

@property (nonatomic, copy) void(^updateDeviceListVersionHandler)(NSDictionary *dic);

- (void)checkFirmwareVersionRequest:(NSDictionary *)object;

@end
