//
//  SOSPDView.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseXibView.h"

@interface SOSPDView : SOSBaseXibView
@property (weak, nonatomic) IBOutlet UIImageView *LTImage;
@property (weak, nonatomic) IBOutlet UILabel *LTLB;

@property (weak, nonatomic) IBOutlet UIImageView *RTImage;
@property (weak, nonatomic) IBOutlet UILabel *RTLB;

@property (weak, nonatomic) IBOutlet UIImageView *LBImage;
@property (weak, nonatomic) IBOutlet UILabel *LBLB;

@property (weak, nonatomic) IBOutlet UIImageView *RBImage;
@property (weak, nonatomic) IBOutlet UILabel *RBLB;


@property (weak, nonatomic) IBOutlet UIImageView *LTTireImage;
@property (weak, nonatomic) IBOutlet UIImageView *RTTireImage;
@property (weak, nonatomic) IBOutlet UIImageView *LBTireImage;
@property (weak, nonatomic) IBOutlet UIImageView *RBTireImage;

@property (weak, nonatomic) IBOutlet UILabel *FrontTireLB;
@property (weak, nonatomic) IBOutlet UILabel *RearTireLB;

- (void)configView;

/**
 车辆检测报告刷新
 */
- (void)configViewForDectViewWidth:(NNOVDEmailDTO *)ovdEmail;


/*****************************My21车型********************/
- (void)suitMy21;
@property (weak, nonatomic) UILabel *topBrakeLabel;
@property (weak, nonatomic) UILabel *bottomBrakeLabel;
/**************************************/
@end
