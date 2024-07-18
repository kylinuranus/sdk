//
//  SOSTabBarCotroller.h
//  Onstar
//
//  Created by Onstar on 2018/11/15.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CYLTabBarController/CYLTabBarController.h>
#import "SOSModuleProtocols.h"
#import "SOSTopPromptView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSHomeTabBarCotroller : CYLTabBarController <SOSHomeTabBarControllerProtocol,UITabBarControllerDelegate>

@property (nonatomic, strong) UIView *onstarLinkButtonView;

@property (strong, nonatomic) SOSTopPromptView *promptView;

- (BOOL)promptViewIsShowing;

@end

NS_ASSUME_NONNULL_END
