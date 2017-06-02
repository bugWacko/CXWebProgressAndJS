//
//  CXWebVC.m
//  CXWebProgressAndJS
//
//  Created by 陈晨昕 on 2017/6/2.
//  Copyright © 2017年 bugWacko. All rights reserved.
//

#import "CXWebVC.h"
#import "CXWebProgress.h"
#import "CXWebProgressView.h"

const CGFloat progressBarHeight = 2.f;

@interface CXWebVC ()<CXWebProgressDelegate, UIWebViewDelegate, CXWebJSDelegate> {

    CXWebProgressView *_progressView;
    CXWebProgress *_progressProxy;
}

@property (strong, nonatomic) NSString * shareTitle;
@property (strong, nonatomic) NSString * shareDesc;
@property (strong, nonatomic) NSString * shareLink;
@property (strong, nonatomic) NSString * shareImgUrl;

@property (strong, nonatomic) UIWebView * webView;
@property (strong, nonatomic) UIButton * closeBtn;

@end

@implementation CXWebVC

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    [_progressView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //add webView
    [self.view addSubview:self.webView];
    
    //add nav btn
    [self addNavBtn];
    
    _progressProxy = [[CXWebProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webDelegate = self;
    _progressProxy.delegate = self;
    _progressProxy.jsDelegate = self;
    
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[CXWebProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self requestWeb];
}

#pragma mark - 请求web
-(void)requestWeb {

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [self.webView loadRequest:request];
}

#pragma mark - 返回关闭按钮
-(void)addNavBtn {
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    backBtn.frame = CGRectMake(0, 0, 30, 44);
    
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    //关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    closeBtn.frame = CGRectMake(0, 0, 30, 44);
    

    [closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn = closeBtn;
    [self.closeBtn setHidden:YES];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10;
    self.navigationItem.leftBarButtonItems = @[spaceItem, backItem, closeItem];
}

#pragma mark - 返回
-(void)backBtnAction:(UIButton *)sender {

    if ([self.webView canGoBack]) {
        [self.webView goBack];
        [self.closeBtn setHidden:NO];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 关闭
-(void)closeBtnAction:(UIButton *)sender {
 
    for (UIViewController * viewVC in self.navigationController.viewControllers) {
        if ([viewVC isKindOfClass:NSClassFromString(self.popRootVCStr)]) {
            [self.navigationController popToViewController:viewVC animated:YES];
            break;
        }
    }
}

#pragma mark - UIWebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.title = @"载入中...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
}

#pragma mark - CXWebProgress Delegate
-(void)webViewProgress:(CXWebProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - CXWebProgress JSDelegate
-(void)webViewShare:(NSString *)title withDesc:(NSString *)desc withLink:(NSString *)link withImgUrl:(NSString *)imgUrl {

    //js回调回传信息
    self.shareTitle = title;
    self.shareDesc = desc;
    self.shareLink = link;
    self.shareImgUrl = imgUrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UIWebView *)webView {

    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.frame = self.view.bounds;
    }
    return _webView;
}

@end
