//
//  SOSRouteMapVC.h
//  Onstar
//
//  Created by Coir on 23/11/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseMapVC.h"
#import "SOSRouteTool.h"

@interface SOSRouteMapVC : SOSBaseMapVC

@property (nonatomic, assign) SOSRouteSearchResultType routeType;
@property (nonatomic, strong) SOSRouteInfo *routeInfo;

- (id)initWithRoutePolylines:(NSArray *)polylines RouteInfos:(SOSRouteInfo *)routes;

- (void)showRoutePolylines:(NSArray *)polylines RouteInfos:(SOSRouteInfo *)routeInfo;

@end
