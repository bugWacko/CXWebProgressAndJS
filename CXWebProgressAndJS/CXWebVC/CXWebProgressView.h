//
//  CXWebProgressView.h
//  CXWebProgressAndJS
//
//  Created by 陈晨昕 on 2017/6/2.
//  Copyright © 2017年 bugWacko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXWebProgressView : UIView
@property (nonatomic) float progress;

@property (nonatomic) UIView *progressBarView;
@property (nonatomic) NSTimeInterval barAnimationDuration; // default 0.1
@property (nonatomic) NSTimeInterval fadeAnimationDuration; // default 0.27
@property (nonatomic) NSTimeInterval fadeOutDelay; // default 0.1

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
