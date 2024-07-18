//
//  SOSActionNavigation.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSActionNavigation.h"
#import "CarOperationWaitingVC.h"

@interface SOSActionNavigation ()     {
    
    __weak IBOutlet NSLayoutConstraint *tbtButtonWidthGuide;
    
}
@end

@implementation SOSActionNavigation

- (void)awakeFromNib    {
    [super awakeFromNib];
    if (self.poi.sosPoiType == POI_TYPE_Home || self.poi.sosPoiType == POI_TYPE_Company)  {
        _TBTBtn.hidden = YES;
        _ODDBtn.hidden = YES;
        _ensureButton.hidden = NO;
        return;
    }
    if ([CustomerInfo sharedInstance].currentVehicle.sendToNAVSupport && [CustomerInfo sharedInstance].currentVehicle.sendToTBTSupported) {
        tbtButtonWidthGuide.constant = SCREEN_WIDTH / 2;
    }else{
        if ([CustomerInfo sharedInstance].currentVehicle.sendToNAVSupport) {
            tbtButtonWidthGuide.constant = 0;
        }else{
            if ([CustomerInfo sharedInstance].currentVehicle.sendToTBTSupported) {
                tbtButtonWidthGuide.constant = SCREEN_WIDTH + 1;
            }else{
                _TBTBtn.hidden = YES;
                _ODDBtn.hidden = YES;
            }
        }
        
    }
    
}

- (void)setPoi:(SOSPOI *)poi    {
    _poi = poi;
    if (poi.sosPoiType == POI_TYPE_Home || self.poi.sosPoiType == POI_TYPE_Company) {
        _TBTBtn.hidden = YES;
        _ODDBtn.hidden = YES;
        _ensureButton.hidden = NO;
    }
}

- (IBAction)TBT:(id)sender {
    if (self.poi.sosPoiType == POI_TYPE_LBS) {
        [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_TBT];
    }   else    {
        [SOSDaapManager sendActionInfo:Map_POIdetail_TBT];
    }
    CarOperationWaitingVC *vc = [CarOperationWaitingVC initWithPoi:self.poi Type:OrderTypeTBT FromVC:self.viewController];
    [vc checkAndShowFromVC:self.viewController];
}

- (IBAction)ODD:(id)sender {
    if (self.poi.sosPoiType == POI_TYPE_LBS) {
        [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_ODD];
    }   else    {
        [SOSDaapManager sendActionInfo:Map_POIdetail_odd];
    }
    //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_ODD];
    CarOperationWaitingVC *vc = [CarOperationWaitingVC initWithPoi:self.poi Type:OrderTypeODD FromVC:self.viewController];
    [vc checkAndShowFromVC:self.viewController];
}

@end
