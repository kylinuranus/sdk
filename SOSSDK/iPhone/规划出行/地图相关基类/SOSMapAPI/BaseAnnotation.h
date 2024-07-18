//
//  BaseAnnotation.h
//  Onstar
//
//  Created by Onstar on 13-6-20.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSMapHeader.h"

@interface SOSPolyline : MAPolyline

@property(nonatomic, assign) BOOL isSelected;

@end

@interface SOSCircle : MACircle

@property(nonatomic, assign) BOOL isOpen;

@end


@interface BaseAnnotation : MAPointAnnotation <MAAnnotation>

//some user info
@property (nonatomic, copy) NSString *name;
@property(nonatomic, readwrite) POIType annotationType;

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, strong) CLLocation *location;
- (id)initWithLocation:(CLLocationCoordinate2D)location;
- (id)initWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lon;
@end
