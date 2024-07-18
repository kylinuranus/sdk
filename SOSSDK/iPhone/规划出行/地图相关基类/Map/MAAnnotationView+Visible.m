//
//  MAAnnotationView+Visible.m
//  Onstar
//
//  Created by Coir on 16/7/20.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "MAAnnotationView+Visible.h"


@implementation MAAnnotationView (Visible)

- (void)setViewType:(POIType)viewType    {
    ((BaseAnnotation *)self.annotation).annotationType = viewType;
}

- (POIType)viewType      {
    return ((BaseAnnotation *)self.annotation).annotationType;
}

- (BOOL)isVisibleAtMapView:(MAMapView *)mapView     {
    NSSet *set = [mapView annotationsInMapRect:mapView.visibleMapRect];
    __block BOOL isVisible = NO;
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        CLLocationCoordinate2D coordinate = ((id <MAAnnotation>)obj).coordinate;
        CLLocationCoordinate2D selfCoordinate = self.annotation.coordinate;
        if (coordinate.latitude == selfCoordinate.latitude && coordinate.longitude == selfCoordinate.longitude) {
            isVisible = YES;
            *stop = YES;
        }
    }];
    return isVisible;
}

- (void)updateMapviewVisibleRegion:(MAMapView *)mapView {
    
    MAMapRect zoomRect = MAMapRectZero;
    for (id <MAAnnotation> annotation in mapView.annotations) {
        MAMapPoint annotationPoint = MAMapPointForCoordinate(annotation.coordinate);
        MAMapRect pointRect = MAMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MAMapRectIsEmpty(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MAMapRectUnion(zoomRect, pointRect);
        }
    }
    zoomRect = [mapView mapRectThatFits:zoomRect];
    [mapView setVisibleMapRect:zoomRect animated:YES];
}
@end
