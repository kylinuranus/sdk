//
//  SOSRouteInfoViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/11.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseSegmentViewController.h"

@class SOSRouteInfo;

@interface SOSRouteInfoViewController : SOSBaseSegmentViewController
@property (nonatomic, assign) NSMutableArray *arraySelectPOI;
@property (nonatomic, strong) SOSRouteInfo *routeInfo;
@property (nonatomic, copy) NSArray *polylines;
@end
