//
//  SOSGPSNavPointInfoView.h
//  Onstar
//
//  Created by onstar on 2018/4/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSGPSNavPointInfoView : UIView
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLocationLabel;

@end
