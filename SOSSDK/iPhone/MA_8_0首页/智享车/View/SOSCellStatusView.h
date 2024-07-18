//
//  SOSCellStatusView.h
//  Onstar
//
//  Created by lmd on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseXibView.h"

@interface SOSCellStatusView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelCenterY;

@property (nonatomic, assign) RemoteControlStatus status;
@property (nonatomic, copy) void(^retryClickBlock)(void);

- (void)showBlueRetryButton;
- (void)showBlueRetryButtonStatusLabelTextColor:(UIColor *)color ;

@end
