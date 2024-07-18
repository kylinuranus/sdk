//
//  SOSVehicleServicesView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleServicesView.h"

@implementation SOSVehicleServicesView

/**
 因为xib中UI拉的太傻X...导致写这么智障的代码..
 */
- (void)switchToEVStyle {
    
    _imageView0.image = [UIImage imageNamed:@"icon_car_ECS"];
    _imageView1.image = [UIImage imageNamed:@"icon_car_ABS"];
    _imageView2.image = [UIImage imageNamed:@"icon_car_onstar_service2"];
    _imageView3.image = [UIImage imageNamed:@"icon_car_airbag"];
    _imageView4.hidden = YES;
    _imageView5.hidden = YES;
    
    _label0.text = @"车身稳定\n控制系统";
    _label1.text = @"制动\n防抱死系统";
    _label2.text = @"安吉星系统";
    _label3.text = @"安全\n气囊系统";
    _label4.hidden = YES;
    _label5.hidden = YES;
    
    _absImgView.hidden = YES;
    _onStarImgView.hidden = YES;
    
    _evCarStyle = YES;
}

- (void)configViewForDectViewWith:(NNOVDEmailDTO *)ovdEmail {
    if (_evCarStyle) {
        NNOvdStatusInfo *statusInfo = ovdEmail.ovdEmailDTO.ovdStatusInfo;
        [self showImageView:_engineImgView status:statusInfo.stabiliTrak.status];
        [self showImageView:_drainageImgView status:statusInfo.abs.status];
        [self showImageView:_airBagImgView status:statusInfo.onStar.status];
        [self showImageView:_stabiliTrakImgView status:statusInfo.airBag.status];
        return;
    }
    [self showImageView:_engineImgView status:ovdEmail.ovdEmailDTO.ovdStatusInfo.engineTransmission.status];
    [self showImageView:_drainageImgView status:ovdEmail.ovdEmailDTO.ovdStatusInfo.drainage.status];
    [self showImageView:_airBagImgView status:ovdEmail.ovdEmailDTO.ovdStatusInfo.airBag.status];
    [self showImageView:_stabiliTrakImgView status:ovdEmail.ovdEmailDTO.ovdStatusInfo.stabiliTrak.status];
    [self showImageView:_absImgView status:ovdEmail.ovdEmailDTO.ovdStatusInfo.abs.status];
    [self showImageView:_onStarImgView status:ovdEmail.ovdEmailDTO.ovdStatusInfo.onStar.status];
}

- (void)showImageView:(UIImageView *)imgView status:(NSNumber *)status {
    if (0 == status.intValue) {
        imgView.image = [UIImage imageNamed:@"icon_alert_green_idle"];
    }else {
        imgView.image = [UIImage imageNamed:@"icon_alert_red_idle"];
    }
}




@end
