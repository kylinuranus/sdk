//
//  SOSStarTravelCell.m
//  Onstar
//
//  Created by lmd on 2017/9/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSStarTravelCell.h"
#import "SOSStarTravelView.h"

@interface SOSStarTravelCell ()
@property (nonatomic, strong) SOSStarTravelView *starTravelView;
@end

@implementation SOSStarTravelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpView {
//    self.containerView.titleLb.text = @"星享之旅";
//    self.containerView.shadowView.image = [UIImage imageNamed:@"tile_shadow_purple"];
    [self.containerView addSubview:self.starTravelView];
     self.starTravelView.layer.cornerRadius = 4;
    [self.starTravelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (SOSStarTravelView *)starTravelView {
    if (!_starTravelView) {
        _starTravelView = [SOSStarTravelView viewFromXib];
    }
    return _starTravelView;
}

- (void)refreshWithResp:(id)response {
    [super refreshWithResp:response];
//    [self showErrorStatusView];

//    if (response == nil) {
//        self.status = RemoteControlStatus_OperateSuccess;
//    }
//
//    if (self.status == RemoteControlStatus_InitSuccess) {
//        //显示读取中
//        self.statusView.status = RemoteControlStatus_InitSuccess;//懒加载创建
//        self.statusView.hidden = NO;
//    }
    
//    if ([response isKindOfClass:[NNStarTravelResp class]]) {
//        //显示头部信息
//            NNStarTravelResp *resp = response;
//            id currentStageInfo = resp.currentStageInfo;
//            self.containerView.infoLb.text = [NSString stringWithFormat:@"第%@天", currentStageInfo?resp.serviceDays:@"--"];
//            self.containerView.infoLb.hidden = NO;
//
//    }else {
//        //判断角色显示 注册登录 or 升级车主
//        if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
//            //未登录
//            self.containerView.infoLb.text = @"登录/注册";
//            self.containerView.infoLb.hidden = NO;
//        }else if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGTOKEN) {
//            self.containerView.infoLb.hidden = YES;
//        }
//        response = nil;
//    }
    
    [self.starTravelView refreshWithResponseData:response status:self.status];
    
}

//- (UIImage *)statusImage {
//    return self.starTravelView.bgImageView.image;
//}

@end
