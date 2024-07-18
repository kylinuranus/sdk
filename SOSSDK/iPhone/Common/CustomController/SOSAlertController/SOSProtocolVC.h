//
//  SOSProtocolVC.h
//  Onstar
//
//  Created by Coir on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSFlexibleAlertController.h"
#import "SOSAgreement.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSProtocolVC : SOSFlexibleAlertController

+ (instancetype)initWithTitle:(NSString *)title AgreementType:(SOSAgreementType)type CompleteHanlder:(void (^)(BOOL agreeStatus))completion;

+ (instancetype)initWithTitle:(NSString *)title AgreeTitle:(NSString *)agreeTItle CancelTitle:(NSString *)cancelTitle AgreementType:(SOSAgreementType)type CompleteHanlder:(void (^)(BOOL agreeStatus))completion;

- (void)show;

@end

NS_ASSUME_NONNULL_END
