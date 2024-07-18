//
//  UIViewController+errorPage.h
//  Onstar
//
//  Created by lizhipan on 16/9/19.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (errorPage)
- (void)goErrorPage:(NSString *)detail_ image:(NSString *)image_;
- (void)goH5ErrorPage:(NSString *)detail_ image:(NSString *)image_ refreshBlock:(void(^)(void))refreshBlock ;
@end
