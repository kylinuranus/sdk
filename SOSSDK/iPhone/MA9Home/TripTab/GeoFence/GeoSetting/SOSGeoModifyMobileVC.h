//
//  SOSGeoModifyMobileVC.h
//  Onstar
//
//  Created by Coir on 2019/7/8.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^backBlock)(void);

@interface SOSGeoModifyMobileVC : UIViewController

@property (nonatomic, copy) NNGeoFence *geofence;
@property (nonatomic, assign)BOOL isReplenishMobile;//是否用于登录补充手机号
@property (nonatomic, copy) backBlock backHandler;
//@property (nonatomic, copy) backBlock rightHandler;

@property (nonatomic, copy) backBlock completeHandler;

@end

NS_ASSUME_NONNULL_END
