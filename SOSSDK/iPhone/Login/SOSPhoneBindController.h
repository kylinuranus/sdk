//
//  SOSPhoneBindController.h
//  Onstar
//
//  Created by WQ on 2019/4/1.
//  Copyright © 2019年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FinishBlock)(NSString *phone);
typedef void(^ReloginBlock)(void);

//deprecate
@interface SOSPhoneBindController : UIViewController

@property(nonatomic,copy)FinishBlock overBlock;
@property(nonatomic,copy)ReloginBlock needRelogin;

@end

NS_ASSUME_NONNULL_END
