//
//  SOSTirpUserLocationView.m
//  Onstar
//
//  Created by Coir on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTirpUserLocationView.h"
#import "CollectionToolsOBJ.h"
#import "SOSAMapSearchTool.h"
#import "NavigateShareTool.h"
#import "SOSAroundSearchVC.h"

@interface SOSTirpUserLocationView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *collectionFlagImgView;
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;
@property (weak, nonatomic) IBOutlet UIButton *aroundSearchButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *successRenewButton;
@property (weak, nonatomic) IBOutlet UIButton *failureRenewButton;

@end

@implementation SOSTirpUserLocationView

- (void)awakeFromNib    {
    [super awakeFromNib];
    __weak __typeof(self) weakSelf = self;
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        // 用户登录成功
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

- (void)setCardStatus:(SOSUserLocationCardStatus)cardStatus		{
    if (_cardStatus == cardStatus)		return;
    else	{
        _cardStatus = cardStatus;
        dispatch_async_on_main_queue(^{
            [self configSelfWithCardStatus];
        });
    }
}

- (void)configSelfWithCardStatus	{
    NSString *imgName = nil;
    BOOL loadDataError = NO;
    BOOL loadDataSuccess = NO;
    switch (self.cardStatus) {
        case SOSUserLocationCardStatus_loading:
            imgName = @"Trip_User_Location_Card_Icon_Loading";
            [self.titleButton setTitleForNormalState:@"获取中.."];
            self.addressLabel.text = @"";
            break;
        case SOSUserLocationCardStatus_fail:
            imgName = @"Trip_User_Location_Card_Icon_Fail";
            [self.titleButton setTitleForNormalState:@"点击重新获取定位"];
            self.addressLabel.text = @"";
            loadDataError = YES;
            break;
        case SOSUserLocationCardStatus_success:
            loadDataSuccess = YES;
            imgName = @"Trip_User_Location_Card_Icon_Success";
            [self.titleButton setTitleForNormalState:@""];
            break;
        default:
            break;
    }
    self.iconImgView.image = [UIImage imageNamed:imgName];
    self.shareButton.userInteractionEnabled = loadDataSuccess;
    self.collectionButton.userInteractionEnabled = loadDataSuccess;
    self.aroundSearchButton.userInteractionEnabled = loadDataSuccess;
    
    self.titleButton.userInteractionEnabled = loadDataError;
    self.failureRenewButton.userInteractionEnabled = loadDataError;
    self.successRenewButton.userInteractionEnabled = loadDataSuccess;
}

- (void)setUserLocationPOI:(SOSPOI *)userLocationPOI	{
    _userLocationPOI = [userLocationPOI copy];
    
    dispatch_async_on_main_queue(^{
        self.cardStatus = SOSUserLocationCardStatus_success;
        [self.titleButton setTitleForNormalState:userLocationPOI.name];
        self.addressLabel.text = userLocationPOI.address;
    });
    [self refreshTimeLabel];
    [self getCollectionState];
}

- (void)getCollectionState	{
    if (self.userLocationPOI == nil)	return;
    // 未登录状态不执行操作
    if (![[LoginManage sharedInstance] isLoadingUserBasicInfoReady])    return;
    if (self.userLocationPOI.collectionState) 	return;
    [Util showHUD];
    [[SOSAMapSearchTool sharedInstance] getAMapIDWithPOI:self.userLocationPOI Success:^(NSString * _Nonnull aMapID) {
        self.userLocationPOI.pguid = aMapID;
        [[SOSAMapSearchTool sharedInstance] getCollectionStateWithPOI:self.userLocationPOI Success:^(SOSPOICollectionState collectionState, NSString *destinationID) {
            [Util dismissHUD];
            self.userLocationPOI.collectionState = collectionState;
            self.userLocationPOI.destinationID = destinationID;
            dispatch_async_on_main_queue(^{
                self.collectionFlagImgView.highlighted = (collectionState == SOSPOICollectionState_Collected);
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

- (void)refreshTimeLabel		{
    dispatch_async_on_main_queue(^{
        self.timeLabel.text = self.userLocationPOI.gapTime;
    });
}

- (IBAction)shareButtonTapped 	{
    [SOSDaapManager sendActionInfo:TRIP_MYLOCATION_SHARE];
    [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:self.userLocationPOI];
    [NavigateShareTool sharedInstance].shareToMomentsDaapID = TRIP_MYLOCATION_SHARE_MOMENTS;
    [NavigateShareTool sharedInstance].shareToChatDaapID = TRIP_MYLOCATION_SHARE_WECHAT;
    [NavigateShareTool sharedInstance].shareCancelDaapID = TRIP_MYLOCATION_SHARECANCEL;
}

- (IBAction)aroundSearchButtonTapped {
    [SOSDaapManager sendActionInfo:TRIP_MYLOCATION_SEARCHAROUND];
    SOSAroundSearchVC *vc = [[SOSAroundSearchVC alloc] init];
    vc.selectedPoi = self.userLocationPOI;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)collectionButtonTapped {
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self.viewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (finished) {
            switch (self.userLocationPOI.collectionState) {
                case SOSPOICollectionState_Non:    {
                    [Util toastWithMessage:@"当前POI收藏状态未知,请稍候再试"];
                    return;
                }
                case SOSPOICollectionState_Collected:    {
                    [Util showHUD];
                    [CollectionToolsOBJ deleteCollectionWithDestinationID:self.userLocationPOI.destinationID Success:^{
                        [Util dismissHUD];
                        self.userLocationPOI.collectionState = SOSPOICollectionState_Not_Collected;
                        self.collectionFlagImgView.highlighted = NO;
                    } Failure:^{
                        [Util dismissHUD];
                        return;
                    }];
                    break;
                }
                case SOSPOICollectionState_Not_Collected:    {
                    if (![SOSCheckRoleUtil checkVisitorInPage:nil])        return;
                    [Util showHUD];
                    [CollectionToolsOBJ addCollectionFromVC:self.viewController WithPoi:self.userLocationPOI NickName:self.userLocationPOI.name Success:^(NSString *destinationID){
                        [Util dismissHUD];
                        self.userLocationPOI.destinationID = destinationID;
                        self.userLocationPOI.collectionState = SOSPOICollectionState_Collected;
                        self.collectionFlagImgView.highlighted = YES;
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

- (IBAction)renewLocationButtonTapped {
    [SOSDaapManager sendActionInfo:TRIP_MYLOCATION_RETEST];
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshLocationButtonTapped)]) {
        [self.delegate refreshLocationButtonTapped];
    }
}

@end
