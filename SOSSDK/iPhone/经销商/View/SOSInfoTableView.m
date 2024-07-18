//
//  SOSInfoTableView.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/4.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoTableView.h"
#import "SOSTravalInfoTableViewCell.h"
//#import "SetCollectionNickNameVC.h"
#import "SOSAroundSearchVC.h"
#import "NavigateShareTool.h"
#import "CarOperationWaitingVC.h"

@implementation SOSInfoTableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.table.tableFooterView = [UIView new];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentType = ContentTypeDefault;
    self.table.tableFooterView = [UIView new];
}

- (void)setContentType:(ContentType)contentType{
    _contentType = contentType;
    switch (_contentType) {
        case ContentTypeDefault:{
            _titleArray = @[@"电话号码",@"收藏目的地",@"周边检索",@"分享位置"];
            _iconArray = @[@"icon_travel_map_panel_call",@"icon_travel_map_panel_favourite",@"icon_travel_map_panel_around",@"icon_travel_map_panel_share"];
            break;
        }
        case ContentTypeDealer:{
            if ([Util vehicleIsIcm]) {
                _titleArray = @[@"电话号码", @"收藏目的地", @"", @"车载导航"];
                _iconArray = @[@"icon_travel_map_panel_call",@"icon_travel_map_panel_favourite",@"",@"icon_travel_map_panel_ODD"];

            }   else    {
                if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.sendToTBTSupported && [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.sendToNAVSupport) {
                    _titleArray = @[@"电话号码",@"收藏目的地",@"音控领航",@"车载导航"];
                    _iconArray = @[@"icon_travel_map_panel_call",@"icon_travel_map_panel_favourite",@"icon_travel_map_panel_TBT"
                                   ,@"icon_travel_map_panel_ODD"];
                }else{
                    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.sendToTBTSupported) {
                        _titleArray = @[@"电话号码",@"收藏目的地",@"音控领航", @""];
                        _iconArray = @[@"icon_travel_map_panel_call",@"icon_travel_map_panel_favourite",@"icon_travel_map_panel_TBT",@""];
                    }else{
                        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.sendToNAVSupport) {
                            _titleArray = @[@"电话号码",@"收藏目的地",@"",@"车载导航"];
                            _iconArray = @[@"icon_travel_map_panel_call",@"icon_travel_map_panel_favourite",@""
                                           ,@"icon_travel_map_panel_ODD"];
                        }else{
                            
                        }
                    }
                }
                
            }
            break;
        }
        case ContentTypeChargeStation:{
            _titleArray = @[@"收藏目的地",@"周边检索",@"分享位置"];
            _iconArray = @[@"icon_travel_map_panel_favourite",@"icon_travel_map_panel_around",@"icon_travel_map_panel_share"];
            break;
        }
            
        default:
            break;
    }
    [_table reloadData];
}

- (void)setPoi:(SOSPOI *)poi    {
    _poi = poi;
    switch (poi.sosPoiType) {
        case POI_TYPE_ChargeStation:
        case POI_TYPE_OilStation:{
            dispatch_async(dispatch_get_main_queue(), ^{
                _titleArray = @[@"电话号码",@"收藏目的地",@"",@"分享位置"];
                _iconArray = @[@"icon_travel_map_panel_call", @"icon_travel_map_panel_favourite", @"",  @"icon_travel_map_panel_share"];
                [_table reloadData];
            });
            break;
        }
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _titleArray[indexPath.row];
    if (title.length <= 0) {
        return 0;
    }
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSTravalInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSTravalInfoTableViewCell"];
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSTravalInfoTableViewCell" owner:self options:nil][0];
    }
    cell.titleLb.text = self.titleArray[indexPath.row];
    cell.iconView.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_contentType) {
        case ContentTypeDefault:
            [self contentTypeDefaultDidSelectRowAtIndexPath:indexPath];
            break;
        case ContentTypeDealer:
            [self contentTypeDealerDidSelectRowAtIndexPath:indexPath];
            break;
        case ContentTypeChargeStation:
            [self contentTypeChargeStationDidSelectRowAtIndexPath:indexPath];
            break;
        default:
            break;
    }
}

/// 默认页面点击事件
- (void)contentTypeDefaultDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //电话
    if (indexPath.row == 0) {
        [SOSDaapManager sendActionInfo:Map_POIdetail_call];
        if (!self.poi.tel.length) {
            [Util toastWithMessage:@"无号码"];
        }   else    {
            //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_dialicon];
            [SOSUtil callPhoneNumber:self.poi.tel];
        }
        //收藏
    }   else if (indexPath.row == 1)    {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_favorite];
//        [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self.viewController andTobePushViewCtr:nil completion:^(BOOL finished) {
//            if (finished) {
//                SetCollectionNickNameVC *vc = [[SetCollectionNickNameVC alloc] init];
//                vc.poi = self.poi;
//                [self.viewController.navigationController pushViewController:vc animated:YES];
//            }
//        }];
        //周边检索
    }   else if (indexPath.row == 2)    {
        [SOSDaapManager sendActionInfo:Map_POIdetail_searcharound];
        SOSAroundSearchVC *vc = [[SOSAroundSearchVC alloc] init];
        vc.selectedPoi = self.poi;
        [self.viewController.navigationController pushViewController:vc animated:YES];
        //分享
    }   else if (indexPath.row == 3)    {
        [SOSDaapManager sendActionInfo:Map_POIdetail_sharePOI];
        [[NavigateShareTool sharedInstance] shareWithPOI:self.poi];
    }
}

/// 周边经销商页面点击事件
- (void)contentTypeDealerDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //电话
    if (indexPath.row == 0) {
        if (!self.poi.tel.length) {
            [Util toastWithMessage:@"无号码"];
        }   else    {
            [SOSDaapManager sendActionInfo:Dealeraptmt_Map_POIdetail_call];
            //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_dialicon];
            [SOSUtil callPhoneNumber:self.poi.tel];
        }
        //收藏
    }   else if (indexPath.row == 1)    {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_favorite];
//        [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self.viewController andTobePushViewCtr:nil completion:^(BOOL finished) {
//            if (finished) {
//                [SOSDaapManager sendActionInfo:Dealeraptmt_Map_POIdetail_saveasfavorite];
//                SetCollectionNickNameVC *vc = [[SetCollectionNickNameVC alloc] init];
//                vc.poi = self.poi;
//                [self.viewController.navigationController pushViewController:vc animated:YES];
//            }
//        }];
        //音控领航
    }   else if (indexPath.row == 2)    {
        [SOSDaapManager sendActionInfo:Dealeraptmt_Map_POIdetail_odd];
        CarOperationWaitingVC *vc = [CarOperationWaitingVC initWithPoi:self.poi Type:OrderTypeTBT FromVC:self.viewController];
//        [vc checkAndShowFromVC:self.viewController];
        [vc checkAndShowFromVC:self.viewController needToastMessage:NO needShowWaitingVC:YES completion:nil];

        //车载导航
    }   else if (indexPath.row == 3)    {
        [SOSDaapManager sendActionInfo:Dealeraptmt_Map_POIdetail_TBT];
        CarOperationWaitingVC *vc = [CarOperationWaitingVC initWithPoi:self.poi Type:OrderTypeODD FromVC:self.viewController];
//        [vc checkAndShowFromVC:self.viewController];
        [vc checkAndShowFromVC:self.viewController needToastMessage:NO needShowWaitingVC:YES completion:nil];
    }

}

/// 充电桩页面点击事件
- (void)contentTypeChargeStationDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        //收藏
    if (indexPath.row == 0)    {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_favorite];
//        [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self.viewController andTobePushViewCtr:nil completion:^(BOOL finished) {
//            if (finished) {
//                SetCollectionNickNameVC *vc = [[SetCollectionNickNameVC alloc] init];
//                vc.poi = self.poi;
//                [self.viewController.navigationController pushViewController:vc animated:YES];
//            }
//        }];
        //周边检索
    }   else if (indexPath.row == 1)    {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_aroundsearch];
        SOSAroundSearchVC *vc = [[SOSAroundSearchVC alloc] init];
        vc.selectedPoi = self.poi;
        [self.viewController.navigationController pushViewController:vc animated:YES];
        //分享
    }   else if (indexPath.row == 2)    {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:POIdetail_share];
        [[NavigateShareTool sharedInstance] shareWithPOI:self.poi];
    }

}


- (void)sosAlertView:(SOSCustomAlertView *)alertView didClickButtonAtIndex:(NSInteger)buttonIndex   {
    if (buttonIndex) {
        [SOSUtil callPhoneNumber:self.poi.tel];
    }
}

@end
