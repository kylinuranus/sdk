//
//  SOSBleReceiveAlertViewController.h
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSBleReceiveAlertViewController : UIViewController

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *hide;
@property (nonatomic, copy) NSString *orginUrl;
@property (nonatomic, assign) BOOL isPer;//是否是永久共享
@end
