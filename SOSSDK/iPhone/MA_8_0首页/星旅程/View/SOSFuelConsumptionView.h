//
//  SOSFuelConsumptionView.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSFuelConsumptionView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

- (void)refreshWithResponseData:(id)responseData
                         status:(RemoteControlStatus)status
                         isFuel:(BOOL)isFuel;

@end
