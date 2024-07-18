//
//  SOSTripChargeDetailView.m
//  Onstar
//
//  Created by Coir on 2019/4/23.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripChargeDetailView.h"
#import "CollectionToolsOBJ.h"
#import "SOSAYChargeManager.h"
#import "SOSAMapSearchTool.h"
#import "NavigateShareTool.h"
#import "SOSNavigateTool.h"
#import "SOSTripRouteVC.h"

@interface SOSTripChargeDetailView ()

@property (weak, nonatomic) IBOutlet UIView *unNormalBGView;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *ayChargeButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quickChargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *slowChargeChargeLabel;
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;
@property (weak, nonatomic) IBOutlet UIView *ayChargeDetailBGView;

@property (weak, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *quickPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *slowPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *servicePriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingGuide;

@property (strong, nonatomic) SOSPOI *poi;

@end

@implementation SOSTripChargeDetailView

- (void)awakeFromNib    {
    [super awakeFromNib];
    __weak __typeof(self) weakSelf = self;
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        // // 用户登录成功
        if ([newValue isKindOfClass:[NSNumber class]]) {
            LOGIN_STATE_TYPE newState = [newValue intValue];
            switch (newState) {
                case LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS:    {
                    [weakSelf getCollectionState];
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

- (void)setStatus:(SOSChargeDetailViewStatus)status	{
    _status = status;
    BOOL isSuccess = NO;
    BOOL shouldReload = NO;
    NSString *imgName = nil;
    NSString *detailTitle = nil;
    switch (self.status) {
        case SOSChargeDetailViewStatus_Loading:
            imgName = @"Trip_LBS_List_Loading";
            detailTitle = @"";
            break;
        case SOSChargeDetailViewStatus_Fail:
            imgName = @"Trip_LBS_List_Reload";
            detailTitle = @"点击重新加载";
            shouldReload = YES;
            break;
        case SOSChargeDetailViewStatus_Empty:
            imgName = @"Trip_LBS_List_Reload";
            detailTitle = @"附近暂无可用充电桩";
            break;
        case SOSChargeDetailViewStatus_Success:
            isSuccess = YES;
            break;
        default:
            break;
    }
    dispatch_async_on_main_queue(^{
        if (isSuccess) {
            self.unNormalBGView.hidden = YES;
        }    else    {
            self.unNormalBGView.hidden = NO;
            self.reloadButton.userInteractionEnabled = shouldReload;
            self.statusImgView.image = [UIImage imageNamed:imgName];
            self.detailTextLabel.text = detailTitle;
        }
        status == SOSChargeDetailViewStatus_Loading ? [self.statusImgView startRotating] : [self.statusImgView endRotating];
    });
}

- (void)setChargeStationObj:(ChargeStationOBJ *)chargeStationObj	{
    _chargeStationObj = [chargeStationObj copy];
    [self getCollectionState];
    dispatch_async_on_main_queue(^{
        
        /// 品牌充电桩不返回可用桩数量
        if ([chargeStationObj.supplier isEqualToString:@"安悦充电"]) {
            
        }    else    {
            
        }
        
        self.stationNameLabel.text = chargeStationObj.stationName;
        self.addressLabel.text = chargeStationObj.address;
        NSString *distanceStr = chargeStationObj.distance;
        if ([distanceStr.lowercaseString containsString:@"km"]) {
            distanceStr = [distanceStr.lowercaseString stringByReplacingOccurrencesOfString:@"km" withString:@"公里"];
        }	else if ([distanceStr.lowercaseString containsString:@"m"]) {
            distanceStr = [distanceStr.lowercaseString stringByReplacingOccurrencesOfString:@"m" withString:@"米"];
        }
        self.distanceLabel.text = distanceStr;
        self.quickChargeLabel.textColor = [UIColor colorWithHexString:chargeStationObj.quickCharge.intValue ? @"6CCA46" : @"DDE8FF"];
        self.slowChargeChargeLabel.textColor = [UIColor colorWithHexString:chargeStationObj.slowCharge.intValue ? @"6CCA46" : @"DDE8FF"];
        self.quickChargeLabel.text = chargeStationObj.quickCharge.stringValue;
        self.slowChargeChargeLabel.text = chargeStationObj.slowCharge.stringValue;
        
        self.openTimeLabel.text = chargeStationObj.openTime ? : @"未知";
        self.quickPriceLabel.text = chargeStationObj.quickChargeCostFee ? : @"未知";
        self.slowPriceLabel.text = chargeStationObj.slowChargeCostFee ? : @"未知";
        self.servicePriceLabel.text = chargeStationObj.serveFee ? : @"未知";
    });
}

- (void)setIsAYChargeDetailMode:(BOOL)isAYChargeDetailMode	{
    _isAYChargeDetailMode = isAYChargeDetailMode;
    dispatch_async_on_main_queue(^{
        self.height = isAYChargeDetailMode ? 220 : 160;
        self.ayChargeButton.hidden = !isAYChargeDetailMode;
        self.ayChargeDetailBGView.hidden = !isAYChargeDetailMode;
        self.nameLabelTrailingGuide.constant = isAYChargeDetailMode ? 46 : 6;
    });
}

- (SOSPOI *)poi	{
    if (!_poi) 	 _poi = [self.chargeStationObj transToPoi];
    return _poi;
}

- (void)getCollectionState	{
    // 未登录状态不执行操作
    if (![[LoginManage sharedInstance] isLoadingUserBasicInfoReady])    return;
    [Util showHUD];
    [[SOSAMapSearchTool sharedInstance] getAMapIDWithPOI:self.poi Success:^(NSString * _Nonnull aMapID) {
        self.poi.pguid = aMapID;
        [[SOSAMapSearchTool sharedInstance] getCollectionStateWithPOI:self.poi Success:^(SOSPOICollectionState state, NSString *destinationID) {
            [Util dismissHUD];
            self.poi.collectionState = state;
            self.poi.destinationID = destinationID;
            dispatch_async_on_main_queue(^{
                self.collectionButton.selected = (state == SOSPOICollectionState_Collected);
            });
        } Failure:^{
            [Util dismissHUD];
            [Util toastWithMessage:@"获取收藏状态失败"];
        }];
    } Failure:^{
        [Util dismissHUD];
        [Util toastWithMessage:@"获取收藏状态失败"];
    }];
}

#pragma mark - Button Action
- (IBAction)ayChargeButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_anyocharging];
    [SOSAYChargeManager enterAYChargeVCIsFromCarLife:NO];
}

/// 分享
- (IBAction)shareButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_Share];
    [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:self.poi];
    [NavigateShareTool sharedInstance].shareToMomentsDaapID = Trip_GoWhere_AroundChargeStation_POIdetail_Share_WeChatMoments;
    [NavigateShareTool sharedInstance].shareToChatDaapID = Trip_GoWhere_AroundChargeStation_POIdetail_Share_WeChatFriends;
    [NavigateShareTool sharedInstance].shareCancelDaapID = Trip_GoWhere_AroundChargeStation_POIdetail_Share_Cancel;
}

/// 发送到车
- (IBAction)sendToCarButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SentToCar];
    [SOSNavigateTool sendToCarAutoWithPOI:self.poi];
}

/// 规划路线
- (IBAction)routeButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_GoHere];
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:[self.chargeStationObj transToPoi]];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

/// 收藏
- (IBAction)collectionButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_Favorite];
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self.viewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (finished) {
            switch (self.poi.collectionState) {
                case SOSPOICollectionState_Non:    {
                    [Util toastWithMessage:@"当前POI收藏状态未知,请稍候再试"];
                    return;
                }
                case SOSPOICollectionState_Collected:    {
                    [Util showHUD];
                    [CollectionToolsOBJ deleteCollectionWithDestinationID:self.poi.destinationID Success:^{
                        [Util dismissHUD];
                        self.poi.collectionState = SOSPOICollectionState_Not_Collected;
                        self.collectionButton.selected = NO;
                    } Failure:^{
                        [Util dismissHUD];
                        return;
                    }];
                    break;
                }
                case SOSPOICollectionState_Not_Collected:    {
                    if (![SOSCheckRoleUtil checkVisitorInPage:nil])        return;
                    [Util showHUD];
                    [CollectionToolsOBJ addCollectionFromVC:self.viewController WithPoi:self.poi NickName:self.poi.name Success:^(NSString *destinationID){
                        [Util dismissHUD];
                        self.poi.destinationID = destinationID;
                        self.poi.collectionState = SOSPOICollectionState_Collected;
                        self.collectionButton.selected = YES;
                    } Failure:^{
                        [Util dismissHUD];
                        return;
                    }];
                    break;
                }
            }
        }
    }];
}

/// 查看更多
- (IBAction)showMoreResults {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showMoreResultsWithStations:)]) {
        [self.delegate showMoreResultsWithStations:self.stationArray];
    }
}

/// 重新加载数据
- (IBAction)reloadData {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadButtonTapped)]) {
        [self.delegate reloadButtonTapped];
    }
}

- (void)dealloc		{
    [Util dismissHUD];
}

@end
