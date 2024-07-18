//
//  SOSSocialWaitingViewController.m
//  Onstar
//
//  Created by onstar on 2019/4/21.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialWaitingViewController.h"
#import "SOSFlexibleAlertController.h"
#import "WeiXinMessageInfo.h"
#import "NavigateShareTool.h"
#import "SOSSocialContactShareView.h"
#import "SOSSocialContactViewController.h"
#import "SOSSocialService.h"
#ifndef SOSSDK_SDK
#import "SOSShareAttachment.h"
#import "SOSIMApi.h"
#endif
@interface SOSSocialWaitingViewController ()
@property (nonatomic, strong) SOSSocialOrderShareInfoResp *orderShareInfo;

@end

@implementation SOSSocialWaitingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我来接";
    [[SOSSocialService shareInstance] startObserverAcceptStatus];
}
- (IBAction)resendButtonTaped:(UIButton *)sender {
    [SOSDaapManager sendActionInfo:Pickup_INIT_resend];
    [self showShare];
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


- (IBAction)endButtonTaped:(UIButton *)sender {
    [SOSDaapManager sendActionInfo:Pickup_INIT_end];
    [Util showAlertWithTitle:@"是否终止本次接送" message:@"终止接送后，已发出的确认函将失效" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //终止
            [self finishJourney];
        }
    } cancleButtonTitle:@"取消" otherButtonTitles:@"终止", nil];
}

- (void)finishJourney {
    [Util showHUD];
    [SOSSocialService changeStatusWithParams:@{@"statusName":@"CANCEL"} success:^{
        [Util dismissHUD];
        SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:NO];
        [[SOSSocialService shareInstance] endUploadLocationService];
    } Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        [Util showErrorHUDWithStatus:[Util visibleErrorMessage:responseStr]];
        id errorr = [responseStr toBasicObject];
        if ([errorr isKindOfClass:[NSDictionary class]]) {
            
            if ([errorr[@"code"] isEqualToString:@"PICK1001"]||
                [errorr[@"code"] isEqualToString:@"PICK1002"]||
                [errorr[@"code"] isEqualToString:@"PICK1003"]) {
                SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
                [self.navigationController pushViewController:vc wantToPopRootAnimated:YES];
            }
        }
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
