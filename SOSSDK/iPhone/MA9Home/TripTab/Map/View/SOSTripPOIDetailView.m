//
//  SOSTripPOIDetailView.m
//  Onstar
//
//  Created by Coir on 2019/4/8.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripPOIDetailView.h"
#import "CollectionToolsOBJ.h"
#import "SOSAMapSearchTool.h"
#import "NavigateShareTool.h"
#import "SOSAroundSearchVC.h"
#import "SOSNavigateTool.h"
#import "SOSTripRouteVC.h"

@interface SOSTripPOIDetailView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *collectionFlagImgView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIView *collectionnButtonBGView;
@property (weak, nonatomic) IBOutlet UIView *phoneButtonBGView;
@property (weak, nonatomic) IBOutlet UIView *aroundSearchButtonBGView;
@property (weak, nonatomic) IBOutlet UIButton *appointButtonBGView;
@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMoreButtonHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneBGViewLeadingGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendToCarButtonWidthGuide;

@end

@implementation SOSTripPOIDetailView

- (void)awakeFromNib	{
    [super awakeFromNib];
    __weak __typeof(self) weakSelf = self;
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        // 用户登录成功
        if ([newValue isKindOfClass:[NSNumber class]]) {
            LOGIN_STATE_TYPE newState = [newValue intValue];
            switch (newState) {
                case LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS:    {
                    [weakSelf refreshWithCollectionStatus];
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

- (void)setIsFromAroundSearch:(BOOL)isFromAroundSearch	{
    _isFromAroundSearch = isFromAroundSearch;
    dispatch_async_on_main_queue(^{
        if(self.aroundSearchButtonBGView.hidden == NO && isFromAroundSearch)	{
            self.aroundSearchButtonBGView.hidden = YES;
        }
    });
}

- (void)setPoiArray:(NSArray<SOSPOI *> *)poiArray	{
    _poiArray = [poiArray copy];
    dispatch_async_on_main_queue(^{
        self.showMoreButton.hidden = poiArray.count == 0;
        self.showMoreButtonHeightGuide.constant = poiArray.count ? 36 : 6;
        [self layoutIfNeeded];
    });
}

- (void)setPoi:(SOSPOI *)poi	{
    _poi = poi;
    [self refreshWithCollectionStatus];
    [self getPOIAMapID];
    dispatch_async_on_main_queue(^{
        self.nameLabel.text = poi.name;
        self.adressLabel.text = poi.address;
        if (self.distanceLabel.hidden == NO)	{
            self.distanceLabel.text = poi.distanceWithUnit;
        }
    });
}

- (void)getPOIAMapID	{
    if (self.mapType == MapTypeShowDealerPOI) {
        __weak __typeof(self) weakSelf = self;
        [[SOSAMapSearchTool sharedInstance] getAMapIDWithPOI:self.poi Success:^(NSString * _Nonnull aMapID) {
            weakSelf.poi.pguid = aMapID;
            [[SOSPoiHistoryDataBase sharedInstance] insert:weakSelf.poi];
        } Failure:nil];
    }
}

- (void)setMapType:(MapType)mapType		{
    _mapType = mapType;
    dispatch_async_on_main_queue(^{
        switch (mapType) {
            case MapTypeShowPoiPoint:
            case MapTypeShowPoiPointFromList:
                self.collectionnButtonBGView.hidden = NO;
                self.aroundSearchButtonBGView.hidden = NO;
                self.phoneButtonBGView.hidden = YES;
                self.appointButtonBGView.hidden = YES;
                self.distanceLabel.hidden = YES;
                break;
            case MapTypeOil:
                self.collectionnButtonBGView.hidden = NO;
                self.aroundSearchButtonBGView.hidden = YES;
                self.phoneButtonBGView.hidden = NO;
                self.phoneBGViewLeadingGuide.constant = 90.f;
                self.appointButtonBGView.hidden = YES;
                self.distanceLabel.hidden = NO;
                break;
            case MapTypeShowDealerPOI:
                self.collectionnButtonBGView.hidden = YES;
                self.aroundSearchButtonBGView.hidden = YES;
                self.phoneButtonBGView.hidden = NO;
                self.phoneBGViewLeadingGuide.constant = 14.f;
                self.appointButtonBGView.hidden = NO;
                self.distanceLabel.hidden = NO;
                if (SCREEN_WIDTH <= 320) {
                    self.phoneBGViewLeadingGuide.constant = 10.f;
                    self.sendToCarButtonWidthGuide.constant = 60.f;
                }
                break;
            default:
                break;
        }
    });
}

- (void)refreshWithCollectionStatus		{
    switch (self.poi.collectionState) {
        case SOSPOICollectionState_Non:	{
            // 未登录状态不执行操作
            if (![[LoginManage sharedInstance] isLoadingUserBasicInfoReady])	return;
            // 展示经销商不需要获取收藏状态
            if (self.mapType == MapTypeShowDealerPOI)							return;
            [Util showHUD];
            __weak __typeof(self) weakSelf = self;
            [[SOSAMapSearchTool sharedInstance] getCollectionStateWithPOI:[self.poi copy] Success:^(SOSPOICollectionState state, NSString *destinationID) {
                [Util dismissHUD];
                dispatch_async_on_main_queue(^{
                    weakSelf.collectionFlagImgView.highlighted = (state == SOSPOICollectionState_Collected);
                    weakSelf.poi.collectionState = state;
                    weakSelf.poi.destinationID = destinationID;
                });
            } Failure:^{
                [Util dismissHUD];
                [Util toastWithMessage:@"获取收藏状态失败"];
            }];
            break;
        }
        case SOSPOICollectionState_Collected:
            self.collectionFlagImgView.highlighted = YES;
            break;
        case SOSPOICollectionState_Not_Collected:
            self.collectionFlagImgView.highlighted = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Button Action
- (IBAction)shareButtonTapped {
    [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:self.poi];
    if (self.mapType == MapTypeShowDealerPOI) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_Share];
        [NavigateShareTool sharedInstance].shareToMomentsDaapID = Trip_GoWhere_AroundDealer_POIdetail_Share_WeChatMoments;
        [NavigateShareTool sharedInstance].shareToChatDaapID = Trip_GoWhere_AroundDealer_POIdetail_Share_WeChatFriends;
        [NavigateShareTool sharedInstance].shareCancelDaapID = Trip_GoWhere_AroundDealer_POIdetail_Share_Cancel;
    }	else if (self.mapType == MapTypeOil) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_Share];
        [NavigateShareTool sharedInstance].shareToMomentsDaapID = Trip_GoWhere_AroundGasSation_POIdetail_Share_WeChatMoments;
        [NavigateShareTool sharedInstance].shareToChatDaapID = Trip_GoWhere_AroundGasSation_POIdetail_Share_WeChatFriends;
        [NavigateShareTool sharedInstance].shareCancelDaapID = Trip_GoWhere_AroundGasSation_POIdetail_Share_Cancel;
    }    	else	{
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_Share];
        [NavigateShareTool sharedInstance].shareToMomentsDaapID = Trip_GoWhere_POIdetail_Share_WeChatMoments;
        [NavigateShareTool sharedInstance].shareToChatDaapID = Trip_GoWhere_POIdetail_Share_WeChatFriends;
        [NavigateShareTool sharedInstance].shareCancelDaapID = Trip_GoWhere_POIdetail_Share_Cancel;
    }
}

- (IBAction)collectionButtonTapped {
    if (self.mapType == MapTypeOil) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_Favorite];
    }    else    {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_Favorite];
    }
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self.viewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (finished) {
            switch (self.poi.collectionState) {
                case SOSPOICollectionState_Non:    {
                    [Util toastWithMessage:@"当前POI收藏状态未知,请稍候再试"];
                    return;
                }
                case SOSPOICollectionState_Collected:	{
                    [Util showHUD];
                    [CollectionToolsOBJ deleteCollectionWithDestinationID:self.poi.destinationID Success:^{
                        [Util dismissHUD];
                        self.poi.collectionState = SOSPOICollectionState_Not_Collected;
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
                    [CollectionToolsOBJ addCollectionFromVC:self.viewController WithPoi:self.poi NickName:self.poi.name Success:^(NSString *destinationID){
                        [Util dismissHUD];
                        self.poi.destinationID = destinationID;
                        self.poi.collectionState = SOSPOICollectionState_Collected;
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

- (IBAction)phoneButtonTapped {
    if (self.mapType == MapTypeShowDealerPOI) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_Call];
    }	else if (self.mapType == MapTypeOil) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_Call];
    }
    if (!self.poi.tel.length) {
        [Util toastWithMessage:@"无号码"];
    }   else    {
        [SOSUtil callPhoneNumber:self.poi.tel];
    }
}

- (IBAction)aroundSerachButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SearchAround];
    SOSAroundSearchVC *vc = [[SOSAroundSearchVC alloc] init];
    vc.selectedPoi = self.poi;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showMoreResults {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showMoreResultsWithPoiArray:)]) {
        [self.delegate showMoreResultsWithPoiArray:self.poiArray];
    }
}

- (IBAction)appointmentButtonnTapped {
    if (self.dealer.dealerCode.length <= 0) {
        [Util toastWithMessage:@"亲，该经销商不支持预约系统，建议您直接电话联系。"];
        return;
    }
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_Appointment];
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:[Util getStaticConfigureURL:@"/mweb/ma80/redealer/index.html#/choiseTime"]];
    vc.isDealer = YES;
    vc.dealerName = self.dealer.dealerName;
    vc.dealerCode = self.dealer.dealerCode;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sendToCarButtonTapped {
    if (self.mapType == MapTypeShowDealerPOI) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SentToCar];
    }	else if (self.mapType == MapTypeOil) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_SentToCar];
    }	else	{
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SentToCar];
    }
    [SOSNavigateTool sendToCarAutoWithPOI:self.poi TBTDaapFuncID:Trip_GoWhere_POIdetail_SentToCar_TBT AndODDDaapFuncID:Trip_GoWhere_POIdetail_SentToCar_ODD CancelDaapFuncID:Trip_GoWhere_POIdetail_SentToCar_Cancel];
}

- (IBAction)routeButtonTapped {
    if (self.mapType == MapTypeShowDealerPOI) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_GoHere];
    }    else if (self.mapType == MapTypeOil) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_GoHere];
    }  	else	{
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_GoHere];
    }
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:self.poi];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc	{
    [Util dismissHUD];
}

@end
