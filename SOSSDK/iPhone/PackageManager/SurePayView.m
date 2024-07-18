//
//  SurePayView.m
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SurePayView.h"

@implementation SurePayView
- (void)awakeFromNib
{
    [super awakeFromNib];
    [_sureBtn setBackgroundColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    _sureBtn.enabled = NO;
}
- (IBAction)backAct:(id)sender {
    self.hidden = YES;
    if (self.surePayDelegate && [self.surePayDelegate respondsToSelector:@selector(backFromSurePayVC)]) {
        [self.surePayDelegate backFromSurePayVC];
    }
}
- (IBAction)surePayAct:(id)sender {
    if (self.surePayDelegate && [self.surePayDelegate respondsToSelector:@selector(surePay)]) {
        [self.surePayDelegate surePay];
    }
}
- (IBAction)selectPayWayAct:(id)sender {
    if (self.surePayDelegate && [self.surePayDelegate respondsToSelector:@selector(selectPayWay_surePayDelegate)]) {
        [self.surePayDelegate selectPayWay_surePayDelegate];
    }
}

- (IBAction)canPayButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    _sureBtn.enabled = sender.selected;
//    if (self.surePayDelegate && [self.surePayDelegate respondsToSelector:@selector(canPay:)]) {
//        [self.surePayDelegate canPay:sender.selected];
//    }
}

- (void)loadingChannelState
{
    _loadingActivity.hidden = NO;
    [_loadingActivity startAnimating];
    _payWayLB.hidden = YES;
    _selectChannelArrow.hidden = YES;
    
    _sureBtn.userInteractionEnabled = NO;
    _sureBtn.enabled = NO;
}
- (void)channelLoadAlreadyState
{
    [_loadingActivity stopAnimating];
    _loadingActivity.hidden = YES;
    _payWayLB.hidden = NO;
//    _selectChannelArrow.hidden = NO;
    _selectChannelArrow.hidden = YES;
    _sureBtn.userInteractionEnabled = YES;
//    _sureBtn.enabled = YES;
}
- (void)unavailableChannelState
{
    [_loadingActivity stopAnimating];
    _loadingActivity.hidden = YES;
    _payWayLB.hidden = NO;
    _selectChannelArrow.hidden = YES;
    _sureBtn.userInteractionEnabled = NO;
    _sureBtn.enabled = NO;
}

@end
