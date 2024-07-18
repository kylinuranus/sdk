//
//  AssociateCell.m
//  Onstar
//
//  Created by Coir on 16/2/16.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "AssociateCell.h"
#import "SOSTripRouteVC.h"
#import "SOSGeoDataTool.h"
#import "SOSHomeAndCompanyTool.h"

@interface AssociateCell () {
    
    __weak IBOutlet UILabel *contentLabel;
    __weak IBOutlet UILabel *addressLabel;
    __weak IBOutlet UIButton *routeButton;
    
    
}

@end

@implementation AssociateCell

- (void)awakeFromNib {
     [super awakeFromNib];
}

- (void)configSelf  {
    NSRange range = [self.tip.name rangeOfString:self.inputStr];
    if (range.location != NSNotFound) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.tip.name attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor colorWithHexString:@"28292F"]}];
        [string addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"6896ED"]} range:range];
        contentLabel.attributedText = string;
    }	else	{
        contentLabel.text = self.tip.name;
    }
    addressLabel.text = self.tip.address;
}

- (void)setOperationType:(SelectPointOperation)operationType	{
    _operationType = operationType;
    dispatch_async_on_main_queue(^{
        switch (operationType) {
            case OperationType_Set_Home:
            case OperationType_Set_Home_Send_POI:
                [self configRouteButton];
                if ([CustomerInfo sharedInstance].homePoi)	{
                    routeButton.selected = [[CustomerInfo sharedInstance].homePoi.pguid isEqualToString:self.tip.uid];
                }
                break;
            case OperationType_Set_Company:
            case OperationType_Set_Company_Send_POI:
                [self configRouteButton];
                if ([CustomerInfo sharedInstance].companyPoi)    {
                    routeButton.selected = [[CustomerInfo sharedInstance].companyPoi.pguid isEqualToString:self.tip.uid];
                }
                break;
            case OperationType_Set_GroupTrip_Destination:
            case OperationType_set_Geo_Center:
                [self configRouteButton];
                break;
            case OperationType_set_Route_Begin_POI:
            case OperationType_set_Route_Destination_POI:
                routeButton.hidden = YES;
            default:
                break;
        }
    });
}

- (void)configRouteButton		{
    [routeButton setTitle:@"选定" forState:UIControlStateNormal];
    [routeButton setTitle:@"已选定" forState:UIControlStateSelected];
    [routeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [routeButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [routeButton setTitleColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateNormal];
    [routeButton setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateSelected];
}

- (NSString *)inputStr	{
    return _inputStr.length ? _inputStr : @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)routeButtonTapped {
    SOSPOI *tempPoi = [SOSPOI new];
    tempPoi.name = self.tip.name;
    tempPoi.address = self.tip.address;
    tempPoi.longitude = @(self.tip.location.longitude).stringValue;
    tempPoi.latitude = @(self.tip.location.latitude).stringValue;
    tempPoi.pguid = self.tip.uid;
    if ([routeButton.currentTitle isEqualToString:@"去这里"]) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_GoHere];
        [[SOSPoiHistoryDataBase sharedInstance] insert:tempPoi];
        
        SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:tempPoi];
        [self.viewController.navigationController pushViewController:vc animated:YES];
    // 设定 家/公司 地址
    }	else if ([routeButton.currentTitle containsString:@"选定"])	{

        switch (self.operationType) {
            case OperationType_Set_Home:
            case OperationType_Set_Company:
            case OperationType_Set_Home_Send_POI:
            case OperationType_Set_Company_Send_POI:    {
                [SOSDaapManager sendActionInfo:Trip_GoWhere_Set_Search_SearchResult_POIdetail_Select];
                // 修改家/公司地址
                [Util showHUD];
                // 设定地址
                [SOSHomeAndCompanyTool setHomeOrCompanyWithPOI:tempPoi OperationType:self.operationType successBlock:^(SOSNetworkOperation *operation, id responseStr) {
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
            	[SOSGeoDataTool setGeoCenterWithPOI:tempPoi FromVC:self.viewController];
                break;
            case OperationType_Set_GroupTrip_Destination:
                [SOSDaapManager sendActionInfo:GroupToTravel_Group_SetDestination_Choose];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoti_GroupTrip_Destination_Changed" object:tempPoi.mj_JSONObject];
                [self.viewController dismissViewControllerAnimated:YES completion:nil];
                break;
            default:
                break;
        }
    }
}

@end
