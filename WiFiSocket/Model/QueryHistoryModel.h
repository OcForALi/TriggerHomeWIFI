//
//  QueryHistoryModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/12/4.
//  Copyright © 2018 QiXing. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueryHistoryModel : BaseModel<HandlingDataModelDelegate>

- (void)deviceHistoryDataRequest:(NSDictionary *)object;

- (void)deviceOneDayHistoryDataRequest:(NSDictionary *)object;
@end

NS_ASSUME_NONNULL_END
