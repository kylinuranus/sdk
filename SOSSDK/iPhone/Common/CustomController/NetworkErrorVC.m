//
//  NetworkErrorVC.m
//  Onstar
//
//  Created by Coir on 16/6/24.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "NetworkErrorVC.h"

@interface NetworkErrorVC ()

@end

@implementation NetworkErrorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"无网络连接";
//    self.navigationController.//navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
