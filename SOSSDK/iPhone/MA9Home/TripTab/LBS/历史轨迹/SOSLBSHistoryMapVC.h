//
//  SOSLBSHistoryMapVC.h
//  Onstar
//
//  Created by Coir on 28/11/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseMapVC.h"

@interface SOSLBSHistoryMapVC : SOSBaseMapVC

- (id)initWithPoiArray:(NSArray <NNLBSLocationPOI *> *)poiArray;

- (void)setUpWithDate:(NSString *)dateStr StartTime:(NSString *)startTime AndEndTime:(NSString *)endTime;

@end
