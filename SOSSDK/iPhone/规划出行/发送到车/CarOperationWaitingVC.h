//
//  CarOperationWaitingVC.h
//  Onstar
//
//  Created by Coir on 16/3/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OrderType) {
    OrderTypeTBT = 1,
    OrderTypeODD = 2,
    OrderTypeAuto = 3,
    OrderTypeVehicleLocation = 4,
};

typedef void(^completionBlock)(void);

@interface CarOperationWaitingVC : UIViewController

//- (void)startAnimation;

+ (CarOperationWaitingVC *)initWithPoi:(SOSPOI *)poi Type:(OrderType)type FromVC:(UIViewController *)vc;

- (void)checkAndShowFromVC:(UIViewController *)vc;

- (void)checkAndShowFromVC:(UIViewController *)vc needToastMessage:(BOOL)needToast needShowWaitingVC:(BOOL)needShowVC completion:(void (^)(void))completion;

@property (assign, nonatomic) OrderType orderType;

@end
