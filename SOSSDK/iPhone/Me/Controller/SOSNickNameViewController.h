//
//  SOSNickNameViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterTextField.h"
typedef void(^updateCompleteBlock)(NSString* newNickName);

@interface SOSNickNameViewController : SOSBaseViewController
@property(nonatomic,copy) updateCompleteBlock updateBlock;
@end
