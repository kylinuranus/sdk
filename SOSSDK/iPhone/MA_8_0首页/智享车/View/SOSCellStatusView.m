//
//  SOSCellStatusView.m
//  Onstar
//
//  Created by lmd on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCellStatusView.h"

@interface SOSCellStatusView ()

@end

@implementation SOSCellStatusView

- (void)setStatus:(RemoteControlStatus)status {
    switch (status) {
        case RemoteControlStatus_InitSuccess:
        {
            self.refreshButton.hidden = YES;
            self.statusLabelCenterY.constant = 0;
            self.statusLabel.text = @"读取中...";
            self.hidden = YES;//外部控制开启
        }
            break;
        case RemoteControlStatus_OperateSuccess:
        {
            self.hidden = YES;
        }
            break;
        case RemoteControlStatus_OperateFail:
        {
            self.hidden = NO;
            self.refreshButton.hidden = NO;
            self.statusLabel.text = @"读取失败";
            self.statusLabelCenterY.constant = -10;
        }
            break;
        default:
            break;
    }
}
- (IBAction)retryRequest:(id)sender {
    if (self.retryClickBlock) {
        self.retryClickBlock();
    }
}
- (void)showBlueRetryButton {
    [self.refreshButton setTitleColor:UIColorHex(0x107FE0) forState:UIControlStateNormal];
    self.refreshButton.layer.borderColor = UIColorHex(0x107FE0).CGColor;
    self.statusLabel.text = @"";
    self.statusLabelCenterY.constant = -20;
}

- (void)showBlueRetryButtonStatusLabelTextColor:(UIColor *)color {
    [self showBlueRetryButton];
    if (color) {
        self.statusLabel.text = @"读取失败";
        self.statusLabel.textColor = color;
    }
    
   
}


@end
