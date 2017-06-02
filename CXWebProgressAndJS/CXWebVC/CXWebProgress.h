//
//  CXWebProgress.h
//  CXWebProgressAndJS
//
//  Created by 陈晨昕 on 2017/6/2.
//  Copyright © 2017年 bugWacko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol CXWebProgressDelegate;
@protocol CXWebJSDelegate;
@interface CXWebProgress : NSObject<UIWebViewDelegate>
@property (weak, nonatomic) id<CXWebProgressDelegate>delegate;
@property (weak, nonatomic) id<UIWebViewDelegate>webDelegate;
@property (weak, nonatomic) id<CXWebJSDelegate>jsDelegate;

@property (nonatomic, readonly) float progress; // 0.0..1.0

@end

@protocol CXWebJSDelegate <NSObject>
-(void)webViewShare:(NSString *)title withDesc:(NSString *)desc withLink:(NSString *)link withImgUrl:(NSString *)imgUrl;

@end

@protocol CXWebProgressDelegate <NSObject>
- (void)webViewProgress:(CXWebProgress *)webProgress updateProgress:(float)progress;

@end


// -=-= -=-= -=-= -=-= -=-= -=-= -=-= -=-= -=-= -=-= -=-= -=-= -=-=


@protocol JSProtocol <JSExport>

-(void)onMenuShare:(NSString *)title :(NSString *)desc :(NSString *)link :(NSString *)imgUrl;

@end

typedef void(^JSShareBlock)(NSString * title, NSString * desc, NSString * link, NSString * imgUrl);
@interface JSClass : NSObject<JSProtocol>

@property(nonatomic, copy) JSShareBlock shareBlock;

@end
