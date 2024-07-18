//
//  SOSPlantripView.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

@interface SOSPlantripView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLB;
@property (weak, nonatomic) IBOutlet SOSCustomBtn *refreshBtn;


@property (weak, nonatomic) IBOutlet UILabel *carLocationLb;
@property (weak, nonatomic) IBOutlet UILabel *adressLB;
@property (weak, nonatomic) IBOutlet UILabel *timeLB;

- (void)findMyVehicleSuccess;


@end
