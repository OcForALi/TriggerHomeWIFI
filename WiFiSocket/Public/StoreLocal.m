//
//  StoreLocal.m
//  WiFiSocket
//
//  Created by Mac on 2019/3/27.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import "StoreLocal.h"

@implementation StoreLocal

+ (void)storeLocalSevenState:(NSString *)storeLocalName Mac:(NSString *)mac State:(BOOL)state{
    
    NSMutableArray *mutabArray = [[NSMutableArray alloc] initWithArray:[QXUserDefaults objectForKey:storeLocalName]];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < mutabArray.count; i++) {
        
        NSDictionary *dict = mutabArray[i];
        if ([[dict objectForKey:@"mac"] isEqualToString: mac]) {
            [mutabArray replaceObjectAtIndex:i withObject:@{@"mac":mac,@"state":[NSString stringWithFormat:@"%d",state]}];
        }
        [array addObject:dict[@"mac"]];
        
    }
    
    if ([array containsObject:mac]) {
        
    }else{
        [mutabArray addObject:@{@"mac":mac,@"state":[NSString stringWithFormat:@"%d",state]}];
    }
    
    [QXUserDefaults setObject:mutabArray forKey:storeLocalName];
    
}

@end
