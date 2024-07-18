//
//  SOSStationDetailView.m
//  Onstar
//
//  Created by Coir on 2019/8/20.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSStationDetailPriceInfoCell.h"
#import "SOSStationDetailView.h"
#import "UIImageView+WebCache.h"
#import "CollectionToolsOBJ.h"
#import "SOSAMapSearchTool.h"
#import "NavigateShareTool.h"
#import "SOSNavigateTool.h"
#import "SOSOilDataTool.h"
#import "SOSTripRouteVC.h"

@interface SOSStationDetailView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *collectionFlagImgView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stationImgView;
@property (weak, nonatomic) IBOutlet UITableView *priceTableView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImgView;

@property (weak, nonatomic) IBOutlet UIView *collectionnButtonBGView;
@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMoreButtonHeightGuide;

@property (nonnull, strong, nonatomic) SOSPOI *poi;

@property (nonatomic, strong) NSArray <SOSOilStation *>* priceInfoArray;

@end

@implementation SOSStationDetailView

- (void)setStation:(SOSOilStation *)station		{
    _station = [station copy];
    self.poi = station.transToPOI;
    [self getPOIAMapID];
    [self getStationDetailInfo];
    dispatch_async_on_main_queue(^{
        self.nameLabel.text = station.gasName;
        self.adressLabel.text = station.gasAddress;
        self.distanceLabel.text = [NSString stringWithFormat:@"距离%.1f公里", station.distance];
        [self.stationImgView sd_setImageWithURL:[NSURL URLWithString:station.gasLogoSmall]];
    });
}

// 获取油站油号信息
- (void)getStationDetailInfo	{
    self.priceTableView.tableFooterView = [UIView new];
    [self.priceTableView registerNib:[UINib nibWithNibName:@"SOSStationDetailPriceInfoCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSStationDetailPriceInfoCell"];
    [self.loadingImgView startRotating];
    [SOSOilDataTool requestStationOilInfoListWithStationID:self.station.gasId Success:^(NSArray <SOSOilStation *>* stationList) {
        self.priceInfoArray = stationList;
        dispatch_async_on_main_queue(^{
            [self.priceTableView reloadData];
            [self.loadingImgView endRotating];
            self.loadingImgView.hidden = YES;
            self.priceTableView.hidden = NO;
        });
    } Failure:^{
        dispatch_async_on_main_queue(^{
            [self.loadingImgView endRotating];
            self.loadingImgView.hidden = YES;
            self.priceTableView.hidden = NO;
        });
    }];
}

- (void)getPOIAMapID    {
    __weak __typeof(self) weakSelf = self;
    [[SOSAMapSearchTool sharedInstance] getAMapIDWithPOI:self.poi Success:^(NSString * _Nonnull aMapID) {
        weakSelf.poi.pguid = aMapID;
        [[SOSPoiHistoryDataBase sharedInstance] insert:weakSelf.poi];
        [weakSelf refreshWithCollectionStatus];
    } Failure:nil];
}

- (void)refreshWithCollectionStatus        {
    switch (self.poi.collectionState) {
        case SOSPOICollectionState_Non:    {
            // 未登录状态不执行操作
            if (![[LoginManage sharedInstance] isLoadingUserBasicInfoReady])    return;
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
    [SOSDaapManager sendActionInfo:Trip_WisdomOil_DiscountOil_Share];
    [NavigateShareTool sharedInstance].shareToMomentsDaapID = Trip_WisdomOil_DiscountOil_Share_WechatCircle;
    [NavigateShareTool sharedInstance].shareToChatDaapID = Trip_WisdomOil_DiscountOil_Share_WechatFriend;
    [NavigateShareTool sharedInstance].shareCancelDaapID = Trip_WisdomOil_DiscountOil_Share_Cancle;
}

- (IBAction)collectionButtonTapped {
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self.viewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (finished) {
            switch (self.poi.collectionState) {
                case SOSPOICollectionState_Non:    {
                    [Util toastWithMessage:@"当前POI收藏状态未知,请稍候再试"];
                    return;
                }
                case SOSPOICollectionState_Collected:    {
                    [Util showHUD];
                    [SOSDaapManager sendActionInfo:Trip_WisdomOil_DiscountOil_CollectCancel];
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
                    [SOSDaapManager sendActionInfo:Trip_WisdomOil_DiscountOil_Collect];
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

- (IBAction)showMoreResults {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showMoreResults)]) {
        [self.delegate showMoreResults];
    }
}

- (IBAction)sendToCarButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_WisdomOil_DiscountOil_Send];
    [SOSNavigateTool sendToCarAutoWithPOI:self.poi TBTDaapFuncID:Trip_WisdomOil_DiscountOil_Navigation_Voice AndODDDaapFuncID:Trip_WisdomOil_DiscountOil_Navigation_Vehicle CancelDaapFuncID:Trip_WisdomOil_DiscountOil_Navigation_Cancle];
}

- (IBAction)routeButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_WisdomOil_DiscountOil_Navigation];
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:self.poi];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)payOilButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(payOilButtonTappedWithPriceInfoArray:)]) {
        [self.delegate payOilButtonTappedWithPriceInfoArray:[self.priceInfoArray copy]];
    }
}

#pragma mark - TableVIew Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section	{
    return self.priceInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath		{
    SOSStationDetailPriceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSStationDetailPriceInfoCell"];
    cell.station = self.priceInfoArray[indexPath.row];
    return cell;
}

@end
