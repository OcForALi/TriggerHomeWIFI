//
//  SpecialConstant.m
//  WiFiSocket
//
//  Created by Mac on 2018/11/8.
//  Copyright © 2018 QiXing. All rights reserved.
//

#import "SpecialConstant.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NSString *StartAIMUSIK = @"com.miniSocket";
NSString *WanWifiSocket = @"com.WifiSocket";
NSString *WanLondonSocket = @"com.LondonSocket";
NSString *NBSocket = @"com.Okaylight.NBSocket";

NSString *StartAIMUSIKScheme = @"StartAIMUSIK";  //自研插座bundilid
NSString *WanWifiSocketScheme = @"WanWifiTriggerHome"; //万总wifi插座bundilid
NSString *WanLondonSocketScheme = @"WanLondonSocket";  //英国插座
NSString *NBSocketScheme = @"WanNBSocket";  //地暖设备

uint8_t const CUSTOM_H_WAN = 0x00;      //万总

uint8_t const CUSTOM_L_WAN_TRIGGER_BLE = 0x00;    //triggerHomeBle
uint8_t const CUSTOM_L_WAN_TRIGGER_WIFI = 0x02;   //triggerHomeWifi
uint8_t const CUSTOM_L_WAN_LONDON_SOCKET = 0x06;   //英国插座

uint8_t const CUSTOM_H_LI= 0x02;      //李总

uint8_t const CUSTOM_L_LI_PASS_THROUGH = 0x00;    //

uint8_t const CUSTOM_H_STARTAI= 0x08;      //startai

uint8_t const CUSTOM_L_LI_STARTAI_MUSIC = 0x08;   //MUSIC

/**
 *  MUSIK
 */

//uint8_t const CUSTOM_H = CUSTOM_H_STARTAI;
//uint8_t const CUSTOM_L = CUSTOM_L_LI_STARTAI_MUSIC;

/**
 * triggerHomeWifi
 */

//uint8_t const CUSTOM_H = CUSTOM_H_WAN;
//uint8_t const CUSTOM_L = CUSTOM_L_WAN_TRIGGER_WIFI;

/**
 *  英国插座
 */
//uint8_t const CUSTOM_H = CUSTOM_H_WAN;
//uint8_t const CUSTOM_L = CUSTOM_L_WAN_LONDON_SOCKET;

/**
 *  NBSocket
 */
//uint8_t const CUSTOM_H = CUSTOM_H_WAN;
//uint8_t const CUSTOM_L = CUSTOM_L_WAN_TRIGGER_WIFI;


@implementation SpecialConstant

@end
