//
//  SOSAlertRemindSet.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSAlertRemindSet.h"

@implementation SOSAlertRemindSet
 
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication].windows lastObject].bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
        _maskView.alpha = 0.f;
        }
    return _maskView;
}



- (void)showShareReportView {
    UIWindow *keyWindow = [[UIApplication sharedApplication].windows lastObject];
    [keyWindow addSubview:self.maskView];
    [keyWindow addSubview:self];
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 1.f;
        self.alpha = 1.f;
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        
    }];
}
- (IBAction)dismiss:(id)sender {
    [self dismissShareReportView];
}

#pragma mark - dismissAlertView
- (void)dismissShareReportView {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.f;
        self.maskView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            [self.maskView removeFromSuperview];
        }
    }];
}


@end
