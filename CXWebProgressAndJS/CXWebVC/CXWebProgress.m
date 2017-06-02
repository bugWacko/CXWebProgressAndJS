//  CXWebProgress.m
//  CXWebProgressAndJS
//
//  Created by 陈晨昕 on 2017/6/2.
//  Copyright © 2017年 bugWacko. All rights reserved.
//

#import "CXWebProgress.h"

NSString *completeRPCURLPath = @"/cxwebprogressproxy/complete";

const float CXKInitialProgressValue = 0.1f;
const float CXKInteractiveProgressValue = 0.5f;
const float CXKFinalProgressValue = 0.9f;

@implementation CXWebProgress
{
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    NSURL * _currentURL;
    BOOL _interactive;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxLoadCount = _loadingCount = 0;
        _interactive = NO;
    }
    return self;
}

- (void)startProgress
{
    if (_progress < CXKInitialProgressValue) {
        [self setProgress:CXKInitialProgressValue];
    }
}

- (void)incrementProgress
{
    float progress = self.progress;
    float maxProgress = _interactive ? CXKFinalProgressValue : CXKInteractiveProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress
{
    [self setProgress:1.0];
}

- (void)setProgress:(float)progress
{
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        if ([_delegate respondsToSelector:@selector(webViewProgress:updateProgress:)]) {
            [_delegate webViewProgress:self updateProgress:progress];
        }
    }
}

- (void)reset
{
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.0];
}

#pragma mark -
#pragma mark UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL ret = YES;
    if ([_webDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        ret = [_webDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if (ret && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_webDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_webDelegate webViewDidStartLoad:webView];
    }
    
    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    
    [self startProgress];
    
    //add js
    [self addJs:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([_webDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_webDelegate webViewDidFinishLoad:webView];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([_webDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_webDelegate webView:webView didFailLoadWithError:error];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}

#pragma mark - add js fun
-(void)addJs:(UIWebView *)webView {

    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSClass *jsClass = [JSClass new];
    
    //xxxx 表示你们的前端后端定义的key
    context[@"xxxx"] = jsClass;
    
    __weak CXWebProgress * view = self;
    jsClass.shareBlock = ^(NSString * title, NSString * desc, NSString * link, NSString * imgUrl) {
        if (view.jsDelegate && [view.jsDelegate respondsToSelector:@selector(webViewShare:withDesc:withLink:withImgUrl:)]) {
            [view.jsDelegate webViewShare:title withDesc:desc withLink:link withImgUrl:imgUrl];
        }
    };
}

@end

@implementation JSClass

-(void)onMenuShare:(NSString *)title :(NSString *)desc :(NSString *)link :(NSString *)imgUrl {
    if (self.shareBlock) {
        NSLog(@"----- web webview_share js action is run -----");
        self.shareBlock(title, desc, link, imgUrl);
    }
}

@end
