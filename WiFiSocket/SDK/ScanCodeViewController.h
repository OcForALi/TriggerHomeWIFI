//
//  ScanCodeViewController.h
//  Demo
//
//  Created by Mac on 2017/8/8.
//  Copyright © 2017年 QiXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanCodeViewController : UIViewController

@property (nonatomic ,copy) void(^ScanCodeCallBack)(NSString *sn);

@end
