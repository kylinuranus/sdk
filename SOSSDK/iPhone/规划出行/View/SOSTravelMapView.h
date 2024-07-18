//
//  SOSTravelMapView.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/4.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseXibView.h"

@interface SOSTravelMapView : SOSBaseXibView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconY;
@property (weak, nonatomic) IBOutlet UIImageView *smallIcon;
@property (weak, nonatomic) IBOutlet UILabel *DetailLb;
@property (weak, nonatomic) IBOutlet UILabel *fastNoLb;
@property (weak, nonatomic) IBOutlet UIButton *routeBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *ayChargeButton;
@property (weak, nonatomic) IBOutlet UILabel *ayChargeTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *navButton;
@property (weak, nonatomic) IBOutlet UILabel *shareTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeTieleLabel;
@property (weak, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *lowNoLb;
@property (weak, nonatomic) IBOutlet UILabel *fastLb;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *lowLb;
@property (weak, nonatomic) IBOutlet UIImageView *dragEnableFlagImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navButtonWidthGuide;

@property (weak, nonatomic) IBOutlet UILabel *idleFastNoLb;
@property (weak, nonatomic) IBOutlet UILabel *idleLowNoLb;

@property (weak, nonatomic) IBOutlet UIView *chargeDetailView;
@property (weak, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *quickChargeCostFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *slowChargeCostFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serveFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *supplierLabel;



@property(nonatomic, strong) SOSPOI *poiInfo;

- (void)configView:(MapType)mapType;

- (void)configSelfWithPoi:(SOSPOI *)poi;

@end
