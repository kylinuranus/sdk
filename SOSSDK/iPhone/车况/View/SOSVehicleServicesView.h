//
//  SOSVehicleServicesView.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseXibView.h"

@interface SOSVehicleServicesView : SOSBaseXibView

@property (assign, nonatomic) BOOL evCarStyle;


@property (weak, nonatomic) IBOutlet UIImageView *imageView0;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView5;

@property (weak, nonatomic) IBOutlet UILabel *label0;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;


@property (weak, nonatomic) IBOutlet UIImageView *engineImgView;
@property (weak, nonatomic) IBOutlet UIImageView *drainageImgView;
@property (weak, nonatomic) IBOutlet UIImageView *airBagImgView;
@property (weak, nonatomic) IBOutlet UIImageView *stabiliTrakImgView;
@property (weak, nonatomic) IBOutlet UIImageView *absImgView;
@property (weak, nonatomic) IBOutlet UIImageView *onStarImgView;


- (void)switchToEVStyle;
- (void)configViewForDectViewWith:(NNOVDEmailDTO *)ovdEmail;

@end
