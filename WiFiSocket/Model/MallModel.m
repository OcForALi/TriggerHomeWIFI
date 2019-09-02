//
//  MallModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/11/19.
//  Copyright © 2018 QiXing. All rights reserved.
//

#import "MallModel.h"

@interface MallModel ()<WKScriptMessageHandler>

@end

@implementation MallModel

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (NSArray *)funcArr
{
    return @[
             @"goToMallRequest",
             ];
}

- (NSDictionary *)funcDic
{
    return @{
             @"goToMallRequest":@"goToMallRequest:",
             };
}

#pragma mark 进入商城界面请求
- (void)goToMallRequest:(NSDictionary *)object
{
    NSString *path = [ToolHandle toJsonString:object[@"path"]];
    if (self.jumpMallHandler) {
        self.jumpMallHandler(path);
    }
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    @weakify(self);
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weak_self) strongSelf = weak_self;
        [strongSelf.web.configuration.userContentController addScriptMessageHandler:self name:obj];
        [strongSelf.methodArr removeObject:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funcDic.allKeys containsObject:message.name]) {
        DDLog(@"%@...................................",message.name);
        SEL sel = NSSelectorFromString(self.funcDic[message.name]);
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel withObject:message.body];
        }
    }
}

@end
