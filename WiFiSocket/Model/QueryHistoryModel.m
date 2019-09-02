//
//  QueryHistoryModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/12/4.
//  Copyright © 2018 QiXing. All rights reserved.
//

#import "QueryHistoryModel.h"

@interface QueryHistoryModel ()<WKScriptMessageHandler>



@end

@implementation QueryHistoryModel

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
             @"deviceHistoryDataRequest",   //查询设备历史数据
             @"deviceAccumulationParameterRequest", //查询设备累计参数
             @"deviceRateRequest",   //查询设备费率
      ];
}

- (NSDictionary *)funcDic
{
   return @{
            @"deviceHistoryDataRequest":@"deviceHistoryDataRequest:",   //查询设备历史数据
            @"deviceAccumulationParameterRequest":@"deviceAccumulationParameterRequest:", //查询设备累计参数
            @"deviceRateRequest":@"deviceRateRequest:",   //查询设备费率
      };
}

#pragma mark 查询设备电量历史数据
- (void)deviceHistoryDataRequest:(NSDictionary *)object
{
    DDLog(@"deviceHistoryDataRequest...................");
    
    [self deviceOneDayHistoryDataRequest:object];
    
    NSString *mac = [ToolHandle fillNullString:object[@"mac"]];
    NSArray *startArr = [[ToolHandle fillNullString:object[@"startTime"]] componentsSeparatedByString:@"/"];
    NSArray *endArr = [[ToolHandle fillNullString:object[@"endTime"]] componentsSeparatedByString:@"/"];
    
    uint8_t interval = [object[@"interval"] integerValue];
    if (startArr.count == 3 && endArr.count == 3) {
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *startTime = [object[@"startTime"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        NSString *endTime = [object[@"endTime"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        NSDate *startDate = [dateFormatter dateFromString:startTime];
        NSDate *endDate = [dateFormatter dateFromString:endTime];
        if (endDate == nil) {
            
            NSDate *datenow = [NSDate date];
            endDate = datenow;
        
        }
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        //获取两个时间相差多少天
        NSDateComponents *comps = [gregorian components:NSCalendarUnitDay fromDate:startDate  toDate:endDate  options:0];
        
//        if (interval==1) {
//            // 间隔五分钟的数据上报
//            NSString *time = [object[@"startTime"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
//            NSString *path = [NSString stringWithFormat:@"%@-minute",time];
//            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[self getHistoryPath:path mac:mac]];
//            if (data) {
//                NSString *jsonArr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                DDLog(@"获取当天缓存历史记录截止时间为。。。。。。。。。。。。。。。。。。。。。。%ld:%ld",arr.count/12,arr.count%12*5);
//
//                NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%d,%d,'%@')",mac,object[@"startTime"],1,interval,jsonArr];
//                DDLog(@"查询时电量 ---- 上传json %@",jsCode);
//                [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//                }];
////                [self performSelector:@selector(deviceOneDayHistoryDataRequest:) withObject:object afterDelay:6];
////                [self deviceOneDayHistoryDataRequest:object];
//            }else{
////                [self deviceOneDayHistoryDataRequest:object];
////                [self performSelector:@selector(deviceOneDayHistoryDataRequest:) withObject:object afterDelay:6];
//            }
//        }else if (interval == 2) {
//            // 间隔一小时的数据上报
//
//            NSMutableArray *hourArr = [NSMutableArray array];
//            for (NSInteger i=0; i<comps.day; i++) {
//
//                NSDate *nextdate= [NSDate dateWithTimeInterval:24*60*60*i sinceDate:startDate];
//                NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:(long)[nextdate timeIntervalSince1970]];
//                NSString *nextDateStr = [dateFormatter stringFromDate:date2];
//                NSArray *arr = [nextDateStr componentsSeparatedByString:@" "];
//                NSArray *arr1 = [arr[0] componentsSeparatedByString:@"-"];  //年月日
//                NSString *timess = [NSString stringWithFormat:@"%ld-%ld-%ld",[arr1[0] integerValue],[arr1[1] integerValue],[arr1[2] integerValue]];
//                NSString *path = [NSString stringWithFormat:@"%@-hour",timess];
//                NSData *data=  [[NSFileManager defaultManager] contentsAtPath:[self getHistoryPath:path mac:mac]];
//                if (data) {
//                    NSMutableArray*arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                    [hourArr addObjectsFromArray:arr];
//                }else{
//                    for (NSInteger i=0; i<24; i++) {
//                        [hourArr addObject:@{
//                                             @"e":@(0),
//                                             @"s":@(0)
//                                             }];
//                    }
//                    NSDate *predate= [NSDate dateWithTimeInterval:-24*60*60 sinceDate:nextdate];
//                    NSDate *date3 = [NSDate dateWithTimeIntervalSince1970:(long)[predate timeIntervalSince1970]];
//                    NSString *predateStr = [dateFormatter stringFromDate:date3];
//                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:object];
//                    NSString *preStr = [predateStr stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
//                    NSString *nextStr = [nextDateStr stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
//                    [dict setObject:preStr forKey:@"startTime"];
//                    [dict setObject:nextStr forKey:@"endTime"];
//                    [self deviceOneDayHistoryDataRequest:dict];
//                }
//                DDLog(@"=====================间隔一小时电量查询==========================%@",path);
//
//            }
//
//            for (int i = 0; i < hourArr.count; i++) {
//
//                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:hourArr[i]];
//
//                float eFloat = [dict[@"e"] floatValue]*12.0;
//                [dict setObject:@(eFloat) forKey:@"e"];
//
//                 [hourArr replaceObjectAtIndex:i withObject:dict];
//
//            }
//
//            NSString *json = [ToolHandle toJsonString:hourArr];
//            NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%ld,%d,'%@')",mac,object[@"startTime"],comps.day*24,interval,json];
//            DDLog(@"查询每日电量 ---- 上传json %@",jsCode);
//            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//            }];
//
//        }else if (interval == 3){
//            // 间隔一天的数据上报
//
//            NSMutableArray *dayArr = [NSMutableArray array];
//            for (NSInteger i=0; i<comps.day; i++) {
//                NSDate *nextdate= [NSDate dateWithTimeInterval:24*60*60*i sinceDate:startDate];
//                NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:(long)[nextdate timeIntervalSince1970]];
//                NSString *nextDateStr = [dateFormatter stringFromDate:date2];
//                NSArray *arr = [nextDateStr componentsSeparatedByString:@" "];
//                NSArray *arr1 = [arr[0] componentsSeparatedByString:@"-"];  //年月日
//                NSString *timess = [NSString stringWithFormat:@"%ld-%ld-%ld",[arr1[0] integerValue],[arr1[1] integerValue],[arr1[2] integerValue]];
//                NSString *path = [NSString stringWithFormat:@"%@-day",timess];
//                NSData *data=  [[NSFileManager defaultManager] contentsAtPath:[self getHistoryPath:path mac:mac]];
//                if (data) {
//                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                    [dayArr addObject:dic];
//                }else{
//                    [dayArr addObject:@{
//                                        @"e":@(0),
//                                        @"s":@(0)
//                                        }];
//                }
//                DDLog(@"=======================间隔一天数据查询========================%@",path);
//
//            }
//
//            NSString *json = [ToolHandle toJsonString:dayArr];
//            NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%ld,%d,'%@')",mac,object[@"startTime"],comps.day,interval,json];
//            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//            }];
//
//        }else if (interval == 4){
//            // 间隔一星期的数据上报
//            NSMutableArray *weekArr = [NSMutableArray array];
//            for (NSInteger i=0; i<comps.day/7; i++) {
//                CGFloat totalE = 0;
//                CGFloat totalS = 0;
//                for (NSInteger j=0; j<7; j++) {
//                    NSDate *nextdate= [NSDate dateWithTimeInterval:24*60*60*(i*7+j) sinceDate:startDate];
//                    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:(long)[nextdate timeIntervalSince1970]];
//                    NSString *nextDateStr = [dateFormatter stringFromDate:date2];
//                    NSArray *arr = [nextDateStr componentsSeparatedByString:@" "];
//                    NSArray *arr1 = [arr[0] componentsSeparatedByString:@"-"];  //年月日
//                    NSString *timess = [NSString stringWithFormat:@"%ld-%ld-%ld",[arr1[0] integerValue],[arr1[1] integerValue],[arr1[2] integerValue]];
//                    NSString *path = [NSString stringWithFormat:@"%@-day",timess];
//                    NSData *data=  [[NSFileManager defaultManager] contentsAtPath:[self getHistoryPath:path mac:mac]];
//                    if (data) {
//                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                        totalE += [dic[@"e"] floatValue];
//                        totalS += [dic[@"s"] floatValue];
//                    }else{
//
//                    }
//                    DDLog(@"=======================间隔一星期数据查询========================%@",path);
//                }
//                [weekArr addObject:@{
//                                     @"e":@(totalE),
//                                     @"s":@(totalS)
//                                     }];
//            }
//
//            NSString *json = [ToolHandle toJsonString:weekArr];
//            NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%ld,%d,'%@')",mac,object[@"startTime"],comps.day,interval,json];
//            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//            }];
//
//        }else if (interval == 5){
//            // 间隔一个月的数据上报
//            NSMutableArray *monthArr = [NSMutableArray array];
//            for (NSInteger i=0; i<comps.day/30; i++) {
//                CGFloat totalE = 0;
//                CGFloat totalS = 0;
//                for (NSInteger j=0; j<30; j++) {
//                    NSDate *nextdate= [NSDate dateWithTimeInterval:24*60*60*(i*30+j) sinceDate:startDate];
//                    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:(long)[nextdate timeIntervalSince1970]];
//                    NSString *nextDateStr = [dateFormatter stringFromDate:date2];
//                    NSArray *arr = [nextDateStr componentsSeparatedByString:@" "];
//                    NSArray *arr1 = [arr[0] componentsSeparatedByString:@"-"];  //年月日
//                    NSString *timess = [NSString stringWithFormat:@"%ld-%ld-%ld",[arr1[0] integerValue],[arr1[1] integerValue],[arr1[2] integerValue]];
//                    NSString *path = [NSString stringWithFormat:@"%@-day",timess];
//                    NSData *data=  [[NSFileManager defaultManager] contentsAtPath:[self getHistoryPath:path mac:mac]];
//                    if (data) {
//                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                        totalE += [dic[@"e"] floatValue];
//                        totalS += [dic[@"s"] floatValue];
//                    }else{
//
//                    }
//                    DDLog(@"======================间隔一个月数据查询=========================%@",path);
//                }
//                [monthArr addObject:@{
//                                      @"e":@(totalE),
//                                      @"s":@(totalS)
//                                      }];
//            }
//            NSString *json = [ToolHandle toJsonString:monthArr];
//            NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%ld,%d,'%@')",mac,object[@"startTime"],comps.day,interval,json];
//            [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//            }];
//        }else if (interval == 99){
        if (interval == 99){
            NSMutableArray *dayArr = [NSMutableArray array];
            for (NSInteger i=0; i<comps.day; i++) {
                NSDate *nextdate= [NSDate dateWithTimeInterval:24*60*60*i sinceDate:startDate];
                NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:(long)[nextdate timeIntervalSince1970]];
                NSString *nextDateStr = [dateFormatter stringFromDate:date2];
                NSArray *arr = [nextDateStr componentsSeparatedByString:@" "];
                NSArray *arr1 = [arr[0] componentsSeparatedByString:@"-"];  //年月日
                NSString *timess = [NSString stringWithFormat:@"%ld-%ld-%ld",[arr1[0] integerValue],[arr1[1] integerValue],[arr1[2] integerValue]];
                NSString *path = [NSString stringWithFormat:@"%@-day",timess];
                NSData *data=  [[NSFileManager defaultManager] contentsAtPath:[self getHistoryPath:path mac:mac]];
                if (data) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    [dayArr addObject:dic];
                }else{
                    [dayArr addObject:@{
                                        @"e":@(0),
                                        @"s":@(0)
                                        }];
                }
                
            }
            
            NSString *json = [ToolHandle toJsonString:dayArr];
            NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%ld,%d,'%@')",mac,object[@"startTime"],comps.day,interval,json];
            
            CGFloat count = 0.0;
            
            for (NSDictionary *dict in dayArr) {
                
                CGFloat eFloat = [dict[@"e"] floatValue];
                
                //                CGFloat sFloat = [dict[@"s"] floatValue];
                
                count = count + eFloat;
            }
            
            NSCalendar *gcCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            NSDateComponents *dateComponents = [gcCalendar components:kCFCalendarUnitYear |
                                                kCFCalendarUnitMonth |
                                                kCFCalendarUnitDay |
                                                kCFCalendarUnitHour |
                                                kCFCalendarUnitMinute |
                                                kCFCalendarUnitSecond |
                                                kCFCalendarUnitWeekday |
                                                kCFCalendarUnitWeekdayOrdinal |
                                                kCFCalendarUnitQuarter |
                                                kCFCalendarUnitWeekOfMonth |
                                                kCFCalendarUnitWeekOfYear |
                                                kCFCalendarUnitYearForWeekOfYear fromDate:startDate];
            
            NSLog(@"%ld",(long)dateComponents.year);
            
            NSLog(@"%lf",count/1000);
            if ([object objectForKey:@"mode"]) {
                
                jsCode = [NSString stringWithFormat:@"queryElectricityByTimeResponse('%@','%@',%f,%ld,'%ld,'%ld')",mac,object[@"mode"],count/1000,(long)dateComponents.year,(long)dateComponents.month,(long)dateComponents.day];
                DDLog(@"按时间查询已用电量电费返回 ---- 上传json %@",jsCode);
                [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
                    
                }];
                
            }
            
        }
        
    }
    
}

#pragma mark 查询指定日期电量记录
- (void)deviceOneDayHistoryDataRequest:(NSDictionary *)object
{
    
    NSLog(@"发送查询电量记录 --------  %@",object);
    
    NSString *mac = [ToolHandle fillNullString:object[@"mac"]];
    NSArray *startArr = [[ToolHandle fillNullString:object[@"startTime"]] componentsSeparatedByString:@"/"];
    NSArray *endArr = [[ToolHandle fillNullString:object[@"endTime"]] componentsSeparatedByString:@"/"];
    
    NSArray *array = [UDPSocket shareInstance].deviceInfoArr;
    
    uint8_t type = 0x02;
    uint8_t cmd = 0x19;
    
    uint8_t startYear = [startArr[0] integerValue]-2000;
    uint8_t startMonth = [startArr[1] integerValue];
    uint8_t startDay = [startArr[2] integerValue];
    
    uint8_t endYear = [endArr[0] integerValue]-2000;
    uint8_t endMonth = [endArr[1] integerValue];
    uint8_t endDay = [endArr[2] integerValue];
    uint8_t interval = 0X01;
    
    for (NSDictionary *dict in array) {
        
        if ([[dict objectForKey:@"mac"] isEqualToString:mac]) {
            
            NSLog(@"%lf",[[dict objectForKey:@"version"] floatValue]);
            
            if ([[dict objectForKey:@"version"] floatValue] <= 6.5) {
                
                cmd = 0x19;
                
                interval = 0X01;
                
            }else{
                
                cmd = 0x41;
                
                if ([object[@"interval"] integerValue] == 1) {
                    interval = 0X01;
                }else if ([object[@"interval"] integerValue] == 2){
                    interval = 0X02;
                }else if ([object[@"interval"] integerValue] == 3){
                    interval = 0X03;
                }else if ([object[@"interval"] integerValue] == 4){
                    interval = 0X04;
                }else if ([object[@"interval"] integerValue] == 5){
                    interval = 0X05;
                }else if ([object[@"interval"] integerValue] == 6){
                    interval = 0X06;
                }
                
//                interval = [[NSString stringWithFormat:@"0X0%ld",[object[@"interval"] integerValue]] intValue];
                
            }
            
        }
        
    }

    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:startYear]];
    [data appendData:[self getData:startMonth]];
    [data appendData:[self getData:startDay]];
    [data appendData:[self getData:endYear]];
    [data appendData:[self getData:endMonth]];
    [data appendData:[self getData:endDay]];
    [data appendData:[self getData:interval]];
    [self sendData:data mac:mac];
    
}

- (void)queryElectricityByTimeResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac{
    
    DDLog(@"queryElectricityByTimeResponse...................");
    
}

#pragma mark 查询电量历史记录
- (void)deviceHistoryDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"deviceHistoryDataResponse...................查询历史记录返回");
    BOOL res = [object[@"result"] boolValue];
    
    if (res) {
        NSData *data = [object objectForKey:@"data"];
        Byte *testByte = (Byte *)[data bytes];
        NSInteger resever = 8;
        NSInteger year = testByte[3+resever+2+1];
        NSInteger month = testByte[3+resever+2+2];
        NSInteger day = testByte[3+resever+2+3];
        NSInteger days = testByte[3+resever+2+4];
        NSInteger interval = testByte[data.length-3];
        NSMutableArray *muArr = [NSMutableArray array];
        NSInteger loc = 3+resever+2+5;  //电量起始位置
        NSInteger num = (data.length-3 -loc)/4;
        NSInteger num1 =  num;
        
        NSInteger dataIneteger = 0;
        if (interval == 1 || interval == 3) {
            
            for (int i = 0; i < days * 24; i++) {
                
                if (dataIneteger > num - 1) {
                    break;
                }
                
                for (int f = 0; f < 12; f++) {
                    
                    NSDictionary *dic;
                    CGFloat e = 0;
                    
                    if (dataIneteger > num - 1) {
                        break;
                    }else{
                        
                        e = [[NSString stringWithFormat:@"%d",(testByte[loc+dataIneteger*4]<<24)+(testByte[loc+dataIneteger*4+1]<<16)+(testByte[loc+dataIneteger*4+2]<<8)+(testByte[loc+dataIneteger*4+3])] integerValue]/1000.0;
                        
                        NSLog(@"第一个数据%ld ----- %f",dataIneteger,e);
                        
                        if (e < 0) {
                            
                            dic = @{
                                    @"e":@(0)
                                    };
                            
                        }else{
                            
                            dic = @{
                                    @"e":@(e)
                                    };
                            
                            
                        }
                        
                        num1--;
                        dataIneteger = num - num1;
                        
                    }

                    [muArr addObject:dic];
                    
                }

            }
        }else if (interval == 2){
            
            for (int i = 0; i < 168; i++) {
                
                NSDictionary *dic;
                CGFloat e = 0;
                
                if (dataIneteger > num - 1) {
                    
                    dic = @{
                            @"e":@(0)
                            };
                    
                }else{
                    
                    e = [[NSString stringWithFormat:@"%d",(testByte[loc+dataIneteger*4]<<24)+(testByte[loc+dataIneteger*4+1]<<16)+(testByte[loc+dataIneteger*4+2]<<8)+(testByte[loc+dataIneteger*4+3])] integerValue]/1000.0;
                    
                    NSLog(@"第一个数据%ld ----- %f",dataIneteger,e);
                    
                    if (e < 0) {
                        
                        dic = @{
                                @"e":@(0)
                                };
                        
                    }else{
                        
                        dic = @{
                                @"e":@(e)
                                };
                        
                    }
                    
                    num1--;
                    dataIneteger = num - num1;
                    
                }
                
                [muArr addObject:dic];
                
            }
            
        }
        
        NSLog(@"一共多少个 %ld",muArr.count);
        
        NSString *json = [ToolHandle toJsonString:muArr];
        
        NSString *startTime = [NSString stringWithFormat:@"%ld/%ld/%ld",year+2000,month,day];
        NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%ld,%ld,'%@')",deviceMac,startTime,muArr.count,interval,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"查询历史记录返回" message:json delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [alertView show];
        
//        if (interval == 1) {
//            NSString *time = [startTime stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
//            NSString *path = [NSString stringWithFormat:@"%@-minute",time];
//            [self historyPathWithTime:path WithData:[json dataUsingEncoding:NSUTF8StringEncoding] mac:deviceMac];
//
//            NSMutableArray *hourArr = [NSMutableArray array];
//            NSInteger interger = muArr.count/12;
//            //            NSInteger remainder = muArr.count%5;
//            for (NSInteger i=0; i<interger; i++) {
//                CGFloat e = 0;
//                CGFloat s = 0;
//                for (NSInteger j = 0; j < 12; j++) {
//                    e += [muArr[i*12+j][@"e"] floatValue];
//                    s += [muArr[i*12+j][@"s"] floatValue];
//                }
//
//                NSDictionary *hourDic = @{
//                                          @"e":@(e/12.0),
//                                          @"s":@(e/12.0),
//                                          };
//                [hourArr addObject:hourDic];
//            }
//            for (NSInteger i=0; i<24-interger; i++) {
//                NSDictionary *hourDic = @{
//                                          @"e":@(0),
//                                          @"s":@(0),
//                                          };
//                [hourArr addObject:hourDic];
//            }
//            NSData *hourData = [NSJSONSerialization dataWithJSONObject:hourArr options:NSJSONWritingPrettyPrinted error:nil];
//            [self historyPathWithTime:[NSString stringWithFormat:@"%@-hour",time] WithData:hourData mac:deviceMac];
//            //            for (NSInteger i=0; i<remainder; i++) {
//            //
//            //            }
//            NSData *dayData = [NSJSONSerialization dataWithJSONObject:@{
//                                                                        @"e":@(totalE),
//                                                                        @"s":@(totalS),
//                                                                        } options:NSJSONWritingPrettyPrinted error:nil];
//            [self historyPathWithTime:[NSString stringWithFormat:@"%@-day",time] WithData:dayData mac:deviceMac];
//
//        }
    }else{
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"查询历史记录返回失败" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [alertView show];
    }
}

#pragma mark 6.5 后 查询电量历史记录
- (void)deviceHistoryDataNewResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    
}

#pragma mark 五分钟上报电量
- (void)deviceHistoryReportDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"五分钟上报电量.....................%@",object);
    long long time = [[object objectForKey:@"time"] longLongValue];
    
    NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryReportDataResponse('%@','%lld','%@')",deviceMac,time,[ToolHandle toJsonString:object]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *times = [formatter stringFromDate:date];
//    NSArray *arr = [times componentsSeparatedByString:@" "];
//    NSArray *arr1 = [arr[0] componentsSeparatedByString:@"-"];  //年月日
//    NSArray *arr2 = [arr[1] componentsSeparatedByString:@":"];  //时分秒
//    NSString *timess = [NSString stringWithFormat:@"%ld-%ld-%ld",[arr1[0] integerValue],[arr1[1] integerValue],[arr1[2] integerValue]];
//    NSString *timeStr = [NSString stringWithFormat:@"%@-minute",timess];
//
//    if (arr1.count != 3 || arr2.count != 3) {
//        return;
//    }
//
//    NSData *data=  [[NSFileManager defaultManager] contentsAtPath:[self getHistoryPath:timeStr mac:deviceMac]];
//    NSMutableArray *muArr = [NSMutableArray array];
//    NSDictionary *dic = @{@"e":@(0),@"s":@(0)};
//
//    if (!data) {
//        for (NSInteger i = 0; i<12*24; i++) {
//            [muArr addObject:dic];
//        }
//    }else{
//        muArr = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] ];
//    }
//
//    CGFloat e = [object[@"e"] floatValue] < 0 ? 0 : [object[@"e"] floatValue];
//    dic = @{@"e":@(e),@"s":@(0)};
//    NSInteger index = [arr2[0] integerValue]*12+[arr2[1]integerValue]/5;
//    [muArr removeObjectAtIndex:index];
//    [muArr insertObject:dic atIndex:index];
//
//    NSString *json = [ToolHandle toJsonString:muArr];
//    [self historyPathWithTime:timeStr WithData:[json dataUsingEncoding:NSUTF8StringEncoding] mac:deviceMac];
//
//
//    CGFloat totalE = 0;
//    CGFloat totalS = 0;
//    NSMutableArray *hourArr = [NSMutableArray array];
//    NSInteger interger = muArr.count/12;
//    //            NSInteger remainder = muArr.count%5;
//    for (NSInteger i=0; i<interger; i++) {
//        CGFloat e = 0;
//        CGFloat s = 0;
//        for (NSInteger j=0; j<12; j++) {
//            e += [muArr[i*12+j][@"e"] floatValue];
//            s += [muArr[i*12+j][@"s"] floatValue];
//            totalE += e;
//            totalS += s;
//        }
//        NSDictionary *hourDic = @{
//                                  @"e":@(e/12.0),
//                                  @"s":@(e/12.0),
//                                  };
//        [hourArr addObject:hourDic];
//    }
//    for (NSInteger i=0; i<24-interger; i++) {
//        NSDictionary *hourDic = @{
//                                  @"e":@(0),
//                                  @"s":@(0),
//                                  };
//        [hourArr addObject:hourDic];
//    }
//    NSData *hourData = [NSJSONSerialization dataWithJSONObject:hourArr options:NSJSONWritingPrettyPrinted error:nil];
//    [self historyPathWithTime:[NSString stringWithFormat:@"%@-hour",timess] WithData:hourData mac:deviceMac];
////                for (NSInteger i=0; i<remainder; i++) {
////
////                }
//    NSData *dayData = [NSJSONSerialization dataWithJSONObject:@{
//                                                                @"e":@(totalE),
//                                                                @"s":@(totalS),
//                                                                } options:NSJSONWritingPrettyPrinted error:nil];
//    [self historyPathWithTime:[NSString stringWithFormat:@"%@-day",timess] WithData:dayData mac:deviceMac];
//
//        NSString *stbartTime = [NSString stringWithFormat:@"%ld/%ld/%ld",[arr1[0]integerValue],[arr1[1]integerValue],[arr1[2]integerValue]];
//        NSString *jsCode = [NSString stringWithFormat:@"deviceHistoryDataResponse('%@','%@',%d,%d,'%@')",deviceMac,startTime,1,1,json];
//        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//        }];
    
}

#pragma mark 查询设备累计参数
- (void)deviceAccumulationParameterRequest:(NSDictionary *)object
{
    DDLog(@"deviceAccumulationParameterRequest...................");
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type= 0x02;
    uint8_t cmd = 0x21;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendData:data mac:mac];
}

- (void)deviceAccumulationParameterResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"deviceAccumulationParameterResponse...................查询设备累计参数返回");
    NSString *jsCode = [NSString stringWithFormat:@"'%@',%d,%d,%d",deviceMac,[[ToolHandle fillNullString:object[@"totalTime"]]intValue],[[ToolHandle fillNullString:object[@"GHG"]]intValue],[[ToolHandle fillNullString:object[@"electricQuantity"]] intValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询设备费率
- (void)deviceRateRequest:(NSDictionary *)object
{
    DDLog(@"deviceRateRequest...................");
    
    NSString *mac = [object objectForKey:@"mac"];
    uint8_t type= 0x02;
    uint8_t cmd = 0x1F;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendData:data mac:mac];
}

- (void)deviceRateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    DDLog(@"deviceRateResponse...................查询设备费率返回");
    NSString *jsCode = [NSString stringWithFormat:@"'%@',%d,%d,%d,%d,%d,%d",deviceMac,[object[@"firstHour"]intValue],[object[@"firstMinute"]intValue],[object[@"firstPrice"]intValue],[object[@"sencondHour"]intValue],[object[@"secondMinute"]intValue],[object[@"secondPrice"]intValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}


#pragma rmark 消息组包发送
- (void)sendData:(NSMutableData *)data mac:(NSString *)mac
{
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:mac data:data];
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    __weak typeof(self) weakSelf = self;
    [self.funcArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[weakSelf.web configuration].userContentController addScriptMessageHandler:self name:obj];
        [weakSelf.methodArr removeObject:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funcDic.allKeys containsObject:message.name]) {
        DDLog(@"%@...................................",message.name);
        SEL sel = NSSelectorFromString(self.funcDic[message.name]);
        if ([self respondsToSelector:sel]) {
            [[HandlingDataModel shareInstance] regegistDelegate:self];
            [self performSelector:sel withObject:message.body];
        }
    }
}

- (NSString *)getHistoryPath:(NSString *)name mac:(NSString *)mac
{
    DDLog(@"获取指定日期的电量历史记录...............................%@",name);
    
    [QXUserDefaults setObject:[name stringByReplacingOccurrencesOfString:@"-minute" withString:@""] forKey:ElectricQuantityUpdateTime];
    
    NSString *floderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"HistoryFloder-%@",mac]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:floderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:floderPath withIntermediateDirectories:true attributes:nil error:nil];
    }
    return [floderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",name]];
}

- (BOOL)historyPathWithTime:(NSString *)time WithData:(NSData *)data mac:(NSString *)mac
{
    DDLog(@"开始写入电量历史记录数据..............................%@",time);
    NSString *floderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"HistoryFloder-%@",mac]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:floderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:floderPath withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSString *historyPath = [floderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",time]];
    //    [[NSFileManager defaultManager]removeItemAtPath:historyPath error:nil];
    BOOL  res = [[NSFileManager defaultManager] createFileAtPath:historyPath contents:data attributes:nil];
    return res;
}



@end
