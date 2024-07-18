//
//  SOSTripHomeModifyDetailView.m
//  Onstar
//
//  Created by Coir on 2019/4/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripHomeModifyDetailView.h"
#import "SOSHomeAndCompanyTool.h"
#import "SOSAroundSearchVC.h"
#import "NavigateShareTool.h"
#import "SOSNavigateTool.h"
#import "SOSGeoDataTool.h"
#import "SOSTripRouteVC.h"
#import "SOSRouteTool.h"

@interface SOSTripHomeModifyDetailView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMoreButtonHeightGuide;


@end

@implementation SOSTripHomeModifyDetailView

- (void)awakeFromNib	{
    [super awakeFromNib];
    [self.selectButton setTitle:@"选定" forState:UIControlStateNormal];
    [self.selectButton setTitle:@"已选定" forState:UIControlStateSelected];
    [self.selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.selectButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateNormal];
    [self.selectButton setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateSelected];
}

- (void)setPoi:(SOSPOI *)poi	{
    _poi = poi.copy;
    dispatch_async_on_main_queue(^{
        self.titleLabel.text = poi.name;
        self.addressLabel.text = poi.address;
        
        SOSPOI *homePoi = [CustomerInfo sharedInstance].homePoi;
        SOSPOI *companyPoi = [CustomerInfo sharedInstance].companyPoi;
        if (poi.sosPoiType == POI_TYPE_Home && homePoi) {
            self.selectButton.selected = [homePoi.pguid isEqualToString:poi.pguid];
        }	else	{
            self.selectButton.selected = [companyPoi.pguid isEqualToString:poi.pguid];
        }
    });
}

- (void)setPoiArray:(NSArray<SOSPOI *> *)poiArray	{
    _poiArray = poiArray;
    if (poiArray.count)		self.showMoreButtonHeightGuide.constant = 37;
    else					self.showMoreButtonHeightGuide.constant = 0;
    [self layoutIfNeeded];
}

#pragma mark - Button Action
- (IBAction)shareButtonTapped {
    [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:self.poi];
    if (self.operationType == OperationType_Set_GroupTrip_Destination) {
        [SOSDaapManager sendActionInfo:GroupToTravel_Group_SetDestination_POICard_Share];
        [NavigateShareTool sharedInstance].shareToMomentsDaapID = GroupToTravel_Group_SetDestination_POICard_Share_WeChatMoments;
        [NavigateShareTool sharedInstance].shareToChatDaapID = GroupToTravel_Group_SetDestination_POICard_Share_WeChatFriends;
        [NavigateShareTool sharedInstance].shareCancelDaapID = GroupToTravel_Group_SetDestination_POICard_Share_Cancel;
    }	else	{
        [NavigateShareTool sharedInstance].shareToMomentsDaapID = Trip_GoWhere_Set_Search_SearchResult_POIdetail_Share_WeChatMoments;
        [NavigateShareTool sharedInstance].shareToChatDaapID = Trip_GoWhere_Set_Search_SearchResult_POIdetail_Share_WeChatFriends;
        [NavigateShareTool sharedInstance].shareCancelDaapID = Trip_GoWhere_Set_Search_SearchResult_POIdetail_Share_Cancel;
    }
}

// 选定
- (IBAction)selectButtonTapped {
    switch (self.operationType) {
        case OperationType_Set_Home:
        case OperationType_Set_Company:
        case OperationType_Set_Home_Send_POI:
        case OperationType_Set_Company_Send_POI:	{
            [SOSDaapManager sendActionInfo:Trip_GoWhere_Set_Search_SearchResult_POIdetail_Select];
            // 修改家/公司地址
            [Util showHUD];
            [SOSHomeAndCompanyTool setHomeOrCompanyWithPOI:self.poi OperationType:self.operationType successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                [Util dismissHUD];
                dispatch_async_on_main_queue(^{
                    switch (self.operationType) {
                        case OperationType_Set_Home:
                        case OperationType_Set_Company:
                            [self.viewController dismissViewControllerAnimated:YES completion:nil];
                            break;
                        case OperationType_Set_Home_Send_POI:
                        case OperationType_Set_Company_Send_POI:
                            [SOSHomeAndCompanyTool alertSendPOIWithOperationType:self.operationType];
                            break;
                        default:
                            break;
                    }
                });
            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                [Util dismissHUD];
            }];
            break;
        }
        case OperationType_set_Geo_Center:
            [SOSGeoDataTool setGeoCenterWithPOI:self.poi FromVC:self.viewController];
            break;
        case OperationType_set_Route_Begin_POI:
        case OperationType_set_Route_Destination_POI:
            [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_GoHere_EndPosition];
            [SOSRouteTool changeRoutePOIDoneFromVC:self.viewController WithType:self.operationType ResultPOI:self.poi];
            break;
        case OperationType_Set_GroupTrip_Destination:
            [SOSDaapManager sendActionInfo:GroupToTravel_Group_SetDestination_POICard_Choose];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoti_GroupTrip_Destination_Changed" object:self.poi.mj_JSONObject];
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (IBAction)showMoreButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_Set_Search_SearchResult_POIdetail_SeeMore];
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyHomeViewShowMoreResultsWithPoiArray:)]) {
        [self.delegate modifyHomeViewShowMoreResultsWithPoiArray:self.poiArray];
    }
}

@end
