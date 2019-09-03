//
//  LightControlModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/10/30.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightControlModel : BaseModel<HandlingDataModelDelegate>

@property (nonatomic, assign) BOOL smallLightState;

- (void)ordinaryNightLightRequest:(NSDictionary *)object;

@end
