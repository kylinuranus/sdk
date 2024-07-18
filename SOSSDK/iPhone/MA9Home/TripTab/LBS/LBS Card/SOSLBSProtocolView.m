//
//  SOSLBSProtocolView.m
//  Onstar
//
//  Created by Coir on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSProtocolView.h"
#import "SOSAgreement.h"
#import "SOSLBSHeader.h"

typedef void(^completeBlock)(BOOL);

@interface SOSLBSProtocolView ()


@property (weak, nonatomic) IBOutlet UIButton *disAgreeButton;
@property (weak, nonatomic) IBOutlet UIView *protocolBGView;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@property (copy, nonatomic) completeBlock finishBlock;
@property (nonatomic, strong) WKWebView *protocolWebView;
@end

@implementation SOSLBSProtocolView


-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.protocolBGView addSubview:self.protocolWebView];
    [self.protocolWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.protocolBGView).offset(64);
        make.left.right.equalTo(self.protocolBGView);
        make.bottom.equalTo(self.agreeButton.mas_top).offset(-10);
    }];
}


- (void)setCompleteHanlder:(void (^)(BOOL))completion	{
    self.finishBlock = completion;
}

- (void)show:(BOOL)show     {
    if (self.hidden != show)   return;
    if (show) {
        [Util showHUD];
        [SOSAgreement requestAgreementsWithTypes:@[agreementName(ONSTAR_LOCATION_TC)] success:^(NSDictionary *response) {
            [Util dismissHUD];
            NSDictionary *dic = response[agreementName(ONSTAR_LOCATION_TC)];
            SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
            [self.protocolWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:agreement.url]]];
            [SOS_ONSTAR_WINDOW addSubview:self];
            self.hidden = NO;
            self.alpha = .4;
            [UIView animateWithDuration:.3 animations:^{
                self.alpha = 1;
            }];
            
        } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util dismissHUD];
            [Util toastWithMessage:@"获取协议内容失败"];
        }];
    }   else    {
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = .4;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [self removeFromSuperview];
        }];
    }
}

- (IBAction)agreeProtocolButtonTapped:(UIButton *)sender {
    // 保存本地状态
    NSString * agreeKey;
    if([CustomerInfo sharedInstance].userBasicInfo.idpUserId != nil){
        agreeKey = [[NSString stringWithFormat:KSOSLBSProtocolKey] stringByAppendingString:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    }
    UserDefaults_Set_Object(@((sender == _agreeButton)), agreeKey);
    if (self.finishBlock)    self.finishBlock((sender == _agreeButton));
    [self show:NO];
    
    if (sender == _agreeButton) {
        //用户点击 同意 ,同步网络状态,
        [Util showHUD];
        [SOSLBSDataTool setLBSProtocolStatusSuccess:^(SOSNetworkOperation *operation, id responseStr) {
            [Util dismissHUD];
        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util dismissHUD];
        }];
    }   else if (sender == _disAgreeButton)    {
    }
}


-(WKWebView *)protocolWebView{
    if(!_protocolWebView){
        _protocolWebView = [[WKWebView alloc] init];
    }
    return _protocolWebView;
}

@end
