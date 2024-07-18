//
//  SOSGeoCalloutView.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoCalloutView.h"

@implementation SOSGeoCalloutView

- (void)configSelfwithLa:(NSString *)latitude longitude:(NSString *)longitude	{
    self.laLb.text = [NSString stringWithFormat:@"纬度：%.5f", latitude.floatValue];
    self.lonLb.text = [NSString stringWithFormat:@"经度：%.5f", longitude.floatValue];
}

@end
