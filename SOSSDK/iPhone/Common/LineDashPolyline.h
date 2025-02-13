//
//  LineDashPolyline.h
//  OfficialDemo3D
//
//  Created by Li Fei on 10/25/13.
//  Copyright (c) 2013 songjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMapNaviKit/MAPolygon.h"
#import "AMapNaviKit/MAOverlay.h"

@interface LineDashPolyline :NSObject <MAOverlay>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly) MAMapRect boundingMapRect;

@property (nonatomic, strong)  MAPolyline *polyline;

- (id)initWithPolyline:(MAPolyline *)polyline;

@end
