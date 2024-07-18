//
//  SOSSocialRecoverViewController.h
//  Onstar
//
//  Created by onstar on 2019/4/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSSocialRecoverViewController : SOSBaseViewController

@property (nonatomic, strong) SOSSocialOrderInfoResp *orderInfo;

@property (nonatomic, strong) SOSPOI *currentPOI;

@property (nonatomic, assign) BOOL mobileType;//手机恢复导航
@end

NS_ASSUME_NONNULL_END
