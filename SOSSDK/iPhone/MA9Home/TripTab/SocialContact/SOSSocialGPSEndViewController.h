//
//  SOSSocialGPSEndViewController.h
//  Onstar
//
//  Created by onstar on 2019/4/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSSocialGPSEndViewController : SOSTripBaseMapVC
- (instancetype)initWithRouteBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI;

@end

NS_ASSUME_NONNULL_END
