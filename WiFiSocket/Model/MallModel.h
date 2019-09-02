//
//  MallModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/11/19.
//  Copyright © 2018 QiXing. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MallModel : BaseModel

@property (nonatomic, copy) void(^jumpMallHandler)(NSString *path);

@end

NS_ASSUME_NONNULL_END
