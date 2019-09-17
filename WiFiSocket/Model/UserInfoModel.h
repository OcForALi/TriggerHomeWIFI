//
//  UserInfoModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/8/28.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"

@interface UserInfoModel : BaseModel

@property (nonatomic, copy) void(^jumpPhotoController)(NSInteger type);

- (void)updateUserInfoDic:(NSDictionary *)dic;

- (void)registFunctionWithWeb:(WKWebView *)web;

- (void)getPhotoResponse:(NSString *)imgUrl result:(BOOL)result;

@end
