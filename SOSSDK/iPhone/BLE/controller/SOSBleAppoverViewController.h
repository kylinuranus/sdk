//
//  SOSBleAppoverViewController.h
//  Onstar
//
//  Created by onstar on 2018/11/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSBleAppoverViewController : UIViewController

@property (nonatomic, copy) void(^acceptBlock)(void);
@property (nonatomic, copy) NSString *phone;
@end

NS_ASSUME_NONNULL_END
