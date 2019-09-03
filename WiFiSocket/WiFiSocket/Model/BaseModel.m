//
//  BaseModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"
@interface BaseModel ()

@end


@implementation BaseModel

- (void)setMethodArr:(NSMutableArray *)methodArr
{
    _methodArr = methodArr;
}

- (void)registFunctionWithWeb:(WKWebView *)web
{

}

- (NSData *)getData:(uint8_t)da
{
    NSData *data = [[NSData alloc] initWithBytes:&da length:sizeof(da)];
    return data;
}

- (void)sendDataWithMac:(NSString *)mac data:(NSMutableData *)data
{
    [[UDPSocket shareInstance] sendMessageData:data mac:mac];
}


@end
