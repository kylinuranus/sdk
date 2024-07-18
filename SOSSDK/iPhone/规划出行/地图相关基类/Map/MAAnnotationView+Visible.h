//
//  MAAnnotationView+Visible.h
//  Onstar
//
//  Created by Coir on 16/7/20.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSMapHeader.h"
#import "BaseAnnotation.h"

@interface MAAnnotationView (Visible)

- (BOOL)isVisibleAtMapView:(MAMapView *)mapView;
- (void)updateMapviewVisibleRegion:(MAMapView *)mapView;

@property (nonatomic, assign) POIType viewType;

@end
