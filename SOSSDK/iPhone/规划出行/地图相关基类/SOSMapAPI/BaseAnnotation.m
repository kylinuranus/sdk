//
//  BaseAnnotation.m
//  Onstar
//
//  Created by Onstar on 13-6-20.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import "BaseAnnotation.h"

@implementation SOSPolyline

@end

@implementation SOSCircle

@end

@implementation BaseAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D)location     {
    if (self = [super init]) {
        self.latitude = location.latitude;
        self.longitude = location.longitude;
        self.coordinate = location;
        self.location = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    }
    return self;
}

- (id)initWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lon     {
    if (self = [super init]) {
        self.latitude = lat;
        self.longitude = lon;
        self.coordinate = CLLocationCoordinate2DMake(lat, lon);
        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    return self;
}

@end
