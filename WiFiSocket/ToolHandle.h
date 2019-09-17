//
//  ToolHandler.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolHandle : NSObject

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)toJsonString:(id)objet;

+ (NSString *)fillNullString:(id)object;

+ (NSMutableData *)checkeffData:(NSMutableData *)data;

+ (NSMutableData *)checkeeeData:(NSMutableData *)data;

+ (NSMutableData *)checke55Data:(NSMutableData *)data;

+ (NSMutableData *)getPacketData:(NSMutableData *)data;

+ (NSData *)getData:(uint8_t)da;

+ (uint8_t)getByteWithData:(NSData *)data offset:(int)offset;

+ (NSMutableData *)escapingSpecialCharacters:(NSMutableData *)data;

+ (BOOL)isSameLan:(NSString *)ip1 ip2:(NSString *)ip2;

Byte myCRC8(Byte *buffer,int start,int end);

+ (long long)getNowTime;

@end
