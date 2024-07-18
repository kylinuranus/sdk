//
//  SOSGeoCenterAndRadiusView.m
//  Onstar
//
//  Created by Coir on 2019/6/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoCenterAndRadiusView.h"
#import "SOSGeoModifyAlertTypeVC.h"
#import "NavigateSearchVC.h"
#import "SOSGeoDataTool.h"

@interface SOSGeoCenterAndRadiusView ()

@property (weak, nonatomic) IBOutlet UILabel *geoCenterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *geoRadiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *geoRadiusMaxLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geoRadiusLeadingGuide;

@end

@implementation SOSGeoCenterAndRadiusView

- (void)awakeFromNib	{
    [super awakeFromNib];
    [self.geoRadiusSlider setThumbImage:[UIImage imageNamed:@"SOS_Switch_Open"] forState:UIControlStateNormal];
}

- (void)setGeofence:(NNGeoFence *)geofence	{
    _geofence = [geofence copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.geoRadiusSlider.value = geofence.range.floatValue;
        self.geoCenterNameLabel.text = geofence.centerPoiName;
        self.geoRadiusLabel.text = [NSString stringWithFormat:@"%.1fkm", self.geoRadiusSlider.value];
        if (geofence.isLBSMode) {
            self.geoRadiusMaxLabel.text = @"5km";
            self.geoRadiusSlider.maximumValue = 5.f;
        }	else	{
            self.geoRadiusMaxLabel.text = @"100km";
            self.geoRadiusSlider.maximumValue = 100.f;
        }
        if (self.width != SCREEN_WIDTH - 24) self.width = SCREEN_WIDTH - 24;
        [self updateGeoRadiusLabelPosition];
    });
}

// 返回
- (IBAction)backButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(geoCenterAndRadiusViewBackButtonTapped)]) {
        [self.delegate geoCenterAndRadiusViewBackButtonTapped];
    }
}

// 修改围栏中心点,进入搜索页面
- (IBAction)changeGeoCenter {
    NavigateSearchVC *vc = [NavigateSearchVC new];
    vc.fromGeoFecing = YES;
    vc.geoFence = _geofence;
    vc.operationType = OperationType_set_Geo_Center;
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.vc presentViewController:navVC animated:YES completion:nil];
    // 选定中心点之后,后续逻辑在 SOSGeoDataTool 中处理
    
}

// 围栏半径变更
- (IBAction)geofenceRadiusChanged:(UISlider *)sender 	{
    self.geoRadiusLabel.text = [NSString stringWithFormat:@"%.1fkm", self.geoRadiusSlider.value];
    [self updateGeoRadiusLabelPosition];
    self.geofence.range = @(self.geoRadiusSlider.value).stringValue;
    if (self.delegate && [self.delegate respondsToSelector:@selector(geoRadiusChangedWithGeofence:)]) {
        [self.delegate geoRadiusChangedWithGeofence:self.geofence];
    }
}

- (void)updateGeoRadiusLabelPosition	{
    UISlider *slider = self.geoRadiusSlider;
    float leading = slider.value / slider.maximumValue * (slider.width - 30) - self.geoRadiusLabel.width / 2 + 13.f;
    self.geoRadiusLeadingGuide.constant = leading;
    [self layoutIfNeeded];
}

// 保存
- (IBAction)saveButtonTapped 	{
    // 新建围栏时,到围栏信息卡片再上传服务器保存
    if (self.geofence.isNewToAdd) {
        if (self.isFirstCard) {
            SOSGeoModifyAlertTypeVC *vc = [SOSGeoModifyAlertTypeVC new];
            vc.geofence = self.geofence;
            vc.isFromOriginAddPage = YES;
            [self.viewController.navigationController pushViewController:vc animated:YES];
        }	else	{
            [self backButtonTapped];
        }
    }	else	{
    // 已有围栏,编辑时,立即上传服务器保存信息
        [Util showHUD];
        self.userInteractionEnabled = NO;
        [SOSGeoDataTool updateGeoFencingWithGeo:self.geofence Success:^(SOSNetworkOperation *operation, id responseStr) {
            [Util dismissHUD];
            [Util showSuccessHUDWithStatus:@"围栏更新成功"];
            self.userInteractionEnabled = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_CenterAndRadius), @"Geofence":[self.geofence copy], @"ShouldChangeLocal": @(YES)}];
            [self backButtonTapped];
        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util dismissHUD];
            self.userInteractionEnabled = YES;
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }];
    }
}

@end
