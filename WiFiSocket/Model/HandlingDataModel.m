//
//  HandlingDataModel.m
//  BluetoothSocket
//
//  Created by Mac on 2018/7/16.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "HandlingDataModel.h"
#import <objc/runtime.h>

#import "LoginModel.h"          //登陆管理
#import "HomeModel.h"           //设备主界面管理
#import "ConfigWiFiModel.h"     //配网管理
#import "BaseControlModel.h"    //设备基础任务管理
#import "SettingModel.h"        //设备进阶设置管理
#import "MallModel.h"           //商城管理model
#import "UserInfoModel.h"       //用户信息管理
#import "FirmwareUpdateModel.h" //固件升级管理
#import "MqMessageResponseModel.h"  //广域网消息处理
#import "LightControlModel.h"       //灯光管理
#import "QueryHistoryModel.h"       //查询设备历史记录

@interface HandlingDataModel ()
{
    uint8_t useDataLoc; //获取有效数据部分起始位置 不包含result
}
@property (nonatomic, strong) NSMutableData *recevieData;
@property (nonatomic, weak) id<HandlingDataModelDelegate>delegate;
@property (nonatomic, strong) NSMutableDictionary *deviceDic;

@property (nonatomic, strong) NSDictionary *delegeDic;

@end

@implementation HandlingDataModel


+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.recevieData = [[NSMutableData alloc] init];
        self.deviceDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)regegistDelegate:(id)obj
{
    self.delegate = obj;
}

- (void)unRegistDelegate:(id)obj
{
    self.delegate = nil;
}


- (NSDictionary *)delegeDic
{
    return @{
             [NSString stringWithFormat:@"%d-%d",0x02,0x04]:[HomeModel shareInstance],    //时间校准回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x10]:[HomeModel shareInstance],    //查询当前时间回复

             [NSString stringWithFormat:@"%d-%d",0x01,0x06]:[ConfigWiFiModel shareInstance],    //绑定与解绑回复
                     
             [NSString stringWithFormat:@"%d-%d",0x01,0x36]:[BaseControlModel shareInstance],    //设置开关控制返回
             [NSString stringWithFormat:@"%d-%d",0x01,0x38]:[BaseControlModel shareInstance],    //查询开关状态返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x02]:[BaseControlModel shareInstance],    //设置电源开关返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x06]:[BaseControlModel shareInstance],    //设置定时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x08]:[BaseControlModel shareInstance],    //设置倒计时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x0a]:[BaseControlModel shareInstance],    //设置定温度回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x0c]:[BaseControlModel shareInstance],    //查询开关状态返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x0e]:[BaseControlModel shareInstance],    //查询倒计时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x12]:[BaseControlModel shareInstance],    //查询定温度返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x14]:[BaseControlModel shareInstance],    //查询定时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x16]:[BaseControlModel shareInstance],    //设置定电定费回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x18]:[BaseControlModel shareInstance],    //查询定电定费
             [NSString stringWithFormat:@"%d-%d",0x02,0x2C]:[BaseControlModel shareInstance],    //设置温湿度定时模式返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x2E]:[BaseControlModel shareInstance],    //查询温湿度定时模式返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x3A]:[BaseControlModel shareInstance],    //查询传感器返回
             [NSString stringWithFormat:@"%d-%d",0x03,0x01]:[BaseControlModel shareInstance],    //上报温湿度
             [NSString stringWithFormat:@"%d-%d",0x03,0x03]:[BaseControlModel shareInstance],    //上报功率电压
             [NSString stringWithFormat:@"%d-%d",0x03,0x05]:[BaseControlModel shareInstance],    //上报定温度完成
             [NSString stringWithFormat:@"%d-%d",0x03,0x07]:[BaseControlModel shareInstance],    //上报倒计时
             [NSString stringWithFormat:@"%d-%d",0x03,0x09]:[BaseControlModel shareInstance],    //上报定时结束
             [NSString stringWithFormat:@"%d-%d",0x03,0x11]:[BaseControlModel shareInstance],    //上报传感器状态
             [NSString stringWithFormat:@"%d-%d",0x02,0x40]:[BaseControlModel shareInstance],    //查询7种状态
             [NSString stringWithFormat:@"%d-%d",0x02,0x44]:[BaseControlModel shareInstance],    //温温度-恒温模式设置返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x46]:[BaseControlModel shareInstance],    //温度-恒温模式列表数据返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x48]:[BaseControlModel shareInstance],    //温度-恒温模式删除返回
                     
             [NSString stringWithFormat:@"%d-%d",0x01,0x0c]:[SettingModel shareInstance],    //重命名设备名称
             [NSString stringWithFormat:@"%d-%d",0x02,0x0e]:[SettingModel shareInstance],    //查询设备名称
             [NSString stringWithFormat:@"%d-%d",0x02,0x3C]:[SettingModel shareInstance],    //控制指示灯返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x3E]:[SettingModel shareInstance],    //查询指示灯返回
             [NSString stringWithFormat:@"%d-%d",0x04,0x10]:[SettingModel shareInstance],    //设置电压告警回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x12]:[SettingModel shareInstance],    //查询电压告警回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x14]:[SettingModel shareInstance],    //设置电流告警回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x16]:[SettingModel shareInstance],    //查询电流告警回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x18]:[SettingModel shareInstance],    //设置功率g告警回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x1a]:[SettingModel shareInstance],    //查询功率告警回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x1c]:[SettingModel shareInstance],    //设置温度单位回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x1e]:[SettingModel shareInstance],    //查询温度单位回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x20]:[SettingModel shareInstance],    //设置货币单位回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x22]:[SettingModel shareInstance],    //查询货币单位回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x24]:[SettingModel shareInstance],    //设置本地电价回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x26]:[SettingModel shareInstance],    //查询本地电价回复
             [NSString stringWithFormat:@"%d-%d",0x04,0x28]:[SettingModel shareInstance],    //恢复出厂设置回复
                     
             [NSString stringWithFormat:@"%d-%d",0x01,0x0a]:[FirmwareUpdateModel shareInstance],        //固件查询升级操作
             
             [NSString stringWithFormat:@"%d-%d",0x02,0x26]:[LightControlModel shareInstance],       //设置rgb回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x2A]:[LightControlModel shareInstance],       //查询rgb回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x30]:[LightControlModel shareInstance],        //查询彩灯模式返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x32]:[LightControlModel shareInstance],        //设置彩灯模式返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x34]:[LightControlModel shareInstance],        //查询所有彩灯模式返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x36]:[LightControlModel shareInstance],        //小夜灯定时设置返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x38]:[LightControlModel shareInstance],        //小夜灯查询返回
                     
             [NSString stringWithFormat:@"%d-%d",0x02,0x1a]:[QueryHistoryModel shareInstance],       //查询一天历史数据回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x42]:[QueryHistoryModel shareInstance],       //查询一天历史数据回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x1A]:[QueryHistoryModel shareInstance],    //按时间查询已用电量电费返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x20]:[QueryHistoryModel shareInstance],       //查询费率回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x22]:[QueryHistoryModel shareInstance],       //查询设备累计参数
             [NSString stringWithFormat:@"%d-%d",0x03,0x0B]:[QueryHistoryModel shareInstance],    //上报电量数据
             
             
             [NSString stringWithFormat:@"%d-%d",0x01,0x02]:[UDPSocket shareInstance],    //心跳回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x2e]:[UDPSocket shareInstance],    //请求token返回
             [NSString stringWithFormat:@"%d-%d",0x01,0x30]:[UDPSocket shareInstance],    //局域网连接握手返回
             [NSString stringWithFormat:@"%d-%d",0x01,0x32]:[UDPSocket shareInstance],    //局域网休眠
             [NSString stringWithFormat:@"%d-%d",0x02,0x0a]:[UDPSocket shareInstance],
             
             [NSString stringWithFormat:@"%d-%d",0x01,0x04]:[MqMessageResponseModel shareInstance],    //发现设备回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x0e]:[MqMessageResponseModel shareInstance],    //查询设备名称回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x3E]:[MqMessageResponseModel shareInstance],    //查询WiFiSSID
             
             };
}

- (void)handlingRecevieData:(NSData *)data deviceIdentifiy:(NSString *)deviceIdentifiy fromAddress:(NSString *)address
{
    //设备按照局域网广域网消息分开解析
    NSMutableData *property = objc_getAssociatedObject(self, &deviceIdentifiy);
    if (!property) {
        property = [NSMutableData data];
        objc_setAssociatedObject(self, &deviceIdentifiy, property, OBJC_ASSOCIATION_RETAIN);
    }
    
    NSInteger len = -1;
    Byte *test = (Byte*)[data bytes];//得到data1中bytes的指针。
    for (NSInteger i=0; i<data.length; i++) {
        Byte byte = test[i];
        if (byte== 0xff && property.length) {
            // 在组包过程中又发现了包头 丢弃旧包
            property = [[NSMutableData alloc]init];
        }
        [property appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
        if (byte == 0xee) {
            //组成完整的包 剩余的数据留在下一包解析
            len = i+1;
            break;
        }
    }

    if (property.length) {
        //没有包头的数据直接丢弃
        uint8_t ffx = 0xff;
        NSData *ff = [property subdataWithRange:NSMakeRange(0, 1)];
        if (![ff isEqualToData:[NSData dataWithBytes:&ffx length:1]]) {
            property = [[NSMutableData alloc] init];
        }
    }
    
    if (property.length) {
        //没有包尾的数据继续等待下一条数据
        uint8_t eex = 0xee;
        NSData *ee = [property subdataWithRange:NSMakeRange(property.length-1, 1)];
        if (![ee isEqualToData:[NSData dataWithBytes:&eex length:1]]) {
            return;
        }
    }
    
    NSRange range;
    
    if (property.length > 0) {
        range = [property rangeOfData:[ToolHandle getData:0xee] options:NSDataSearchAnchored range:NSMakeRange(0, property.length-1)];
    }
    
    if (property.length>0 && range.length ) {
        // 数据解析有误重新解析
        NSMutableData *da1 = [NSMutableData dataWithData:property];
        property = [NSMutableData data];
        objc_setAssociatedObject(self, &deviceIdentifiy, property, OBJC_ASSOCIATION_RETAIN);
        [self handlingRecevieData:da1 deviceIdentifiy:deviceIdentifiy fromAddress:address];
        return;
    }
    
    //将数据包中需要转义的数据重新序列化
    property = [ToolHandle escapingSpecialCharacters:property];
    
    uint8_t reserve = 8;  //协议预留字节长度
    Byte type = 0x00;     //指令类型
    Byte cmd = 0x00;      //指令
    useDataLoc = 3+reserve+2+1;     //获取result之后第一个有效数据位置
    Byte *testByte = (Byte*)[property bytes];
    self.recevieData = property;

    uint8_t custome_h = [[QXUserDefaults objectForKey:CUSTOM_H] intValue];
    uint8_t custome_l = [[QXUserDefaults objectForKey:CUSTOM_L] intValue];
    
    if (!([self getByteWithoffset:3+reserve-2] == custome_h)
        || !([self getByteWithoffset:3+reserve-1] == custome_l)) {
        // 不是此app的数据不进行解析
        property = [NSMutableData data];
        objc_setAssociatedObject(self, &deviceIdentifiy, property, OBJC_ASSOCIATION_RETAIN);
        return;
    }
    
//    DDLog(@"特征值更新......................%@",property);
    
    if (property.length<5) {
        DDLog(@"无效数据....................");
        return;
    }
    
    Byte selfCrc8 = myCRC8(testByte, 3, (int)property.length-2);
    NSData *crc8Data = [property subdataWithRange:NSMakeRange(property.length-2, 1)];
    if (![[NSData dataWithBytes:&selfCrc8 length:sizeof(selfCrc8)] isEqualToData:crc8Data]) {
        DDLog(@"不符合crc8数据校验规则................");
        return;
    }
    
    for(int i = 0;i<[property length];i++){
        if (i==3+reserve) {
            type = testByte[i];
        }else if (i==4+reserve){
            cmd =testByte[i];
        }
    }
    
    
    // 局域网消息传mac地址  广域网消息传sn 要找到mac地址
    NSString *deviceMac;
    if (address) {
        deviceMac = deviceIdentifiy;
    }else{
        deviceMac = deviceIdentifiy;//@"mac";
        for (NSDictionary *device in self.deviceArr) {
            if ([device[@"id"] isEqualToString:deviceIdentifiy]) {
                if (device[@"mac"]) {
                    deviceMac = device[@"mac"];
                }
            }
        }
    }
    
    if ((testByte[5+2] == 0x06) || (testByte[5+8] == 0x06)) {
        [[UDPSocket shareInstance] closed];
    }
    
    // 去掉重发消息队列中的指令
    NSString *key = [NSString stringWithFormat:@"%@-%d-%d",deviceMac,type,cmd-1];
    if ([[UDPSocket shareInstance].sendMsgDic.allKeys containsObject:key]) {
        [[UDPSocket shareInstance].sendMsgDic removeObjectForKey:key];
    }
    
    // 指令发生错误
    if (type == 0x00 && cmd == 0x00) {
        uint8_t result = [self getByteWithoffset:useDataLoc-1];
        uint8_t errType = [self getByteWithoffset:useDataLoc];
        uint8_t errCmd = [self getByteWithoffset:useDataLoc+1];
        
//        result 0x00 数据错误 0x02校验错误 0x03 命令类型错误 0x04 命令错误 0x05 有效数据长度错误
        DDLog(@"控制指令发生错误...............%d..........%d..........%d.",result,errType,errCmd);
    }
    
    //指令控制失败
    BOOL result = (BOOL)[self getByteWithoffset:useDataLoc-1];
    result = !result;
    if (result == false && type != 0x03) {
        DDLog(@"当前指令返回失败...............%d..........%d.........",type,cmd);
        return;
    }
    
    //根据指令找到代理
    self.delegate = nil;
    id classIva = [self.delegeDic objectForKey:[NSString stringWithFormat:@"%d-%d",type,cmd]];
    if (!classIva) {
        return;
    }
    self.delegate = classIva;

    if (type == 0x01) {
        if (cmd == 0x02) {
            //心跳回复
            if ([self.delegate respondsToSelector:@selector(heartBeatResponse:deviceMac:)]) {
                [self.delegate heartBeatResponse:@{@"state":@([self getByteWithoffset:useDataLoc-1])} deviceMac:deviceMac];
            }
//            DDLog(@"/n/n...............心跳回复.....................");
        }else if(cmd == 0x04 && property.length>50){
            //发现设备回复
            //            if (testByte[8] == 0x01) {
            //BLE插座
            //            }else if (testByte[8] == 0x02){
            //WiFi插座
            //                Byte *addressbyte = (Byte *)[address bytes];

            NSMutableString *macStr = [[NSMutableString alloc] init];
            NSInteger macLoc = useDataLoc+1;  //mac地址起始地址
            for (NSInteger i=macLoc; i<macLoc+6; i++) {
                NSString *str;
                if (testByte[i] < 16) {
                    str = [NSString stringWithFormat:@"0%x:",testByte[i]];
                }else{
                    str = [NSString stringWithFormat:@"%x:",testByte[i]];
                }
                str = [str uppercaseString];
                [macStr appendString:str];
            }
            [macStr replaceCharactersInRange:NSMakeRange(macStr.length-1, 1) withString:@""];

            NSInteger nameLoc = useDataLoc+1+6; //设备名称起始地址
            NSData *name = [property subdataWithRange:NSMakeRange(nameLoc, 32)];
            name = [self replaceNoUtf8:name];
            NSString *nameStr = [NSString stringWithUTF8String:[name bytes]];
            if ([nameStr hasPrefix:@"*"]) {
                nameStr = [nameStr substringWithRange:NSMakeRange(1, nameStr.length-1)];
            }

            NSString *version = [NSString stringWithFormat:@"%d.%d",[self getByteWithoffset:useDataLoc+1+6+32],[self getByteWithoffset:useDataLoc+1+6+32+1]];

            int bindLoc = useDataLoc+1+6+32+1+1+1;
            uint8_t bindStaus = [self getByteWithoffset:bindLoc];
            //            uint8_t bit0 = bindStaus & 0x01;
            int bit1 = bindStaus & 0x02;
            //            uint8_t bit2 = bindStaus & 0x04;
            uint8_t bit4 = bindStaus & 0x10;
            uint8_t bit5 = bindStaus & 0x20;
            //            uint8_t useState = testByte[bindLoc+1];
            BOOL bindState = bit4 + bit5>0?true:false;

            int rssi = (int8_t)[self getByteWithoffset:bindLoc+2]/100;
            NSString *wifiStr;
            if (property.length>bindLoc+2+32+2) {
                NSData *wifiData = [property subdataWithRange:NSMakeRange(bindLoc+2+1, 32)];
                wifiData = [self replaceNoUtf8:wifiData];
                wifiStr = [NSString stringWithUTF8String:[wifiData bytes]];
                if ([wifiStr hasPrefix:@"*"]) {
                    wifiStr = [wifiStr substringWithRange:NSMakeRange(1, wifiStr.length-1)];
                }
                if (!wifiStr) {
                    wifiStr = [BasicInfoCollection getCurreWiFiSsid];
                }
            }else{
                wifiStr = [BasicInfoCollection getCurreWiFiSsid];
            }
            
            NSDictionary * dic = @{
                                   @"name": nameStr,
                                   @"mac": macStr,
                                   @"ip": address,
                                   @"encrypted":@(bit1>0),
                                   @"isBinding":@(bindState),
                                   @"remoteStatus":@([self getByteWithoffset:52]),
                                   @"version":version,
                                   @"wifiInfomation": @{
                                           @"ssid": wifiStr,
                                           @"strength": @(rssi)
                                           }
                                   };
            [self.deviceDic setObject:address forKey:macStr];
            
            if (self.findDeviceHandler) {
                self.findDeviceHandler(dic,self.deviceDic);
            }
//            DDLog(@"--------------发现设备：%@--------------发现包：%@",nameStr,property);
        }
        else if (cmd == 0x06){
            //绑定与解绑回复
            BOOL isBind = [self getByteWithoffset:(int)(property.length-3)]>0?true:false;
            NSInteger snLoc = useDataLoc+1;
            NSData *sn = [property subdataWithRange:NSMakeRange(snLoc, 32)];
            NSData *mac = [property subdataWithRange:NSMakeRange(snLoc+32+32, 6)];
            NSDictionary *dic = @{
                                  @"result":@(result),
                                  @"sn":sn,
                                  @"mac":mac,
                                  };
            if (isBind && [self.delegate respondsToSelector:@selector(bindDeviceResponse:deviceMac:)]) {
                [self.delegate bindDeviceResponse:dic deviceMac:deviceMac];
            }else if(!isBind && [self.delegate respondsToSelector:@selector(unBindDeviceResponse:deviceMac:)]){
                [self.delegate unBindDeviceResponse:dic deviceMac:deviceMac];
            }
            
        }else if (cmd == 0x0a){
            //固件操作信息 0x1:升级  0x2:查询 0x3 强制升级
            NSString *current = [NSString stringWithFormat:@"%d.%d",[self getByteWithoffset:useDataLoc+1],[self getByteWithoffset:useDataLoc+2]];
            NSString *new = [NSString stringWithFormat:@"%d.%d",[self getByteWithoffset:useDataLoc+3],[self getByteWithoffset:useDataLoc+4]];
            if ([self.delegate respondsToSelector:@selector(FirmwareOperationResponse:deviceMac:)]) {
                [self.delegate FirmwareOperationResponse:@{@"result":@(result),@"type":@([self getByteWithoffset:useDataLoc]),
                                                           @"currentVersion":current,@"newVersion":new,
                                                           @"progress":@([self getByteWithoffset:useDataLoc+5])
                                                           } deviceMac:deviceMac];
            }
        }else if (cmd == 0x0c) {
            //重命名设备名称
            NSInteger nameLoc = useDataLoc; //设备名称起始地址
            NSData *name = [data subdataWithRange:NSMakeRange(nameLoc, 32)];
            name = [self replaceNoUtf8:name];
            NSString *nameStr = [NSString stringWithUTF8String:[name bytes]];
            if ([nameStr hasPrefix:@"*"]) {
                nameStr = [nameStr substringWithRange:NSMakeRange(1, nameStr.length-1)];
            }
            if (self.reNameDeviceHandler) {
                self.reNameDeviceHandler(@{@"name":nameStr,@"mac":deviceMac});
            }
            if ([self.delegate respondsToSelector:@selector(reNameResponse:deviceMac:)]) {
                [self.delegate reNameResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
            for (NSDictionary *dic in [UDPSocket shareInstance].deviceInfoArr) {
                if ([dic[@"mac"] isEqualToString:deviceMac]) {
                    NSString *sn = dic[@"id"];
                    if (sn.length) {
                        [[MqttClientManager shareInstance].client updateRemarkWithFid:sn remark:nameStr completionHandler:^(StartAIResultState res) {
                            
                        }];
                        break;
                    }
                }
            }
            
        }else if (cmd == 0x0e){
            //查询设备名称返回
            if (property.length>useDataLoc+32) {
                NSData *name = [data subdataWithRange:NSMakeRange(useDataLoc, 32)];
                name = [self replaceNoUtf8:name];
                NSString *nameStr = [NSString stringWithUTF8String:[name bytes]];
                if ([nameStr hasPrefix:@"*"]) {
                    nameStr = [nameStr substringWithRange:NSMakeRange(1, nameStr.length-1)];
                }
                if (self.reNameDeviceHandler) {
                    self.reNameDeviceHandler(@{@"name":nameStr,@"mac":deviceMac});
                }
                if ([self.delegate respondsToSelector:@selector(queryDeviceNameResponse:deviceMac:)]) {
                    [self.delegate queryDeviceNameResponse:@{@"name":nameStr} deviceMac:deviceMac];
                }
                for (NSDictionary *dic in [UDPSocket shareInstance].deviceInfoArr) {
                    if ([dic[@"mac"] isEqualToString:deviceMac]) {
                        NSString *sn = dic[@"id"];
                        if (sn.length) {
                            [[MqttClientManager shareInstance].client updateRemarkWithFid:sn remark:nameStr completionHandler:^(StartAIResultState res) {
                                
                            }];
                            break;
                        }
                    }
                }
            }

        }else if (cmd == 0x2b){
            //请求注册

        }else if (cmd == 0x2e){
            //请求token码回复
            NSData *tokenData = [property subdataWithRange:NSMakeRange(useDataLoc+4, 4)];
            DDLog(@"............请求token码返回返回....................%d",result);
            if ([self.delegate respondsToSelector:@selector(requestTokenResonse:deviceMac:)]) {
                [self.delegate requestTokenResonse:@{@"result":@(result),@"token":tokenData} deviceMac:deviceMac];
            }
        }else if (cmd == 0x30){
            //局域网连接返回
//            DDLog(@"............局域网握手连接返回....................%d",result);
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"局域网握手连接返回" message:[NSString stringWithFormat:@"%d",result] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alertView show];
            if ([self.delegate respondsToSelector:@selector(requestLANConnectionResponse:deviceMac:)]) {
                [self.delegate requestLANConnectionResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x32){
            //局域网休眠
            if ([self.delegate respondsToSelector:@selector(requestLanConnectionSleepResponse:deviceMac:)]) {
                [self.delegate requestLanConnectionSleepResponse:@{@"result":@([self getByteWithoffset:useDataLoc-1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x36){
            //开关控制返回
            uint8_t model = [self getByteWithoffset:useDataLoc+1];
            [self switchInstructionReturn:model result:result deviceMac:deviceMac];

        }else if (cmd == 0x38){
            //查询开关返回
            uint8_t model = [self getByteWithoffset:useDataLoc+1];
            [self switchInstructionReturn:model result:result deviceMac:deviceMac];

        }else if (cmd == 0x3E){
            //获取设备wifissid
            int rssi = (int8_t)[self getByteWithoffset:useDataLoc];
            NSString *wifiStr;
            if (property.length>useDataLoc+32) {
                NSData *wifiData = [property subdataWithRange:NSMakeRange(useDataLoc+1, 32)];
                wifiData = [self replaceNoUtf8:wifiData];
                wifiStr = [NSString stringWithUTF8String:[wifiData bytes]];
                if ([wifiStr hasPrefix:@"*"]) {
                    wifiStr = [wifiStr substringWithRange:NSMakeRange(1, wifiStr.length-1)];
                }
                if (!wifiStr) {
                    wifiStr = [BasicInfoCollection getCurreWiFiSsid];
                }
            }else{
                wifiStr = [BasicInfoCollection getCurreWiFiSsid];
            }
            if (self.updateWifiInfomation) {
                NSDictionary *dic = @{
                                       @"wifiInfomation":@{
                                              @"ssid": wifiStr,
                                              @"strength": @(rssi)
                                              },
                                        @"mac":deviceMac,
                                      };
                self.updateWifiInfomation(dic);
            }
        }

    }else if (type == 0x02) {
        if (cmd == 0x02) {
            //设置电源开关回复
            uint8_t model = [self getByteWithoffset:useDataLoc+1];
            [self switchInstructionReturn:model result:result deviceMac:deviceMac];

        }else if (cmd == 0x04){
            //时间校准回复
        }else if (cmd == 0x06){
            //设置定时回复
            if ([self.delegate respondsToSelector:@selector(commonPatternTimingResponse:deviceMac:)]) {
                [self.delegate commonPatternTimingResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if(cmd == 0x08){
            //设置倒计时回复
            BOOL switc = ([self getByteWithoffset:useDataLoc] == 0x01)?true:false;
            if ([self.delegate respondsToSelector:@selector(powerSwitchCountdownResponse:deviceMac:)]) {
                [self.delegate powerSwitchCountdownResponse:@{@"state":@(switc),
                                                              @"result":@(result),
                                                              @"switch":@([self getByteWithoffset:useDataLoc+1]),
                                                              } deviceMac:deviceMac];
            }
        }else if (cmd == 0x0a){
            //设置定温湿度回复
            if ([self.delegate respondsToSelector:@selector(alarmTemperatureValueResponse:deviceMac:)]){
                [self.delegate alarmTemperatureValueResponse:
                 @{@"result":@(result),@"state":@([self getByteWithoffset:useDataLoc]),@"mode":@([self getByteWithoffset:useDataLoc+1]),@"type":@([self getByteWithoffset:useDataLoc+2])} deviceMac:deviceMac];
                NSLog(@"%hhu",[self getByteWithoffset:useDataLoc+3]);
            }
        }else if (cmd == 0x0c){
            //查询开关状态回复
            uint8_t model = [self getByteWithoffset:useDataLoc+1];
            [self switchInstructionReturn:model result:result deviceMac:deviceMac];
            
        }else if (cmd == 0x0e){
            //查询倒计时回复
            if ([self.delegate respondsToSelector:@selector(CountdownResult:deviceMac:)]) {
                NSInteger realHour;
                NSInteger realMinute;
//                if ([self getByteWithoffset:useDataLoc+6] == 0x00
//                    && [self getByteWithoffset:useDataLoc+7] == 0x00) {
//                    realHour =0;
//                    realMinute = 0;
//                }else{
                    realHour = [self getByteWithoffset:useDataLoc+4];
                    realMinute = [self getByteWithoffset:useDataLoc+5];
//                }
                
                NSLog(@"confirm = %@ switch = %@ hour = %@ minit = %@ hour = %@ minit = %@ seconds = %@ seconds = %@",
                      @([self getByteWithoffset:useDataLoc]),
                      @([self getByteWithoffset:useDataLoc+1]),
                      @([self getByteWithoffset:useDataLoc+2]),
                      @([self getByteWithoffset:useDataLoc+3]),
                      @([self getByteWithoffset:useDataLoc+4]),
                      @([self getByteWithoffset:useDataLoc+5]),
                      @([self getByteWithoffset:useDataLoc]+6),
                      @([self getByteWithoffset:useDataLoc]+7)
                      );
                
                [self.delegate CountdownResult:@{@"result":@(result),
                                                 @"state":@([self getByteWithoffset:useDataLoc]),
                                                 @"switch":@([self getByteWithoffset:useDataLoc+1]),
                                                 @"hour":@([self getByteWithoffset:useDataLoc+2]),
                                                 @"minute":@([self getByteWithoffset:useDataLoc+3]),
                                                 @"realHour":@(realHour),
                                                 @"realMinute":@(realMinute),
                                                 @"updateSwitch":@(false),
                                                 @"seconds":@([self getByteWithoffset:useDataLoc+6])
                                                 } deviceMac:deviceMac];
                
            }
        }else if (cmd == 0x10){
            //查询当前时间回复
            if ([self.delegate respondsToSelector:@selector(calibrationTimeResponse:deviceMac:)]) {
                [self.delegate calibrationTimeResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x12){
            //查询定温湿度返回
            CGFloat ding = [[[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:useDataLoc+3],(int8_t)[self getByteWithoffset:useDataLoc+4]] floatValue];
            CGFloat curr = [[[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:useDataLoc+5],(int8_t)[self getByteWithoffset:useDataLoc+6]] floatValue];
            BOOL state = [self getByteWithoffset:useDataLoc] == 0x01 ? true : false;
            if ([self.delegate respondsToSelector:@selector(temperatureAndHumidityDataResponse:deviceMac:)]) {
                [self.delegate temperatureAndHumidityDataResponse:@{@"result":@(result),
                                                                    @"state":@(state),
                                                                    @"mode":@([self getByteWithoffset:useDataLoc+1]),
                                                                    @"currentValue":@(curr),
                                                                    @"alarmValue":@(ding),
                                                                    @"type":@([self getByteWithoffset:useDataLoc+2])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x14){
            //查询定时回复
            if ([self.delegate respondsToSelector:@selector(commonPatternListDataResponse:deviceMac:)]) {
                [self.delegate commonPatternListDataResponse:@{@"data":property} deviceMac:deviceMac];
            }
        }else if (cmd == 0x16){
            //设置定电定费回复
            if ([self.delegate respondsToSelector:@selector(spendingCountdownAlarmResponse:deviceMac:)]) {
                [self.delegate spendingCountdownAlarmResponse:@{@"result":@(result),
                                                                @"mode":@([self getByteWithoffset:useDataLoc+1]),
                                                                @"state":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        } else if (cmd == 0x18){
            //查询定电定费
            if ([self.delegate respondsToSelector:@selector(spendingCountdownDataResponse:deviceMac:)]) {
                [self.delegate spendingCountdownDataResponse:@{@"data":property} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1a){
            //查询某一天的历史数据回复
            if ([self.delegate respondsToSelector:@selector(deviceHistoryDataResponse:deviceMac:)]) {
                [self.delegate deviceHistoryDataResponse:@{@"result":@(result),@"data":property
                                                           } deviceMac:deviceMac];
            }
        }else if (cmd == 0x1A){
         
            if ([self.delegate respondsToSelector:@selector(queryElectricityByTimeResponse:deviceMac:)]) {
                [self.delegate spendingCountdownAlarmResponse:@{@"result":@(result),
                                                                @"y":@([self getByteWithoffset:useDataLoc+1]),
                                                                @"m":@([self getByteWithoffset:useDataLoc]+2),
                                                                @"d":@([self getByteWithoffset:useDataLoc]+3),
                                                                @"electric":@([self getByteWithoffset:useDataLoc] + 5),
                                                                @"spend":@([self getByteWithoffset:useDataLoc]+6)
                                                                } deviceMac:deviceMac];
            }
            
        }else if (cmd == 0x20){
            //查询费率回复
            if ([self.delegate respondsToSelector:@selector(deviceRateResponse:deviceMac:)]) {
                [self.delegate deviceRateResponse:@{@"result":@(result),@"firstHour":@([self getByteWithoffset:useDataLoc]),
                                                    @"firstMinute":@([self getByteWithoffset:useDataLoc+1]),@"firstPrice":@([self getByteWithoffset:useDataLoc+2]),
                                                    @"sencondHour":@([self getByteWithoffset:useDataLoc+3]),@"secondMinute":@([self getByteWithoffset:useDataLoc+4]),
                                                    @"secondPrice":@([self getByteWithoffset:useDataLoc+5])
                                                    } deviceMac:deviceMac];
            }
        }else if (cmd == 0x22){
            //查询设备累计参数
            if ([self.delegate respondsToSelector:@selector(deviceAccumulationParameterResponse:deviceMac:)]) {
                [self.delegate deviceAccumulationParameterResponse:@{@"result":@(result),@"electricQuantity":@([self getByteWithoffset:useDataLoc]),
                                                                     @"totalTime":@([self getByteWithoffset:useDataLoc+1]),@"GHG":@([self getByteWithoffset:useDataLoc+2])
                                                                     } deviceMac:deviceMac];
            }
        }else if (cmd == 0x26){
            //设置RGB回复
            if ([self.delegate respondsToSelector:@selector(colourLampControlResponse:deviceMac:)]) {
                [self.delegate colourLampControlResponse:@{@"result":@(result),
                                                           @"id":@([self getByteWithoffset:useDataLoc]),
                                                           @"r":@([self getByteWithoffset:useDataLoc+1]),
                                                           @"g":@([self getByteWithoffset:useDataLoc+2]),
                                                           @"b":@([self getByteWithoffset:useDataLoc+3]),
                                                           @"w":@([self getByteWithoffset:useDataLoc+4]),
                                                           } deviceMac:deviceMac];
            }
        }else if (cmd == 0x2A){
            //查询RGB回复
            if ([self.delegate respondsToSelector:@selector(colourLampControlResponse:deviceMac:)]) {
                [self.delegate colourLampControlResponse:@{@"result":@(result),
                                                           @"id":@([self getByteWithoffset:useDataLoc]),
                                                           @"r":@([self getByteWithoffset:useDataLoc+1]),
                                                           @"g":@([self getByteWithoffset:useDataLoc+2]),
                                                           @"b":@([self getByteWithoffset:useDataLoc+3]),
                                                           @"w":@([self getByteWithoffset:useDataLoc+4]),
                                                           } deviceMac:deviceMac];
            }
        }else if (cmd == 0x2C){
            //温度湿度定时高级模式返回
            BOOL state = [self getByteWithoffset:useDataLoc+12] == 0x01?true:false;
            NSInteger mode = [self getByteWithoffset:useDataLoc+15];
            if ([self.delegate respondsToSelector:@selector(alarmTimerAndTemperatureValueResponse:deviceMac:)]) {
                [self.delegate alarmTimerAndTemperatureValueResponse:@{@"result":@(result),
                                                                       @"state":@(state),
                                                                       @"mode":@(mode),
                                                                       } deviceMac:deviceMac];
            }
        }else if (cmd == 0x2E){
            //温度湿度查询高级模式返回
            if ([self.delegate respondsToSelector:@selector(timingAndTemperatureDataResponse:deviceMac:)]) {
                [self.delegate timingAndTemperatureDataResponse:@{@"result":@(result),@"data":property} deviceMac:deviceMac];
            }
        }else if (cmd == 0x30){
            //查询彩灯模式返回
            if ([self.delegate respondsToSelector:@selector(colourLampModeQueryResponse:deviceMac:)]) {
                [self.delegate colourLampModeQueryResponse:@{} deviceMac:deviceMac];
            }
        }else if (cmd == 0x32){
            //设置彩灯模式返回
        }else if (cmd == 0x34){
            //查询所有彩灯模式返回
            if ([self.delegate respondsToSelector:@selector(colourLampModeListQueryResponse:deviceMac:)]) {
                [self.delegate colourLampModeListQueryResponse:@{} deviceMac:deviceMac];
            }
        }else if (cmd == 0x36){
            //小夜灯定时设置返回
            NSInteger ID = [self getByteWithoffset:useDataLoc];
            BOOL state = [self getByteWithoffset:useDataLoc+1] == 0x01? true:false;
            NSString *startTime = [NSString stringWithFormat:@"%d:%d",[self getByteWithoffset:useDataLoc+2],[self getByteWithoffset:useDataLoc+3]];
            NSString *endTime = [NSString stringWithFormat:@"%d:%d",[self getByteWithoffset:useDataLoc+4],[self getByteWithoffset:useDataLoc+5]];
            NSDictionary *dic = @{@"id": @(ID),
                                  @"state": @(state),
                                  @"timing": @{
                                          @"startTime": startTime,
                                          @"endTime": endTime
                                          }
                                  };
            if ([self.delegate respondsToSelector:@selector(nightLightSettingResponse:deviceMac:)]) {
                [self.delegate nightLightSettingResponse:dic deviceMac:deviceMac];
            }
        }else if (cmd == 0x38){
            //小夜灯查询返回
            NSInteger ID = [self getByteWithoffset:useDataLoc];
            BOOL state = [self getByteWithoffset:useDataLoc+1] == 0x01? true:false;
            NSString *startTime = [NSString stringWithFormat:@"%d:%d",[self getByteWithoffset:useDataLoc+2],[self getByteWithoffset:useDataLoc+3]];
            NSString *endTime = [NSString stringWithFormat:@"%d:%d",[self getByteWithoffset:useDataLoc+4],[self getByteWithoffset:useDataLoc+5]];
            NSDictionary *dic = @{@"id": @(ID),
                                  @"state": @(state),
                                  @"timing": @{
                                          @"startTime": startTime,
                                          @"endTime": endTime
                                          }
                                  };
            if ([self.delegate respondsToSelector:@selector(nightLightSettingResponse:deviceMac:)]) {
                [self.delegate nightLightSettingResponse:dic deviceMac:deviceMac];
            }
        }else if (cmd == 0x3A){
            //查询传感器状态
            if ([self.delegate respondsToSelector:@selector(temperatureSensorStateResponse:deviceMac:)]) {
                [self.delegate temperatureSensorStateResponse:@{@"mode":@([self getByteWithoffset:useDataLoc]),
                                                                @"status":@([self getByteWithoffset:useDataLoc+1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x3C){
            //一键控制所有指示灯状态返回
            if ([self.delegate respondsToSelector:@selector(indicatorLightStateResponse:deviceMac:)]) {
                [self.delegate indicatorLightStateResponse:@{@"seq":@([self getByteWithoffset:useDataLoc]),
                                                             @"state":@([self getByteWithoffset:useDataLoc+1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x3E){
            //查询一键控制所有指示灯状态返回
            if ([self.delegate respondsToSelector:@selector(indicatorLightStateResponse:deviceMac:)]) {
                [self.delegate indicatorLightStateResponse:@{@"seq":@([self getByteWithoffset:useDataLoc]),
                                                             @"state":@([self getByteWithoffset:useDataLoc+1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x40){
            //查询7种状态
            if ([self.delegate respondsToSelector:@selector(selectSevenStatusResponse:deviceMac:)]) {
                uint8_t status0 = [self getByteWithoffset:useDataLoc];
                int power = status0 & 0x01;
                int colorLight = status0 & 0x02;
                int sleepLight = status0 & 0x04;
                int UsbPower = status0 & 0x08;
                int pilotLight = status0 & 0x10;
                
                uint8_t status1 = [self getByteWithoffset:useDataLoc + 1];
                int colorLightTimer = status1 & 0x01;
                int sleepLightTimer = status1 & 0x02;
                
                uint8_t status2 = [self getByteWithoffset:useDataLoc+2];
                int timer = status2 & 0x01;
                int highTimer = status2 & 0x02;
                int countDown = status2 & 0x04;
                int UsbTimer = status2 & 0x08;
                
                uint8_t status3 = [self getByteWithoffset:useDataLoc + 3];
                int temperature = status3 & 0x01;
                int temperatureSensing = status3 & 0x02;
                int humidity = status3 & 0x04;
                int highTemperature = status3 &0x08;
                
                uint8_t status4 = [self getByteWithoffset:useDataLoc+4];
                int setMeasure = status4 & 0x01;
                int setCost = status4 & 0x2;
                
                [self.delegate selectSevenStatusResponse:@{@"power":@(power),
                                                           @"colorLight":@(colorLight),
                                                           @"sleepLight":@(sleepLight),
                                                           @"UsbPower":@(UsbPower),
                                                           @"pilotLight":@(pilotLight),
                                                           
                                                           @"colorLightTimer":@(colorLightTimer),
                                                           @"sleepLightTimer":@(sleepLightTimer),
                                                           
                                                           @"timer":@(timer),
                                                           @"highTimer":@(highTimer),
                                                           @"countDown":@(countDown),
                                                           @"UsbTimer":@(UsbTimer),
                                                           
                                                           @"temperature":@(temperature),
                                                           @"temperatureSensing":@(temperatureSensing),
                                                           @"humidity":@(humidity),
                                                           @"highTemperature":@(highTemperature),
                                                           
                                                           @"setMeasure":@(setMeasure),
                                                           @"setCost":@(setCost)
                                                           } deviceMac:deviceMac];

            }
            
            
        }else if (cmd == 0x42){
            //查询某一天的历史数据回复
            if ([self.delegate respondsToSelector:@selector(deviceHistoryDataResponse:deviceMac:)]) {
                [self.delegate deviceHistoryDataResponse:@{@"result":@(result),@"data":property
                                                           } deviceMac:deviceMac];
            }
        }else if (cmd == 0x44){
            
            if ([self.delegate respondsToSelector:@selector(timingConstTemperatureDataSetResponse:deviceMac:)]) {
                [self.delegate timingConstTemperatureDataSetResponse:@{@"result":@([self getByteWithoffset:useDataLoc-1]),
                                                                       @"data":property
                                                           } deviceMac:deviceMac];
            }
            
        }else if (cmd == 0x46){
            
            if ([self.delegate respondsToSelector:@selector(timingConstTemperatureDataResponse:deviceMac:)]) {
                [self.delegate timingConstTemperatureDataResponse:@{@"result":@(result),@"data":property
                                                           } deviceMac:deviceMac];
            }
            
        }else if (cmd == 0x48){
            
            if ([self.delegate respondsToSelector:@selector(timingConstTemperatureDataDeleteResponse:deviceMac:)]) {
                [self.delegate timingConstTemperatureDataDeleteResponse:@{@"result":@([self getByteWithoffset:useDataLoc-1]),
                                                                          @"data":property
                                                                          } deviceMac:deviceMac];
                
            }
            
        }
        
        
    }else if (type == 3) {
        uint8_t startLoc = useDataLoc-1;
        if (cmd == 0x01) {
            //上报温湿度
            CGFloat lower = [[[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:startLoc],(int8_t)[self getByteWithoffset:startLoc+1]] floatValue];
            CGFloat humidity = [[[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:9],(int8_t)[self getByteWithoffset:10]] floatValue];
            NSDictionary *dic = @{
                                  @"temperature":@{
                                          @"value" : @(lower),
//                                          @"alarmValue" : @(100),
                                          },
                                  @"humidity":@{
                                          @"value" : @(humidity),
//                                          @"alarmValue" : @(100),
                                          },
                                  };
            if ([self.delegate respondsToSelector:@selector(ReportingRealTimeData:deviceMac:)]) {
                [self.delegate ReportingRealTimeData:dic deviceMac:deviceMac];
            }
            
            if ([self.delegate respondsToSelector:@selector(temperatureAndHumidityDataResponse:deviceMac:)]) {
                [self.delegate temperatureAndHumidityDataResponse:@{
                                                                    @"currentValue" : @(lower),
//                                                                  @"alarmValue" : @(100),
                                                                    @"mode":@(1),
                                                                    @"type":@(1),
                                                                    } deviceMac:deviceMac];
                
            }
            if (lower == 100) {
                if (self.showToastHandler) {
                    self.showToastHandler();
                }
            }

        }else if (cmd == 0x02){
            //上报温湿度回复
        }else if (cmd == 0x03){
            //上报功率电压
            CGFloat gonglv = [[[NSString alloc] initWithFormat:@"%d",([self getByteWithoffset:startLoc]<<8)+[self getByteWithoffset:startLoc+1]] floatValue];
            CGFloat averagelv = [[[NSString alloc] initWithFormat:@"%d",(([self getByteWithoffset:startLoc+2]<<8))+[self getByteWithoffset:startLoc+3]] floatValue];
            CGFloat maxlv = [[[NSString alloc] initWithFormat:@"%d",(([self getByteWithoffset:startLoc+4]<<8))+[self getByteWithoffset:startLoc+5]] floatValue];
            CGFloat frequency = [[[NSString alloc] initWithFormat:@"%f",(([self getByteWithoffset:startLoc+6]<<8)+[self getByteWithoffset:startLoc+7])/100.0] floatValue];
            CGFloat dianya = [[[NSString alloc] initWithFormat:@"%f",(([self getByteWithoffset:startLoc+8]<<8)+[self getByteWithoffset:startLoc+9])/100.0] floatValue];
            CGFloat dianliu = [[[NSString alloc] initWithFormat:@"%f",(([self getByteWithoffset:startLoc+10]<<8)+[self getByteWithoffset:startLoc+11])/1000.0] floatValue];
//            CGFloat max_current = [[[NSString alloc] initWithFormat:@"%d",(([self getByteWithoffset:startLoc+12]<<8)+[self getByteWithoffset:startLoc+13])] floatValue];
            CGFloat powerFactor = [[[NSString alloc] initWithFormat:@"%f",(([self getByteWithoffset:startLoc+14]<<8)+[self getByteWithoffset:startLoc+15])/1000.0] floatValue];
            
            NSDictionary *dic = @{
                                  @"power":@{
                                          @"value":@(gonglv),
                                          @"averageValue":@(averagelv),
                                          @"maximumValue":@(maxlv)
                                          },
                                  @"voltage" : @(dianya),
                                  @"electricity" : @(dianliu),
                                  @"frequency" : @(frequency),
                                  @"powerFactor" : @(powerFactor)
                                  };
            if ([self.delegate respondsToSelector:@selector(ReportingRealTimeData:deviceMac:)]) {
                [self.delegate ReportingRealTimeData:dic deviceMac:deviceMac];
            }
        }else if (cmd == 0x04){
            //上报功率电压回复
        }else if (cmd == 0x05){
            //上报定温度完成
            CGFloat ding = [[[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:startLoc+4],(int8_t)[self getByteWithoffset:startLoc+5]] floatValue];
            CGFloat curr = [[[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:startLoc+6],(int8_t)[self getByteWithoffset:startLoc+7]] floatValue];
            BOOL state = [self getByteWithoffset:startLoc] == 0x01 ? true : false;
            BOOL switc = [self getByteWithoffset:startLoc+1] == 0x01 ? true : false;
            if ([self.delegate respondsToSelector:@selector(temperatureAndHumidityDataResponse:deviceMac:)]) {
                [self.delegate temperatureAndHumidityDataResponse:@{@"result":@(true),
                                                                    @"switch":@(switc),
                                                                    @"state":@(state),
                                                                    @"mode":@([self getByteWithoffset:startLoc+2]),
                                                                    @"currentValue":@(curr),
                                                                    @"alarmValue":@(ding),
                                                                    @"type":@([self getByteWithoffset:startLoc+3])} deviceMac:deviceMac];
            }
            if ([self.delegate respondsToSelector:@selector(powerSwitchResponse:deviceMac:)]) {
                [self.delegate powerSwitchResponse:@{@"state":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x07){
            //上报倒计时
            if ([self.delegate respondsToSelector:@selector(CountdownResult:deviceMac:)]) {
                [self.delegate CountdownResult:@{@"result":@(true),
                                                 @"state":@([self getByteWithoffset:startLoc]),
                                                 @"switch":@([self getByteWithoffset:startLoc+1]),
                                                 @"hour":@([self getByteWithoffset:startLoc+2]),
                                                 @"minute":@([self getByteWithoffset:startLoc+3]),
                                                 @"realHour":@([self getByteWithoffset:startLoc + 4]),
                                                 @"realMinute":@([self getByteWithoffset:startLoc + 5]),
                                                 @"seconds":@([self getByteWithoffset:startLoc + 6]),
                                                 @"updateSwitch":@(true),
                                                 } deviceMac:deviceMac];
            }
        }else if (cmd == 0x09){
            //上报定时结束
            if ([self.delegate respondsToSelector:@selector(reportendoftime:deviceMac:)]) {
                [self.delegate reportendoftime:@{@"state":@([self getByteWithoffset:startLoc+2])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x0B){
            //上报电量数据
            if ([self.delegate respondsToSelector:@selector(deviceHistoryReportDataResponse:deviceMac:)]) {
                long long time = [[NSString stringWithFormat:@"%d",([self getByteWithoffset:startLoc]<<24)+([self getByteWithoffset:startLoc+1]<<16)+([self getByteWithoffset:startLoc+2]<<8)+[self getByteWithoffset:startLoc+3]] longLongValue]*1000;
                CGFloat electricity = [[NSString stringWithFormat:@"%d",([self getByteWithoffset:startLoc+4]<<24)+([self getByteWithoffset:startLoc+5]<<16)+([self getByteWithoffset:startLoc+6]<<8)+[self getByteWithoffset:startLoc+7]] integerValue]/1000.0;
                [self.delegate deviceHistoryReportDataResponse:@{
                                                                 @"time":@(time),
                                                                 @"e":@(electricity),
                                                                 } deviceMac:deviceMac];
            }
        }else if (cmd == 0x11){
            //上报传感器状态
            if ([self.delegate respondsToSelector:@selector(temperatureSensorStateResponse:deviceMac:)]) {
                [self.delegate temperatureSensorStateResponse:@{@"mode":@([self getByteWithoffset:startLoc]),
                                                                @"status":@([self getByteWithoffset:startLoc+1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x13){
            
            if ([self.delegate respondsToSelector:@selector(selectSevenStatusResponse:deviceMac:)]) {
                
                uint8_t status0 = [self getByteWithoffset:useDataLoc];
                int power = status0 & 0x01;
                int colorLight = status0 & 0x02;
                int sleepLight = status0 & 0x04;
                int UsbPower = status0 & 0x08;
                int pilotLight = status0 & 0x10;
                
                uint8_t status1 = [self getByteWithoffset:useDataLoc + 1];
                int colorLightTimer = status1 & 0x01;
                int sleepLightTimer = status1 & 0x02;
                
                uint8_t status2 = [self getByteWithoffset:useDataLoc+2];
                int timer = status2 & 0x01;
                int highTimer = status2 & 0x02;
                int countDown = status2 & 0x04;
                int UsbTimer = status2 & 0x08;
                
                uint8_t status3 = [self getByteWithoffset:useDataLoc + 3];
                int temperature = status3 & 0x01;
                int temperatureSensing = status3 & 0x02;
                int humidity = status3 & 0x04;
                int highTemperature = status3 &0x08;
                
                uint8_t status4 = [self getByteWithoffset:useDataLoc+4];
                int setMeasure = status4 & 0x01;
                int setCost = status4 & 0x2;
                
                [self.delegate selectSevenStatusResponse:@{@"power":@(power),
                                                           @"colorLight":@(colorLight),
                                                           @"sleepLight":@(sleepLight),
                                                           @"UsbPower":@(UsbPower),
                                                           @"pilotLight":@(pilotLight),
                                                           
                                                           @"colorLightTimer":@(colorLightTimer),
                                                           @"sleepLightTimer":@(sleepLightTimer),
                                                           
                                                           @"timer":@(timer),
                                                           @"highTimer":@(highTimer),
                                                           @"countDown":@(countDown),
                                                           @"UsbTimer":@(UsbTimer),
                                                           
                                                           @"temperature":@(temperature),
                                                           @"temperatureSensing":@(temperatureSensing),
                                                           @"humidity":@(humidity),
                                                           @"highTemperature":@(highTemperature),
                                                           
                                                           @"setMeasure":@(setMeasure),
                                                           @"setCost":@(setCost)
                                                           } deviceMac:deviceMac];
                
            }
            
        }
    }else if(type == 0x04){
        if (cmd == 0x10) {
            //设置电压告警值回复
            if ([self.delegate respondsToSelector:@selector(settingAlarmVoltageResponse:deviceMac:)]) {
                [self.delegate settingAlarmVoltageResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x12){
            NSString *Voltage = [NSString stringWithFormat:@"%d",([self getByteWithoffset:useDataLoc]<<8)+[self getByteWithoffset:useDataLoc+1]];
            //查询电压告警值回复
            if ([self.delegate respondsToSelector:@selector(queryAlarmVoltageResponse:deviceMac:)]) {
                [self.delegate queryAlarmVoltageResponse:@{@"result":@(result),@"Voltage":Voltage} deviceMac:deviceMac];
            }
        }else if (cmd == 0x14){
            //设置电流警告值回复
            if ([self.delegate respondsToSelector:@selector(settingAlarmCurrentResponse:deviceMac:)]) {
                [self.delegate settingAlarmCurrentResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x16){
            //查询电流警告值回复
            CGFloat electric = (([self getByteWithoffset:useDataLoc]<<8) + [self getByteWithoffset:useDataLoc+1])/100;
            if ([self.delegate respondsToSelector:@selector(queryAlarmCurrentResponse:deviceMac:)]) {
                [self.delegate queryAlarmCurrentResponse:@{@"result":@(result),@"electricity":@(electric)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x18){
            //设置功率警告值回复
            if ([self.delegate respondsToSelector:@selector(settingAlarmPowerResponse:deviceMac:)]) {
                [self.delegate settingAlarmPowerResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1a){
            //查询设置功率警告值回复
            NSInteger power = [[NSString stringWithFormat:@"%d",([self getByteWithoffset:useDataLoc]<<8)+[self getByteWithoffset:useDataLoc+1]] floatValue];
            if ([self.delegate respondsToSelector:@selector(queryAlarmPowerResponse:deviceMac:)]) {
                [self.delegate queryAlarmPowerResponse:@{@"result":@(result),@"power":@(power)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1c){
            //设置温度单位回复
            if ([self.delegate respondsToSelector:@selector(settingTemperatureUnitResponse:deviceMac:)]) {
                [self.delegate settingTemperatureUnitResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1e){
            //查询温度单位回复
            if ([self.delegate respondsToSelector:@selector(queryTemperatureUnitResponse:deviceMac:)]) {
                [self.delegate queryTemperatureUnitResponse:@{@"result":@(result),@"type":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x20){
            //设置货币单位回复
            if ([self.delegate respondsToSelector:@selector(settingMonetarytUnitResponse:deviceMac:)]) {
                [self.delegate settingMonetarytUnitResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x22){
            //查询货币单位回复
            if ([self.delegate respondsToSelector:@selector(queryMonetarytUnitResponse:deviceMac:)]) {
                [self.delegate queryMonetarytUnitResponse:@{@"result":@(result),@"type":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x24){
            //设置本地电价回复
            if ([self.delegate respondsToSelector:@selector(settingLocalElectricityResponse:deviceMac:)]) {
                [self.delegate settingLocalElectricityResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x26){
            //查询本地电价回复
            CGFloat price = [[NSString stringWithFormat:@"%d",([self getByteWithoffset:useDataLoc]<<8)+[self getByteWithoffset:useDataLoc+1]] floatValue];
            if ([self.delegate respondsToSelector:@selector(queryLocalElectricityResponse:deviceMac:)]) {
                [self.delegate queryLocalElectricityResponse:@{@"result":@(result),@"price":@(price)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x28){
            //恢复出厂设置回复
            if ([self.delegate respondsToSelector:@selector(settingResumeSetupResponse:deviceMac:)]) {
                [self.delegate settingResumeSetupResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }
    }
    
    property = [NSMutableData data];
    if (len> -1 && data.length>len) {
        [property appendData:[data subdataWithRange:NSMakeRange(len, data.length-len)]];
        if (property.length &&
            [property rangeOfData:[ToolHandle getData:0xff] options:NSDataSearchBackwards range:NSMakeRange(0, 1)].length &&
            [property rangeOfData:[ToolHandle getData:0xee] options:NSDataSearchBackwards range:NSMakeRange(property.length-1, 1)].length) {
            //说明此条数据还包含数个完整包 需要继续解析
            [self handlingRecevieData:property deviceIdentifiy:deviceIdentifiy fromAddress:address];
        }else{
            objc_setAssociatedObject(self, &deviceIdentifiy, property, OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    
    
    objc_setAssociatedObject(self, &deviceIdentifiy, property, OBJC_ASSOCIATION_RETAIN);
}


- (NSData *)replaceNoUtf8:(NSData *)data
{
    char aa[] = {'*','*','*','*','*','*'};                      //utf8最多6个字符，当前方法未使用
    NSMutableData *md = [NSMutableData dataWithData:data];
    int loc = 0;
    while(loc < [md length])
    {
        char buffer;
        [md getBytes:&buffer range:NSMakeRange(loc, 1)];
        if((buffer & 0x80) == 0)
        {
            loc++;
            continue;
        }
        else if((buffer & 0xE0) == 0xC0)
        {
            loc++;
            if (loc>=data.length) {
                continue;
            }
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                continue;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else if((buffer & 0xF0) == 0xE0)
        {
            loc++;
            if (loc>=data.length) {
                continue;
            }
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                [md getBytes:&buffer range:NSMakeRange(loc, 1)];
                if((buffer & 0xC0) == 0x80)
                {
                    loc++;
                    continue;
                }
                loc--;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else
        {
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
    }
    
    return md;
}

- (void)switchInstructionReturn:(uint8_t)model result:(BOOL)result deviceMac:(NSString *)deviceMac
{
    if (model == 0x01) {
        //插座状态开关
        self.delegate = [BaseControlModel shareInstance];
        if ([self.delegate respondsToSelector:@selector(powerSwitchResponse:deviceMac:)]) {
            [self.delegate powerSwitchResponse:@{@"state":@([self getByteWithoffset:useDataLoc]),
                                                 @"result":@(result),
                                                 } deviceMac:deviceMac];
        }
    }else if (model == 0x02){
        //背光状态开关
        
    }else if (model == 0x03){
        //闪光灯开关
        if ([self.delegate respondsToSelector:@selector(colourLampSwitchResponse:deviceMac:)]) {
            [self.delegate colourLampSwitchResponse:@{@"state":@([self getByteWithoffset:useDataLoc]),
                                                      @"result":@(result),
                                                      } deviceMac:deviceMac];
        }
    }else if (model == 0x04){
        //USB开关
        self.delegate = [LightControlModel shareInstance];
        if ([self.delegate respondsToSelector:@selector(USBSwitchStateRequest:deviceMac:)]) {
            [self.delegate USBSwitchStateRequest:@{@"state":@([self getByteWithoffset:useDataLoc]),
                                                   @"result":@(result),
                                                   } deviceMac:deviceMac];
        }
    }else if(model == 0x05){
        //小夜灯
        self.delegate = [LightControlModel shareInstance];
        if ([self.delegate respondsToSelector:@selector(ordinaryNightLightResponse:deviceMac:)]) {
            [self.delegate ordinaryNightLightResponse:@{@"state":@([self getByteWithoffset:useDataLoc]),
                                                        @"result":@(result),
                                                        } deviceMac:deviceMac];
        }
    }
}


- (uint8_t)getByteWithoffset:(int)offset
{
    if (offset > self.recevieData.length) {
        return 0x00;
    }
    Byte *testByte = (Byte*)[self.recevieData bytes];
    return testByte[offset];
}


@end
