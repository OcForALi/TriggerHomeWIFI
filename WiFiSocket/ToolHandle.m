//
//  ToolHandler.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "ToolHandle.h"

//static uint8_t sequence = 0;

@implementation ToolHandle

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString *)toJsonString:(id)objet
{
    NSString *json;
    if (objet == nil) {
        json = @"";
    }else if ([objet isKindOfClass:[NSString class]]){
        json = objet;
    }else{
        NSData *data = [NSJSONSerialization dataWithJSONObject:objet options:NSJSONWritingPrettyPrinted error:nil];
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    json = [json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return json;
}

+ (NSString *)fillNullString:(id)object
{
    if (![object isKindOfClass:[NSString class]]) {
        return @"";
    }else if (object == NULL || object == nil){
        return @"";
    }
    return object;
}

+ (NSMutableData *)checkeffData:(NSMutableData *)data
{
    NSData *ff = [self getData:0xff];
    NSMutableData *tianchong = [[NSMutableData alloc] init];
    [tianchong appendData:[self getData:0x55]];
    [tianchong appendData:[self getData:0xaa]];
    BOOL res = true;
    while (res) {
        NSRange range = [data rangeOfData:ff options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
        if (!range.length) {
            res = false;
        }else{
            [data replaceBytesInRange:range withBytes:tianchong.bytes length:2];
        }
    }
    
    return data;
}

+ (NSMutableData *)checkeeeData:(NSMutableData *)data
{
    NSData *ee = [self getData:0xee];
    NSMutableData *tianchong = [[NSMutableData alloc] init];
    [tianchong appendData:[self getData:0x55]];
    [tianchong appendData:[self getData:0x99]];
    BOOL res = true;
    while (res) {
        NSRange range = [data rangeOfData:ee options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
        if (!range.length) {
            res = false;
        }else{
            [data replaceBytesInRange:range withBytes:tianchong.bytes length:2];
        }
    }
    
    return data;
}

+ (NSMutableData *)checke55Data:(NSMutableData *)data
{
    NSData *five = [self getData:0x55];
    NSData *zero = [self getData:0x00];
    NSMutableData *tianchong = [[NSMutableData alloc] init];
    [tianchong appendData:[self getData:0x55]];
    [tianchong appendData:[self getData:0x00]];

    NSInteger length = data.length-2;
    
    while (length) {
        NSRange range1 = [data rangeOfData:five options:NSDataSearchBackwards range:NSMakeRange(1, length)];
        if (range1.length) {
            NSData *data1 = [data subdataWithRange:NSMakeRange(range1.location+1, 1)];
            if ([data1 isEqualToData:zero]) {
                
            }else{
                [data replaceBytesInRange:range1 withBytes:tianchong.bytes length:2];
            }
        }
        length--;
    }
    
    return data;
}

+ (NSMutableData *)getPacketData:(NSMutableData *)data
{
    return data;
//    NSMutableData *packetData = [[NSMutableData alloc] init];
//    int8_t header = 0xff;
//    int8_t len_h = 0x00;
//    int8_t len_l = data.length+8;
//    uint8_t version = 1;
////    uint8_t sequence = 1;
//    uint8_t reserve4 = 0x00;
//    uint8_t reserve3 = 0x00;
//    uint8_t reserve2 = 0x00;
//    uint8_t reserve1 = 0x00;
//    uint8_t custome_h = CUSTOM_H;
//    uint8_t custome_l = CUSTOM_L;
//
//    int8_t ee = 0xee;
//
//    [packetData appendData:[self getData:header]];
//    [packetData appendData:[self getData:len_h]];
//    [packetData appendData:[self getData:len_l]];
//    [packetData appendData:[self getData:version]];
//    [packetData appendData:[self getData:sequence]];
//    [packetData appendData:[self getData:reserve4]];
//    [packetData appendData:[self getData:reserve3]];
//    [packetData appendData:[self getData:reserve2]];
//    [packetData appendData:[self getData:reserve1]];
//    [packetData appendData:[self getData:custome_h]];
//    [packetData appendData:[self getData:custome_l]];
//    [packetData appendData:data];
//
//    Byte *byte = (Byte*)[packetData bytes];
//    Byte b = myCRC8(byte, 3, (int)packetData.length);
//    [packetData appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
//    [packetData appendData:[self getData:ee]];
//
//    packetData = [self checkeffData:packetData];
//    packetData = [self checkeeeData:packetData];
//
//    sequence = (sequence+1)&0xff;
//    return packetData;
}

+ (NSData *)getData:(uint8_t)da
{
    NSData *data = [[NSData alloc] initWithBytes:&da length:sizeof(da)];
    return data;
}

+ (uint8_t)getByteWithData:(NSData *)data offset:(int)offset
{
    if (offset > data.length) {
        return 0x00;
    }
    Byte *testByte = (Byte*)[data bytes];
    return testByte[offset];
}

+ (NSMutableData *)escapingSpecialCharacters:(NSMutableData *)data
{
    NSMutableData *ffda = [[NSMutableData alloc] init];
    NSMutableData *eeda = [[NSMutableData alloc] init];
    NSMutableData *fiveda = [[NSMutableData alloc] init];
    
    uint8_t a = 0x55;
    uint8_t b = 0xaa;
    uint8_t c= 0x00;
    uint8_t d = 0x99;
    
    [ffda appendBytes:&a length:1];
    [ffda appendBytes:&b length:1];
    
    [eeda appendBytes:&a length:1];
    [eeda appendBytes:&d length:1];
    
    [fiveda appendBytes:&a length:1];
    [fiveda appendBytes:&c length:1];
    
    if (data.length>3 &&[data rangeOfData:ffda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)].length) {
        BOOL res = true;
        while (res) {
            NSRange range = [data rangeOfData:ffda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
            uint8_t ff = 0xff;
            if (!range.length) {
                res = false;
            }else{
                [data replaceBytesInRange:range withBytes:&ff length:1];
            }
        }
    }
    
    if (data.length>3 &&[data rangeOfData:eeda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)].length) {
        BOOL res = true;
        while (res) {
            NSRange range = [data rangeOfData:eeda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
            uint8_t ff = 0xee;
            if (!range.length) {
                res = false;
            }else{
                [data replaceBytesInRange:range withBytes:&ff length:1];
            }
        }
    }
    
    if (data.length>3 &&[data rangeOfData:fiveda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)].length) {
        BOOL res = true;
        while (res) {
            NSRange range = [data rangeOfData:fiveda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
            uint8_t ff = 0x55;
            if (!range.length) {
                res = false;
            }else{
                [data replaceBytesInRange:range withBytes:&ff length:1];
            }
        }
    }
    return data;
}

+ (BOOL)isSameLan:(NSString *)ip1 ip2:(NSString *)ip2
{
    NSArray *arr1 = [ip1 componentsSeparatedByString:@"."];
    NSArray *arr2 = [ip2 componentsSeparatedByString:@"."];
    if (arr1.count == 4 &&
        arr2.count ==4 &&
        [arr1[0] isEqualToString:arr2[0]] &&
        [arr1[1] isEqualToString:arr2[1]] &&
        [arr1[2] isEqualToString:arr2[2]]) {
        return true;
    }
    return false;
}

Byte myCRC8(Byte *buffer,int start,int end){
    unsigned char crc = 0x00;   //起始字节00
    for (int j = start; j < end; j++) {
        crc ^= buffer[j] & 0xFF;
        for (int i = 0; i < 8; i++) {
            if ((crc & 0x01) != 0) {
                crc = (crc >> 1) ^ 0x8c;
            } else {
                crc >>= 1;
            }
        }
    }
    return (Byte) (crc & 0xFF);
}


+ (long long)getNowTime
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    long long time = a;
    
    return time;
}


@end
