//
//  SOSGroupTripCalloutView.m
//  Onstar
//
//  Created by Coir on 2019/11/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGroupTripCalloutView.h"

@interface SOSGroupTripCalloutView ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation SOSGroupTripCalloutView

- (void)configSelfWithStatus:(SOSGroupTripTeamMemberStatus)status	{
    NSString *imgName = nil, *text = nil;
    switch (status) {
        case SOSGroupTripTeamMemberStatus_UnNormal:
            imgName = @"Group_Trip_POI_Callout_Yellow";
            text = @"车况异常";
            break;
        case SOSGroupTripTeamMemberStatus_OffLine:
            imgName = @"Group_Trip_POI_Callout_Gray";
            text = @"设备已离线";
            break;
        case SOSGroupTripTeamMemberStatus_Emergency:
            imgName = @"Group_Trip_POI_Callout_Red";
            text = @"按下了红键";
            break;
        default:
            break;
    }
    self.bgImgView.image = [UIImage imageNamed:imgName];
    self.contentLabel.text = text;
}

@end
