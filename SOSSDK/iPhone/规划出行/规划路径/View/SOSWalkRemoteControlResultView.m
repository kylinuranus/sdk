//
//  SOSWalkRemoteControlResultView.m
//  Onstar
//
//  Created by Coir on 2018/8/30.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSWalkRemoteControlResultView.h"


@interface SOSWalkRemoteControlResultView ()

@property (weak, nonatomic) IBOutlet UIImageView *resultImgView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;


@end

@implementation SOSWalkRemoteControlResultView

- (void)showWithResultMode:(SOSWalkRemoteResultType)mode	{
    NSString *resultStr = @"";
    if (mode == SOSWalkRemoteResultType_Loading) {
        self.resultImgView.hidden = YES;
        self.loadingActivityView.hidden = NO;
        [self.loadingActivityView startAnimating];
        resultStr = @"控车指令正在下发...";
    }    else    {
        /// todo, 和安卓保持一致,使用通用Toast
        /*
        self.resultImgView.hidden = NO;
        self.loadingActivityView.hidden = YES;
        if (self.loadingActivityView.isAnimating)     [self.loadingActivityView stopAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
        switch (mode) {
            case SOSWalkRemoteResultType_Loading:
                break;
            case SOSWalkRemoteResultType_LockDoor_Success:
                self.resultImgView.highlighted = NO;
                resultStr = @"指令下发成功,车门已开";
                break;
            case SOSWalkRemoteResultType_LockDoor_Fail:
                self.resultImgView.highlighted = YES;
                resultStr = @"车门解锁指令下发失败";
                break;
            case SOSWalkRemoteResultType_Light_Success:
                self.resultImgView.highlighted = NO;
                resultStr = @"指令下发成功,已为您闪灯";
                break;
            case SOSWalkRemoteResultType_Light_Fail:
                self.resultImgView.highlighted = YES;
                resultStr = @"闪灯指令下发失败";
                break;
            case SOSWalkRemoteResultType_Horn_Success:
                self.resultImgView.highlighted = NO;
                resultStr = @"指令下发成功,已为您闪灯";
                break;
            case SOSWalkRemoteResultType_Horn_Fail:
                self.resultImgView.highlighted = YES;
                resultStr = @"鸣笛指令下发失败";
                break;
            case SOSWalkRemoteResultType_LightAndHorn_Success:
                self.resultImgView.highlighted = NO;
                resultStr = @"指令下发成功,已为您闪灯鸣笛";
                break;
            case SOSWalkRemoteResultType_LightAndHorn_Fail:
                self.resultImgView.highlighted = YES;
                resultStr = @"闪灯鸣笛指令下发失败";
                break;
            default:
                break;
        }
         */
    }
    self.infoLabel.text = resultStr;
}

@end
