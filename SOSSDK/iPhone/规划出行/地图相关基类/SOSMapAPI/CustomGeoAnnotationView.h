//
//  CustomAnnotationView.h
//  CustomAnnotationDemo
//
//  Created by songjian on 13-3-11.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "SOSMapHeader.h"
#import "SOSGeoCalloutView.h"

@interface CustomGeoAnnotationView : MAAnnotationView

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong, readwrite) SOSGeoCalloutView *calloutView;

@property (nonatomic, strong) UIImage *portrait;
@property(nonatomic, assign) CLLocationCoordinate2D location;

@end
