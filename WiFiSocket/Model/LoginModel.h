//
//  LoginModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/10/16.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseControlModel.h"


@interface LoginModel : BaseControlModel

@property (nonatomic, copy) void(^loginHandler)(NSString *type,NSInteger loginType);
@property (nonatomic, assign) BOOL isBindWx;
@property (nonatomic, assign) BOOL isBindAlipay;

+ (instancetype)shareInstace;

- (void)wxLoginState:(SendAuthResp *)resp;

- (void)aliPayLoginState:(NSDictionary *)resultDic;

@end
