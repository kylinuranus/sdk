//
//  SOSBleReconnectStatusView.m
//  Onstar
//
//  Created by onstar on 2018/8/6.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleReconnectStatusView.h"
#import "UIView+FDCollapsibleConstraints.h"

@interface SOSBleReconnectStatusView ()
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation SOSBleReconnectStatusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setStatus:(RemoteControlStatus)status {
    _status = status;
    
    if (status == RemoteControlStatus_OperateFail) {
        self.statusImageView.image = [UIImage imageNamed:@"red_idle"];
        self.statusLabel.text = @"连接失败";
        self.retryButton.fd_collapsed = NO;
        [self stopRotationWithView:self.statusImageView];
        
    }else if (status == RemoteControlStatus_InitSuccess) {
        self.statusImageView.image = [UIImage imageNamed:@"LoadingAndroid"];
        self.statusLabel.text = @"正在恢复连接";
        self.retryButton.fd_collapsed = YES;
        [self startRotationWithView:self.statusImageView];
    }
    
}
- (IBAction)retryTap:(id)sender {
    !self.retryBlock?:self.retryBlock(self);
}

- (void)startRotationWithView:(UIView *)view {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INT_MAX;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopRotationWithView:(UIView *)view {
    [view.layer removeAnimationForKey:@"rotationAnimation"];
}

@end
