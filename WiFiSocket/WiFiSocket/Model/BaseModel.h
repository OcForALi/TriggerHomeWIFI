//
//  BaseModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "LANConversation.h"

@interface BaseModel : NSObject

@property (nonatomic, strong) WKWebView *web;
@property (nonatomic, strong) NSArray *funcArr;
@property (nonatomic, strong) NSDictionary *funcDic;
@property (nonatomic, strong) NSMutableArray *methodArr;


+ (instancetype)shareInstance;

- (void)registFunctionWithWeb:(WKWebView *)web;

- (NSData *)getData:(uint8_t)da;

- (void)sendDataWithMac:(NSString *)mac data:(NSMutableData *)data;



@end
