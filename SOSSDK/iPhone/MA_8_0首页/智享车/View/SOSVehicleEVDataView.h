//
//  SOSVehicleEVDataView.h
//  Onstar
//
//  Created by TaoLiang on 2018/10/25.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSVehicleEVDataView : UIView
@property (weak, nonatomic) IBOutlet UILabel *label0;
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chargeStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *jumpButton;


- (void)refresh;
@end

NS_ASSUME_NONNULL_END
