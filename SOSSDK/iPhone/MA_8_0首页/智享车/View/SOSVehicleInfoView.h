//
//  SOSVehicleInfoView.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSVehicleInfoView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *carSeriesLB;
@property (weak, nonatomic) IBOutlet UILabel *yearLB;
@property (weak, nonatomic) IBOutlet UILabel *vinLB;
@property (weak, nonatomic) IBOutlet UIImageView *exmImageView;

- (void)refresh;

@end
