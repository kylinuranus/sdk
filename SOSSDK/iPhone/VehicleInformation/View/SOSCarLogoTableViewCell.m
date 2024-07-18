//
//  SOSCarLogoTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarLogoTableViewCell.h"
#import "SOSGreetingManager.h"
#import "SOSAvatarManager.h"
#import "SOSCardUtil.h"


@interface SOSCarLogoTableViewCell ()
@property (strong, nonatomic) UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *wifiBtn;
@property (weak, nonatomic) IBOutlet UIImageView *wifiArraw;

@end

@implementation SOSCarLogoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    BOOL shouldHideWifi = !(([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) &&
    ![Util isLoadUserProfileFailure] &&
    [CustomerInfo sharedInstance].currentVehicle.wifiSupported &&
    ![Util vehicleIsIcm]);
    _wifiBtn.hidden = shouldHideWifi;
    _wifiArraw.hidden = shouldHideWifi;
    
    self.contentView.backgroundColor = SOSUtil.onstarLightGray;
    _carImageView = UIImageView.new;
    _carImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_carImageView];
    [self.contentView sendSubviewToBack:_carImageView];
    [_carImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(272, 120));
    }];

//    [self refreshHeadInfo];
}

- (void)refreshData {
    if (SOSCheckRoleUtil.isOwner || SOSCheckRoleUtil.isDriverOrProxy) {
        [[SOSAvatarManager sharedInstance] fetchVehicleAvatar:SOSVehicleAvatarTypeOther avatarBlock:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
            self.carImageView.image = avatar;
        }];
        
        NSString *licensePlate = (!IsStrEmpty(UserDefaults_Get_Object(@"CarInfoTypeLicenseNum")))?UserDefaults_Get_Object(@"CarInfoTypeLicenseNum"):@"";
        if (licensePlate.length > 2) {
            
            NSMutableString *temp = [[NSMutableString alloc] initWithString:licensePlate];
            [temp insertString:@"·" atIndex:2];
            licensePlate = temp.copy;
        }
        [_switchBtn setTitle:licensePlate.length > 0? licensePlate : @"设置车牌号" forState:UIControlStateNormal];
        //9.4UI需求且确认modelDesc是品牌+型号的格式, 并要求拆分ModelDesc.
        NSString *modelDesc = CustomerInfo.sharedInstance.currentVehicle.modelDesc.copy;
        NSMutableArray<NSString *> *temp = [modelDesc componentsSeparatedByString:@" "].mutableCopy;
        _title.text = temp.firstObject;
        NSString *year = CustomerInfo.sharedInstance.currentVehicle.year ? : @"";
        if (temp.count > 1) {
            NSString *desc;
            if (temp.count == 2) {
                desc = temp[1];
            }else {
                NSMutableString *tempDesc = @"".mutableCopy;
                for (int i=1; i<temp.count; i++) {
                    [tempDesc appendString:temp[i]];
                    if (i < temp.count) {
                        [tempDesc appendString:@" "];
                    }
                }
                desc = tempDesc.copy;
            }

            
            _infoLb.text = [NSString stringWithFormat:@"%@款 %@", year, desc?:@""];
        }
        self.carLogoImageView.image = self.carBrand;
    }
}


- (UIImage *)carBrand {
    if ([Util vehicleIsBuick]) {
        return [UIImage imageNamed:@"brand_buick_70x70"];
    }else if ([Util vehicleIsCadillac])
    {
        return [UIImage imageNamed:@"brand_cadillac_70x70"];
    }else if ([Util vehicleIsChevrolet])
    {
        return [UIImage imageNamed:@"brand_chevrolet_70x70"];
    }
    return [UIImage imageNamed:@"brand_fail_70x70"];
}
//- (void)refreshHeadInfo {
//
//    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
//        [[SOSAvatarManager sharedInstance] fetchVehicleAvatar:SOSVehicleAvatarTypeOther avatarBlock:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
//            self.carImageView.image = avatar;
//        }];
//    }
//
//    NSString *licensePlate = (!IsStrEmpty(UserDefaults_Get_Object(@"CarInfoTypeLicenseNum")))?UserDefaults_Get_Object(@"CarInfoTypeLicenseNum"):@"";
//    if (licensePlate.length > 2) {
//
//        NSMutableString *temp = [[NSMutableString alloc] initWithString:licensePlate];
//        [temp insertString:@"·" atIndex:2];
//        licensePlate = temp.copy;
//    }
//    [_switchBtn setTitle:licensePlate forState:UIControlStateNormal];
//
//    @weakify(self);
//    [RACObserve([SOSGreetingManager shareInstance], roleGreeting) subscribeNext:^(id x) {
//        @strongify(self);
//        if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
//            if ([x isKindOfClass:[NSDictionary class]] ) {
//                [self refreshWithStatus:RemoteControlStatus_OperateSuccess];
//            }else if(([x isEqual:@NO]) ) {
//                [self refreshWithStatus:RemoteControlStatus_OperateFail];
//            }else {
//                [self refreshWithStatus:RemoteControlStatus_InitSuccess];
//            }
//        }else {
//            [self refreshWithStatus:RemoteControlStatus_OperateFail];
//        }
//    }];
//}
//
//- (void)refreshWithStatus:(RemoteControlStatus)status {
//    dispatch_async(dispatch_get_main_queue(), ^{
////        switch (status) {
////            case RemoteControlStatus_OperateSuccess:
////            case RemoteControlStatus_OperateFail:	{
////                SOSGreetingModel *model = [[SOSGreetingManager shareInstance] getGreetingModelWithType:SOSGreetingTypeVehicleInfo];
////                if (![model.subGreetings containsString:@"#VEHICLEMODEL#"]) {
////                    self.title.text = @"数据加载失败";
////                    self.infoLb.text = @"";
//////                    self.carLogoImageView.image = [UIImage imageNamed:@"icon_placeholder_Empty"];
//////                    self.carLogoImageView.contentMode = UIViewContentModeCenter;
////                    return;
////                }	else	{
////                    SOSVehicle *vehic = CustomerInfo.sharedInstance.currentVehicle;
////                    self.title.text = model.greetings;
////                    self.infoLb.text = [model.subGreetings stringByReplacingOccurrencesOfString:@"#VEHICLEMODEL#" withString:[[CustomerInfo sharedInstance] currentVehicle].modelDesc?:@""];
////
////                }
////                break;
////            }
////
////            case RemoteControlStatus_InitSuccess:
////                self.title.text = @"读取中...";
////                self.infoLb.text = @"读取中...";
////                //            self.headInfoView.btn.hidden = YES;
////                break;
////            default:
////                break;
////        }
////        self.carLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
//        NSString *modelDesc = CustomerInfo.sharedInstance.currentVehicle.modelDesc.copy;
//        NSArray<NSString *> *temp = [modelDesc componentsSeparatedByString:@" "];
//        _title.text = temp.firstObject;
//
//        NSString *year = CustomerInfo.sharedInstance.currentVehicle.year ? : @"";
//        if (temp.count > 1) {
//            _infoLb.text = [NSString stringWithFormat:@"%@ %@", temp[1], year];
//        }
//        self.carLogoImageView.image = [SOSUtilConfig returnImageBySortOfCarbrand];
//    });
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)toWifi:(id)sender {
    [_delegate respondsToSelector:@selector(logoCell:didPressWifiBtn:)] ? [_delegate logoCell:self didPressWifiBtn:sender] : nil;

}

- (IBAction)toSwitchCar:(id)sender {
    [_delegate respondsToSelector:@selector(logoCell:didPressSwitchCarBtn:)] ? [_delegate logoCell:self didPressSwitchCarBtn:sender] : nil;
}


@end
