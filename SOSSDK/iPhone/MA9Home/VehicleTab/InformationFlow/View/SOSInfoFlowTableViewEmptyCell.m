//
//  SOSInfoFlowTableViewEmptyCell.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowTableViewEmptyCell.h"
#import "SOSOverallScanController.h"

@interface SOSInfoFlowTableViewEmptyCell ()
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UILabel *loginLabel;

@end

@implementation SOSInfoFlowTableViewEmptyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        UIImageView *imageView = [UIImageView new];
        //修改，背景移到tableView background了
//        imageView.image = [UIImage imageNamed:@"Bg_car_bg_user_def_375x116"];
        [self.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self.contentView);
//            make.height.equalTo(@(SCREEN_WIDTH / 375 * 225));
            make.height.equalTo(@120);
        }];
        
        @weakify(self);
        [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shouldShowLoginView:state.integerValue == LOGIN_STATE_NON];
            });
        }];

    }
    return self;
}

- (void)shouldShowLoginView:(BOOL)show {
    if (show) {
        //property懒加载
        self.loginButton.hidden = NO;
        self.loginLabel.hidden = NO;
    }else {
        //直接调用实例变量防止无意义的生成实例
        _loginButton.hidden = YES;
        _loginLabel.hidden = YES;
    }
}

- (void)loginButnClicked:(id)sender {
    [SOSDaapManager sendActionInfo:VEHICLE_INFORFLOW_LOGIN_];
    [SOSUtil presentLoginFromViewController:((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]).topViewController toViewController:nil];
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_loginButton setTitle:@"登录安吉星" forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 2;
        _loginButton.layer.borderColor = [UIColor colorWithHexString:@"#6896ED"].CGColor;
        _loginButton.layer.borderWidth = 1;
        [_loginButton setTitleColor:[UIColor colorWithHexString:@"#6896ED"] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_loginButton addTarget:self action:@selector(loginButnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_loginButton];
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(@29);
            make.width.equalTo(@112);
        }];

    }
    return _loginButton;
}

- (UILabel *)loginLabel {
    if (!_loginLabel) {
        _loginLabel = [UILabel new];
        _loginLabel.font = [UIFont systemFontOfSize:12];
        _loginLabel.textColor = [UIColor colorWithHexString:@"#828389"];
        _loginLabel.attributedText = [[NSAttributedString alloc] initWithString:@"立即开启智慧生活" attributes:@{NSKernAttributeName: @2}];
        [self.contentView addSubview:_loginLabel];
        [_loginLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(_loginButton.mas_bottom).offset(8);
        }];
    }
    return _loginLabel;
}

@end
