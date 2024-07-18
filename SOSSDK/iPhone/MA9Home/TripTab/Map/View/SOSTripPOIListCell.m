//
//  SOSTripPOIListCell.m
//  Onstar
//
//  Created by Coir on 2019/4/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSHomeAndCompanyTool.h"
#import "SOSTripPOIListCell.h"
#import "SOSTripRouteVC.h"
#import "SOSGeoDataTool.h"
#import "SOSRouteTool.h"

@interface SOSTripPOIListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *routeButton;

@end

@implementation SOSTripPOIListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTableType:(SOSTripListTableType)tableType	{
    _tableType = tableType;
    dispatch_async_on_main_queue(^{
        switch (tableType) {
            case SOSTripListTableType_Void:
            case SOSTripListTableType_POI_List:
                self.routeButton.hidden = NO;
                self.selectButton.hidden = YES;
                break;
            case SOSTripListTableType_Oli_List:
                break;
            case SOSTripListTableType_selectPoint:
                self.routeButton.hidden = YES;
                self.selectButton.hidden = NO;
                [self configSelectButton];
                break;
        }
    });
}

- (void)configSelectButton	{
    [self.selectButton setTitle:@"选定" forState:UIControlStateNormal];
    [self.selectButton setTitle:@"已选定" forState:UIControlStateSelected];
    [self.selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.selectButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateNormal];
    [self.selectButton setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateSelected];
}

- (void)setPoi:(SOSPOI *)poi	{
    _poi = poi;
    dispatch_async_on_main_queue(^{
        self.nameLabel.text = poi.name;
        self.addressLabel.text = poi.address;
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)routeButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_Search_POIdetailList_GoHere];
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:self.poi];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)selectButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_Set_Search_SearchResult_Select];
    switch (self.operationType) {
        case OperationType_Set_Home:
        case OperationType_Set_Company:
        case OperationType_Set_Home_Send_POI:
        case OperationType_Set_Company_Send_POI:    {
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
            [SOSRouteTool changeRoutePOIDoneFromVC:self.viewController WithType:self.operationType ResultPOI:self.poi];
            break;
        case OperationType_Set_GroupTrip_Destination:
            [SOSDaapManager sendActionInfo:GroupToTravel_Group_SetDestination_Choose];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoti_GroupTrip_Destination_Changed" object:self.poi.mj_JSONObject];
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

@end
