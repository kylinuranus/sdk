//
//  SOSVerifyMAMobileViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/9/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterTextField.h"
typedef void(^verifyCompleteBlock)(BOOL verifySuccess);

@interface SOSVerifyMAMobileViewController : SOSBaseViewController
@property(nonatomic,copy)verifyCompleteBlock verifyBlock;
@property(nonatomic,copy)NSString * gaaMobile;
@end
