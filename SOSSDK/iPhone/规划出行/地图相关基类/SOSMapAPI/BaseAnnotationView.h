//
//  BaseAnnotationView.h
//  Onstar
//
//  Created by Coir on 16/8/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSMapHeader.h"
#import "BaseCalloutView.h"

@interface BaseAnnotationView : MAAnnotationView

@property (nonatomic, readonly) BaseCalloutView *calloutView;
@property(nonatomic, strong) UIImageView *checkImageView;
@property(nonatomic, strong) UILabel *cityLB;
@property(nonatomic, strong) UILabel *footmarkLB;

@property (nonatomic, assign) POIType type;

@property (nonatomic, assign) BOOL isLBSMapMode;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSNumber *cityCount;

- (void)configView:(NSString *)cityName footInfoCount:(NSInteger)footCount;

@end
