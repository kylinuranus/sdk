//
//  SOSLBSHistoryInfoBGView.m
//  Onstar
//
//  Created by Coir on 20/12/2017.
//  Copyright © 2017 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSHistoryInfoBGView.h"

@interface SOSLBSHistoryInfoBGView	()
@property (weak, nonatomic) IBOutlet UILabel *imeiLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationTimeLabel;

@end

@implementation SOSLBSHistoryInfoBGView

- (void)setHistoryPOI:(NNLBSLocationPOI *)historyPOI	{
    if (historyPOI == _historyPOI)         return;
    _historyPOI = historyPOI;
    self.imeiLabel.text = historyPOI.imei;
    self.speedLabel.text = [NSString stringWithFormat:@"速度：%.2fKm/h", historyPOI.s.floatValue];
    self.locationMethodLabel.text = [NSString stringWithFormat:@"定位方式：%@", (historyPOI.g.boolValue ? @"GPS" : @"LBS")];
    self.locationTimeLabel.text = [NSString stringWithFormat:@"定位时间: %@", historyPOI.pt];
}

@end
