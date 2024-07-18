//
//  SOSVehicleLocationStatusView.m
//  Onstar
//
//  Created by Onstar on 2019/1/4.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleLocationStatusView.h"
#import "SOSRemoteTool.h"
#import "SOSCardUtil.h"
#import "UIImage+SOSSkin.h"
@interface SOSVehicleLocationStatusView(){
    UIImageView * icon ;
    UILabel * locationLabel;
    UILabel * timeLB;
    NSInteger actionType;
    BOOL recordDaap;
    NSTimeInterval startTime;
}

@end
@implementation SOSVehicleLocationStatusView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self addObserver];
    }
    return self;
}
-(void)initView{
    UIImage * ici;
    if (SOS_BUICK_PRODUCT) {
        ici = [UIImage imageNamed:@"vehicle_icon_location_sdkbuick"];
    }else{
       ici = [UIImage imageNamed:@"vehicle_icon_location"];
    }
    
    icon = [[UIImageView alloc] initWithImage:ici];
    [self addSubview:icon];
    
    locationLabel = [[UILabel alloc] init];
    locationLabel.userInteractionEnabled = YES;
    @weakify(self);
    [locationLabel setTapActionWithBlock:^{
        @strongify(self);
        if (actionType == 0) {
            [self findMyVehicle];
            [SOSDaapManager sendActionInfo:VEHICLE_GETLOCATION];

        }else{
            if (actionType == 1) {
                [self showVehicleLocation];
                [SOSDaapManager sendActionInfo:VEHICLE_CHECKLOCATION];
            }
        }
    }];
    [locationLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 12]];
    [locationLabel setTextColor:[UIColor colorWithHexString:@"#4E5059"]];
    [self addSubview:locationLabel];
   
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.top.mas_equalTo(self);
        
    }];
    [locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(icon);
        make.left.mas_equalTo(icon.mas_right).mas_offset(6);
        make.width.mas_equalTo(SCALE_WIDTH(158));
    }];

    SOSPOI *poi =  [[SOSRemoteTool sharedInstance] loadSavedVehicleLocation];
    if (poi && poi.isValidLocation) {
        [self refreshTitleWithGeoLocationStatus:RemoteControlStatus_OperateSuccess];
    }else{
        [self refreshTitleWithGeoLocationStatus:RemoteControlStatus_Void];
    }
}

-(void)refreshTitleWithGeoLocationStatus:(RemoteControlStatus)status{
    switch (status) {
        case RemoteControlStatus_Void:
            [self findMyVehicleInit];
            break;
        case RemoteControlStatus_InitSuccess:
            [self findMyVehicleInProgress];
            break;
        case RemoteControlStatus_OperateSuccess:
            [self findMyVehicleSuccess];
            break;
        case RemoteControlStatus_OperateFail:
        case RemoteControlStatus_OperateTimeout:
        {
            [self findMyVehicleFail];
        }
            break;
           
        default:
            break;
    }

}
-(void)addObserver{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        NSDictionary *info = noti.userInfo;
        if ([info[@"OperationType"] intValue] == SOSRemoteOperationType_VehicleLocation) {
            RemoteControlStatus status = [info[@"state"] intValue];
            [self refreshTitleWithGeoLocationStatus:status];
        }
    }];
}
-(void)findMyVehicle{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:SOSRemoteOperationType_VehicleLocation];
    recordDaap = YES;
    startTime = [[NSDate date] timeIntervalSince1970] ;
}
-(void)showVehicleLocation{
    [SOSCardUtil routerToVehicleLocationInMap];
}
- (void)findMyVehicleSuccess {
    if (recordDaap) {
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES funcId:VEHICLE_GETLOCATION_LOADTIME];
        recordDaap = NO;
    }
    SOSPOI *poi =  [[SOSRemoteTool sharedInstance] loadSavedVehicleLocation];
    
    [locationLabel setText:poi.address];
    if (!timeLB) {
        timeLB = [[UILabel alloc] init];
        timeLB.font = [UIFont fontWithName:@"PingFang-SC-Medium" size: 11];
        
        timeLB.textColor = [UIColor colorWithHexString:@"#A4A4A4"];
        [self addSubview:timeLB];
        [timeLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(locationLabel);
            make.top.mas_equalTo(locationLabel.mas_bottom);
        }];
    }
    timeLB.hidden = NO;
    NSString * time ;
    if ([poi.gapTime hasPrefix:@"刚"]) {
        time = [NSString stringWithFormat:@"%@", poi.gapTime];
    }else{
        time =[NSString stringWithFormat:@"更新于%@", poi.gapTime];
    }
    timeLB.text =time;
    [icon setImage:[UIImage sosSDK_imageNamed:@"vehicle_icon_success"]];
    actionType = 1;
}
-(void)findMyVehicleInit{
    [locationLabel setText:@"点击获取车辆位置"];
    if (SOS_BUICK_PRODUCT) {
        [icon setImage:[UIImage imageNamed:@"vehicle_icon_location_sdkbuick"]];
    }else{
        [icon setImage:[UIImage imageNamed:@"vehicle_icon_location"]];
    }
    
    if (timeLB) {
        timeLB.hidden = YES;
    }
    actionType = 0;
}
-(void)findMyVehicleInProgress{
    [locationLabel setText:@"获取中.."];
    if (SOS_BUICK_PRODUCT) {
        [icon setImage:[UIImage imageNamed:@"vehicle_icon_location_sdkbuick"]];
    }else{
        [icon setImage:[UIImage imageNamed:@"vehicle_icon_location"]];

    }
    if (timeLB) {
        timeLB.hidden = YES;
    }
    actionType = -1;
}
-(void)findMyVehicleFail{
    
    if (recordDaap) {
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO funcId:VEHICLE_GETLOCATION_LOADTIME];
        recordDaap = NO;
    }
    [locationLabel setText:@"点击重新获取定位"];
    [icon setImage:[UIImage imageNamed:@"vehicle_icon_relocation"]];
    if (timeLB) {
        timeLB.hidden = YES;
    }
    //UAT要求弹出框提示失败,defect 20833
    [Util showAlertWithTitle:@"获取车辆位置失败, 请稍后重试" message:nil completeBlock:NULL cancleButtonTitle:nil otherButtonTitles:@"知道了",nil];
    actionType = 0;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
