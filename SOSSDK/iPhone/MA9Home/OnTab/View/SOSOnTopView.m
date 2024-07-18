//
//  SOSOnTopView.m
//  Onstar
//
//  Created by onstar on 2019/2/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOnTopView.h"

@interface SOSOnTopView ()

@property (weak, nonatomic) IBOutlet UIImageView *carLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *carVinLabel;
@property (weak, nonatomic) IBOutlet UIView *carView;   //有车的
@end

@implementation SOSOnTopView

- (void)awakeFromNib {
    [super awakeFromNib];
    if (SOS_CD_PRODUCT) {
        [_carVinLabel setTextColor:[UIColor cadiStytle]];
    }
    if (SOS_BUICK_PRODUCT) {
        [_carVinLabel setTextColor:[UIColor whiteColor]];
        [_carVinLabel setTextAlignment:NSTextAlignmentCenter];
        UIImageView * imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sossdk_licenseplate_blue"]];
        [_carView insertSubview:imgV belowSubview:_carVinLabel];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_carVinLabel);
        }];
    }
    [self addObserver];
}

- (void)addObserver {
    @weakify(self);
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //退出登录or登录成功
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                //登陆成功
    //            if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS || [LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
                [self loadVehicleInfo];
    //            }
                if (![SOSCheckRoleUtil isVisitor]) {
                    
                    //LOGO
                    self.carLogoImageView.image = [SOSUtilConfig returnImageBySortOfCarbrand];
                    //title
    //                self.carVinLabel.text = [NSString stringWithFormat:@"%@",[[CustomerInfo sharedInstance] currentVehicle].modelDesc];
                    
                }
                
                //            self.helpButton.hidden = NO;
                if ([SOSCheckRoleUtil isOwner]) {
                    self.carView.hidden = NO;
                }else if ([SOSCheckRoleUtil isDriverOrProxy]){
                    self.carView.hidden = NO;
                  
                }else if ([SOSCheckRoleUtil isVisitor]) {
                    self.carView.hidden = YES;
                }
            }else if ([[LoginManage sharedInstance] isInLoadingMainInterface] || [[LoginManage sharedInstance] isLoadingMainInterfaceFail]) {
                //登录中 失败
                self.carView.hidden = YES;
            }else {
                //按未登录处理
                self.carView.hidden = YES;
            }
            
        });

      
        
    }];
    
}


#pragma mark - 加载车辆信息
- (void)loadVehicleInfo
{
    if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
        
    }else {
        return;
    }
    
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSLog(@"车辆信息responseStr:%@",responseStr);
            dispatch_async(dispatch_get_main_queue(), ^{
                NNVehicleInfoModel *vehicleInfo  =[NNVehicleInfoModel mj_objectWithKeyValues:responseStr];
                
                self.carVinLabel.text = vehicleInfo.licensePlate;
            });
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"GET"];
        [operation start];
        
    }
  
}

- (IBAction)exchangeVehicle:(id)sender {
    //切车
    !self.changeVehicleBlock?:self.changeVehicleBlock();
}

- (IBAction)carShareCenter:(id)sender {
    !self.shareCenterBlock?:self.shareCenterBlock();
}

@end
