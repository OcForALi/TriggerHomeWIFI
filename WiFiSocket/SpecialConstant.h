//
//  SpecialConstant.h
//  WiFiSocket
//
//  Created by Mac on 2018/11/8.
//  Copyright © 2018 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


extern NSString *StartAIMUSIK;  //自研插座bundilid
extern NSString *WanWifiSocket; //万总wifi插座bundilid
extern NSString *WanLondonSocket;  //英国插座
extern NSString *NBSocket;  //地暖设备

extern NSString *StartAIMUSIKScheme;  //自研插座bundilid
extern NSString *WanWifiSocketScheme; //万总wifi插座bundilid
extern NSString *WanLondonSocketScheme;  //英国插座
extern NSString *NBSocketScheme;  //地暖设备

extern uint8_t const CUSTOM_H_WAN;      //万总

extern uint8_t const CUSTOM_L_WAN_TRIGGER_BLE ;    //triggerHomeBle
extern uint8_t const CUSTOM_L_WAN_TRIGGER_WIFI ;   //triggerHomeWifi
extern uint8_t const CUSTOM_L_WAN_LONDON_SOCKET;   //英国插座

extern uint8_t const CUSTOM_H_LI;      //李总

extern uint8_t const CUSTOM_L_LI_PASS_THROUGH;    //

extern uint8_t const CUSTOM_H_STARTAI;      //startai

extern uint8_t const CUSTOM_L_LI_STARTAI_MUSIC;   //MUSIC

//extern uint8_t const CUSTOM_H ;
//extern uint8_t const CUSTOM_L ;

@interface SpecialConstant : NSObject

@end

NS_ASSUME_NONNULL_END
