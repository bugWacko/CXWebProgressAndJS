---
# CXWebProgressAndJS

这个实例是web加载动画和网页js信息回调功能集合，里面的关键代码在于动画的添加和js的初始化和回调。

### Web Progress Animation

其中使用的动画比较简单，自带API：

```
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);
```
进度动画代码如下：

```
//public method
/*
 * _progressBarView 动画控件
 */
- (void)setProgress:(float)progress animated:(BOOL)animated
{
    BOOL isGrowing = progress > 0.0;
    [UIView animateWithDuration:(isGrowing && animated) ? _barAnimationDuration : 0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = _progressBarView.frame;
        frame.size.width = progress * self.bounds.size.width;
        _progressBarView.frame = frame;
    } completion:nil];
    
    if (progress >= 1.0) {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:_fadeOutDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _progressBarView.alpha = 0.0;
        } completion:^(BOOL completed){
            CGRect frame = _progressBarView.frame;
            frame.size.width = 0;
            _progressBarView.frame = frame;
        }];
    }
    else {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _progressBarView.alpha = 1.0;
        } completion:nil];
    }
}
```

### Web And JS

实例中我们已一个分享返回为例，通过点击指定web方法，实现js回调回传数据，其中包括分享连接、图片等数据，具体可因自己开发而定。

* 添加JS回调事件

```
/*
 * JSClass js对象，将获取的js实例化
 * xxxx 表示定义的js方法名
 */
-(void)addJs:(UIWebView *)webView {

    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSClass *jsClass = [JSClass new];
    context[@"xxxx"] = jsClass;
    
    __weak CXWebProgress * view = self;
    jsClass.shareBlock = ^(NSString * title, NSString * desc, NSString * link, NSString * imgUrl) {
        if (view.jsDelegate && [view.jsDelegate respondsToSelector:@selector(webViewShare:withDesc:withLink:withImgUrl:)]) {
            [view.jsDelegate webViewShare:title withDesc:desc withLink:link withImgUrl:imgUrl];
        }
    };
}
```

* JSClass

```
//JSClass.h

@protocol JSProtocol <JSExport>

-(void)onMenuShare:(NSString *)title :(NSString *)desc :(NSString *)link :(NSString *)imgUrl;

@end

typedef void(^JSShareBlock)(NSString * title, NSString * desc, NSString * link, NSString * imgUrl);
@interface JSClass : NSObject<JSProtocol>

@property(nonatomic, copy) JSShareBlock shareBlock;

@end
```

```
//JSClass.m

@implementation JSClass

-(void)onMenuShare:(NSString *)title :(NSString *)desc :(NSString *)link :(NSString *)imgUrl {
    if (self.shareBlock) {
        DLog(@"----- web webview_share js action is run -----")
        self.shareBlock(title, desc, link, imgUrl);
    }
}

@end
```

才疏学浅，希望可以帮到大家，之前一直将开源控件本地化，没怎么传，现在会慢慢捡回来，希望大家多多关注。

#### happy reading！！！

---