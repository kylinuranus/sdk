//
//  SOSCardBaseCell.m
//  Onstar
//
//  Created by lmd on 2017/9/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCardBaseCell.h"

@interface SOSCardBaseCell ()
@end
@implementation SOSCardBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpView];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setUpView {

}

- (SOSCardContainerView *)containerView {
    if (!_containerView ) {
        _containerView = [[SOSCardContainerView alloc] init];
        _containerView.layer.cornerRadius = 4;
        _containerView.layer.shadowColor = [UIColor colorWithRed:101/255.0 green:112/255.0 blue:181/255.0 alpha:0.2].CGColor;
        _containerView.layer.shadowOffset = CGSizeMake(0,3);
        _containerView.layer.shadowOpacity = 1;
        _containerView.layer.shadowRadius = 8;
        _containerView.backgroundColor = [UIColor whiteColor];
//        _containerView.clipsToBounds = YES;
        [self.contentView addSubview:_containerView];
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.contentView).mas_offset(12.0f);
            make.right.mas_equalTo(self.contentView).mas_offset(-12.0f);
            make.bottom.mas_equalTo(self.contentView);
        }];
        
    }
    return _containerView;
}

- (void)refreshWithResp:(id)response {
    self.status = [self cellStatusWithRespose:response];
}

- (void)showErrorStatusView {
    [self showErrorStatusView:NO];
}

- (void)showErrorStatusView :(BOOL)blueButton {
    if (self.status == RemoteControlStatus_OperateFail) {
        //showErrorView
        self.statusView.status = self.status;
    }else {
        if (_statusView) {
            _statusView.status = self.status;
        }
    }
    if (blueButton) {
        [_statusView showBlueRetryButton];
    }
}

- (void)showErrorStatusView :(BOOL)blueButton statusLabelColor:(UIColor *)color {
    if (self.status == RemoteControlStatus_OperateFail) {
        //showErrorView
        self.statusView.status = self.status;
    }else {
        if (_statusView) {
            _statusView.status = self.status;
        }
    }
    if (blueButton) {
        [_statusView showBlueRetryButtonStatusLabelTextColor:color];
    }
}


#pragma mark setter
- (void)setStatus:(RemoteControlStatus)status {
    _status = status;
    [self configCellWithChangeStatus:status];
}

- (SOSCellStatusView *)statusView {
    if (!_statusView) {
        _statusView = [[NSBundle SOSBundle] loadNibNamed:@"SOSCellStatusView" owner:nil options:nil].firstObject;
        if ([self statusImage]) {
            _statusView.imgView.backgroundColor = [UIColor whiteColor];
            _statusView.imgView.image = [self statusImage];
        }else {
            _statusView.imgView.backgroundColor = [UIColor clearColor];
        }
        [self.containerView.configCellView addSubview:_statusView];
        [_statusView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.containerView.configCellView);
        }];
    }
    
    _statusView.retryClickBlock = self.retryClickBlock;
    return _statusView;
}

- (UIImage *)statusImage {
    return nil;
}

- (RemoteControlStatus)cellStatusWithRespose:(id)response {
    
    RemoteControlStatus status;
    if (response == nil) {
        //读取中
        status = RemoteControlStatus_Void;
    }else if ([response isKindOfClass:[NSNumber class]]) {
        if ([response boolValue] == YES) {
            //读取中
            status = RemoteControlStatus_InitSuccess;
        }else {
            //加载失败
            status = RemoteControlStatus_OperateFail;
        }
    }else if (response) {
        status = RemoteControlStatus_OperateSuccess;
    }else {
        //加载失败
        status = RemoteControlStatus_OperateFail;
    }
    return status;
}

- (void)configCellWithChangeStatus:(RemoteControlStatus)status
{
    switch (status) {
        case RemoteControlStatus_InitSuccess:
        {
            dispatch_async_on_main_queue(^{
//                self.containerView.transformView.image = [UIImage imageNamed:@"transformrotation"];
//                [SOSUtilConfig transformRotationWithView:self.containerView.transformView];
            });
        }
            break;
        case RemoteControlStatus_OperateSuccess:
        {
            dispatch_async_on_main_queue(^{
//                [SOSUtilConfig transformIdentityStatusWithView:self.containerView.transformView];
//                self.containerView.transformView.image = [UIImage imageNamed:@"icon_arrow_right_passion_blue_idle"];
//                [self.containerView.transformView.layer removeAllAnimations];
            });
        }
            break;
        case RemoteControlStatus_OperateFail:
        {
            dispatch_async_on_main_queue(^{
//                [SOSUtilConfig transformIdentityStatusWithView:self.containerView.transformView];
//                self.containerView.transformView.image = [UIImage imageNamed:@"icon_alert_red_idle"];
//                [self.containerView.transformView.layer removeAllAnimations];
            });
        }
            break;
        default:
            break;
    }
}

@end
