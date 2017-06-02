//
//  ViewController.m
//  CXWebProgressAndJS
//
//  Created by 陈晨昕 on 2017/6/2.
//  Copyright © 2017年 bugWacko. All rights reserved.
//

#import "ViewController.h"
#import "CXWebVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - push web view
- (IBAction)InterBtnAction:(UIButton *)sender {
    
    CXWebVC * web = [[CXWebVC alloc] init];
    web.hidesBottomBarWhenPushed = YES;
    web.url = @"https://www.baidu.com/";
    web.popRootVCStr = NSStringFromClass([ViewController class]);
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
