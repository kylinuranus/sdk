//
//  UIView+SOSBleToast.h
//  Onstar
//
//  Created by onstar on 2018/8/6.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SOSBleToast)

- (UIView *)showBleAlertWithMessage:(NSString *)message;

- (void)hideBleAlert:(UIView *)cover;

- (UIView *)showBleAlertView:(UIView *)alertView;

@end
