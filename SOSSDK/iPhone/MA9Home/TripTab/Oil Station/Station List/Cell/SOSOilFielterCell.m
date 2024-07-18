//
//  SOSOilFielterCell.m
//  Onstar
//
//  Created by Coir on 2019/8/30.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilFielterCell.h"

@interface SOSOilFielterCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *brandImgView;
@property (weak, nonatomic) IBOutlet UIImageView *flagImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingGuide;

@end

@implementation SOSOilFielterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.highlightedTextColor = [UIColor colorWithHexString:@"6896ED"];
}

- (void)setTitleStr:(NSString *)titleStr	{
    _titleStr = titleStr;
    self.titleLabel.text = titleStr;
}

- (void)setCellType:(SOSFielterCellType)cellType	{
    if (cellType == _cellType)		return;
    _cellType = cellType;
    switch (cellType) {
        // 默认配置,暂不需要更改
        case SOSFielterCellType_Oil_Station:
            break;
        case SOSFielterCellType_Dealer_Brand:
            self.brandImgView.hidden = NO;
            self.titleLabel.font = [UIFont systemFontOfSize:15.f];
            self.titleLabelLeadingGuide.constant = 44.f;
            [self layoutIfNeeded];
            break;
    }
}

- (void)setBrandType:(SOSDealerBrandType)brandType	{
    _brandType = brandType;
    NSString *brandImgName = [SOSOilFielterCell getBrandImageNameWithBrandType:brandType];
    NSString *brandName = [SOSOilFielterCell getBrandNameWithBrandType:brandType];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.brandImgView.hidden = !brandImgName.length;
        self.titleStr = brandName;
        self.brandImgView.image = [UIImage imageNamed:brandImgName];
        self.titleLabelLeadingGuide.constant = 16.f + (28 * !self.brandImgView.hidden );
        [self layoutIfNeeded];
    });
}

+ (NSString *)getBrandNameWithBrandType:(SOSDealerBrandType)brandType    {
    NSString *title = @"";
    switch (brandType) {
        case SOSDealerBrandType_All:
        case SOSDealerBrandType_Void:
            title = @"所有品牌";
            break;
        case SOSDealerBrandType_Buick:
            title = @"别克";
            break;
        case SOSDealerBrandType_Cadillac:
            title = @"凯迪拉克";
            break;
        case SOSDealerBrandType_Chevrolet:
            title = @"雪佛兰";
            break;
    }
    return title;
}

+ (NSString *)getBrandImageNameWithBrandType:(SOSDealerBrandType)brandType	{
    NSString *brandImgName = @"";
    switch (brandType) {
        case SOSDealerBrandType_All:
        case SOSDealerBrandType_Void:
            break;
        case SOSDealerBrandType_Buick:
            brandImgName = @"vehicletab_brand_BUICK";
            break;
        case SOSDealerBrandType_Cadillac:
            brandImgName = @"vehicletab_brand_CADILLAC";
            break;
        case SOSDealerBrandType_Chevrolet:
            brandImgName = @"vehicletab_brand_CHEVROLET";
            break;
        default:
            brandImgName = @"vehicletab_brand_fail";
            break;
    }
    return brandImgName;
}

- (void)setSelectedState:(BOOL)selectedState	{
    _selectedState = selectedState;
    self.titleLabel.highlighted = selectedState;
    self.flagImgView.hidden = !selectedState;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
