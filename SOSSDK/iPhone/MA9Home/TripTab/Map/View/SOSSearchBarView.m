//
//  SOSSearchBarView.m
//  Onstar
//
//  Created by Coir on 2019/4/8.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"
#import "SOSSearchBarView.h"
#import "SOSRemoteTool.h"

@interface SOSSearchBarView ()

@property (weak, nonatomic) IBOutlet UIView *loadingBGView;
@property (weak, nonatomic) IBOutlet UILabel *loadingTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingIconImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *detailModeBGView;
@property (weak, nonatomic) IBOutlet UIView *listModeBGView;

@property (assign, nonatomic) BOOL lock;

@end

@implementation SOSSearchBarView

- (void)awakeFromNib	{
    [super awakeFromNib];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *x) {
        NSDictionary *userInfo = x.userInfo;
        //        @{@"state":@(RemoteControlStatus_InitSuccess), @"OperationType" : @(type) , @"message": message}
        SOSRemoteOperationType operationType = [userInfo[@"OperationType"] intValue];
        if ([SOSRemoteTool isSendPOIOperation:operationType]) {
            RemoteControlStatus state = [userInfo[@"state"] intValue];
            
            [self configLoadingViewWithRemoteControlStatus:state AndType:operationType];
            switch (state) {
                case RemoteControlStatus_OperateTimeout:
                case RemoteControlStatus_OperateFail:
                    [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_KNOW];
                    break;
                default:
                    break;
            }
        }
    }];
}

- (void)configLoadingViewWithRemoteControlStatus:(RemoteControlStatus)status AndType:(SOSRemoteOperationType)type    {
    if (status == RemoteControlStatus_InitSuccess) {
        dispatch_async_on_main_queue(^{
            if (type == SOSRemoteOperationType_SendPOI_TBT) {
                self.loadingTextLabel.text = @"路线正在下发,大概需要1-3分钟";
            }    else if (type == SOSRemoteOperationType_SendPOI_ODD)    {
                self.loadingTextLabel.text = @"目的地正在下发,大概需要1-3分钟";
            }
            [self.loadingIconImgView startRotating];
            self.loadingBGView.hidden = NO;
        });
    }    else    {
        dispatch_async_on_main_queue(^{
            self.loadingBGView.hidden = YES;
            [self.loadingIconImgView endRotating];
        });
    }
}

- (void)setViewMode:(SOSSearchBarViewMode)viewMode	{
    if (self.lock)		return;	
    _viewMode = viewMode;
    SOSTripBaseMapVC *vc = nil;
    if ([self.viewController isKindOfClass:NSClassFromString(@"SOSTripBaseMapVC")]) {
        vc = (SOSTripBaseMapVC *)self.viewController;
    }
    switch (viewMode) {
        case SOSSearchBarViewMode_List:
            self.listModeBGView.hidden = NO;
            self.detailModeBGView.hidden = YES;
            vc.topStatusBarView.hidden = NO;
            break;
        case SOSSearchBarViewMode_Detail:
            self.listModeBGView.hidden = YES;
            self.detailModeBGView.hidden = NO;
            vc.topStatusBarView.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)lockStateChange:(BOOL)lock	{
    self.lock = lock;
}

- (void)setTitle:(NSString *)title	{
    _title = title;
    dispatch_async_on_main_queue(^{
        self.titleLabel.text = title;
        self.centerTitleLabel.text = title;
    });
}

- (IBAction)searchButtonTapped {
    
    [self.viewController.navigationController popViewControllerAnimated:YES];
}


@end
