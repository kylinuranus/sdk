//
//  SOSTravelMapView.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/4.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSTravelMapView.h"
#import "NavigateShareTool.h"

@implementation SOSTravelMapView

- (void)awakeFromNib    {
    [super awakeFromNib];
    self.navButtonWidthGuide.constant = 0;
//    self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    
//    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self);
//    }];
    
    
//    [SOSUtilConfig setView:self.bgView RoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:CGSizeMake(10, 10)];
}

- (void)setPoiInfo:(SOSPOI *)poiInfo    {
    _poiInfo = poiInfo;
    [self configSelfWithPoi:poiInfo];
}

- (void)configSelfWithPoi:(SOSPOI *)poi     {
    NSString *poiIconImgNameString = @"";
    NSString *routeButtonImgNameStr = @"";
    NSString *routeTitleStr = @"";
    switch (poi.sosPoiType) {
        case POI_TYPE_CURRENT_LOCATION:
            routeTitleStr = @"去这里";
            poiIconImgNameString = @"icon_map_location_green";
            routeButtonImgNameStr = @"icon_travel_map_destination";
            break;
        case POI_TYPE_VEHICLE_LOCATION:
            routeTitleStr = @"步行规划";
            poiIconImgNameString = poi.annotationImgName;
            routeButtonImgNameStr = @"LBS_icon_travel_map_panel_edit_passion_blue50x50";
            break;
        case POI_TYPE_ROUTE_END:
            routeTitleStr = @"车辆遥控";
            poiIconImgNameString = poi.annotationImgName;
            routeButtonImgNameStr = @"icon_Route_Car_Remote";
            break;
        case POI_TYPE_LBS:
            routeTitleStr = @"历史轨迹";
            poiIconImgNameString = poi.annotationImgName;
            routeButtonImgNameStr = @"LBS_icon_travel_map_panel_edit_passion_blue50x50";
            break;
        case POI_TYPE_ChargeStation:
            self.titleLabelHeightGuide.constant = 20;
            self.titleLb.numberOfLines = 1;
        default:
            routeTitleStr = @"去这里";
            poiIconImgNameString = poi.annotationImgName;
            routeButtonImgNameStr = @"icon_travel_map_destination";
            break;
    }
    self.routeTieleLabel.text = routeTitleStr;
    UIImage *image = [UIImage imageNamed:routeButtonImgNameStr];
    [self.routeBtn setImage:image forState:UIControlStateNormal];
    [self.routeBtn setImage:image forState:UIControlStateHighlighted];
    [self.routeBtn setImage:image forState:UIControlStateSelected];
    self.smallIcon.image = [UIImage imageNamed:poiIconImgNameString];
    self.titleLb.text = poi.name;
    self.DetailLb.text = poi.address;
}

- (IBAction)shareButtonTapped {
    if (self.poiInfo) {
        [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_sharelocation];
        [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:self.poiInfo];
    }
}

- (void)configView:(MapType)mapType    {
//    dispatch_async(dispatch_get_main_queue(), ^{
        switch (mapType) {
            case MapTypeShowPoiPoint:
                self.smallIcon.image = [UIImage imageNamed:@"icon_travel_navigation_destination"];
                [self.routeBtn setImage:[UIImage imageNamed:@"icon_flag"] forState:UIControlStateNormal];
                self.titleLb.text = self.poiInfo.name;
                self.DetailLb.text = self.poiInfo.address;
                self.titleLabelTrailingGuide.constant = 10;
                self.shareTitleLabel.hidden = YES;
                self.shareButton.hidden = YES;
                break;
            case MapTypeLBSCurrentLocation:
                self.dragEnableFlagImgView.highlightedImage = [UIImage imageNamed:@"nav_slider_down_35x10"];
                self.dragEnableFlagImgView.image = [UIImage imageNamed:@"nav_slider_top_35x10"];
                self.smallIcon.image = [UIImage imageNamed:@"LBS_icon_travel_map_lbs_tracking25x25"];
                [self.routeBtn setImage:[UIImage imageNamed:@"LBS_icon_travel_map_panel_edit_passion_blue50x50"] forState:UIControlStateNormal];
                self.DetailLb.text = self.poiInfo.address;
                self.titleLb.text = self.poiInfo.name;
                self.titleLabelTrailingGuide.constant = 60;
                self.shareTitleLabel.hidden = NO;
                self.shareButton.hidden = NO;
                break;
            case MapTypeLBSUserLocation:
                self.smallIcon.image = [UIImage imageNamed:@"icon_dealer_shadow_enegy_green"];
                break;
            default:
                break;
        }
//    });
}

@end
