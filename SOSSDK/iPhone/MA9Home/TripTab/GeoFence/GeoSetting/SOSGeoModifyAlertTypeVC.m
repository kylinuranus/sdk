//
//  SOSGeoModifyAlertTypeVC.m
//  Onstar
//
//  Created by Coir on 2019/6/28.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoDataTool.h"
#import "SOSGeoModifyMobileVC.h"
#import "SOSGeoModifyAlertTypeVC.h"

@interface SOSGeoModifyAlertTypeVC ()

@property (nonatomic, copy) NNGeoFence *originGeofence;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *outTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *outFlagImgView;
@property (weak, nonatomic) IBOutlet UILabel *inTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inFlagImgView;

@property (copy, nonatomic) NSString *modifyMobileToken;

@end

@implementation SOSGeoModifyAlertTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"提醒设置";
    __weak __typeof(self) weakSelf = self;
    [self setRightBarButtonItemWithTitle:@"保存" AndActionBlock:^(id item) {
        if (weakSelf.phoneLabel.tag == 99) {
            [Util showAlertWithTitle:@"请设置接收提醒的手机号" message:nil confirmBtn:@"知道了" completeBlock:nil];
            return ;
        }
        [weakSelf saveGeofenceChange];
    }];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_Nav_Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSNotifacationChangeGeo object:nil] subscribeNext:^(NSNotification *noti) {
        NSDictionary *notiDic = noti.object;
        if ([notiDic isKindOfClass:[NSDictionary class]] && notiDic.count) {
            SOSChangeGeoType type = [notiDic[@"Type"] intValue];
            // 只关注修改围栏手机号相关通知
            if (type == SOSChangeGeoType_Update_Mobile) {
                NSString *token = notiDic[@"ModifyMobileToken"];
                weakSelf.modifyMobileToken = token;
                NNGeoFence *notiGeo = notiDic[@"Geofence"];
                weakSelf.geofence = notiGeo;
            }
        }
    }];
}

- (void)setGeofence:(NNGeoFence *)geofence	{
    _geofence = [geofence copy];
    _originGeofence = [geofence copy];
}

- (void)back     {
    if (self.geofence.isNewToAdd && self.isFromOriginAddPage) {
        [self showAlert];
    }	else	{
        if (( [self.geofence.alertType isEqualToString:self.originGeofence.alertType] &&
             [self.geofence.getGeoMobile isEqualToString:self.originGeofence.getGeoMobile] ) == NO) {
            [self showAlert];
        }	else	{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)showAlert	{
    [Util showAlertWithTitle:@"是否保存设置？" message:nil completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            [self saveGeofenceChange];
        }    else    {
            // 丢弃
            if (self.geofence.isNewToAdd) {
                if (self.geofence.isLBSMode)	((NNLBSGeoFence *)self.geofence).mobile = nil;
                else							self.geofence.mobilePhone = nil;
                // 新建围栏时,返回到围栏预览
                [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_AlertAndMobile), @"Geofence":[self.geofence copy]}];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } cancleButtonTitle:@"丢弃" otherButtonTitles:@"保存", nil];
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    [self configPhoneLabel];
    [self configAlertType];
}

- (void)configPhoneLabel	{
    NSString *mobile = nil;
    if (self.geofence.isLBSMode) {
        NNLBSGeoFence *lbsGeo = (NNLBSGeoFence *)self.geofence;
        mobile = lbsGeo.mobile;
    }	else	{
        mobile = self.geofence.mobilePhone;
    }
    if (mobile.length) {
        self.phoneLabel.tag = 88;
        self.phoneLabel.text = [Util maskMobilePhone:mobile];
    }	else	{
        self.phoneLabel.tag = 99;
        self.phoneLabel.text = @"未设置";
    }
}

- (void)configAlertType		{
    self.inTypeLabel.textColor = [UIColor colorWithHexString:@"28292F"];
    self.inTypeLabel.highlightedTextColor = [UIColor colorWithHexString:@"6896ED"];
    self.outTypeLabel.textColor = [UIColor colorWithHexString:@"28292F"];
    self.outTypeLabel.highlightedTextColor = [UIColor colorWithHexString:@"6896ED"];
    if ([self.geofence.alertType isEqualToString:@"IN"]) {
        [self selectInType];
    }	else	{
        [self selectOutType];
    }
}

- (IBAction)setPhoneNumButtonTapped {
    SOSGeoModifyMobileVC *vc = [SOSGeoModifyMobileVC new];
    vc.geofence = self.geofence;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)selectOutType {
    self.outTypeLabel.highlighted = YES;
    self.inTypeLabel.highlighted = NO;
    self.outFlagImgView.hidden = NO;
    self.inFlagImgView.hidden = YES;
    self.geofence.alertType = @"OUT";
    self.outTypeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.inTypeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
}

- (IBAction)selectInType {
    self.outTypeLabel.highlighted = NO;
    self.inTypeLabel.highlighted = YES;
    self.outFlagImgView.hidden = YES;
    self.inFlagImgView.hidden = NO;
    self.geofence.alertType = @"IN";
    self.outTypeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.inTypeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
}

- (void)saveGeofenceChange	{
    if (self.geofence.isNewToAdd) {
        // 新建围栏时,返回上一级页面保存
        [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_AlertAndMobile), @"Geofence":[self.geofence copy]}];
        [self.navigationController popViewControllerAnimated:YES];
    }    else    {
        // 编辑围栏时,需实时保存
        [Util showHUD];
        [SOSGeoDataTool updateGeoFencingWithGeo:self.geofence Success:^(SOSNetworkOperation *operation, id responseStr) {
            [Util dismissHUD];
            [Util showSuccessHUDWithStatus:@"围栏更新成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_AlertAndMobile), @"Geofence":[self.geofence copy], @"ShouldChangeLocal": @(YES)}];
            [self.navigationController popViewControllerAnimated:YES];
        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util dismissHUD];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }];
    }
}

@end
