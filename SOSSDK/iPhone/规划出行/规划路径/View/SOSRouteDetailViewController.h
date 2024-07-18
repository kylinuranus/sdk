//
//  SOSRouteDetailViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/11.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSearchOBJ.h"

@interface SOSRouteDetailViewController : UIViewController

@property(nonatomic, assign) DriveStrategy strategy;
@property(nonatomic, strong) NSMutableArray *routePoisArray;
//@property (nonatomic, strong) NSArray *routeInfosArray;
@property (nonatomic, strong) NSArray *polyLines;
@property (nonatomic, strong) SOSRouteInfo *routeInfo;

- (void)configRouteTimeAndLength;

- (void)showLoadingView:(BOOL)show;

@end
