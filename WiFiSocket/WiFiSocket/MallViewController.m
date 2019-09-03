//
//  MallViewController.m
//  WiFiSocket
//
//  Created by Mac on 2019/1/24.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import "MallViewController.h"
#import <WebKit/WebKit.h>

@interface MallViewController ()<WKNavigationDelegate,WKUIDelegate>
{
    MBProgressHUD *hud;
}
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation MallViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:configuration];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.loadURL]];
    [self.webView loadRequest:request];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:self.webView];
}

- (void)setLoadURL:(NSString *)loadURL
{
    _loadURL = loadURL;
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"正在加载";
    [self.view addSubview:hud];
    [hud showAnimated:true];
}


#pragma mark webview加载代理方法
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [hud hideAnimated:true];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    hud.label.text = @"加载失败";
    [hud hideAnimated:true afterDelay:2.0];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //    NSURLRequest *request = navigationAction.request;
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    actionPolicy = WKNavigationActionPolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    completionHandler(@"完成");
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertView *aletView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:nil, nil];
    [aletView show];
    completionHandler();
}

#pragma mark - 监听加载进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object ==self.webView) {
            [hud hideAnimated:YES afterDelay:1.5];
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object  change:change context:context];
        }
        
    }
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
