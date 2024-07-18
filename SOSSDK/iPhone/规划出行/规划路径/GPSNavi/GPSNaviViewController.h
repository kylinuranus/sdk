//
//  GPSNaviViewController.h
//  AMapNaviKit
//
//  Created by liubo on 7/29/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMapHeader.h"
#import "SOSGPSNavInitProtocol.h"

@interface GPSNaviViewController : UIViewController<SOSGPSNavInitProtocol>

@property (nonatomic, strong) SOSPOI *startPoint;
@property (nonatomic, strong) SOSPOI *endPoint;
@property (nonatomic, assign) AMapNaviDrivingStrategy drivingStrategy;

@end
