//
//  SOSTripDealerCell.m
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripDealerCell.h"
#import "SOSOilFielterCell.h"

@interface SOSTripDealerCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;

@property (weak, nonatomic) IBOutlet UIView *phoneNumBGView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;

@property (weak, nonatomic) IBOutlet UIView *oilStationInfoBGView;
@property (weak, nonatomic) IBOutlet SOSCustomLB *stationTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *oilPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountPriceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *brandImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingGuide;


@end

@implementation SOSTripDealerCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setCellType:(SOSTripCellType)cellType	{
    _cellType = cellType;
    dispatch_async_on_main_queue(^{
        switch (cellType) {
            case SOSTripCellType_AMap_Oil_Station:
                self.phoneNumBGView.hidden = NO;
                self.brandImgView.hidden = YES;
                self.oilStationInfoBGView.hidden = YES;
                self.nameLabelLeadingGuide.constant = 14.f;
                break;
            case SOSTripCellType_SOS_Oil_Station:
                self.phoneNumBGView.hidden = YES;
                self.brandImgView.hidden = YES;
                self.oilStationInfoBGView.hidden = NO;
                self.nameLabelLeadingGuide.constant = 14.f;
                break;
            case SOSTripCellType_Dealer:
            case SOSTripCellType_Dealer_ALl:
            self.phoneNumBGView.hidden = NO;
            self.oilStationInfoBGView.hidden = YES;
                self.brandImgView.hidden = (cellType == SOSTripCellType_Dealer);
                self.nameLabelLeadingGuide.constant = (cellType == SOSTripCellType_Dealer) ? 14 : 42;
                break;
            default:
                break;
        }
    });
}

- (void)setDealer:(NNDealers *)dealer	{
    _dealer = [dealer copy];
    dispatch_async_on_main_queue(^{
        self.nameLabel.text = dealer.dealerName;
        self.addressLabel.text = dealer.address;
        self.phoneNumLabel.text = dealer.telephone;
        if (@(dealer.distance).stringValue.length) {
            self.distanceLabel.text = [NSString stringWithFormat:@"%.1f", @(dealer.distance).floatValue];
            self.distanceUnitLabel.text = @"公里";
        }	else	{
            self.distanceLabel.text = @"--";
            self.distanceUnitLabel.text = nil;
        }
        NSString *imgName = [SOSOilFielterCell getBrandImageNameWithBrandType:dealer.brandCode.intValue];
        imgName = imgName.length ? imgName : @"vehicletab_brand_fail";
        self.brandImgView.image = [UIImage imageNamed:imgName];
    });
}

- (void)setOilStation:(SOSOilStation *)oilStation	{
    _oilStation = oilStation;
    dispatch_async_on_main_queue(^{
        self.nameLabel.text = oilStation.gasName;
        self.addressLabel.text = oilStation.gasAddress;
        self.oilPriceLabel.text = [NSString stringWithFormat:@"%.2f", oilStation.priceYfq.floatValue];
        float discount = oilStation.priceOfficial.floatValue - oilStation.priceYfq.floatValue;
        self.discountPriceLabel.text = [NSString stringWithFormat:@"降%.2f 元", discount > 0 ? discount : 0];
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f", oilStation.distance];
        self.distanceUnitLabel.text = @"公里";
        
        NSString *stationType = @"其它";
        //油站类型（1 中石油，2 中石化，3 壳牌，4 其他）
        switch (oilStation.gasType.intValue) {
            case 1:
                stationType = @"中石油";
                break;
            case 2:
                stationType = @"中石化";
                break;
            case 3:
                stationType = @"壳牌";
                break;
            default:
                break;
        }
        self.stationTypeLabel.text = [NSString stringWithFormat:@"  %@  ", stationType];
    });
    
}

- (void)setPoi:(SOSPOI *)poi	{
    _poi = [poi copy];
    dispatch_async_on_main_queue(^{
        self.nameLabel.text = poi.name;
        self.addressLabel.text = poi.address;
        self.phoneNumLabel.text = poi.tel;
        if (poi.distance.length) {
            self.distanceLabel.text = poi.formatDistance;
            self.distanceUnitLabel.text = poi.distanceUnit;
        }    else    {
            self.distanceLabel.text = @"--";
            self.distanceUnitLabel.text = nil;
        }
    });
}

- (IBAction)phoneButtonTapped {
    if (self.dealer) {
        if (self.dealer.isPreferredDealer) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore_PreferDealerTab_Call];
        }    else    {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore_AroundPreferDealerTab_Call];
        }
    }	else if (self.poi)	{
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_SeeMore_AroundGasSationList_Call];
    }
    [SOSUtil callPhoneNumber:self.phoneNumLabel.text];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
