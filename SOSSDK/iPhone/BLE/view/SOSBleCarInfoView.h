//
//  SOSBleCarInfoView.h
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSBleCarInfoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *carLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UILabel *carTypeLabel;

- (void)showOwnerCarInfo;

@end
