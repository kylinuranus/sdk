//
//  SOSScanChargeVC.h
//  Onstar
//
//  Created by Coir on 2018/10/30.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSScanChargeVC : UIViewController

@property (nonatomic, copy) NSString *sessionID;

@property (nonatomic, copy) void(^scanCompleteBlock)(NSString *url);

@end

NS_ASSUME_NONNULL_END
