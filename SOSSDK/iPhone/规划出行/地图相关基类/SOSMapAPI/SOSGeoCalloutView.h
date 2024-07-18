//
//  SOSGeoCalloutView.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMapHeader.h"

@interface SOSGeoCalloutView : UIView
@property (weak, nonatomic) IBOutlet UILabel *laLb;
@property (weak, nonatomic) IBOutlet UILabel *lonLb;

- (void)configSelfwithLa:(NSString *)latitude longitude:(NSString *)longitude;

@end
