//
//  SOSGPSRoutePlanViewController.h
//  Onstar
//
//  Created by onstar on 2018/4/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMapHeader.h"


@interface SOSGPSRoutePlanViewController : UIViewController

@property (nonatomic, strong) AMapNaviRoute *naviRoute;
@property (nonatomic, strong) NSDate *gpsBeginDate;
@property (nonatomic, strong) SOSPOI *beginPoi;
@property (nonatomic, strong) SOSPOI *endPoi;


@end
