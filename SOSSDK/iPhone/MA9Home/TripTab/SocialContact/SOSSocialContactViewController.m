//
//  SOSSocialContactViewController.m
//  Onstar
//
//  Created by onstar on 2019/4/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialContactViewController.h"
#import "SOSFlexibleAlertController.h"
#import "WeiXinMessageInfo.h"
#import "NavigateShareTool.h"
#import "SOSSocialContactShareView.h"
#import "SOSSocialWaitingViewController.h"
#import "SOSSocialRecoverViewController.h"
#import "SOSSocialGPSEndViewController.h"
#import "SOSSocialService.h"
#ifndef SOSSDK_SDK
#import "SOSShareAttachment.h"
#import "SOSIMApi.h"
#endif

#import "SOSSocialLocationViewController.h"
#import "SOSSocialBeginGPSViewController.h"

@interface SOSSocialContactViewController ()<GeoDelegate>
@property (nonatomic, strong) SOSSocialOrderInfoResp *orderInfo;
@property (nonatomic, strong) SOSSocialOrderShareInfoResp *orderShareInfo;
@property (nonatomic, strong) BaseSearchOBJ *searchOBJ;
@end

@implementation SOSSocialContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title= @"我来接";
    [self selectOrderStatusRequest];
}

- (void)selectOrderStatusRequest {
    [Util showLoadingView];
    [SOSSocialService selectOrderSuccess:^(SOSSocialOrderInfoResp * _Nonnull resp) {
        self.orderInfo = resp;
        [self pushWithStaus];
    } Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        [Util hideLoadView];
    }];
}

- (void)pushWithStaus {
    if ([self.orderInfo.statusName isEqualToString:@"AVAILABILITY"]) {
        //可创建订单（逻辑状态不入库）
        [Util hideLoadView];
    }else if ([self.orderInfo.statusName isEqualToString:@"INIT"]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Util hideLoadView];
        });
        //可接单状态 waiting
        SOSSocialWaitingViewController *v = [[SOSSocialWaitingViewController alloc] initWithNibName:@"SOSSocialWaitingViewController" bundle:nil];
        [self.navigationController pushViewController:v wantToRemoveViewController:self animated:NO];
    }else if ([self.orderInfo.statusName isEqualToString:@"PASSENGERCONFIRM"]) {
        //乘客确认 开始导航页面
        [self geoLocation];
        
    }else if ([self.orderInfo.statusName isEqualToString:@"DRIVERCONFIRM"]) {
        //司机确认
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Util hideLoadView];
        });
        SOSSocialRecoverViewController *v = [[SOSSocialRecoverViewController alloc] initWithNibName:@"SOSSocialRecoverViewController" bundle:nil];
        v.orderInfo = self.orderInfo;
        v.mobileType = YES;
        [self.navigationController pushViewController:v wantToRemoveViewController:self animated:NO];
    }else if ([self.orderInfo.statusName isEqualToString:@"DRIVERCONFIRMFORVEHICLE"]) {
        //司机确认
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Util hideLoadView];
        });
        SOSSocialRecoverViewController *v = [[SOSSocialRecoverViewController alloc] initWithNibName:@"SOSSocialRecoverViewController" bundle:nil];
        v.orderInfo = self.orderInfo;
        [self.navigationController pushViewController:v wantToRemoveViewController:self animated:NO];
    }else {
        [Util hideLoadView];
    }
    
    
//    int flag = arc4random()%4;
//    if (flag == 0) {
//
//    }else if (flag == 0) {
//        
//    }else if (flag == 0) {
//        SOSPOI *poi = [SOSPOI new];
////        poi.longitude = @"121.511594";
////        poi.latitude = @"31.143172";
////        poi.name = @"三林(地铁站)";
//        SOSSocialGPSEndViewController *vc = [[SOSSocialGPSEndViewController alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:poi];
//        [self.navigationController pushViewController:vc animated:NO];
//    }else if (flag == 0) {
//
//        SOSSocialGPSEndViewController *v = [[SOSSocialGPSEndViewController alloc] initWithNibName:@"SOSSocialGPSEndViewController" bundle:nil];
//        [self.navigationController pushViewController:v wantToRemoveViewController:self animated:NO];
//    }
}

- (void)geoLocation {
    self.searchOBJ = [BaseSearchOBJ new];
    self.searchOBJ.geoDelegate = self;
    /// 逆地理编码请求
    NSArray *locationAry = [self.orderInfo.destinationLocation componentsSeparatedByString:@","];
    NSString *longitude = locationAry.firstObject;
    NSString *latitude = locationAry.lastObject;
    [self.searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:latitude.floatValue longitude:longitude.floatValue]];
}


- (void)reverseGeocodingResults:(NSArray *)results  {
    [Util hideLoadView];
    if (results == nil || results.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util toastWithMessage:@"地图服务失败,请稍后再试"];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        return;
    }
    dispatch_async_on_main_queue(^{
        
        SOSPOI *resultPOI = results[0];
        
//        resultPOI.longitude = @"121.511594";
//        resultPOI.latitude = @"31.143172";
//        resultPOI.name = @"三林(地铁站)";
        
        SOSSocialLocationViewController *vc = [[SOSSocialLocationViewController alloc] initWithPOI:resultPOI];
        vc.mapType = MapTypeShowPoiPoint;
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:NO];
        
    });
}



- (IBAction)SendButtonTaped:(UIButton *)sender {
    [SOSDaapManager sendActionInfo:Pickup_Send];
    if (UserDefaults_Get_Bool(@"SocialContactAcceptRemindKey")) {
        //showshare
        [self showShare];
        return;
    }
    UIView *alertContent = [UIView new];
    UILabel *titleLab = [UILabel new];
    titleLab.text = @"您的位置将实时分享给对方";
    titleLab.textColor = UIColorHex(#28292F);
    titleLab.font = [UIFont systemFontOfSize:12];
    
    UIButton *tipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tipBtn setImage:[UIImage imageNamed:@"不同意"] forState:UIControlStateNormal];
    [tipBtn setImage:[UIImage imageNamed:@"icon_nav_checked_idle_25x25"] forState:UIControlStateSelected];
    [tipBtn setBlockForControlEvents:UIControlEventTouchUpInside block:^(UIButton*  _Nonnull sender) {
        sender.selected = !sender.selected;
        [SOSDaapManager sendActionInfo:Pickup_send_Popup_noremind];
    }];
    
    UILabel *tipLab = [UILabel new];
    tipLab.text = @"不再提示";
    tipLab.textColor = UIColorHex(#4E5059F);
    tipLab.font = [UIFont systemFontOfSize:12];
    [alertContent addSubview:titleLab];
    [alertContent addSubview:tipBtn];
    [alertContent addSubview:tipLab];

    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(21);
        make.top.mas_equalTo(30);
        make.left.mas_equalTo(30);
    }];
    [tipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(25);
        make.top.mas_equalTo(titleLab.mas_bottom).mas_offset(8);
        make.left.mas_equalTo(30);
        make.bottom.mas_equalTo(-30);
    }];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipBtn.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(tipBtn);
    }];
    
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                    title:nil
                                                                                  message:nil
                                                                               customView:alertContent
                                                                           preferredStyle:SOSAlertControllerStyleAlert];
    @weakify(self)
    SOSAlertAction *action1 = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:Pickup_send_Popup_cancel];
    }];
    SOSAlertAction *action2 = [SOSAlertAction actionWithTitle:@"知道了" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
        if (tipBtn.selected) {
            UserDefaults_Set_Bool(YES, @"SocialContactAcceptRemindKey");
        }
        @strongify(self)
        [self showShare];
        [SOSDaapManager sendActionInfo:Pickup_send_Popup_iknow];
    }];
    [vc addActions:@[action1,action2]];
    [vc show];
    
}


- (void)showShare {
    SOSSocialContactShareView *view = [SOSSocialContactShareView viewFromXib];
    
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                    title:nil
                                                                                  message:nil
                                                                               customView:view
                                                                           preferredStyle:SOSAlertControllerStyleActionSheet];
    @weakify(vc)
    view.shareTapBlock = ^(NSInteger index) {
        @strongify(vc)
        [vc dismissViewControllerAnimated:YES completion:nil];

        [self createOrderWithIndex:index];
        SOSSocialWaitingViewController *v = [[SOSSocialWaitingViewController alloc] initWithNibName:@"SOSSocialWaitingViewController" bundle:nil];
        [self.navigationController pushViewController:v wantToRemoveViewController:self animated:YES];
    };
    
    SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:Pickup_send_cancel];
    }];
    [vc addActions:@[action]];
    [vc show];
    
}

- (void)createOrderWithIndex:(NSInteger)index {
    if (index == 0) {
       [SOSDaapManager sendActionInfo:Pickup_send_Xingyou];
    }else {
        [SOSDaapManager sendActionInfo:Pickup_send_Wechat];
    }
    [SOSSocialService createOrderSuccess:^(SOSSocialOrderShareInfoResp * _Nonnull urlRequest) {
        self.orderShareInfo = urlRequest;
        if (index == 0) {
            [self sendToIM];
        }else if (index == 1) {
            [self sendToWechat];
        }
    } Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        [Util showErrorHUDWithStatus:[Util visibleErrorMessage:responseStr]];
        id errorr = [responseStr toBasicObject];
        if ([errorr isKindOfClass:[NSDictionary class]]) {
            if ([errorr[@"code"] isEqualToString:@"PICK1004"]) {
                SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
                [self.navigationController pushViewController:vc wantToPopRootAnimated:YES];
            }
        }
    }];
}

- (void)sendToIM {
#ifndef SOSSDK_SDK
    //星友圈
    SOSShareAttachment *att = [SOSShareAttachment new];
    att.requestUrl = self.orderShareInfo.onstarMomentShareUrl;
    att.token = self.orderShareInfo.pickupToken;
    SOSIMMediaMessage *imMsg = [SOSIMMediaMessage message];
    imMsg.mediaObject = att;
    
    SendMessageToSOSIMReq *imReq = [[SendMessageToSOSIMReq alloc] init];
    imReq.messageType = SOSIMMessageTypeSocial;
    imReq.message = imMsg;
    imReq.fromNav = self.navigationController;
    imReq.cancelFuncId = Pickup_send_Xingyou_cancel;
    imReq.confirmFuncId = Pickup_send_Xingyou_send;
    [SOSIMApi sendReq:imReq];
#endif
}

- (void)sendToWechat {
    //微信
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    messageInfo.messageTitle = @"确认函：您的好友前来接驾";
    messageInfo.messageDescription = @"您的好友发来一个接驾邀请，快来和好友共享位置，该链接有效期为24小时，过期作废。";
    messageInfo.messageWebpageUrl = self.orderShareInfo.wechatShareUrl;
    
    messageInfo.messageThumbImage = [UIImage imageNamed:@"pic_IMG_60x60"];
    
    [[NavigateShareTool sharedInstance] shareToWeixinSceneWeiXinMessageInfo:0 messageInfo:messageInfo];
}



@end
