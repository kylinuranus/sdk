//
//  SOSStationDetailPriceInfoCell.m
//  Onstar
//
//  Created by Coir on 2019/8/30.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSStationDetailPriceInfoCell.h"

@interface SOSStationDetailPriceInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *gasNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *gasPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@end

@implementation SOSStationDetailPriceInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setStation:(SOSOilStation *)station	{
    _station = [station copy];
    dispatch_async_on_main_queue(^{
        self.gasNameLabel.text = [NSString stringWithFormat:@"%@汽油", station.oilName];
        self.gasPriceLabel.text = [NSString stringWithFormat:@"%.2f元/升起", station.priceYfq.floatValue];
        float discount = station.priceOfficial.floatValue - station.priceYfq.floatValue;
        self.discountLabel.text = [NSString stringWithFormat:@"降%.2f元", discount > 0 ? discount : 0];
        
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
