//
//  SOSOnICMVehicleStatusCell.m
//  Onstar
//
//  Created by onstar on 2018/12/20.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSOnICMVehicleStatusCell.h"
#import "SOSICMVehicleStatusCCell.h"
#import "SOSVehicleInfoUtil.h"
#import "SOSDateFormatter.h"
#import "ServiceController.h"
#import "SOSOnMy21DoorStatusCell.h"
#import "UIImage+SOSSkin.h"
@interface SOSOnICMVehicleStatusCell ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *statusArray;

@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (nonatomic, strong) UIView *statusView;//加载中View
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, assign) BOOL holdingRefresh;//车辆状态hold状态
@end

@implementation SOSOnICMVehicleStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.titleArray = @[].mutableCopy;
    self.statusArray = @[].mutableCopy;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.statusButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    if (SOS_CD_PRODUCT) {
        [self.statusButton setImage:[UIImage imageNamed:@"Trip_User_Location_Card_Icon_Success_sdkcd"] forState:0];
    }else{
        [self.statusButton setImage:[UIImage imageNamed:@"Trip_User_Location_Card_Icon_Success"] forState:0];
    }
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SOSICMVehicleStatusCCell" bundle:nil] forCellWithReuseIdentifier:SOSICMVehicleStatusCCell.className];
    [_collectionView registerClass:SOSOnMy21DoorStatusCell.class forCellWithReuseIdentifier:SOSOnMy21DoorStatusCell.className];
    [RACObserve([CustomerInfo sharedInstance], icmVehicleRefreshState) subscribeNext:^(NSNumber*  _Nullable x) {
        if (x.integerValue == RemoteControlStatus_InitSuccess) {
            [self showLoadingStatus];
        }else if (x.integerValue == RemoteControlStatus_OperateFail){
             [self showFailStatus];
        }else  if (x.integerValue == RemoteControlStatus_OperateSuccess){
             [self showSuccessStatus];
        }
    }];
    
    
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
//        //        @{@"state":@(RemoteControlStatus_OperateFail), @"OperationType" : @(type)}
//        NSDictionary *notiDic = noti.userInfo;
//        RemoteControlStatus resultState = [notiDic[@"state"] intValue];
//        NSLog(@"xxx");
//        if (resultState == RemoteControlStatus_OperateFail || resultState == RemoteControlStatus_OperateSuccess) {
//            if (self.holdingRefresh) {
//                self.holdingRefresh = NO;
//                [self refresh];
//            }
//        }
//    }];
    [RACObserve([ServiceController sharedInstance], switcherLock) subscribeNext:^(NSNumber*  _Nullable x) {
        if (!x.boolValue) {
            if (self.holdingRefresh) {
                self.holdingRefresh = NO;
                [self refresh];
            }
        }
    }];
    
    
}
- (IBAction)statusButtonTap:(id)sender {
    
    [SOSDaapManager sendActionInfo:ON_ICMVEHICLESTATUS_CLICK_REFRESH];
    if ([[ServiceController sharedInstance] canPerformRequest:nil]) {
         [self refresh];
    }
   
}


- (void)refresh {

//    if ([CustomerInfo sharedInstance].icmVehicleRefreshState == RemoteControlStatus_InitSuccess && !self.holdingRefresh) {
//        return;
//    }
    
    if (self.holdingRefresh) {
        return;
    }
      [CustomerInfo sharedInstance].icmVehicleRefreshState = RemoteControlStatus_InitSuccess;
    if ([ServiceController sharedInstance].switcherLock && self.holdingRefresh == NO) {
        self.holdingRefresh = YES;
        return;
    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [SOSDaapManager sendActionInfo:REMOTECONTROL_DATAREFRESH];
     [SOSVehicleInfoUtil requestICM2VehicleInfoSuccess:nil Failure:nil];
//    });
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)statusView {
    if (!_statusView) {
        _statusView = [UIView new];
        _statusView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:_statusView];
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.collectionView);
        }];
        
        _statusLabel = [UILabel new];
        _statusLabel.text = @"车辆状态获取中..";
        _statusLabel.font = [UIFont systemFontOfSize:12];
        [_statusView addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_statusView);
        }];
    }
    return _statusView;
}


#pragma mark collectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SOSICM2ItemState state = [self.statusArray[indexPath.row] intValue];
    if (Util.vehicleIsMy21 && [self.titleArray[indexPath.row] isEqualToString:@"车门"]) {
        SOSOnMy21DoorStatusCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SOSOnMy21DoorStatusCell.className forIndexPath:indexPath];
        [cell configData:state];
        return cell;
    }
    SOSICMVehicleStatusCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SOSICMVehicleStatusCCell.className forIndexPath:indexPath];

    cell.titleLabel.text = self.titleArray[indexPath.row];
    NSString *imgName = @"Icon_22x22_OnStar_icon_car-parts-closing_22x22";
    switch (state) {
        case SOSICM2ItemState_Non:

            break;
        case SOSICM2ItemState_open:
            imgName = @"Icon_22x22_OnStar_icon_car-parts-closing_22x221";
            break;
            
        case SOSICM2ItemState_close:

            break;
            
        case SOSICM2ItemState_unNormal:
            //异常
            imgName = @"Icon／22x22／OnStar_icon_car-parts-closing_22x22";
            break;
        default:
            break;
    }
    cell.statusImageView.image = [UIImage sosSDK_imageNamed:imgName];
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kScreenWidth/self.titleArray.count-10, 90);
}


#pragma mark reloadData

- (void)reload {
    
    if (([Util vehicleIsICM2] || Util.vehicleIsMy21) &&
        ([SOSCheckRoleUtil isOwner] ||
         ([SOSCheckRoleUtil isDriverOrProxy] && [CustomerInfo sharedInstance].carSharingFlag))) {
            SOSICM2VehicleStatus *vehicleStatus = [SOSICM2VehicleStatus readSavedVehicleStatus];
            RemoteControlStatus status = [CustomerInfo sharedInstance].icmVehicleRefreshState;

            if (!vehicleStatus && status == RemoteControlStatus_Void) {
                [self refresh];
            }else {
//                [self showSuccessStatus];
                if (status == RemoteControlStatus_InitSuccess) {
                    [self showLoadingStatus];
                }else if (status == RemoteControlStatus_OperateFail){
                    [self showFailStatus];
                }else {
                    [self showSuccessStatus];
                }
            }
            self.contentView.hidden = NO;
        }else {
            self.contentView.hidden = YES;
        }
    
//    self.contentView.hidden = ![Util vehicleIsICM2] || ![CustomerInfo sharedInstance].carSharingFlag;
//
//    if ([Util vehicleIsICM2] && [CustomerInfo sharedInstance].carSharingFlag) {
//        SOSICM2VehicleStatus *vehicleStatus = [SOSICM2VehicleStatus readSavedVehicleStatus];
//        if (!vehicleStatus) {
//            [self refresh];
//        }else {
//            [self showSuccessStatus];
//        }
//    }
    
}


- (void)reloadCollectionViewData:(BOOL)defaultValue {
    [self.titleArray removeAllObjects];
    [self.statusArray removeAllObjects];
    SOSICM2VehicleStatus *vehicleStatus = [SOSICM2VehicleStatus readSavedVehicleStatus];
    //有数据 显示数据
    SOSVehicle *info = [CustomerInfo sharedInstance].currentVehicle;
    if (info.doorPositionSupport == YES) {
        [self.titleArray addObject:@"车门"];
        defaultValue?[self.statusArray addObject:@(SOSICM2ItemState_Non)]:[self.statusArray addObject:@(vehicleStatus.carDoorStatus)];
    }
    
    if (info.lightStateSupport == YES) {
        [self.titleArray addObject:@"大灯"];
        defaultValue?[self.statusArray addObject:@(SOSICM2ItemState_Non)]:[self.statusArray addObject:@(vehicleStatus.lightStatus)];
    }
    
    if (info.flashStateSupport == YES) {
        [self.titleArray addObject:@"警示灯"];
        defaultValue?[self.statusArray addObject:@(SOSICM2ItemState_Non)]:[self.statusArray addObject:@(vehicleStatus.flashStatus)];
    }
    
//    if (Util.vehicleIsMy21 && info.engineStateSupport) {
//        [self.titleArray addObject:@"发动机"];
//        defaultValue?[self.statusArray addObject:@(SOSICM2ItemState_Non)]:[self.statusArray addObject:@(vehicleStatus.engineStatus)];
//
//    }
    
    if (info.windowPositionSupport == YES) {
        [self.titleArray addObject:@"车窗"];
        defaultValue?[self.statusArray addObject:@(SOSICM2ItemState_Non)]:[self.statusArray addObject:@(vehicleStatus.windowPositionStatus)];
    }
    if (info.sunroofPositionSupport == YES) {
        [self.titleArray addObject:@"天窗"];
        defaultValue?[self.statusArray addObject:@(SOSICM2ItemState_Non)]:[self.statusArray addObject:@(vehicleStatus.sunroofPositionStatus)];
    }
    
    if (info.trunkPositionSupport == YES) {
        [self.titleArray addObject:@"后备箱"];
        defaultValue?[self.statusArray addObject:@(SOSICM2ItemState_Non)]:[self.statusArray addObject:@(vehicleStatus.trunkStatus)];
    }
    
    
    [self.collectionView reloadData];
}

- (void)showFailStatus {
    
    self.statusView.hidden = NO; //[SOSICM2VehicleStatus readSavedVehicleStatus]?YES: 
    
    _statusLabel.text = @"车辆状态信息获取失败,请刷新";
    _statusLabel.textColor = UIColorHex(#C50000);
    [self.statusButton setTitle:@"点击重新加载信息" forState:UIControlStateNormal];
    [self.statusButton setImage:[UIImage sosSDK_imageNamed:@"Icon／22x22／OnStar_icon_renew_22x22"] forState:(UIControlState)UIControlStateNormal];
    [SOSUtilConfig transformIdentityStatusWithView:self.statusButton.imageView];
}


- (void)showSuccessStatus {
    [SOSDaapManager sendActionInfo:ON_ICMVEHICLESTATUS_SUCCESS];
    _statusView.hidden = YES;
    
    SOSICM2VehicleStatus *vehicleStatus = [SOSICM2VehicleStatus readSavedVehicleStatus];
    NSDate *date = [NSDate dateWithString:vehicleStatus.completionTime format:@"yyyy-MM-dd HH:mm"];
    NSString *time = [SOSDateFormatter gapTimeStrFromNowWithDate:date];
    if ([time isEqualToString:@"刚刚"]) {
        time = @"刚刚更新";
    }else {
        time = [NSString stringWithFormat:@"更新于 %@", (vehicleStatus.completionTime.length ? [SOSDateFormatter gapTimeStrFromNowWithDate:date] : @"--")];
    }
    [self.statusButton setTitle:time forState:UIControlStateNormal];
    if (SOS_CD_PRODUCT) {
        [self.statusButton setImage:[UIImage imageNamed:@"Trip_User_Location_Card_Icon_Success_sdkcd"] forState:(UIControlState)UIControlStateNormal];
    }else{
        [self.statusButton setImage:[UIImage imageNamed:@"Trip_User_Location_Card_Icon_Success"] forState:(UIControlState)UIControlStateNormal];
    }
    [SOSUtilConfig transformIdentityStatusWithView:self.statusButton.imageView];
    [self reloadCollectionViewData:NO];
}

- (void)showLoadingStatus {
    SOSICM2VehicleStatus *vehicleStatus = [SOSICM2VehicleStatus readSavedVehicleStatus];
    if (vehicleStatus) {
        _statusView.hidden = YES;
        [self reloadCollectionViewData:YES];
    }else {
        self.statusView.hidden = NO;
        _statusLabel.text = @"车辆状态获取中..";
        _statusLabel.textColor = UIColorHex(#4E5059);
    }

    [self.statusButton setTitle:@"加载中.." forState:UIControlStateNormal];
    if (SOS_CD_PRODUCT) {
        [self.statusButton setImage:[UIImage imageNamed:@"Trip_User_Location_Card_Icon_Success_sdkcd"] forState:(UIControlState)UIControlStateNormal];
    }else{
        [self.statusButton setImage:[UIImage imageNamed:@"Trip_User_Location_Card_Icon_Success"] forState:(UIControlState)UIControlStateNormal];
    }
    dispatch_async_on_main_queue(^{
        [SOSUtilConfig transformRotationWithView:self.statusButton.imageView];
    });
}


@end
