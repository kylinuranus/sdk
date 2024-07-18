//
//  SOSMeDonateCell.m
//  Onstar
//
//  Created by Onstar on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSMeDonateCell.h"
#import "SOSMeDonateView.h"
#import "SOSDonateDataTool.h"

@interface SOSMeDonateCell ()
@property (nonatomic, strong) SOSMeDonateView *meDonateView;
@end
@implementation SOSMeDonateCell

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
    
    [self.containerView addSubview:self.meDonateView];
    [self.meDonateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (SOSMeDonateView *)meDonateView {
    if (!_meDonateView) {
        _meDonateView = [[SOSMeDonateView alloc] initWithFrame:CGRectZero];
        
    }
    return _meDonateView;
}

- (void)refreshWithResp:(id)response {
    [super refreshWithResp:response];

//    if (response == nil) {
//        self.status = RemoteControlStatus_OperateSuccess;
//    }
//    if (self.status == RemoteControlStatus_InitSuccess) {
//        //显示读取中
//        self.statusView.status = RemoteControlStatus_InitSuccess;//懒加载创建
//    }
//    if ([response isKindOfClass:[SOSDonateUserInfo class]]) {
//        self.status = RemoteControlStatus_OperateSuccess;
////        //显示头部信息
////        if ([SOSCheckRoleUtil isVisitor]) {
////            self.containerView.infoLb.text = @"请先升级为车主";
////            self.containerView.infoLb.hidden = NO;
////        }else {
////            NNStarTravelResp *resp = response;
////            id currentStageInfo = resp.currentStageInfo;
////            self.containerView.infoLb.text = [NSString stringWithFormat:@"第%@天", currentStageInfo?resp.serviceDays:@"--"];
////            self.containerView.infoLb.hidden = NO;
////        }
//
//    }

    [self.meDonateView refreshWithResponseData:response status:self.status];
    
}

@end
