//
//  SOSGeoModifyAlertTypeVC.h
//  Onstar
//
//  Created by Coir on 2019/6/28.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSGeoModifyAlertTypeVC : UIViewController

@property (nonatomic, copy) NNGeoFence *geofence;

@property (nonatomic, assign) BOOL isFromOriginAddPage;

@end

NS_ASSUME_NONNULL_END
