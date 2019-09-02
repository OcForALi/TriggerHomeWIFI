//
//  BaseControlModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"

@interface BaseControlModel : BaseModel<HandlingDataModelDelegate>

// 开关状态返回需要同时更新设备列表的开关状态
@property (nonatomic, copy) void(^updateDeviceListSwitchStausHandler)(NSDictionary *dic);

- (void)powerWIFISwitchStatusRequest:(NSDictionary *)object;

- (void)powerWIFISwitchRequest:(NSDictionary *)object;

- (void)powerSwitchStatusRequest:(NSDictionary *)object;

- (void)powerSwitchRequest:(NSDictionary *)object;

- (void)sendData:(NSMutableData *)data mac:(NSString *)mac;

@end
