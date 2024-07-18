//
//  UIViewController+errorPage.m
//  Onstar
//
//  Created by lizhipan on 16/9/19.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "UIViewController+errorPage.h"
#import "ErrorPageVC.h"

@implementation UIViewController (errorPage)
- (void)goErrorPage:(NSString *)detail_ image:(NSString *)image_{
    ErrorPageVC *errorPage = [[ErrorPageVC alloc]initWithErrorPage:NSLocalizedString(@"assistantReportStatusTitle", @"") imageName:image_ detail:detail_];
    [errorPage.view setFrame:self.view.bounds];
    [self.view addSubview:errorPage.view];
}

- (void)goH5ErrorPage:(NSString *)detail_ image:(NSString *)image_ refreshBlock:(void(^)(void))refreshBlock {
    ErrorPageVC *errorPage = [[ErrorPageVC alloc]initWithErrorPage:NSLocalizedString(@"assistantReportStatusTitle", @"") imageName:image_ detail:detail_];
    [errorPage.view setFrame:self.view.bounds];
    errorPage.view.backgroundColor = [UIColor whiteColor];
    errorPage.refreshBlock = refreshBlock;
    [self addChildViewController:errorPage];
    [self.view addSubview:errorPage.view];
}

@end
