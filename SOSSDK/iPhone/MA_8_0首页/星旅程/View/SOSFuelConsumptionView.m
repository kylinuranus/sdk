//
//  SOSFuelConsumptionView.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSFuelConsumptionView.h"
#import "SOSCellStatusView.h"
#import "Masonry.h"

@interface SOSFuelConsumptionView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIImageView *exampleImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelCenterY;

@end

@implementation SOSFuelConsumptionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    [SOSUtilConfig setView:self.bgView RoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight withRadius:CGSizeMake(10, 10)];
}


- (void)refreshWithResponseData:(id)responseData
                         status:(RemoteControlStatus)status
                         isFuel:(BOOL)isFuel{
    
    if (status == RemoteControlStatus_OperateSuccess) {
        if ([responseData isKindOfClass:[NNOilRankResp class]]) {
            responseData = (NNOilRankResp *)responseData;
            
            if ([responseData recentUseFlag]) {
                self.numLabel.text = [responseData fuelRatio];
                self.infoLabel.text = [responseData rankMsg];
                self.exampleImage.hidden = ![[responseData mockFlag] boolValue];
                self.infoLabelCenterY.constant = 0;
                self.titleLabel.text = @"";
            }else {
                self.numLabel.text = @"--";
                self.infoLabel.text = @"看看您的\n油耗水平如何";
                self.exampleImage.hidden = YES;
                self.infoLabelCenterY.constant = 10;
                self.titleLabel.text = @"快来驾驶";
            }
           self.bgView.image = [UIImage imageNamed:@"tile_bg1"];
            
        }else if ([responseData isKindOfClass:[NNEngrgyRankResp class]]) {
            responseData = (NNEngrgyRankResp *)responseData;
            if ([responseData recentUseFlag]) {
                self.numLabel.text = [responseData costRatio];
                self.infoLabel.text = [responseData rankMsg];
                self.titleLabel.text = [responseData rankMsgTitle];
                self.exampleImage.hidden = ![[responseData mockFlag] boolValue];
                self.infoLabelCenterY.constant = 10;
                self.bgView.image = [[responseData mockFlag] boolValue]?[UIImage imageNamed:@"tile_bg_4_355x140"]:[UIImage imageNamed:@"tile_bg_1_355x140"];
            }else {
                self.numLabel.text = @"--";
                self.infoLabel.text = @"看看您的\n能耗水平如何";
                self.exampleImage.hidden = YES;
                self.infoLabelCenterY.constant = 10;
                self.titleLabel.text = @"快来驾驶";
                self.bgView.image = [UIImage imageNamed:@"tile_bg_2_355x140"];
            }
            
        }
    }else if (status == RemoteControlStatus_InitSuccess) {
        self.numLabel.text = @"--";
        self.infoLabel.text = @"读取中...";
        self.exampleImage.hidden = YES;
        self.titleLabel.text = @"";
        self.infoLabelCenterY.constant = 0;
         if (isFuel) {
             self.bgView.image = [UIImage imageNamed:@"tile_bg1"];
         }else {
             self.bgView.image = [UIImage imageNamed:@"tile_bg_3_355x140"];
         }
    }
    
  
   

}


@end
