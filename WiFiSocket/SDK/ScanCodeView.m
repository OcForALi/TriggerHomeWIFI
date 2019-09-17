//
//  ScanCodeView.m
//  SMARTAI
//
//  Created by Mac on 2018/1/23.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "ScanCodeView.h"
#define QRCodeWidth  480/2.0  //正方形二维码的边长


@implementation ScanCodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self setupMaskView];
}

- (void)setupMaskView
{
    //设置统一的视图颜色和视图的透明度
    UIColor *color = [UIColor blackColor];
    float alpha = 0.7;
    
    //设置扫描区域外部上部的视图
    UIView *topView = [[UIView alloc]init];
    topView.frame = CGRectMake(0, 0, SCREEN_WITDH, (SCREEN_HEIGHT-NavBarHeight-QRCodeWidth)/3.0);
    topView.backgroundColor = color;
    topView.alpha = alpha;
    
    //设置扫描区域外部左边的视图
    UIView *leftView = [[UIView alloc]init];
    leftView.frame = CGRectMake(0, topView.frame.size.height, (SCREEN_WITDH-QRCodeWidth)/2.0,QRCodeWidth);
    leftView.backgroundColor = color;
    leftView.alpha = alpha;
    
    //设置扫描区域外部右边的视图
    UIView *rightView = [[UIView alloc]init];
    rightView.frame = CGRectMake((SCREEN_WITDH-QRCodeWidth)/2.0+QRCodeWidth,topView.frame.size.height, (SCREEN_WITDH-QRCodeWidth)/2.0,QRCodeWidth);
    rightView.backgroundColor = color;
    rightView.alpha = alpha;
    
    //设置扫描区域外部底部的视图
    UIView *botView = [[UIView alloc]init];
    botView.frame = CGRectMake(0, QRCodeWidth+topView.frame.size.height,SCREEN_WITDH,SCREEN_HEIGHT-NavBarHeight-QRCodeWidth-topView.frame.size.height);
    botView.backgroundColor = color;
    botView.alpha = alpha;
    
    //将设置好的扫描二维码区域之外的视图添加到视图图层上
    [self addSubview:topView];
    [self addSubview:leftView];
    [self addSubview:rightView];
    [self addSubview:botView];
    
    //设置扫描区域的位置(考虑导航栏和电池条的高度为64)
    UIView *scanWindow = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WITDH-QRCodeWidth)/2.0,(SCREEN_HEIGHT-QRCodeWidth-NavBarHeight)/3.0,QRCodeWidth,QRCodeWidth)];
    scanWindow.layer.borderColor = [UIColor whiteColor].CGColor;
    scanWindow.layer.borderWidth = 0.5;
    
    scanWindow.clipsToBounds = YES;
    [self addSubview:scanWindow];
    
    //设置扫描区域的动画效果
    CGFloat scanNetImageViewH = 12;
    CGFloat scanCornerWidth = 3.0;
    CGFloat scanNetImageViewW = scanWindow.frame.size.width;
    UIImageView *scanNetImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QRCodeScanningLine"]];
    scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
    CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath =@"transform.translation.y";
    scanNetAnimation.byValue = @(QRCodeWidth);
    scanNetAnimation.duration = 2.0;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [scanNetImageView.layer addAnimation:scanNetAnimation forKey:nil];
    [scanWindow addSubview:scanNetImageView];

    
    UIColor *strokeColor = [UIColor greenColor];
    UIBezierPath *leftTop = [UIBezierPath bezierPath];
    leftTop.lineWidth = scanCornerWidth;
    [strokeColor set];
    
    leftTop.lineCapStyle = kCGLineCapButt;
    leftTop.lineJoinStyle  = kCGLineJoinBevel;
    [leftTop moveToPoint:CGPointMake(scanWindow.left, scanWindow.top+30)];
    [leftTop addLineToPoint:CGPointMake(scanWindow.left, scanWindow.top)];
    [leftTop addLineToPoint:CGPointMake(scanWindow.left+30, scanWindow.top)];
    [leftTop stroke];
    
    UIBezierPath *rightTop = [UIBezierPath bezierPath];
    rightTop.lineWidth = scanCornerWidth;
    [strokeColor set];
    rightTop.lineCapStyle = kCGLineCapButt;
    rightTop.lineJoinStyle = kCGLineJoinBevel;
    [rightTop moveToPoint:CGPointMake(scanWindow.right-30, scanWindow.top)];
    [rightTop addLineToPoint:CGPointMake(scanWindow.right, scanWindow.top)];
    [rightTop addLineToPoint:CGPointMake(scanWindow.right, scanWindow.top+30)];
    [rightTop stroke];
    
    UIBezierPath *leftBottom = [UIBezierPath bezierPath];
    leftBottom.lineWidth = scanCornerWidth;
    [strokeColor set];
    leftBottom.lineCapStyle = kCGLineCapButt;
    leftBottom.lineJoinStyle = kCGLineJoinBevel;
    [leftBottom moveToPoint:CGPointMake(scanWindow.left, scanWindow.bottom-30)];
    [leftBottom addLineToPoint:CGPointMake(scanWindow.left, scanWindow.bottom)];
    [leftBottom addLineToPoint:CGPointMake(scanWindow.left+30, scanWindow.bottom)];
    [leftBottom stroke];
    
    UIBezierPath *rightBottom = [UIBezierPath bezierPath];
    rightBottom.lineWidth = scanCornerWidth;
    [strokeColor set];
    rightBottom.lineCapStyle = kCGLineCapButt;
    rightBottom.lineJoinStyle = kCGLineJoinBevel;
    [rightBottom moveToPoint:CGPointMake(scanWindow.right-30, scanWindow.bottom)];
    [rightBottom addLineToPoint:CGPointMake(scanWindow.right, scanWindow.bottom)];
    [rightBottom addLineToPoint:CGPointMake(scanWindow.right, scanWindow.bottom-30)];
    
    //    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //    [self addCornerLineWithContext:ctx rect:mainRect];
    
    [rightBottom stroke];
    
}

@end
