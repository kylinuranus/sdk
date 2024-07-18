//
//  NavigteSearchHomeAndCompanyCell.m
//  Onstar
//
//  Created by Coir on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "NavigteSearchHomeAndCompanyCell.h"
#import "SOSFlexibleAlertController.h"
#import "SOSHomeAndCompanyTool.h"
#import "CollectionToolsOBJ.h"
#import "NavigateSearchVC.h"
#import "SOSRouteTool.h"
#import "SOSTripPOIVC.h"


@interface NavigteSearchHomeAndCompanyCell ()   {
    
    __weak IBOutlet UILabel *homeLabel;
    __weak IBOutlet UILabel *companyLabel;
    __weak IBOutlet UIButton *HomeButton;
    __weak IBOutlet UIButton *companyButton;
    
    __weak IBOutlet UIButton *homeMoreButton;
    __weak IBOutlet UIButton *companyMoreButtonn;
    
}

@end

@implementation NavigteSearchHomeAndCompanyCell

- (instancetype)init    {
    self = [[NSBundle SOSBundle] loadNibNamed:@"NavigteSearchHomeAndCompanyCell" owner:self options:nil][0];
    if (self) {
        [self configHomeAndCompanyInfo];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    homeLabel.text = @"住家";
    companyLabel.text = @"公司";
    [HomeButton setTitleForNormalState:@"设置住家地址"];
    [companyButton setTitleForNormalState:@"设置公司地址"];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KHomeAndCompanyChangedNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [self configHomeAndCompanyInfo];
    }];
}

- (void)configHomeAndCompanyInfo    {
    SOSPOI *homePoi = [CustomerInfo sharedInstance].homePoi;
    SOSPOI *companyPoi = [CustomerInfo sharedInstance].companyPoi;
    if (homePoi) 		{
       	[HomeButton setTitle:homePoi.name forState:UIControlStateNormal];
        homeMoreButton.userInteractionEnabled = YES;
    }	else				{
        [HomeButton setTitleForNormalState:@"设置住家地址"];
//        homeMoreButton.userInteractionEnabled = NO;
    }
    if (companyPoi) 	{
        [companyButton setTitle:companyPoi.name forState:UIControlStateNormal];
        companyMoreButtonn.userInteractionEnabled = YES;
    }	else				{
        [companyButton setTitleForNormalState:@"设置公司地址"];
//        companyMoreButtonn.userInteractionEnabled = NO;
    }
    
}

- (IBAction)jumpToMapWithHomePoi:(UIButton *)sender {
    [self setHomeOrCompanyAddress:HomeButton];
}

- (IBAction)JumpToMapWithCompanyPoi:(UIButton *)sender {
    [self setHomeOrCompanyAddress:companyButton];
}

- (IBAction)homeMoreButtonTapped {
    [self homeOrCompanyTappedMoreWithIsHomeButtonTapped:YES];
}

- (IBAction)companyMoreButtonTapped {
    [self homeOrCompanyTappedMoreWithIsHomeButtonTapped:NO];
}

- (void)homeOrCompanyTappedMoreWithIsHomeButtonTapped:(BOOL)isHomeButtonTapped		{
    if (![SOSCheckRoleUtil checkVisitorInPage:self.viewController])      return;

    SOSPOI *selectPOI = isHomeButtonTapped ? [CustomerInfo sharedInstance].homePoi : [CustomerInfo sharedInstance].companyPoi;
    [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_FavoriteTab_HomeMore : Trip_GoWhere_FavoriteTab_OfficeMore];
    if (!selectPOI) {
                [Util showAlertWithTitle:@"地点未设置，现在去设置吗？" message:nil completeBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1)     {
                        [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_SET];
                        [self modifyHomeAddressWithPOI:selectPOI IsHomeButtonTapped:isHomeButtonTapped];
                    }    else    {
                        [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_NO];
                    }
                } cancleButtonTitle:@"不了" otherButtonTitles:@"去设置", nil];
        return;
    }
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:nil preferredStyle:SOSAlertControllerStyleActionSheet];
    SOSAlertAction *modifyAction = [SOSAlertAction actionWithTitle:isHomeButtonTapped ? @"修改住家地址" : @"修改公司地址" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_FavoriteTab_HomeMore_EditHomeAdd : Trip_GoWhere_FavoriteTab_OfficeMore_EditOfficeAdd];
        [self modifyHomeAddressWithPOI:selectPOI IsHomeButtonTapped:isHomeButtonTapped];
    }];
    SOSAlertAction *deleteAction = [SOSAlertAction actionWithTitle:@"删除" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_FavoriteTab_HomeMore_Delete : Trip_GoWhere_FavoriteTab_OfficeMore_Delete];
        [Util showAlertWithTitle:[NSString stringWithFormat:@"确定删除收藏夹%@的地址吗？", isHomeButtonTapped ? @"家" : @"公司"] message:nil completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_FavoriteTab_HomeMore_Delete_Confirm : Trip_GoWhere_FavoriteTab_OfficeMore_Delete_Confirm];
                [Util showHUD];
                [CollectionToolsOBJ deleteCollectionWithDestinationID:selectPOI.destinationID NeedToast:NO Success:^{
                    [Util dismissHUD];
                    if (isHomeButtonTapped)     [CustomerInfo sharedInstance].homePoi = nil;
                    else                        [CustomerInfo sharedInstance].companyPoi = nil;
                    
                    [self configHomeAndCompanyInfo];
                    [Util showSuccessHUDWithStatus:@"已删除"];
                } Failure:^{
                    [Util dismissHUD];
                    [Util showErrorHUDWithStatus:@"操作异常"];
                }];
            }	else	{
                [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_FavoriteTab_HomeMore_Delete_Cancel : Trip_GoWhere_FavoriteTab_OfficeMore_Delete_Cancel];
            }
        } cancleButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }];
    SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_FavoriteTab_HomeMore_Cancel : Trip_GoWhere_FavoriteTab_OfficeMore_Cancel];
    }];
    [vc addActions:@[modifyAction, deleteAction, cancelAction]];
    [vc show];
}

// 家和公司地址Cell点击,展示 家/公司 地址
- (void)setHomeOrCompanyAddress:(UIButton *)sender {
    BOOL isHomeButtonTapped = (sender == HomeButton);
    [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_FavoriteTab_HomePOI : Trip_GoWhere_FavoriteTab_OfficePOI];
    
    // 未设置时, 先去设置 家/公司 地址
    SOSPOI *selectPOI = isHomeButtonTapped ? [CustomerInfo sharedInstance].homePoi : [CustomerInfo sharedInstance].companyPoi;
    if (selectPOI == nil) {
        [SOSDaapManager sendActionInfo:isHomeButtonTapped ? Trip_GoWhere_NotSet_Home_Set : Trip_GoWhere_NotSet_Office_Set];
        [self modifyHomeAddressWithPOI:selectPOI IsHomeButtonTapped:isHomeButtonTapped];
        return;
    }
    // 设置路径起终点
    if (self.type == OperationType_set_Route_Begin_POI || self.type == OperationType_set_Route_Destination_POI) {
        [SOSRouteTool changeRoutePOIDoneFromVC:self.nav.topViewController WithType:self.type ResultPOI:selectPOI];
        return;
    }
    
    // 展示 家/公司 地址
    selectPOI.sosPoiType = isHomeButtonTapped ? POI_TYPE_Home : POI_TYPE_Company;
    
    SOSTripPOIVC *vc = [[SOSTripPOIVC alloc] initWithPOI:selectPOI];
    vc.mapType = isHomeButtonTapped ? MapTypeShowHomeAddress : MapTypeShowCompanyAddress;
    [self.nav pushViewController:vc animated:YES];
}

// 修改/设定 家/公司 地址
- (void)modifyHomeAddressWithPOI:(nullable SOSPOI *)poi IsHomeButtonTapped:(BOOL)isHomeButtonTapped	{

                //设定 家/公司 地址
                NavigateSearchVC *vc = [NavigateSearchVC new];
                vc.operationType = isHomeButtonTapped ? OperationType_Set_Home : OperationType_Set_Company;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self.nav.topViewController presentViewController:nav animated:YES completion:nil];;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
