//
//  map.h
//  Demo
//
//  Created by Mac on 2017/8/7.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationInformation : NSObject

@property (nonatomic, assign) BOOL canGetLocation;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *town;

@property (nonatomic, copy) void(^getLocationJurisdictionHandler)(BOOL res);
@property (nonatomic, copy) void(^getLoactionHandler)(NSString *lat,NSString *longitude);

- (BOOL)getLocationJurisdiction;

- (void)startLoaction;

- (void)endLocation;

+ (LocationInformation *)shareInstance;

@end
